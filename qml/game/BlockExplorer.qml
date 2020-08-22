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
    function findHorizontalSpan(field, block) {
        let row = block.row
        let col = block.column
        let type = block.type

        if (row < 0 || row >= rows)
            return [0,0]

        var span = []
        var nr = 1
        // look left
        while(col - nr >= 0 && field[row][col-nr].type === type) {
            nr++
        }
        span.push(-nr+1)

        // look right
        nr = 1
        while(col + nr < columns && field[row][col+nr].type === type) {
            nr++
        }
        span.push(nr)

        return span
    }

    function findVerticalSpan(field, block) {
        let row = block.row
        let col = block.column
        let type = block.type

        if (col < 0 || col >= columns)
            return [0,0]

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

    function findConnectedComponent(field, block) {

        return {
            'origin': {'x':block.row, 'y':block.column},
            'xSpan': findHorizontalSpan(field, block),
            'ySpan': findVerticalSpan(field, block)}
    }
}
