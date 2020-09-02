import QtQuick 2.9
import QtQuick.Controls 2.5
//import QtQuick.Controls 1.4
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3
import io.qt.examples.dataload 1.0
import QtQml.Models 2.3
import QtQml 2.3

ApplicationWindow{
    id:newprj
    width: 1000
    height: 800
    title: qsTr("new XTC project")

    property int rows: 2
    property int cols: 3
    //property var coreList:["refer"]
    //property var paramList:["age model"]
    property var fileName: "No Data"
    property var filePath
    property var rowModles: []
    property var colModles: []
    property int temp_row: 0

    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.creatMatrix()
        }
    }


    function addrow(){
        libraryModel.append({name:'tbuton',anaimal:'dog'})
    }

    function addcols(){
        at.append({para:'t'})
    }

    Rectangle{
        id:ftable
        width: parent.width
        height: parent.height/10*8
        //anchors.top: npc.bottom


        Rectangle{
            id: butArea1
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 10

            Button {
                id: sp
                anchors.left: butArea1.left
                text: qsTr("Set Path")
                onClicked: {
                    fileDia.visible = true
                }
            }

            TextField{
                anchors.left: sp.right
                width: 160
                text: 'path'
            }
        }


        Rectangle{
            id:butArea2
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 500

            Button {
                id:spn
                anchors.left: butArea2.left
                text: qsTr("Add parameter")

                onClicked: {
                    cols +=1
                    addcols()
                }
            }

            TextField{
                id:spnt
                anchors.left: spn.right
                width: 50
                text: cols
            }
        }

        Rectangle{
            id:butArea3
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 300

            Button {
                id:scn
                anchors.left: butArea3.left
                text: qsTr("Add core")

                onClicked: {
                    rows+=1
                    addrow()
                }
            }

            TextField{
                id: scnt
                anchors.left: scn.right
                width: 50
                text: rows
            }
        }



        /*
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
        */

        FileDialog {
            id: fileDia
            title: "Please choose a file"
            //folder: shortcuts.home
            //folder:"file:///archive/oceans/antarctic/_XTC"
            //folder:"file:///archive/oceans/black_sea/_XTC_BS"
            folder:"file:///home/jiabo/Documents/ps_XTC_practice"
            //folder: "///home/jiabo/Documents/"
            sidebarVisible: false
            visible: false
            nameFilters: ["(*.xtci)", "All files (*)"]
            onAccepted: {
                fileDia.close()
                filePath = fileDia.fileUrls[0]
                fileName = filePath.split('/')[filePath.split('/').length-1]
                //intro.fileNameGet(fileDialog.fileUrls[0])
            }
            onRejected: {
                console.log("Canceled")
                //Qt.quit()
            }
        }

        Rectangle{
            id:tablearea
            anchors.fill: ftable
            //anchors.top: ftable.top
            //anchors.left: ftable.left
            anchors.topMargin: 100
            //color: "grey"

            ListModel {
                id: libraryModel
            }

            ListModel {
                id: at
            }

            ListView {
                id:tableView
                orientation: ListView.Vertical
                anchors.fill: tablearea
                //anchors.left: parent.left
                //anchors.right: parent.right
                width: 1000
                anchors.topMargin: 50
                anchors.leftMargin: 50
                clip: true
                model: libraryModel
                delegate: ItemDelegate {
                    property int rowindex: index
                    ListView{
                        width: 1000
                        //anchors.fill: parent
                        orientation: ListView.Horizontal
                        model: at
                        delegate: Button {
                            property int colindex: index
                            //width: 50
                            text: String(rowindex)+String(colindex)
                            background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            border.color: "grey"
                            color: "lightgrey"
                           }
                           onClicked: console.log(String(rowindex)+String(colindex))
                        }
                    }
                }
            }



            Component.onCompleted: {
                //aDeleRow.add(tbuton)
                at.append({para:'param'})
                at.append({para:'refer data'})
                libraryModel.append({name:'param',anaimal:'dog'})
                libraryModel.append({name:'refer',anaimal:'dog2'})
                libraryModel.append({name:'name3',anaimal:'dog2'})

            }

        }

    }


}
