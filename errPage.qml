import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1
import io.qt.examples.dataload 1.0

Item {

    id:page
    width: parent.width
    height: parent.height
    //anchors.fill: parent
    //color: "red"
    property string errs: ""

    DataLoad {
        id: dataload
    }

    ///Introduction {onErrorList: errorList = errors}


    Text {
        anchors.fill: parent
        id: error
        text: dataload.filePrj
    }

    onErrsChanged: {
        //error.text = "red"
        page.color="red"
        console.log(dataload.filePrj)
    }
}
