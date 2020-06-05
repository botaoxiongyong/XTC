import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.qmlmodels 1.0

ApplicationWindow{
    id:newprj
    width: 1000
    height: 800
    title: qsTr("new XTC project")

    Rectangle{
        id:npc
        width: parent.width
        height: parent.height/10
        anchors.top: parent.top

        Rectangle{
            width: npc.width/2
            height: npc.height
            anchors.left: npc.left
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("creat new XTC project")
            }
        }
        Rectangle{
            width: npc.width/2
            height: npc.height
            anchors.right: npc.right
            Text {
                id:er
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("creat new XTC project")
            }
        }
    }

    Rectangle{
        id:ftable
        width: parent.width
        height: parent.height/10*8
        anchors.top: npc.bottom

        Text {
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.leftMargin: 100
            text: qsTr("cores")
        }

        Text {
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 20

            text: qsTr("parameters")
        }
        Button{
            anchors.right: ftable.right
            text: qsTr("core")
            onClicked: {
                console.log("clicked")
                table_model.rowNumb(1)
                loader.sourceComponent = mycomp

            }
        }

        Rectangle{
            anchors.fill:parent
            anchors.topMargin: 100
            Loader{
                id:loader
                anchors.fill: parent
                focus: true
                //sourceComponent: mycomp
            }
        }



        Component{
            id:mycomp
            TableView {
                id: tableView

                columnWidthProvider: function (column) { return 100; }
                rowHeightProvider: function (column) { return 60; }
                //anchors.fill: parent
                //anchors.topMargin: 100
                leftMargin: rowsHeader.implicitWidth
                topMargin: columnsHeader.implicitHeight
                model: table_model
                ScrollBar.horizontal: ScrollBar{}
                ScrollBar.vertical: ScrollBar{}
                clip: true

                delegate: Rectangle {
                    Text {
                        text: display
                        anchors.fill: parent
                        anchors.margins: 10
                        color: 'black'
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Rectangle { // mask the headers
                    z: 3
                    color: "#222222"
                    y: tableView.contentY
                    x: tableView.contentX
                    width: tableView.leftMargin
                    height: tableView.topMargin
                }

                Row {
                    id: columnsHeader
                    y: tableView.contentY
                    z: 2
                    Repeater {
                        model: tableView.columns > 0 ? tableView.columns : 1
                        Label {
                            width: tableView.columnWidthProvider(modelData)
                            height: 35
                            text: table_model.headerData(modelData, Qt.Horizontal)
                            color: '#aaaaaa'
                            font.pixelSize: 15
                            padding: 10
                            verticalAlignment: Text.AlignVCenter

                            background: Rectangle { color: "#333333" }
                        }
                    }
                }
                Column {
                    id: rowsHeader
                    x: tableView.contentX
                    z: 2
                    Repeater {
                        model: tableView.rows > 0 ? tableView.rows : 1
                        Label {
                            width: 60
                            height: tableView.rowHeightProvider(modelData)
                            text: table_model.headerData(modelData, Qt.Vertical)
                            color: '#aaaaaa'
                            font.pixelSize: 15
                            padding: 10
                            verticalAlignment: Text.AlignVCenter
                            background: Rectangle { color: "#333333" }
                        }
                    }
                }

                ScrollIndicator.horizontal: ScrollIndicator { }
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }


    }
}
