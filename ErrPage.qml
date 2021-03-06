import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1


Rectangle{
    id:load_page
    //anchors.right: parent.right
    width: parent.width
    height: parent.height
    anchors.fill: parent
    //color: "lightgrey"

    Label {
        id:info

    }


    ProgressBar {
        property color proColor: "#148014"
        property color proBackgroundColor: "#AAAAAA"
        property int proWidth: 2
        property real progress: 0
        property real proRadius: 3
        property alias interval: timer.interval

        function isRunning(){
            return(timer.running)
        }

        function onStart(){
            cProgress.progress = 0;
            timer.running = true;
        }

        function onStop(){
            timer.running = false;
        }

        id: cProgress
        anchors.centerIn: parent
        value: (progress/100)
        padding: 2

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 16
            color: cProgress.proBackgroundColor
            radius: cProgress.proRadius
        }

        contentItem: Item {
            implicitWidth: 200
            implicitHeight: 10

            Rectangle {
                width: cProgress.visualPosition * parent.width
                height: parent.height
                radius: 2
                color: cProgress.proColor
            }
        }

        Timer{
            id: timer
            running: false
            repeat: true
            interval: 50
            onTriggered:{
                cProgress.progress++;
                if (cProgress.progress > 100){
                    cProgress.onStop();
                    return;
                }
            }
        }
    }
}

