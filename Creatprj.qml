import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3
import io.qt.examples.dataload 1.0

ApplicationWindow{
    id:newprj
    width: 1000
    height: 800
    title: qsTr("new XTC project")

    property int rows: 0
    property int cols: 0
    //property var coreList:["refer"]
    //property var paramList:["age model"]
    property var fileName: "No Data"
    property var filePath
    property var rowModles: []
    property var colModles: []
    property int temp_row: 0

    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.creatMatrix()
        }
    }

    function coreList(core){
        coreListModel.append({name:core})
        return coreListModel
    }
    function paramList(param){
        paramListModel.append({name:param})
        return paramListModel
    }
    function collist(col,row){
        //console.log(row,col)
        fileListModle.append({name:String(col)+String(row),col:col,row:row})
    }

    function rowllist(col,row){
        //corePModel.append({name:'add',row:row})
        //console.log(fileListModle.count)
        //fileListModle.append({name:'add',col:col})
        rowModles.push()
    }

    function row_add(row){
        console.log(row)
        for (var i=0;i<cols;i++){
            fileListModle.setProperty(i,"row",row)
            fileListModle.setProperty(i,"name",String(row))
        }
        return fileListModle
    }

    function update_table(row,col){
        for (var r=0;r<row;r++){
            for (var c=0;c<col;c++){
                colModles.push(c,"table_button")
            }
            rowModles.push(r,colModles)
        }
    }

    Rectangle{
        id:npc
        width: newprj.width
        height: newprj.height/20
        anchors.top: newprj.top

        Popup {
            id:cpinput
            x: 100
            y: 100
            width: 200
            height: 70
            modal: true
            focus: true
            //closePolicy: Popup.close | Popup.closePolicy
            Rectangle{
                id:cpwindow
                anchors.fill: parent
                color: "grey"
                Rectangle{
                    anchors.top: cpwindow.top
                    //anchors.horizontalCenter: parent.horizontalCenter
                    width: cpwindow.width
                    height: cpwindow.height/2
                    color: "lightgrey"
                    Text {
                        anchors.horizontalCenter: parent.verhorizontalCenter
                        id: addnote
                    }
                }

                Rectangle{
                    anchors.bottom: cpwindow.bottom
                    height: cpwindow.height/2
                    width: cpwindow.width
                    border.color: "green"
                    TextInput{
                        id: inputtext
                        text: "name"
                        color: "lightgrey"
                        selectByMouse: true
                        selectionColor: "black"

                        Keys.onReturnPressed: {
                            if (addnote.text === "core Name"){
                                //coreList.push(inputtext.text)
                                coreList(inputtext.text)
                                rowllist(cols,rows)
                            }
                            else if (addnote.text === "parameter Name"){
                                paramList(inputtext.text)
                                collist(cols,rows)
                            }
                            //console.log(rows,cols)
                            update_table(rows,cols)
                            //loader.sourceComponent = undefined
                            //table_model.rowNumb(rows)
                            //table_model.colNumb(cols)
                            //table_model.coreList(coreList)
                            //table_model.paramList(paramList)
                            cpinput.close()
                        }
                    }
                }
            }
            //onClosed: {
            //    loader.sourceComponent = mycomp
            //}
        }

        Rectangle{
            width: npc.width/2
            height: npc.height
            anchors.left: npc.left
            Button {
                //anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("add core")

                onClicked: {
                    addnote.text = qsTr("core Name")
                    cpinput.open()
                    //loader.sourceComponent = undefined
                    rows = rows + 1
                }
            }
        }
        Rectangle{
            width: npc.width/2
            height: npc.height
            anchors.right: npc.right
            Button {
                //anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("add parameter")

                onClicked: {
                    addnote.text = qsTr("parameter Name")
                    cpinput.open()
                    //loader.sourceComponent = undefined
                    cols = cols+1
                }
            }
        }

    }

    Rectangle{
        id:coreNameList
        width: 100
        anchors.left: parent.left
        anchors.top: paraNameList.bottom
        anchors.bottom: parent.bottom
        color: "lightblue"

        ListView{
            id:cNameLview
            anchors.fill: coreNameList
            model: coreListModel
            delegate: cNameComponent
        }

        ListModel{
            id:coreListModel
            ListElement{name:"refer"}
            //ListElement{name:"refer"}
        }

        Component{
            id:cNameComponent
            Rectangle{
                height: 50
                width: 100
                border.color: "grey"
                //color: "red"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: name
                }
            }
        }
    }

    Rectangle{
        id:paraNameList
        height: 50
        anchors.left: coreNameList.right
        anchors.top: npc.bottom
        anchors.right: parent.right
        //anchors.bottom: parent.bottom
        color: "lightblue"

        ListView{
            id:pNameLview
            orientation: Qt.Horizontal
            anchors.fill: paraNameList
            model: paramListModel
            delegate: pNameComponent
        }

        ListModel{
            id:paramListModel
            ListElement{name:"Age Model"}
            //ListElement{name:"refer"}
        }

        Component{
            id:pNameComponent
            Rectangle{
                height: 50
                width: 100
                border.color: "grey"
                //color: "red"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: name
                }
            }
        }
    }

    Rectangle {
        id:tableArea
        width: parent.width-100
        anchors.left: coreNameList.right
        anchors.right: parent.right
        height: parent.height/10*8
        anchors.top: paraNameList.bottom
        anchors.bottom: parent.bottom
        color: "lightgrey"

        ListView{
            orientation: Qt.Vertical
            anchors.fill: parent
            model: rowModles
            //delegate: filePathObj
            //delegate: test
            delegate: ListView{
                property int indexofrow: index
                width: parent.width
                height: 50
                orientation: Qt.Horizontal
                //width: parent.width
                //model: fileListModle
                model: colModles
                //delegate: filePathObj
                delegate: filePathObj
            }

        }

        ListModel{
            id:corePModel
            ListElement{disp:"row";col:0;row:0}
            //ListElement{name:"1-1"}
            //ListElement{name:"1-1"}
        }

        ListModel{
            id:fileListModle
            ListElement{name:"col";col:0;row:0}
            //ListElement{name:"1-1"}
            //ListElement{name:"1-1"}
        }

        Component{
            id:filePathObj
            Button{
                id:table_button
                width: 100
                height: 50
                text: name

                onClicked: {
                    console.log(row,col,name)
                }
            }
        }
    }


/*---
    Rectangle{
        id:ftable
        width: parent.width
        height: parent.height/10*8
        anchors.top: npc.bottom

        Button {
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.leftMargin: 100
            text: qsTr("cores")
            onClicked: {
                fileDia.visible = true
            }
        }

        Text {
            anchors.top: ftable.top
            anchors.left: ftable.left
            anchors.topMargin: 20
            anchors.leftMargin: 20

            text: qsTr("parameters")
        }

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

        FileDialog {
            id: fileDia
            title: "Please choose a file"
            //folder: shortcuts.home
            //folder:"file:///archive/oceans/antarctic/_XTC"
            //folder:"file:///archive/oceans/black_sea/_XTC_BS"
            folder:"file:///home/jiabo/Documents/ps_XTC_practice"
            //folder: "///home/jiabo/Documents/"
            sidebarVisible: false
            visible: false
            nameFilters: ["(*.xtci)", "All files (*)"]
            onAccepted: {
                fileDia.close()
                filePath = fileDia.fileUrls[0]
                fileName = filePath.split('/')[filePath.split('/').length-1]
                //intro.fileNameGet(fileDialog.fileUrls[0])
            }
            onRejected: {
                console.log("Canceled")
                //Qt.quit()
            }
        }

        Component.onCompleted: {
            table_model.rowNumb(rows)
            table_model.colNumb(cols)
            table_model.coreList(coreList)
            table_model.paramList(paramList)
            loader.sourceComponent = mycomp
        }

        Component{
            id:mycomp
            TableView {
                id: tableView

                columnWidthProvider: function (column) { return 100; }
                rowHeightProvider: function (column) { return 60; }
                //anchors.fill: parent
                //anchors.topMargin: 100
                leftMargin: rowsHeader.implicitWidth
                topMargin: columnsHeader.implicitHeight
                model: table_model
                ScrollBar.horizontal: ScrollBar{}
                ScrollBar.vertical: ScrollBar{}
                clip: true

                delegate: Rectangle {

                    Text {
                        text: display
                        anchors.fill: parent
                        anchors.margins: 10
                        color: 'black'
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                console.log(display)
                                //fileDia.open()
                            }
                        }
                    }
                    Button {
                        //id: cpbuton
                        text: String(rows)+"&"+String(cols)
                        anchors.fill: parent
                        //anchors.margins: 10

                        background: Rectangle {
                            implicitHeight: 20
                            implicitWidth: 100
                            border.color: "black"
                        }
                        onClicked: {
                            //fileDia.open()
                            console.log(parent.text)

                        }
                    }

                }
                Rectangle { // mask the headers
                    z: 3
                    color: "#222222"
                    y: tableView.contentY
                    x: tableView.contentX
                    width: tableView.leftMargin
                    height: tableView.topMargin
                }

                Row {
                    id: columnsHeader
                    y: tableView.contentY
                    z: 2
                    Repeater {
                        model: tableView.columns > 0 ? tableView.columns : 1
                        Label {
                            width: tableView.columnWidthProvider(modelData)
                            height: 35
                            text: table_model.headerData(modelData, Qt.Horizontal)
                            color: '#aaaaaa'
                            font.pixelSize: 15
                            padding: 10
                            verticalAlignment: Text.AlignVCenter

                            background: Rectangle { color: "#333333" }
                        }
                    }
                }
                Column {
                    id: rowsHeader
                    x: tableView.contentX
                    z: 2
                    Repeater {
                        model: tableView.rows > 0 ? tableView.rows : 1
                        Label {
                            width: 60
                            height: tableView.rowHeightProvider(modelData)
                            text: table_model.headerData(modelData, Qt.Vertical)
                            color: '#aaaaaa'
                            font.pixelSize: 15
                            padding: 10
                            verticalAlignment: Text.AlignVCenter
                            background: Rectangle { color: "#333333" }
                        }
                    }
                }

                ScrollIndicator.horizontal: ScrollIndicator { }
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }

    }
*/
}
