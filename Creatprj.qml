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

Rectangle{
    id:newprj
    width: 1000
    height: 800
    //title: qsTr("new XTC project")

    property int rows: 4
    property int cols: 3
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
    property var fullText: ""
    //property var colArray: []
    property var modelArray: []
    signal fileName2Get(string fileName2)

    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.creatMatrix()
            //initMatrix()
        }
    }

    Loader {
        id:plotpage1
        anchors.fill: parent
        //source: "Introduction.qml"
        focus: true
    }


    function addrow(){
        rowModel.append({name:'tbuton',anaimal:'dog'})
    }

    function addcols(){
        colModel.append({name:'tbuton',para:'t'})
    }
    function tableColor(row,col){
        if (row >0 && col>0){
            if (row===0 | row===2 | col===0){
                return "white"
            }
            else{
                return "lightblue"
            }
        }
        else{
            return "white"
        }
    }
    function tableChangeName(row,col){
        if (col===0 && titleName==="core"){

        }
    }
    function popOpenSwitch(row,col){
        if (row !== 0 & row !==2 && col !==0){
            popupWindow.open()
        }
        else{
            popChangeName.open()
        }
    }

    function modelDel(rows,cols){
        colModel.clear()
        rowModel.clear()
        //var rms = rowModel.count
        //var cms = colModel.count
        //console.log(rms,cms)
/*
        for (var r=0;r<rows-3;r++){
            rowModel.remove(0)
        }
        for (var i=0;i<cols-2;i++){
            colModel.remove(0)
        }
        //rowModel.remove(0,rowModel.count-1)
*/
        for (var r=0;r<rows;r++){
            rowModel.append({})
        }
        for (var i=0;i<cols;i++){
            colModel.append({})
        }
    }

    function getText(rowi,coli){
        //console.log(rowi,coli)
        //console.log(datal                           oad.getMaxtrixValue(rowi+1,coli+1))
        if (rowi>=0 && coli>=0){
            return dataload.getMaxtrixValue(rowi,coli)
        }else{
            return ""
        }


    }

    Rectangle{
        id:ftable
        width: newprj.width
        height: newprj.height/10*8
        anchors.left: newprj.left
        //anchors.top: npc.bottom

        Rectangle{
            //first line of buttons
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 10

        Rectangle{
            id: butArea1
            //anchors.top: ftable.top
            anchors.left: parent.left
            //anchors.topMargin: 20
            anchors.leftMargin: 10
            Button {
                id: sp
                anchors.left: butArea1.left
                text: qsTr("Set Path")
                onClicked: {
                    //fileDia.DontUseNativeDialog
                    fileDia.open()
                }
            }

            TextField{
                id: spText
                anchors.left: sp.right
                width: 160
                text: 'path'
            }
        }

        Rectangle{
            id:butArea3
            anchors.left: butArea1.right
            //anchors.top: ftable.top
            //anchors.left: ftable.left
            //anchors.topMargin: 20
            anchors.leftMargin: 300

            Button {
                id:scn
                anchors.left: butArea3.left
                text: qsTr("Add core")

                onClicked: {
                    rows+=1
                    addrow()
                }
            }

            TextField{
                id: scnt
                anchors.left: scn.right
                width: 50
                text: rows-3 //number of cores
            }
        }

        Rectangle{
            id:butArea2
            //anchors.top: ftable.top
            //anchors.left: ftable.left
            anchors.left: butArea3.right
            //anchors.topMargin: 20
            anchors.leftMargin: 200

            Button {
                id:spn
                anchors.left: butArea2.left
                text: qsTr("Add parameter")

                onClicked: {
                    cols +=1
                    addcols()
                }
            }
            TextField{
                id:spnt
                anchors.left: spn.right
                width: 50
                text: cols-2 // number of parameters
            }
        }

        Rectangle{
            id:butArea4
            //anchors.top: ftable.top
            //anchors.left: ftable.left
            anchors.left: butArea2.right
            //anchors.topMargin: 20
            anchors.leftMargin: 200

            Button {
                id:saveButton
                //anchors.left: ftable.left
                text: qsTr("save xtc file")

                onClicked: {
                    dataload.saveXTCproject(rows-3,cols-2)
                }
            }
        }
        Rectangle{
            Loader {
                id:loader
                anchors.fill: parent
                //source: "Introduction.qml"
                focus: true
            }

            id:openPlotWindow
            anchors.left: butArea4.right
            //anchors.topMargin: 20
            anchors.leftMargin: 200
            Button{
                id:openPWbutton
                text: qsTr("open plot")
                onClicked: {
                    console.log("open plot to "+filePath)
                    ftable.visible = false
                    newprj.fileName2Get(filePath)
                    //loader.setSource("PlotPage.qml",{"fileName":filePath})
                }
            }
        }
        }

        Rectangle{
            visible: false
            //second baseline
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 80
            anchors.leftMargin: 10
        Rectangle{
            id:butFilter
            anchors.left: parent.left
            //anchors.topMargin: 20
            anchors.leftMargin: 10
            Button {
                id: butFilterText
                anchors.left: butFilter.left
                text: qsTr("Set Filter")
            }
            TextField{
                id: filterText
                anchors.left: butFilterText.right
                width: 50
                text: "*.dat"
            }
        }
        Rectangle{
            id:openDataFile
            anchors.left: butFilter.right
            anchors.leftMargin: 200
            Button{
                id: dataPathButton
                anchors.left: openDataFile.left
                text: "open data"
                onClicked: {
                    datafileOpen.open()
                }
            }
            TextField{
                id: dataPathText
                anchors.left: dataPathButton.right
                width: 200
            }
        }
        }



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
            //visible: false
            nameFilters: ["(*.xtci)", "All files (*)"]
            onAccepted: {
                fileDia.close()
                //filePath = fileDia.fileUrls[0]+'.xtci'
                filePath = fileDia.fileUrls[0]+'.xtci'
                fileName = filePath.split('/')[filePath.split('/').length-1]
                //intro.fileNameGet(fileDialog.fileUrls[0])
                //console.log(filePath)
                spText.text = fileName
                dataload.fileExist(filePath)
                cols = dataload.getColNum();
                rows = dataload.getRowNum();
                console.log(cols,rows)
                modelDel(rows,cols)
            }
            onRejected: {
                console.log("Canceled")
                //Qt.quit()
            }
        }

        FileDialog {
            id: datafileOpen
            title: "Please choose a file"
            folder:"file:///home/jiabo/Documents/ps_XTC_practice"
            sidebarVisible: false
            selectExisting: true
            //selectFolder: true
            //visible: false
            nameFilters: ["(*)","All files (*)"]
            onAccepted: {
                datafileOpen.close()
                datafilePath = datafileOpen.fileUrls[0]
                dataload.coreMaxtrix(rowi,coli,datafilePath.split('/')[datafilePath.split('/').length-1])
                popupPathLable.text = datafilePath.split('/')[datafilePath.split('/').length-1]
                //dataPathText.text = datafilePath.split('/')[datafilePath.split('/').length-1]
                popupPreviewText.text = dataload.filePreview(datafilePath)

            }
            onRejected: {
                console.log("Canceled")
                //return
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
                               //popupWindow.open()
                               popOpenSwitch(rowi,coli)

                           }
                        }
                    }
                }
            }

            Component.onCompleted: {
                //fileDia.open()
                //rows,cols = dataload.rowcolNum()
                //var t = dataload.rowcolNum()
                cols = dataload.getColNum();
                rows = dataload.getRowNum();
                modelDel(rows,cols)
            }
        }

        Popup {
            anchors.centerIn: parent
            id:popupWindow
            //parent: Overlay.overlay
            x: Math.round((newprj.width - 400) / 2)
            y: Math.round((newprj.height - 400) / 2)
            width: 400
            height: 400
            focus: true
            closePolicy: Popup.CloseOnEscape

            Rectangle{
            Rectangle{
                id:popupPath
                height: 40
                width: popupWindow.width-20
                anchors.top: popupWindow.Top
                Button {
                    id:popupPathButton
                    width: popupPath.width/4
                    height: popupPath.height
                    text: "open file"
                    onClicked: {
                        datafileOpen.open()
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
                width: popupWindow.width-20
                anchors.top: popupPath.bottom
                anchors.topMargin: 20
                Rectangle {
                    height: popupLable.height/2
                    width: popupLable.width
                    //anchors.top: popupPath.bottom
                    RowLayout{
                        width: popupWindow.width
                        ColumnLayout{
                            Label{
                                text: "totalColumn"
                            }
                            TextInput{
                                width: 20
                                id:totalColums
                                selectByMouse: true
                                cursorVisible: true
                                text: '2'
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: "XColumn"
                            }
                            TextInput{
                                width: 20
                                id: xcolumn
                                selectByMouse: true
                                cursorVisible: true
                                text: '1'
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: "YColumn"
                            }
                            TextInput{
                                width: 20
                                id: ycolumn
                                selectByMouse: true
                                cursorVisible: true
                                text: '2'
                            }
                        }
                    }
                }

            }

            Rectangle{
                id:popupYN
                height: 50
                width: popupWindow.width-20
                anchors.top: popupLable.bottom

                RowLayout{
                    width: popupWindow.width
                    Button{
                        text: "yes"
                        onClicked: {
                            //console.log(dataload.getMaxtrixValue(rowi,coli))
                            //tableView.
                            if (rowi<2){
                                //reference rows
                                if (totalColums>2){
                                    fullText = "GR"+" "+popupPathLable.text+"   "+totalColums.text+"   "+xcolumn.text+"   "+ycolumn.text
                                }else{
                                    fullText = "FR"+" "+popupPathLable.text+"   "+totalColums.text+"   "+xcolumn.text+"   "+ycolumn.text
                                }
                            }
                            else{
                                //core rows
                                if (totalColums>2){
                                    fullText = "GR"+" "+popupPathLable.text+"   "+totalColums.text+"   "+xcolumn.text+"   "+ycolumn.text
                                }else{
                                    fullText = "FR"+" "+popupPathLable.text+"   "+totalColums.text+"   "+xcolumn.text+"   "+ycolumn.text
                                }
                            }

                            dataload.coreMaxtrix(rowi,coli,fullText)
                            modelDel(rows,cols)
                            popupWindow.close()
                        }
                    }
                    Button{
                        text: "cancel"
                        onClicked: {
                            popupWindow.close()
                        }
                    }
                }
            }

            Rectangle {
                height: 200
                width: popupWindow.width-20
                anchors.top: popupYN.bottom
                ScrollView{
                    clip: true
                    width: popupWindow.width
                    height: 200
                    Text {
                        id: popupPreviewText
                        text: qsTr("data preview")
                    }
                }
            }
            }
        }

        Popup{
            id:popChangeName
            //parent: Overlay.overlay
            x: Math.round((newprj.width - 400) / 2)
            y: Math.round((newprj.height - 400) / 2)
            width: 230
            height: 100
            focus: true
            closePolicy: Popup.CloseOnEscape

            Rectangle{

            ColumnLayout{
                //anchors.fill: popChangeName
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
}
