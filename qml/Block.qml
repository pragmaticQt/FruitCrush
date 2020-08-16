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
        Total
    }

    property int type
    property int row
    property int column

    signal clicked(int row, int column, int type)

    Image {
        anchors.fill: parent
        source: fruitSource()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(row, column, type)
    }

    NumberAnimation {
        id: fadeOutAnimation
        target: block
        properties: "opacity"
        duration: 100
        from: 1.0
        to: 0.0

        onStopped: {
            entityManager.removeEntityById(block.entityId)
        }
    }

    NumberAnimation {
        id: fallDownAnimation
        target: block
        properties: "y"
    }

    Timer {
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false
        onTriggered: {
            fallDownAnimation.start()
        }
    }

    function remove() {
        fadeOutAnimation.start()
    }

    function fallDown(distance) {
        fallDownAnimation.complete()//Unlike stop(), complete() immediately fast-forwards the animation to its end.

        fallDownAnimation.duration = 100 * distance
        fallDownAnimation.to = block.y + distance * block.height

        fallDownTimer.start()
    }

    function fruitSource() {
        switch (type) {
            case Block.FruitType.Apple:
                return "../assets/Apple.png"
            case Block.FruitType.Banana:
                return "../assets/Banana.png"
            case Block.FruitType.BlueBerry:
                return "../assets/BlueBerry.png"
            case Block.FruitType.Orange:
                return "../assets/Orange.png"
            case Block.FruitType.Pear:
                return "../assets/Pear.png"
            default :
                return ""
        }
    }


}
