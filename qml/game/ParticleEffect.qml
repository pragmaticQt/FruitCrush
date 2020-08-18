import QtQuick 2.0
import Felgo 3.0

Item {
    id: particleItem

    property alias fileName: sparkleParticle.fileName

    Particle {
        id: sparkleParticle
        fileName: "../particles/FruitySparkle.json"
    }
    opacity: 0
    visible: opacity > 0
    enabled: opacity > 0

    function start() {
        particleItem.opacity = 1
        sparkleParticle.start()
    }

    function stop() {
        sparkleParticle.stop()
    }
}
