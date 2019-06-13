import QtQuick 2.9
import QtQuick.Controls 2.1
import QtCharts 2.0
import QtQuick.Layouts 1.12
import io.qt.examples.dataload 1.0

Rectangle {
    id: plotpage
    anchors.fill: parent

    //property var coreSelected: []
    //property string coretext
    //signal coreI(int cindex)
    //signal paraI(int pindex)
    property var fileName
    property int pInd: 2
    property int cInd: 1
    property int count: 0
    property int pi
    property var corels
    property var xvect
    property var yvect
    property int coreIdex
    property int paraIdex
    property var params
    property int xmax: 100
    property int xmin: 0

    property int pressX
    property int pressY
    property int releaseX
    property int releaseY
    property int widthRect
    property int heightRect


    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.filePrj = fileName
            corels = dataload.coreList
            params = dataload.paramList
            plot()
            //console.log(corels)
            //console.log(params)
        }
    }

    function coreList(corels){
        //console.log(corels)
        count = 0;
        for (var i in corels){
            //coreI(i)
            //paraI(pInd)
            //!!!!!!!!!!!!!paraIdex initial
            figmod.insert(i,{coretext:corels[i],coreIdex:i,paraIdex:pInd})
            listc.append({coretext:corels[i],check:true,coreIdex:i,fcolor:"black"})
            //figmod.append({coretext:corels[i],check:true,coreIdex:i})
        }
        //console.log(listc.count)
        //chart.removeAllSeries()
        //!!!!!!!!!!!!!!!got problem here, can not plot at the beginning
        //plot()
        //ptest()
        return listc
    }

    function addFigList(chekstate,text,conInt){
        //console.log(chekstate)
        if (chekstate === 2){
            //coreI(conInt)
            //paraI(pInd)
            //figmod.append({coretext:text})
            figmod.insert(conInt, {coretext:text,coreIdex:conInt,paraIdex:pInd})
        }
        else {
            figmod.remove(conInt)
        }
    }


    function loopCheckBox(){
        for (var i = 0; i < listc.count; i++){
            console.log(listc.get(i).listObj)
        }
    }


    Rectangle {
        //anchors.fill: parent
        id: coreL
        anchors.left: parent.left
        width: parent.width*0.2
        height: parent.height
        color: "lightgrey"

        Switch {
            id:modeChange
            text: qsTr("View Mode")

            onCheckedChanged: {
                console.log(modeChange.checked)
                if (modeChange.checked==true){
                    modeChange.text = qsTr("Edit Mode")
                    chart.removeAllSeries()
                    fig.color = "#13141A"
                    //coreL.color = "#13141A"
                    listc.setProperty(cInd,"fcolor","red")
                    chart.theme = ChartView.ChartThemeDark
                    edit()

                }
                else{
                    modeChange.text = qsTr("View Mode")
                    fig.color = "#FFFFFF"
                    //coreL.color = "#FFFFFF"
                    chart.theme = ChartView.ChartThemeLight
                    chart.removeAllSeries()
                    plot()
                }
            }
        }

        ListModel {
            id: listc
            //ListElement {coretext: "corels";check: true}
        }

        Component {
            id: listObj

            CheckBox{
                id:cbox
                Text {
                    anchors.fill:parent
                    anchors.leftMargin: 25
                    anchors.topMargin: 8
                    //anchors.verticalCenter: parent.verticalCenter
                    text: qsTr(coretext)
                    color: fcolor
                }

                checked: true 

                indicator: Rectangle{
                    anchors.verticalCenter: cbox.verticalCenter
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: 3
                    border.color: cbox.activeFocus ? "darkblue" : "gray"
                    border.width: 1
                    Rectangle {
                        visible: cbox.checked
                        color: "green"
                        border.color: "green"
                        radius: 2
                        anchors.margins: 4
                        anchors.fill: parent
                    }
                }

                onCheckStateChanged: {
                    //console.log(cbox.checkState)
                    addFigList(cbox.checkState,coretext,coreIdex)
                    chart.removeAllSeries()
                    plot()
                }
            }
        }

        ListView {
            id: listView
            height: coreL.height*0.8
            width: coreL.width*0.9
            anchors.left: coreL.left
            //anchors.fill: coreL
            anchors.bottom: coreL.bottom
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            model: coreList(corels)
            clip: true
            delegate: listObj

            //Layout.fillWidth: true
            //Layout.fillHeight: true

            ScrollBar.vertical: ScrollBar {}
        }
    }

    Button{
        id:listHide
        text: qsTr("<")
        height: coreL.height
        width: coreL.width*0.1
        anchors.right: coreL.right

        background: Rectangle{
            id:bbg
            color: "lightgrey"
            border.color: "grey"
        }

        onClicked: {
            //bbg.color = "lightblue"
            listShow.visible = true
            //listShow.width = 0.2
            //coreL.anchors.right = plotpage.left
            coreL.visible = false
            listHide.visible = false
            //listShow.anchors.left = plotpage.left
            fig.width = plotpage.width*0.98
        }
    }

    Button{
        id:listShow
        text: qsTr(">")
        height: coreL.height
        width: coreL.width*0.1
        anchors.left: plotpage.left
        visible: false

        background: Rectangle{
            id:bbg2
            color: "lightblue"
            border.color: "blue"
        }

        onClicked: {
            //bbg2.color = "grey"
            listShow.visible = false
            coreL.visible = true
            listHide.visible = true
            fig.width = plotpage.width*0.8


        }
    }

    function nextPara(){
        var fignum = figmod.count

        if (pInd > params.length-1){
            pInd = 0
            console.log(count)
        }

        pInd = pInd + 1
        console.log(pInd)

        for (var i=0; i<fignum; i++){
            figmod.setProperty(i, "paraIdex", pInd)
        }
    }

    function prevPara(){
        var fignum = figmod.count
        if (pInd <= 1){
            pInd = params.length+1
        }

        pInd = pInd - 1
        console.log(pInd)

        for (var i=0; i<fignum; i++){
            figmod.setProperty(i, "paraIdex", pInd)
        }

    }

    function plot() {
        for(var i = 0;i <figmod.count;i++){
            dataload.plot_index(figmod.count-i-1)

            //send lineseries to dataload for update plotting
            yAxis.max = figmod.count//Math.max.apply(Math,yvect)
            yAxis.min = 0
            xAxis.max = 100
            //chart.title = params[figmod.get(i).paraIdex]
            paraLabel.text = params[pInd]
            var series =chart.createSeries(ChartView.SeriesTypeLine, figmod.get(i).coretext, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            dataload.setXyVect(series,figmod.get(i).coreIdex,pInd)
        }
    }

    function edit() {
        for(var i = 0;i <figmod.count;i++){
            dataload.plot_index(figmod.count-i-1)

            //send lineseries to dataload for update plotting
            yAxis.max = figmod.count//Math.max.apply(Math,yvect)
            yAxis.min = 0
            xAxis.max = 100
            //chart.title = params[figmod.get(i).paraIdex]
            paraLabel.text = params[pInd]
            var series =chart.createSeries(ChartView.SeriesTypeScatter,
                                           figmod.get(i).coretext, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            if (i==cInd){
                series.color = "red"
            }else{
                series.color = "lightgrey"
            }
            series.markerSize = 4
            dataload.editXyVect(series,figmod.get(i).coreIdex,pInd,figmod.count)

            //var series2 =chart.createSeries(ChartView.SeriesTypeLine, figmod.get(i).coretext, xAxis, yAxis);
            //series2.useOpenGL = chart.openGL
            //series2.width = 0.5
            //dataload.editXyVect(series2,figmod.get(i).coreIdex,pInd,figmod.count)
        }
        //plot age tie points
    }

    Rectangle {
        id:fig
        //anchors.fill:parent
        width: parent.width*0.8
        height: parent.height
        anchors.right: parent.right
        color: "white"

        ListModel {
            id:figmod
            //ListElement {name:"ni"}
            //ListElement {name:"hao"}
        }

        ChartView {
            property real scaleFactor: 1

            id: chart
            //anchors.fill: parent
            anchors.top: fig.top
            anchors.right: fig.right
            width: fig.width
            height: fig.height*0.95
            antialiasing: true
            backgroundRoundness: 0
            property bool openGL: true

            ValueAxis {
                id: xAxis
                min: 0
                //max: 1500
                //tickCount: 5
            }

            ValueAxis {
                id: yAxis
                //min: 0
                //max: figmod.count
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                acceptedButtons: Qt.LeftButton

                onPressed: {

                    pressX = mouse.x
                    pressY = mouse.y
                    //console.log("Pressed Co-ordinates",pressX,pressY);
                }

                onReleased: {
                    releaseX = mouse.x
                    releaseY = mouse.y
                    //console.log("Released Co-ordinates",releaseX,releaseY);
                    widthRect = releaseX - pressX
                    heightRect = releaseY - pressY
                    //console.log("width, height:",widthRect,heightRect)
                }

                /*
                onMouseXChanged: {
                    //console.log(mouseX);
                    //t1  = chart.mapFromGlobal(mouseX,mouseY)
                    ///console.log(t1)
                    var coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                    var xpos = coords.x
                }
                */

                onWheel: {
                    var coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                    var xpos = coords.x
                    parent.scaleFactor += 2 * wheel.angleDelta.y/120;
                    //if (parent.scaleFactor > 0)
                    //    parent.scaleFactor = 0;

                    //chart.zoom(parent.scaleFactor)


                    xAxis.max = xmax - parent.scaleFactor
                    xAxis.min = xmin + parent.scaleFactor
                }

                onDoubleClicked: {
                    //chart.zoomReset()
                    xAxis.min = 0
                    xAxis.max = 100
                }
            }

        }

        Rectangle {
            id:rectRoi
            opacity: 0.4
            x: pressX
            y: pressY
            width: widthRect
            height: heightRect
            color: "grey"

            MouseArea {
                id:roiarea
                anchors.fill: parent
                acceptedButtons: Qt.RightButton

                onClicked: {
                    //rectRoi.visible = false
                    //console.log("Right Button Clicked");
                    var precoords = chart.mapToValue(Qt.point(pressX,pressY))
                    var xpos1 = precoords.x
                    var relcoords = chart.mapToValue(Qt.point(releaseX,releaseY))
                    var xpos2 = relcoords.x
                    if (xpos1>xpos2){
                        xAxis.max = xpos1
                        xAxis.min = xpos2
                        xmax = xpos1
                        xmin = xpos2
                    }else{
                        xAxis.max = xpos2
                        xAxis.min = xpos1
                        xmax = xpos2
                        xmin = xpos1
                    }
                }
            }
        }

        Button {
            id: nextP
            text: qsTr("Next")
            anchors.bottom: fig.bottom
            anchors.right: fig.right
            onClicked: {
                //console.log(count);
                nextPara();
                chart.removeAllSeries()
                if (chart.theme == ChartView.ChartThemeDark){
                    edit()
                }
                else{
                    plot()
                }
            }
        }

        Button {
            id: prevP
            text: qsTr("Prev")
            anchors.bottom: fig.bottom
            anchors.left: fig.left
            onClicked: {
                //console.log(count);

                prevPara();
                chart.removeAllSeries()
                if (chart.theme == ChartView.ChartThemeDark){
                    edit()
                }
                else{
                    plot()
                }
            }
        }

        Label {
            id:paraLabel
            text: qsTr("Param")
            font.pixelSize: 22
            anchors.bottom: fig.bottom
            anchors.horizontalCenter: fig.horizontalCenter
        }
    }
}
