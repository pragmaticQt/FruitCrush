import QtQuick 2.12

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

    function fruitSource(type) {
        switch (type) {
        case Fruits.FruitType.Apple:
            return "../../assets/Apple.png"
        case Fruits.FruitType.Banana:
            return "../../assets/Banana.png"
        case Fruits.FruitType.BlueBerry:
            return "../../assets/BlueBerry.png"
        case Fruits.FruitType.Orange:
            return "../../assets/Orange.png"
        case Fruits.FruitType.Pear:
            return "../../assets/Pear.png"
        default :
            return ""
        }
    }

}
