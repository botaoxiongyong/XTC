import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1
//import io.qt.examples.dataload 1.0

Rectangle {
    id: intro
    width: parent.width
    height: parent.height
    //anchors.fill: parent
    //FontLoader { id: webFont; source: "./Starburst.ttf" }

    signal prjName(string txt)
    signal errorList(var errors)
    property string test



    Text {
        id: title
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        text: "XTC"
        font.family: "Starburst"
        color: "navy"
        //font.bold: true
        font.pointSize: 50
    }

    Text {
        id: introText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        text: qsTr("Introduction")
    }

    Button {
        id: impProj
        text: "import  XTC  project"
        width: 170
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 150

        background: Rectangle {
            implicitHeight: 40
            implicitWidth: 100
            border.color: "black"
        }

        onClicked: fileDialog.visible = true
    }

    Button {
        id: crtProj
        width: 170
        text: "creat  new  project"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 200

        background: Rectangle {
            implicitHeight: 40
            implicitWidth: 100
            border.color: "black"
        }

        //onClicked: introText.text = dataload.filePrj
        //onClicked: test("pass")
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        sidebarVisible: false
        nameFilters: [ "XTC project (*.xtci)", "All files (*)" ]
        onAccepted: {
            //dataload.filePrj = fileDialog.fileUrls[0]
            //errorList(dataload.error_list)
            prjName(fileDialog.fileUrls[0])
        }
        onRejected: {
            console.log("Canceled")
            //Qt.quit()
        }
    }
}


