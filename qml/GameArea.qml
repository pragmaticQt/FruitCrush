import QtQuick 2.0
import Felgo 3.0
import "./game"

Item {

    id: gameArea

    width: blockSize * 8
    height: blockSize * 12

    property double blockSize
    property int rows: Math.floor(height / blockSize)
    property int columns: Math.floor(width / blockSize)
    readonly property int matches: 3 // least connected blocks to remove

    property var field: [] //holds blocks or entities
    // The syntax for defining a new signal is:
    //    signal <name>[([<type> <parameter name>[, ...]])]
    signal gameOver()

    GameSound {
        id: gameSound
    }

    // turn (row, column) to index in array field
    function index(row, column) {
        return row * columns + column
    }

    // create rows X columns blocks and let filed[i] ref to them (i=0,1, ... , rows X columns-1)
    //NOTE: all created blocks owned by entiryManger
    function initializeField() {
        clearField()

        for (var i = 0; i < rows; i++) {
            for (var j = 0; j < columns; j++) {
                gameArea.field[index(i, j)] = createBlock(i, j)
            }
        }
    }

    // empty field and remove all entities owned by entiryManger
    function clearField() {

        for(var i = 0; i < gameArea.field.length; i++) {
            var block = gameArea.field[i]
            if(block !== null)  {
                entityManager.removeEntityById(block.entityId)
            }
        }
        gameArea.field = []
    }

    // create a new block and let entityManager own it
    // return ref to the new block
    function createBlock(row, column) {
        // configure block
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,

            type: Math.floor(Math.random() * Block.FruitType.Total), // random type
            row: row,
            column: column
        }

        // add block to game area
        var id = entityManager.createEntityFromUrlWithProperties(
                    Qt.resolvedUrl("Block.qml"), entityProperties)

        // link click signal from block to handler function
        var entity = entityManager.getEntityById(id)
        entity.clicked.connect(handleClick)
        entity.fadedout.connect(handleFadeout)

        return entity
    }

    // check if game is over
    function isGameOver() {
      var gameOver = true

      // copy field to search for connected blocks without modifying the actual field
      var fieldCopy = field.slice()

      // search for connected blocks in field
      for(var row = 0; row < rows; row++) {
        for(var col = 0; col < columns; col++) {

          // test all blocks
          var block = fieldCopy[index(row, col)]
          if(block !== null) {
            var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, col, block.type)

            if(blockCount >= matches) {
              gameOver = false
              break
            }
          }

        }
      }

      return gameOver
    }

    // returns true if all animations are finished and new blocks may be removed
    function isFieldReadyForNewBlockRemoval() {
      // check if top row has empty spots or blocks not fully within game area
      for(var col = 0; col < columns; col++) {
        var block = field[index(0, col)]
        if(block === null || block.y < 0)
          return false
      }

      // field is ready
      return true
    }

    // handle user clicks
    function handleClick(row, column, type) {

        if(!isFieldReadyForNewBlockRemoval())
          return

        gameSound.playMoveBlock()

        // copy current field, allows us to change the array without modifying the real game field
        // this simplifies the algorithms to search for connected blocks and their removal
        var fieldCopy = field.slice()

        // count and delete connected blocks
        var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, column, type)
        if(blockCount >= matches) {
            removeConnectedBlocks(fieldCopy)
            moveBlocksToBottom()

            // emit signal if game is over
            if(isGameOver())
              gameOver()

            // calculate and increase score
            // this will increase the added score for each block, e.g. four blocks will be 1+2+3+4 = 10 points
            var score = blockCount * (blockCount + 1) / 2
            gameScene.score += score
        }
    }

    function handleFadeout(entityId) {
        entityManager.removeEntityById(entityId)
    }

    // move remaining blocks to the bottom and fill up columns with new blocks
    function moveBlocksToBottom() {
        // check all columns for empty fields
        for(var col = 0; col < columns; col++) {
            // start at the bottom of the field
            for(var row = rows - 1; row >= 0; row--) {
                // find empty spot in grid
                if(gameArea.field[index(row, col)] === null) {

                    // find block to move down
                    var moveBlock = null

                    for(var moveRow = row - 1; moveRow >= 0; moveRow--) {
                        moveBlock = gameArea.field[index(moveRow,col)]

                        if(moveBlock !== null) {
                            gameArea.field[index(moveRow,col)] = null
                            gameArea.field[index(row, col)] = moveBlock
                            moveBlock.row = row
                            moveBlock.fallDown(row - moveRow)
                            break
                        }
                    }

                    // if no block found, fill whole column up with new blocks
                    if(moveBlock === null) {
                        var distance = row + 1
                        for(var newRow = row; newRow >= 0; newRow--) {
                            var newBlock = createBlock(newRow - distance, col)
                            gameArea.field[index(newRow, col)] = newBlock
                            newBlock.row = newRow
                            newBlock.fallDown(distance)
                        }

                        // column already filled up, no need to check higher rows again
                        break
                    }
                }

            } // end check rows starting from the bottom
        } // end check columns for empty fields
    }

    // recursively check a block and its neighbors
    // returns number of connected blocks
    function getNumberOfConnectedBlocks(fieldCopy, row, column, type) {
        // stop recursion if out of bounds
        if(row >= rows || column >= columns || row < 0 || column < 0)
            return 0

        // get block
        var block = fieldCopy[index(row, column)]

        // stop if block was already checked or block has different type
        if(block === null || block.type !== type)
            return 0

        // block has the required type and was not checked before
        var count = 1

        // remove block from field copy so we can't check it again
        // also after we finished searching, every correct block we found will leave a null value at its
        // position in the field copy, which we then use to remove the blocks in the real field array
        fieldCopy[index(row, column)] = null

        // check all neighbors of current block and accumulate number of connected blocks
        // at this point the function calls itself with different parameters
        // this principle is called "recursion" in programming
        // each call will result in the function calling itself again until one of the
        // checks above immediately returns 0 (e.g. out of bounds, different block type, ...)
        count += getNumberOfConnectedBlocks(fieldCopy, row + 1, column, type) // add number of blocks to the right
        count += getNumberOfConnectedBlocks(fieldCopy, row, column + 1, type) // add number of blocks below
        count += getNumberOfConnectedBlocks(fieldCopy, row - 1, column, type) // add number of blocks to the left
        count += getNumberOfConnectedBlocks(fieldCopy, row, column - 1, type) // add number of bocks above

        // return number of connected blocks
        return count
    }

    // remove previously marked blocks
    function removeConnectedBlocks(fieldCopy) {
        // search for blocks to remove
        for(var i = 0; i < fieldCopy.length; i++) {
            if(fieldCopy[i] === null) {
                // remove block from field
                var block = gameArea.field[i]
                if(block !== null) {
                    gameArea.field[i] = null
                    block.fadeOut()
                }
            }
        }
    }
}
