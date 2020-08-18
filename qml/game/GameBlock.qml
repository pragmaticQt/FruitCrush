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

    Fruits {
        id: fruit
    }

    Image {
        anchors.fill: parent
        source: fruit.fruitSource(type)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: block.clicked(row, column, type)
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

    Timer {// one shot timer for delaying fallDownAnimation
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false
    }

    // particle effect
    ParticleEffect {
        id: particleEffect
        anchors.centerIn: parent
    }

    HighlightEffect {
        id: highlightEffect
        anchors.fill: parent
    }

    Component.onCompleted: {
        fadeOutAnimation.started.connect(particleEffect.start)
        fadeOutAnimation.stopped.connect(particleEffect.stop)
        fadeOutAnimation.stopped.connect(function() { fadedout(block.entityId)} )
        fallDownTimer.triggered.connect(fallDownAnimation.start)
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
}
