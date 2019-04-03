import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.9
import QtQuick.Dialogs 1.1
import io.qt.examples.dataload 1.0

ApplicationWindow {
    visible: true
    width: 740
    height: 580
    title: qsTr("XTC")

    menuBar:MenuBar {
        Menu {
            title: qsTr("&File")
            Action { text: qsTr("&New...") }
            Action { text: qsTr("&Open...") }
            Action { text: qsTr("&Save") }
            Action { text: qsTr("Save &As...") }
            MenuSeparator { }
            Action { text: qsTr("&Quit") }
        }
        Menu {
            title: qsTr("&Edit")
            Action { text: qsTr("Cu&t") }
            Action { text: qsTr("&Copy") }
            Action { text: qsTr("&Paste") }
        }
        Menu {
            title: qsTr("&Help")
            Action { text: qsTr("&About") }
        }
    }

    DataLoad {
        id: dataload
    }

    property var errList
    property var corelist
    property string fName: ""
    property int coreIndex
    property int paraIndex
    property var xvect
    property var yvect
    property var xy

    onFNameChanged: {   
        //console.log(errList.length)
        dataload.filePrj = fName
        errList = dataload.error_list
        showErr(errList)
    }

    onCoreIndexChanged: {
        dataload.coreIndex = coreIndex
        dataload.paraIndex = paraIndex
        xvect = dataload.xvector
        yvect = dataload.yvector
        dataload.xy = xy
        //console.log("print xvector")
        ///console.log(dataload.xvector)
    }
    onParaIndexChanged: {
        //dataload.coreIndex = coreIndex
        //dataload.paraIndex = paraIndex
        //xvect = dataload.xvector
        //yvect = dataload.yvector
        //dataload.paraIndex = paraIndex
    }

    function showErr(errList) {
        if (errList.length > 0){
            //console.log("bingo")
            if (fName != "") {
                view.setCurrentIndex(1)
            }
            else{
                view.setCurrentIndex(0)
            }
        }
        else {
            corelist = dataload.coreList
            view.setCurrentIndex(2)
        }
    }


    SwipeView {
        id: view

        currentIndex: 0
        anchors.fill: parent

        Item {
            id: firstPage
            Introduction {onPrjName: fName = txt}
        }
        Item {
            id: secondPage
            ErrPage{property var err: errList;
                    property var viewObj: view}
        }


        Item {
            id: thirdPage
            PlotPage{property var corels: corelist;
                     onCoreI: coreIndex = cindex;
                     onParaI: paraIndex = pindex;
                     property var xvector: xvect;
                     property var yvector: yvect;
                     onXy: xy = xyArray}
        }
        Component.onCompleted: contentItem.interactive = false
    }


/*
    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }



    Button {
        id:test
        text: "test"
        onClicked: stack.push("page1.qml")

    }

    Introduction {
        id: intro
        onPrjName: fName = txt
    }
*/
}
