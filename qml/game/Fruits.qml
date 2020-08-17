import QtQuick 2.0

QtObject {
    enum FruitType {
        Apple,
        Banana,
        BlueBerry,
        Orange,
        Pear,
        //Add a new fruit before this line
        Total
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
