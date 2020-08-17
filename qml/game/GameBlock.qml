import QtQuick 2.0
import Felgo 3.0

EntityBase {
    id: block
    entityType: "block"
    visible: y >= 0

    property int type // FruitType
    // TopLeft as (0, 0) ---> x
    //                   |
    //                   Vy
    property int row  // position in gamearea grid,
    property int column

    signal clicked(int row, int column, int type)
    signal fadedout(string entityId)

    Image {
        anchors.fill: parent
        source: Fruits.fruitSource()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: block.clicked(row, column, type)
    }

    NumberAnimation on opacity {
        id: fadeOutAnimation
        duration: 500 //increased for visibility
        from: 1.0
        to: 0.0
        running: false

        onStarted: {
            particleEffect.start()
        }

        onStopped: {
            particleEffect.stop()

            fadedout(block.entityId)
        }
    }

    NumberAnimation on y {
        id: fallDownAnimation
    }

    Timer {// one shot timer for delaying fallDownAnimation
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false

        onTriggered: {
            fallDownAnimation.start()
        }
    }

    // particle effect
    ParticleEffect {
        id: particleEffect
        anchors.fill: parent
        fileName: "./particles/FruitySparkle.json"
    }

    HighlightEffect {
        id: highlightEffect
        anchors.fill: parent
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
        fadeOutAnimation.start()
    }

    function fallDown(distance) {
        //Unlike stop(), complete() immediately fast-forwards the animation to its end.
        fallDownAnimation.complete()

        fallDownAnimation.duration = 100 * distance
        fallDownAnimation.to = block.y + distance * block.height

        fallDownTimer.start()
    }
}
