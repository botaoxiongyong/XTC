import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.9
import QtQuick.Dialogs 1.1
//import io.qt.examples.dataload 1.0

ApplicationWindow {
    visible: true
    width: 1400
    height: 900
    title: qsTr("XTC")

    menuBar:MenuBar {
        id:mbar
        background: Rectangle{
            color: "lightgrey"
            border.color: "grey"
        }
        /*
        Menu {
            title: qsTr("&File")
            MenuItem { text: qsTr("&New...") }
            MenuItem { text: qsTr("&Open...") }
            MenuItem {
                text: qsTr("&Save")
                onClicked: {
                    PlotPage.save
                    //dataload.save()
                    //console.log(PlotPage.save)
                }
            }
            MenuItem { text: qsTr("Save &As...") }
            MenuSeparator { }
            MenuItem { text: qsTr("&Quit") }
        }
        Menu {
            title: qsTr("&Edit")
            MenuItem { text: qsTr("Cu&t") }
            MenuItem { text: qsTr("&Copy") }
            MenuItem { text: qsTr("&Paste") }
        }
        Menu {
            title: qsTr("&Help")
            MenuItem { text: qsTr("&About") }
        }
        */
    }

    Loader {
        id:loader
        anchors.fill: parent
        //source: "Introduction.qml"
        focus: true
    }

    Rectangle {
        id:intro
        anchors.fill: parent
        Introduction{
            onFileNameGet: {
                //plot_Page.recieveFileName(fileName)
                loader.setSource("PlotPage.qml",{"fileName":fileName})
                //console.log(fileName)
                intro.visible = false
                //plot.contains(PlotPage)
                //PlotPage.loadCompelte("true")
            }
            onCreatProject:{
                intro.visible = false
                creatprjPage.visible = true
            }
        }
    }
    Rectangle{
        anchors.fill: parent
        id:creatprjPage
        visible: false
        Creatprj{
            onFileName2Get: {
                console.log("loader"+fileName2)
                //plot_Page.recieveFileName(fileName)
                loader.setSource("PlotPage.qml",{"fileName":fileName2})
                //console.log(fileName)
                intro.visible = false
                creatprjPage.visible = false
            }
        }
    }

    /*

    Page {
        id: firstPage
        anchors.fill: parent
        Introduction {}
        //PlotPage{}
    }

    SwipeView {
        id: view

        currentIndex: 0
        anchors.fill: parent

        function addPage(page) {
                    addItem(page)
                    page.visible = true
                }

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
            }
        }
        Component.onCompleted: contentItem.interactive = false
    }
    */


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
