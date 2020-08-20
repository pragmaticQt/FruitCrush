import QtQuick 2.0
import Felgo 3.0

// TopLeft as (0, 0) ---> x
//                   |
//                   Vy

EntityBase {
    id: block

    property int type // FruitType
    property int row  // position in gamearea grid,
    property int column

    signal clicked(int row, int column, int type)

    //signal fadedout(string entityId)
    // emit a signal when block should be swapped with another
    //signal swapBlock(int row, int column, int targetRow, int targetColumn)
    signal swapFinished(int row, int column, int swapRow, int swapColumn)

    // function to move block one step left/right/up or down
    function moveTo(targetRow, targetCol) {
      swapAnimation.complete()

      _.previousRow = block.row
      _.previousColumn = block.column

      if(targetRow !== block.row) {
        swapAnimation.property = "y"
        swapAnimation.to = block.y +
            (targetRow > block.row ? block.height : -block.height)
        block.row = targetRow
      }
      else if(targetCol !== block.column) {
        swapAnimation.property = "x"
        swapAnimation.to = block.x +
            (targetCol > block.column ? block.width : -block.width)
        block.column = targetCol
      }
      else
        return

      swapAnimation.start()
    }

    // highlights the block to help the player find groups
    function highlight(active) {
        if(active) {
            highlightEffect.activate()
        }
        else {
            highlightEffect.deactivate()
        }
    }

    function fadeOut() {
        fadeOutAnimation.from = 1.0
        fadeOutAnimation.to = 0.0
        fadeOutAnimation.start()
    }

    function fallDown(distance) {
        //Unlike stop(), complete() immediately fast-forwards the animation to its end.
        fallDownAnimation.complete()

        fallDownAnimation.duration = 100 * distance
        fallDownAnimation.to = block.y + distance * block.height

        fallDownTimer.restart()
    }

    entityType: "block"
    visible: y >= 0

    Component.onCompleted: {
//        fadeOutAnimation.started.connect(particleEffect.start)
//        fadeOutAnimation.stopped.connect(particleEffect.stop)
        fadeOutAnimation.stopped.connect(function() { gameLogic.fadedout(block.entityId)} )
//        swapAnimation.stopped.connect(swapFinishedTimer.start)

        fallDownTimer.triggered.connect(fallDownAnimation.start)
//        swapFinishedTimer.triggered.connect(function(){ swapFinished(_.previousRow, _.previousColumn, block.row, block.column)})
    }

    QtObject {
        id: _

        property int previousRow
        property int previousColumn
    }

    Fruits {
        id: fruit
    }

    Image {
        anchors.fill: parent
        source: fruit.fruitSource(type)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        // properties to handle dragging
        property bool dragging
        property bool waitForRelease
        property var dragStart

        // start drag on press
        onPressed: {

          if(!dragging && !waitForRelease) {
            dragging = true
            dragStart = { x: mouse.x, y: mouse.y }
          }
        }
        // stop drag on release
        onReleased: {

          dragging = false
          waitForRelease = false
        }
        // trigger swap of blocks after player swiped a certain distance
        onPositionChanged: {

          if(!dragging || waitForRelease)
            return

          var xDistance = mouse.x - dragStart.x
          var yDistance = mouse.y - dragStart.y

          if((Math.abs(xDistance) < block.width/2)
              && (Math.abs(yDistance) < block.height/2))
            return

          var targetRow = block.row
          var targetCol = block.column

          if(Math.abs(xDistance) > Math.abs(yDistance)) {
            if(xDistance > 0)
              targetCol++
            else
              targetCol--
          }
          else {
            if(yDistance > 0)
              targetRow++
            else
              targetRow--
          }

          // signal block move
          //dragging = false
          waitForRelease = true
          gameLogic.swapBlock(row, column, targetRow, targetCol)
        }
    }

    NumberAnimation on opacity {
        id: fadeOutAnimation
        duration: 200 //increased for visibility

        running: false
    }

    NumberAnimation on y {
        id: fallDownAnimation
        running: false
    }

    // one shot timer for delaying fallDownAnimation
    Timer {
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false
    }

    // timer to wait a bit before signal swap finished
    Timer {
      id: swapFinishedTimer
      interval: 50
      repeat: false
      running: false

      onTriggered: swapFinished(_.previousRow, _.previousColumn, block.row, block.column)
    }

    // animation to move a block after swipe
    NumberAnimation {
      id: swapAnimation
      target: block
      duration: 150

      onStopped: swapFinishedTimer.start()
    }

    // particle effect
//    ParticleEffect {
//        id: particleEffect
//        anchors.centerIn: parent
//    }

//    HighlightEffect {
//        id: highlightEffect
//        anchors.fill: parent
//    }
}
