import QtQuick 2.0
import Felgo 3.0

Item {

    id: gameArea

    width: blockSize * 8
    height: blockSize * 12

    property double blockSize
    property int rows: Math.floor(height / blockSize)
    property int columns: Math.floor(width / blockSize)

    property var field: []

    signal gameOver()

    function index(row, column) {
        return row * columns + column
    }

    function initializeField() {
        clearField()

        for (var i = 0; i < rows; i++) {
            for (var j = 0; j < columns; j++) {
                gameArea.field[index(i, j)] = createBlock(i, j)
            }
        }
    }

    function clearField() {
      // remove entities
      for(var i = 0; i < gameArea.field.length; i++) {
        var block = gameArea.field[i]
        if(block !== null)  {
          entityManager.removeEntityById(block.entityId)
        }
      }
      gameArea.field = []
    }

    function createBlock(row, column) {
      // configure block
      var entityProperties = {
        width: blockSize,
        height: blockSize,
        x: column * blockSize,
        y: row * blockSize,

        type: Math.floor(Math.random() * 5), // random type
        row: row,
        column: column
      }

      // add block to game area
      var id = entityManager.createEntityFromUrlWithProperties(
            Qt.resolvedUrl("Block.qml"), entityProperties)

      // link click signal from block to handler function
      var entity = entityManager.getEntityById(id)
      entity.clicked.connect(handleClick)

      return entity
    }

    // handle user clicks
    function handleClick(row, column, type) {
        // copy current field, allows us to change the array without modifying the real game field
        // this simplifies the algorithms to search for connected blocks and their removal
        var fieldCopy = field.slice()

        // count and delete connected blocks
        var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, column, type)
        if(blockCount >= 3) {
          removeConnectedBlocks(fieldCopy)
        }
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
           entityManager.removeEntityById(block.entityId)
         }
       }
     }
   }
}
