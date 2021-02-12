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
                //loader.setSource("PlotPage.qml",{"fileName":fileName})
                plotpagecomp.dataReload(fileName)
                //console.log(fileName)
                intro.visible = false
                creatprjPage.visible = false
                plotPage.visible = true
                //plot.contains(PlotPage)
                //PlotPage.loadCompelte("true")
            }
            onCreatProject:{
                console.log("creat project")
                plotPage.visible = false
                intro.visible = false
                creatprjPage.visible = true
                plotpagecomp.dataReload("")
            }
        }
    }
    Rectangle{
        anchors.fill: parent
        id:creatprjPage
        visible: false
        color: "grey"
        Creatprj{
            anchors.fill: parent
            id:creatprjcomp
            onFileName2Get: {
                //fileName2 from creatprj.qml
                console.log("filename2"+fileName2)
                plotPage.visible = true
                intro.visible = false
                creatprjPage.visible = false
                plotpagecomp.dataReload(fileName2)
            }
            onCreatprjToMain: {
                plotPage.visible = false
                intro.visible = true
                creatprjPage.visible = false
            }
        }
    }

    Rectangle{
        anchors.fill: parent
        id: plotPage
        visible: false
        PlotPage{
            id:plotpagecomp
            //fileName: fileName
            onPlotToEdit:{
                //console.log(fileName3)
                plotPage.visible = false
                intro.visible = false
                creatprjPage.visible = true
                creatprjcomp.dataReload(fileName3)
            }
        }
    }
}
