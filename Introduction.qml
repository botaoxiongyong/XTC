import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1
//import io.qt.examples.dataload 1.0
Rectangle {
    id: intro
    width: parent.width
    height: parent.height
    color: "grey"

    property string tempFile:""

    signal fileNameGet(string fileName)
    signal creatProject()
    signal continueProject(string tempFile)

    function continutButtonShow(tempf){
        continueProj.visible = true
        tempFile = tempf
    }

    Rectangle{
        id:introt
        anchors.fill: parent
        Text {
            id: title
            //anchors.fill: parent
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            text: "XTC"
            //font.family: "Starburst"
            color: "navy"
            //font.bold: true
            font.pointSize: 50
        }

        Text {
            id: introText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 120
            font.pointSize: 15
            color: "navy"
            text: qsTr("Time Series Correlating")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: qsTr("developed by Jiabo Liu & Norbert R. Nowaczyk")
        }

        Button {
            id: impProj
            text: "import  XTC  project"
            width: 170
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 200

            background: Rectangle {
                implicitHeight: 40
                implicitWidth: 100
                border.color: "black"
            }

            onClicked: {
                fileDialog.visible = true
                //console.log(filePath)
                //passFileName(filePath)
            }
        }

        Button {
            id: crtProj
            width: 170
            text: "creat  new  project"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 260

            background: Rectangle {
                implicitHeight: 40
                implicitWidth: 100
                border.color: "black"
            }
            onClicked: {
                //var component = Qt.createComponent("Creatprj.qml")
                //var window = component.createObject("newprj")
                //window.show()
                creatProject()
            }
        }
        Button {
            id: continueProj
            width: 170
            text: "continue  project"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 420
            visible: false

            background: Rectangle {
                implicitHeight: 40
                implicitWidth: 100
                border.color: "black"
            }
            onClicked: {
                continueProject(tempFile)
            }
        }



        FileDialog {
            id: fileDialog
            title: "Please choose a file"
            //folder: shortcuts.home
            //folder:"file:///archive/oceans/antarctic/_XTC"
            //folder:"file:///archive/oceans/black_sea/_XTC_BS"
            folder:"file:///home/jiabo/Documents/ps_XTC_practice"
            sidebarVisible: false
            visible: false
            nameFilters: [ "XTC project (*.xtci)", "All files (*)" ]
            onAccepted: {
                fileDialog.close()
                //cProgress.onStart()
                //dataload.filePrj = fileDialog.fileUrls[0]
                //fileName = fileDialog.fileUrls[0]
                //console.log(fileName)
                intro.fileNameGet(fileDialog.fileUrls[0])

                //passFileName(fileName)
                //Introduction.fileNameGet(fileName)
                //filePath = fileDialog.fileUrls[0]
                //console.log(dataload.error_list)

                //showErr(dataload.error_list)
                //errorList(dataload.error_list)
                //prjName(fileDialog.fileUrls[0])
            }
            onRejected: {
                fileDialog.close()
                console.log("Canceled")
                //Qt.quit()
            }
        }



    }

}


