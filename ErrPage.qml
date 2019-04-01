import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1


Rectangle{
    id:page
    //anchors.right: parent.right
    width: parent.width
    height: parent.height
    anchors.fill: parent
    //color: "lightgrey"

    function test(err){
        if (err === undefined){
            return listerr
        }
        else{
            //return "correct"
            for (var i in err){
                if (i % 2 == 0){
                    listerr.append({errtext: err[i]+"\n"})
                    //listerr.setProperty(color.red)
                }
                else {
                    listerr.append({errtext: err[i]})
                }

            }
            return listerr
        }
    }


    Rectangle{
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "red"

        Text {
            text: qsTr("Errors Message:\n")
            anchors.horizontalCenter: parent.Center
        }
    }


    ListModel {
        id: listerr
        ListElement {errtext: "\n\n"}
    }

    Component {
        id: listtext
        Text {
            text: errtext
            font.pixelSize: 12
            anchors.left: parent.left
            anchors.leftMargin: 2
            //color: "red"
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        model: test(err)
        clip: true
        delegate: listtext

        //Layout.fillWidth: true
        //Layout.fillHeight: true

        ScrollBar.vertical: ScrollBar {}
    }

    Button {
        id:back
        //anchors.fill: page
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: "Back to Start"
        background: Rectangle{color: "lightblue"}

        onClicked:{
            viewObj.setCurrentIndex(0)
        }

        //onClicked: console.log(viewObj)
    }
}

