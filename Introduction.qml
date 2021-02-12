import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1
//import io.qt.examples.dataload 1.0

Rectangle {

    //property string fileName

    id: intro
    width: parent.width
    height: parent.height
    //anchors.fill: parent
    //anchors.leftMargin: 2000
    //anchors.horizontalCenter: parent.horizontalCenter
    //FontLoader { id: webFont; source: "./Starburst.ttf" }
    color: "grey"
    signal fileNameGet(string fileName)
    signal creatProject()

    //signal prjName(string txt)
    //signal errorList(var errors)
    //property string test

    //DataLoad {
    //    id: dataload
    //}

    /*can be delte!!
    Loader {
        id:plotpage1
        anchors.fill: parent
        //source: "Introduction.qml"
        focus: true
    }

    function showErr(errList) {
        if (errList.length > 0){
            console.log("wrong file")

        }
        else {
            //plotpage1.setSource("PlotPage.qml",{"fileName":dataload.filePrj})
            plotpage1.setSource("PlotPage.qml",{"fileName":filePath})
            //plotpage1.source = "PlotPage.qml"
            introt.visible = false
        }
    }

    function passFileName(fileName){
        //dataload.filePrj = fileName
        //showErr(dataload.error_list)

        //cProgress.onStart()
        //plotpage1.setSource("PlotPage.qml",{"fileName":fileName})
        plotpage1.setSource("PlotPage.qml")
        introt.visible = false
    }
    */

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

            //onClicked: introText.text = dataload.filePrj
            //onClicked: test("pass")
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


