import QtQuick 2.0
import Felgo 3.0

Item {
    id: gameArea

    property double blockSize
    property var entityManager

    signal gameOver()
    signal newScore(int score)

    // create random blocks
    //NOTE: all created blocks owned by entiryManger
    function initialize() {
        _.clearField()

        for (var i = 0; i < _.rows; i++) {
            for (var j = 0; j < _.columns; j++) {
                _.field.push(_.createRandomBlock(i, j))
            }
        }
        _.fieldLocked = false
        _.playerMoveInProgress = false
    }

    function handleFadeout(entityId) {
        entityManager.removeEntityById(entityId)
    }

    // handle swaps of two neighbour blocks
    function handleSwap(row, column, targetRow, targetColumn) {
        if(_.fieldLocked || _.gameEnded)
            return

        // swap blocks
        if(targetRow >= 0 && targetRow < _.rows && targetColumn >= 0 && targetColumn < _.columns) {
            _.fieldLocked = true
            gameSound.playMoveBlock()
            _.swapBlocks(row, column, targetRow, targetColumn)
        }
        else {
            gameSound.playMoveBlockBack()
        }
    }

    // swap finished -> check field for possible block removals
    function handleSwapFinished(row, column, swapRow, swapColumn) {
        if(!_.playerMoveInProgress) {
            _.playerMoveInProgress = true

            if(!_.startRemovalOfBlocks(row, column) && !_.startRemovalOfBlocks(swapRow, swapColumn)) {
                // swap is not possible, no blocks can be removed
                gameSound.playMoveBlockBack()
                _.swapBlocks(row, column, swapRow, swapColumn)
            }
            else {
                // increase difficulty every 10 clicks until maxTypes == 5
                //          gameArea.clicks++
                //          if((gameArea.maxTypes < 8) && (gameArea.clicks % 10 == 0))
                //            gameArea.maxTypes++

                _.playerMoveInProgress = false
            }
        }
        else {
            // nothing could be removed and blocks got swapped back
            _.playerMoveInProgress = false
            _.fieldLocked = false
        }
    }

    QtObject {
        id: _

        readonly property int rows: 12
        readonly property int columns: 8
        readonly property int matches: 3 // least connected blocks to remove

        property var field: [] //holds blocks or entities
        property bool fieldLocked
        property bool gameEnded: false
        property bool playerMoveInProgress


        // Meaningful actions

        // empty field and remove all entities owned by entiryManger
        function clearField() {
            fieldLocked = true
            for(var i = 0; i < field.length; i++) {
                var block = field[i]
                if(block !== null)  {
                    entityManager.removeEntityById(block.entityId)
                }
            }
            field = []
        }


        // create a new block and let entityManager own it
        function createRandomBlock(row, column){
            return createBlock(row, column, Math.floor(Math.random() * Fruits.FruitType.Total))
        }

        // return ref to the new block
        function createBlock(row, column, type) {
            // configure block
            var entityProperties = {
                width: blockSize,
                height: blockSize,
                x: column * blockSize,
                y: row * blockSize,

                type: type, // random type
                row: row,
                column: column
            }

            // add block to game area
            var id = entityManager.createEntityFromUrlWithProperties(
                        Qt.resolvedUrl("GameBlock.qml"), entityProperties)

            // link click signal from block to handler function
            var entity = entityManager.getEntityById(id)
            //entity.swapBlock.disconnect(handleSwap) // remove first as pooled block might already be connected
            entity.swapBlock.connect(handleSwap)
            //entity.fadedout.disconnect(handleFadeout)
            entity.fadedout.connect(handleFadeout)

            return entity
        }


        // fill game area by pushing existing blocks towards bottom and fill blank
        function refill() {
            // left to right
            for(var col = 0; col < columns; col++) {

                var lastNullRow = findLastNull(col, rows - 1)
                if (lastNullRow !== -1) {
                    // try pack existing blocks and leave holes at top
                    var movedRow = findLastNonNull(col, lastNullRow-1)
                    while (movedRow !== -1) {
                        // swap the two
                        let moveBlock = field[index(movedRow,col)]
                        field[index(movedRow,col)] = null
                        field[index(lastNullRow, col)] = moveBlock
                        moveBlock.row = lastNullRow // its new destination
                        // fall down the moved block
                        let distance = lastNullRow - movedRow
                        moveBlock.fallDown(distance)

                        // update for new iteration
                        lastNullRow--
                        movedRow--
                        movedRow = findLastNonNull(col, movedRow)

                    }

                    // fill holes at top
                    var distance = lastNullRow + 1
                    for(var newRow = lastNullRow; newRow >= 0; newRow--) {
                        var newBlock = createRandomBlock(newRow - distance, col)
                        field[index(newRow, col)] = newBlock
                        newBlock.row = newRow
                        newBlock.fallDown(distance)
                    }
                }
            }

            fieldLocked = false
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
                    var block = field[i]
                    if(block !== null) {
                        field[i] = null
                        block.fadeOut()
                    }
                }
            }

        }


        // swaps positions of two blocks on field
        function swapBlocks(row, column, row2, column2) {
            var block = field[index(row, column)]
            var block2 = field[index(row2, column2)]

            // disconnect all handlers
            block.swapFinished.disconnect(handleSwapFinished)
            block2.swapFinished.disconnect(handleSwapFinished)

            // react after second swap animation has finished
            block2.swapFinished.connect(handleSwapFinished)

            block.swap(row2, column2)
            block2.swap(row, column)

            field[index(row, column)] = block2
            field[index(row2, column2)] = block
        }

        // starts removal of blocks at given position
        function startRemovalOfBlocks(row, column) {
            var type = field[index(row, column)].type

            // copy current field, allows us to change the array without modifying the real game field
            // this simplifies the algorithms to search for connected blocks and their removal
            var fieldCopy = field.slice()

            // count and delete horizontally OR vertically connected blocks
            var blockCount = findHorizontallyConnectedBlocks(fieldCopy, row, column, type)
            if(blockCount < 3) {
                fieldCopy = field.slice()
                blockCount = findVerticallyConnectedBlocks(fieldCopy, row, column, type)
            }

            if(blockCount >= 3) {
                removeConnectedBlocks(fieldCopy/*, [blockCount], false*/)
                refill()

                // calculate and increase score
                // this will increase the added score for each block, e.g. four blocks will be 1+2+3+4 = 10 points
                var score = blockCount * (blockCount + 1) / 2
                newScore(score)

                // emit signal if game is over
                if(isGameOver())
                    gameOver()
                return true
            }
            else
                return false
        }

        // Predicts
        function isGameOver() {

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
                            return false
                        }
                    }

                }
            }

            return true
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

        // Helper

        // turn (row, column) to index in array field
        function index(row, column) {
            return row * columns + column
        }

        function findLastNull(col, last) {
            // start at the bottom of the field
            for(var row = last; row >= 0; row--) {
                // find empty spot in grid
                if(field[index(row, col)] === null) {
                    return row
                }
            }
            return -1
        }

        function findLastNonNull(col, last) {
            // start at the bottom of the field
            for(var row = last; row >= 0; row--) {
                // find empty spot in grid
                if(field[index(row, col)] !== null) {
                    return row
                }
            }
            return -1
        }

        // get number of horizontal blocks of same type around row, col
        function findHorizontallyConnectedBlocks(fieldCopy, row, col, type) {
            var nrLeft = 1
            // look left
            while((col - nrLeft >= 0) && (fieldCopy[index(row, col - nrLeft)] !== null) && (fieldCopy[index(row, col - nrLeft)].type === type)) {
                fieldCopy[index(row, col - nrLeft)] = null
                nrLeft++
            }
            // look right
            var nrRight = 1
            while((col + nrRight < columns) && (fieldCopy[index(row, col + nrRight)] !== null) && (fieldCopy[index(row, col + nrRight)].type === type)) {
                fieldCopy[index(row, col + nrRight)] = null
                nrRight++
            }

            fieldCopy[index(row, col)] = null
            return nrLeft + nrRight - 1
        }

        // get number of vertical blocks of same type around row, col
        function findVerticallyConnectedBlocks(fieldCopy, row, col, type) {
            var nrUp = 1
            // look up
            while((row - nrUp >= 0) && (fieldCopy[index(row - nrUp, col)] !== null) && (fieldCopy[index(row - nrUp, col)].type === type)) {
                fieldCopy[index(row - nrUp, col)] = null
                nrUp++
            }
            // look down
            var nrDown = 1
            while((row + nrDown < rows) && (fieldCopy[index(row + nrDown, col)] !== null) && (fieldCopy[index(row + nrDown, col)].type === type)) {
                fieldCopy[index(row + nrDown, col)] = null
                nrDown++
            }

            fieldCopy[index(row, col)] = null
            return nrUp + nrDown - 1
        }

    }

    GameSound {
        id: gameSound
    }


    width: blockSize * _.columns
    height: blockSize * _.rows


}
