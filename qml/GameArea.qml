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
      // ...
    }
}
