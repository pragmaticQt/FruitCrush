import QtQuick 2.0
import Felgo 3.0

EntityBase {
    id: block
    entityType: "block"
    visible: y >= 0

    property int type
    property int row
    property int column

    signal clicked(int row, int column, int type)

    Image {
        anchors.fill: parent
        source: {
            if (type == 0) return "../assets/Apple.png"
            else if (type == 1) return "../assets/Banana.png"
            else if (type == 2) return "../assets/BlueBerry.png"
            else if (type == 3) return "../assets/Orange.png"
            else if (type == 4) return "../assets/Pear.png"
//            else if (type == 3) return "../assets/Coconut.png"
//            else if (type == 4) return "../assets/Lemon.png"
//            else /*if (type == 7)*/ return "../assets/WaterMelon.png"
        }
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
}
