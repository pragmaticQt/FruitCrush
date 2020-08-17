import QtQuick 2.0

Item {
    id: highlightEffect
    property alias anchors: highlightRect.anchors

    // rectangle for highlight effect
    Rectangle {
      id: highlightRect
      color: "white"
//      anchors.fill: parent
//      anchors.centerIn: parent
      opacity: 0
      z: 1
    }

    // animation for highlighting a block
    SequentialAnimation {
      id: highlightAnimation
      loops: Animation.Infinite
      NumberAnimation {
        target: highlightRect
        property: "opacity"
        duration: 750
        from: 0
        to: 0.35
      }
      NumberAnimation {
        target: highlightRect
        property: "opacity"
        duration: 750
        from: 0.35
        to: 0
      }
    }

    function activate() {
        highlightRect.opacity = 0
        highlightAnimation.start()
    }

    function deactivate() {
        highlightAnimation.stop()
        highlightRect.opacity = 0
    }
}
