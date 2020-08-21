import QtQuick 2.0

QtObject {
    id: root
    property int rows: 0
    property int columns: 0

    //            (r-1, c)
    //               ^
    //               |
    // (r, c-1)<-- (r, c) --> (r, c+1)
    //               |
    //               v
    //            (r+1, c)
    function findHorizontalSpan(field, row, col, type) {
        if (row < 0 || row >= rows)
            return []

        var span = []
        var nr = 0
        // look left
        while(col - nr >= 0 && field[row][col-nr].type === type) {
            nr++
        }
        span.push(nr===0 ? 0 : -nr+1)

        // look right
        nr = 0
        while(col + nr < columns && field[row][col+nr].type === type) {
            nr++
        }
        span.push(nr)

        return span
    }

    function findVerticalSpan(field, row, col, type) {
        if (col < 0 || col >= columns)
            return []

        var span = []
        var nr = 1
        // look bottom
        while(row-nr >= 0 && field[row-nr][col].type === type) {
            nr++
        }
        span.push(nr===0 ? 0 : -nr+1)

        // look top
        nr = 1
        while(row+nr < rows && field[row+nr][col].type === type) {
            nr++
        }
        span.push(nr)

        return span
    }
}
