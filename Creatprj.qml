import QtQuick 2.9
import QtQuick.Controls 2.5
//import QtQuick.Controls 1.4
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3
import io.qt.examples.dataload 1.0
import QtQml.Models 2.3
import QtQml 2.3
import QtQuick.Layouts 1.3

ApplicationWindow{
    id:newprj
    width: 1000
    height: 800
    title: qsTr("new XTC project")

    property int rows: 0
    property int cols: 0
    property int rowi
    property int coli
    //property var coreList:["refer"]
    //property var paramList:["age model"]
    property var fileName: "No Data"
    property var filePath
    property var datafilePath:""
    property var rowModles: []
    property var colModles: []
    property int temp_row: 0
    property var titleName: ""
    property var tableName: ""
    property var tname: ""
    //property var colArray: []
    property var modelArray: []

    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.creatMatrix()
            //initMatrix()
        }
    }


    function addrow(){
        rowModel.append({name:'tbuton',anaimal:'dog'})
    }

    function addcols(){
        colModel.append({name:'tbuton',para:'t'})
    }
    function tableColor(row,col){
        if (row===0 | row===2 | col===0){
            return "white"
        }
        else{
            return "lightblue"
        }
    }
    function tableChangeName(row,col){
        if (col===0 && titleName==="core"){

        }
    }
    function popOpenSwitch(row,col){
        console.log(tname)
        if (row !== 0 & row !==2 && col !==0){
            popup.open()
            if (popup.closed()){
                tname = "tes1"
            }
            else {
                tname = "test4"
            }

        }
        else{
            popChangeName.open()
            if (popChangeName.closed()){
                tname = "tes2"
            }
            else{
                tname = "tes3"
            }

        }
        return tname

    }

    function modelDel(rows,cols){
        colModel.clear()
        rowModel.clear()
        for (var r=0;r<rows;r++){
            rowModel.append({})
            //colModel.clear()
            //rowModel.remove(r)
        }

        for (var i=0;i<cols;i++){
            colModel.append({})

        }
    }

    function getText(rowi,coli){
        //console.log(rowi,coli)
        //console.log(dataload.getMaxtrixValue(rowi+1,coli+1))
        if (rowi>=0 && coli>=0){
            return dataload.getMaxtrixValue(rowi,coli)
        }else{
            return ""
        }


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
                    //colModleDelegate(rows,cols)

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
                    //rowModleDelegate(rows)
                    //colModleDelegate(rowi,cols)

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
            selectExisting: false
            //selectFolder: true
            visible: false
            nameFilters: ["(*.xtci)", "All files (*)"]
            onAccepted: {
                fileDia.close()
                filePath = fileDia.fileUrls[0]+'.xtci'
                fileName = filePath.split('/')[filePath.split('/').length-1]
                //intro.fileNameGet(fileDialog.fileUrls[0])
                console.log(filePath)
                dataload.fileExist(filePath)
            }
            onRejected: {
                console.log("Canceled")
                //Qt.quit()
            }
        }

        FileDialog {
            id: fileDia2
            title: "Please choose a file"
            folder:"file:///home/jiabo/Documents/ps_XTC_practice"
            sidebarVisible: false
            selectExisting: true
            //selectFolder: true
            visible: false

            nameFilters: ["All files (*)"]
            onAccepted: {
                fileDia2.close()
                datafilePath = fileDia2.fileUrls[0]
                //console.log(datafilePath)
                //console.log(datafilePath.split('/')[datafilePath.split('/').length-1])
                dataload.coreMaxtrix(rowi,coli,datafilePath.split('/')[datafilePath.split('/').length-1])
                popupPathLable.text = datafilePath.split('/')[datafilePath.split('/').length-1]
                //console.log(dataload.filePreview(datafilePath))
                popupPreviewText.text = dataload.filePreview(datafilePath)
            }
            onRejected: {
                return
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
                id: rowModel
            }

            ListModel {
                id: colModel
            }

            ListView {
                id:tableView
                orientation: ListView.Vertical
                anchors.fill: tablearea
                visible: true
                //anchors.left: parent.left
                //anchors.right: parent.right
                width: 1000
                anchors.topMargin: 50
                anchors.leftMargin: 50
                clip: true
                model: rowModel//rowModleDelegate(rows)
                delegate: ItemDelegate {
                    property int rowindex: index
                    ListView{
                        width: 1000
                        //anchors.fill: parent
                        orientation: ListView.Horizontal
                        model: colModel//colModleDelegate(rowindex,cols)
                        delegate: Button {
                            property int colindex: index
                            //width: 50
                            //text://dataload.getMaxtrixValue(rowindex,colindex)//String(rowindex)+String(colindex)
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                border.color: "grey"
                                color: tableColor(rowindex,colindex)
                                Text {
                                    id: bText
                                    text:getText(rowindex,colindex)//dataload.getMaxtrixValue(rowindex,colindex)//colModel.get(colindex).name//modelArray[rowindex].get(colindex).name////
                                }
                           }
                           onClicked: {
                               rowi = rowindex
                               coli = colindex
                               //console.log(modelArray[rowindex].get(colindex).name)
                               //popup.open()
                               popOpenSwitch(rowi,coli)

                           }
                        }
                    }
                }
            }

            Component.onCompleted: {
                //colModel.append({para:"test1"})
                //colModel.append({para:"test2"})
                //colModel.append({para:"test3"})
                //rowModel.append({})
                //rowModel.append({})
                //rowModel.append({})
                //rowModel.append({})

            }
        }

        Popup {
            id:popup
            parent: Overlay.overlay
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: 400
            height: 400
            focus: true
            closePolicy: Popup.CloseOnEscape

            Rectangle{
                id:popupPath
                height: 40
                width: popup.width-20
                anchors.top: popup.Top
                Button {
                    id:popupPathButton
                    width: popupPath.width/4
                    height: popupPath.height
                    text: "open file"
                    onClicked: {
                        fileDia2.visible = true
                    }
                }
                Label {
                    id:popupPathLable
                    anchors.left: popupPathButton.right
                    anchors.top: popupPath.top
                    width: popupPath.width/4*2.8
                    height: popupPath.height
                    color: "green"
                    background: Rectangle{
                        color: "lightblue"
                    }

                    text: {
                        horizontalAlignment: popupPathLable.anchors.centerIn
                        text:"not set"
                    }
                }
            }

            Rectangle{
                id:popupLable
                height: 50
                width: popup.width-20
                anchors.top: popupPath.bottom
                anchors.topMargin: 20
                Rectangle {
                    height: popupLable.height/2
                    width: popupLable.width
                    anchors.top: popupPath.bottom
                    RowLayout{
                        width: popup.width
                        ColumnLayout{
                            Label{
                                text: "totalColumn"
                            }
                            TextInput{
                                selectByMouse: true
                                text: '2'
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: "XColumn"
                            }
                            TextInput{
                                selectByMouse: true
                                text: '2'
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: "YColumn"
                            }
                            TextInput{
                                selectByMouse: true
                                text: '2'
                            }
                        }
                    }
                }

            }

            Rectangle{
                id:popupYN
                height: 50
                width: popup.width-20
                anchors.top: popupLable.bottom

                RowLayout{
                    width: popup.width
                    Button{
                        text: "yes"
                        onClicked: {
                            //console.log(dataload.getMaxtrixValue(rowi,coli))
                            //tableView.
                            modelDel(rows,cols)
                            popup.close()
                        }
                    }
                    Button{
                        text: "cancel"
                        onClicked: {
                            popup.close()
                        }
                    }
                }
            }

            Rectangle {
                height: 200
                width: popup.width-20
                anchors.top: popupYN.bottom
                ScrollView{
                    clip: true
                    width: popup.width
                    height: 200
                    Text {
                        id: popupPreviewText
                        text: qsTr("data preview")
                    }
                }
            }
        }

        Popup{
            id:popChangeName
            parent: Overlay.overlay
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: 230
            height: 100
            focus: true
            closePolicy: Popup.CloseOnEscape

            ColumnLayout{
                anchors.fill: popChangeName
                TextField {
                    id:popChangeNameText
                    height: 100
                    width: popChangeName.width-20
                    selectByMouse: true
                    text: "new name"
                }

                RowLayout{
                    height: 100
                    width: popChangeName.width-20
                    Button{
                        text: "yes"
                        onClicked: {
                            //console.log(rowi,coli)
                            dataload.coreMaxtrix(rowi,coli,popChangeNameText.text)
                            modelDel(rows,cols)
                            popChangeName.close()
                        }
                    }
                    Button{
                        text: "cancel"
                        onClicked: {
                            popChangeName.close()
                        }
                    }
                }
            }
        }
    }
}
