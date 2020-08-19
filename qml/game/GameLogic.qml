import QtQuick 2.0

QtObject {
    // Block to Area
    signal fadedout(string entityId)
    signal swapBlock(int row, int column, int targetRow, int targetColumn)

    // Area to GameScene
    signal gameOver()
    signal newScore(int score)
}
