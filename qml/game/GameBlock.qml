import QtQuick 2.0
import Felgo 3.0

EntityBase {
    id: block
    entityType: "block"
    visible: y >= 0

    enum FruitType {
        Apple,
        Banana,
        BlueBerry,
        Orange,
        Pear,
        //Add a new fruit before this line
        Total
    }

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
        source: fruitSource()
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
            particleItem.opacity = 1
            sparkleParticle.start()
        }

        onStopped: {
            sparkleParticle.stop()
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
    Item {
      id: particleItem
      width: parent.width
      height: parent.height
      x: parent.width/2
      y: parent.height/2

      Particle {
        id: sparkleParticle
        fileName: "./particles/FruitySparkle.json"
      }
      opacity: 0
      visible: opacity > 0
      enabled: opacity > 0
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

    function fruitSource() {
        switch (type) {
            case GameBlock.FruitType.Apple:
                return "../assets/Apple.png"
            case GameBlock.FruitType.Banana:
                return "../assets/Banana.png"
            case GameBlock.FruitType.BlueBerry:
                return "../assets/BlueBerry.png"
            case GameBlock.FruitType.Orange:
                return "../assets/Orange.png"
            case GameBlock.FruitType.Pear:
                return "../assets/Pear.png"
            default :
                return ""
        }
    }
}
