import Felgo 3.0
import QtQuick 2.0

GameWindow {
    id: gameWindow
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    activeScene: gameScene

    // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
    // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
    // you can set this size to any resolution you would like your project to start with, most of the times the one of your main target device
    // this resolution is for iPhone 4 & iPhone 4S
    screenWidth: 640
    screenHeight: 960

    onSplashScreenFinished: {
        backgroundMusic.play()
    }

    EntityManager {
        id: entityManager
        entityContainer: gameArea
    }

    FontLoader {
        id: gameFont
        source: "../assets/fonts/akaDylanPlain.ttf"
    }

    BackgroundMusic {
      id: backgroundMusic
      source: "../assets/snd/backgroundMusic.mp3"
      // autoPlay: true - this is set by default
      autoPlay: false
    }

    Scene {
        id: gameScene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        property int score: 0

        BackgroundImage {
            id: bkgImage
            source: "../assets/JuicyBackground.png"
            anchors.centerIn: gameScene.gameWindowAnchorItem
        }

        Text {
            font.family: gameFont.name
            font.pixelSize: 12
            color: "red"
            text: gameScene.score

            anchors.horizontalCenter: parent.horizontalCenter
            y: 446
        }

        GameOverWindow {
            id: gameOverWindow
            y: 90
            z: 10
            opacity: 1
            anchors.horizontalCenter: parent.horizontalCenter
            onNewGameClicked: gameScene.startGame()
        }

        GameArea {
            id: gameArea
            anchors.horizontalCenter: gameScene.horizontalCenter
            blockSize: 30
            y: 20

            onGameOver: gameOverWindow.show()
        }

        function startGame() {
            gameArea.initializeField()
            gameScene.score = 0

            gameOverWindow.hide()
        }
    }
}
