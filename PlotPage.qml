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
    property int pInd: 1
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
    property int ageonoff: 0
    property var yscale: 1

    property var agepoint
    property var pressX:0
    property var pressY:0
    property var releaseX
    property var releaseY
    property var widthRect
    property var heightRect

    property var xLine
    property var delxPos

    property var colorList: ['#9e0142','#d53e4f','#f46d43','#fdae61','#fee08b','#e6f598','#66c2a5','#3288bd','#5e4fa2','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a']


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
            figmod.insert(i,{coretext:corels[i],coreIdex:i,paraIdex:2,plot:true,textColor:"white"})
            listc.append({coretext:corels[i],check:true,coreIdex:i})
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
            //figmod.append({coretext:techeckstatext})

            //figmod.insert(conInt, {coretext:text,coreIdex:conInt,paraIdex:2,textColor:"white"})
            figmod.setProperty(conInt,"plot",true)
        }
        else {
            //figmod.remove(conInt)
            figmod.setProperty(conInt,"plot",false)
        }
    }

    function editCoreList(){
        coreTextList.clear()
        var t = 0
        for (var i = 0; i<figmod.count; i++){
            if (figmod.get(i).plot == true){
                coreTextList.insert(t,figmod.get(i))
                t = t+1
            }
        }
        return coreTextList
    }

    function getcolor(index){
        var linecolor

        if (index == 0){
            linecolor = '#1f78b4'
        }
        else{
            if ((index > 0) && (index <= 16)){
                linecolor = colorList[index-1]
            }
            else{
                linecolor = colorList[index-17]
            }
        }
        return linecolor
    }

    ListModel{
        id:coreTextList
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
            //text: qsTr("View Mode")
            Text {
                id: modeText
                text: qsTr("View Mode")
                anchors.left: modeChange.right
                anchors.verticalCenter: modeChange.verticalCenter
            }

            onCheckedChanged: {
                console.log(modeChange.checked)
                if (modeChange.checked==true){
                    modeText.text = qsTr("Edit Mode")
                    modeText.color = "white"
                    chart.removeAllSeries()
                    fig.color = "#13141A"
                    coreL.color = "#13141A"
                    //!!!!listc.setProperty(cInd,"fcolor","red")
                    listView.visible = false
                    coreFocus.visible = true
                    chart.theme = ChartView.ChartThemeDark
                    prevP.background.color = "#084594"
                    prevP.contentItem.color = "white"
                    nextP.background.color = "#084594"
                    nextP.contentItem.color = "white"
                    paraLabel.color = "#c6dbef"

                    edit()
                }
                else{
                    modeText.text = qsTr("View Mode")
                    modeText.color = "black"
                    fig.color = "#FFFFFF"
                    coreL.color = "#FFFFFF"
                    listView.visible = true
                    coreFocus.visible = false
                    prevP.background.color = "#f0f0f0"
                    prevP.contentItem.color = "black"
                    nextP.background.color = "#f0f0f0"
                    nextP.contentItem.color = "black"
                    paraLabel.color = "#084594"

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
                    id:corename
                    anchors.verticalCenter: cbox.verticalCenter
                    anchors.left: cbox.left
                    anchors.leftMargin: 30
                    text: qsTr(coretext)
                    color: getcolor(coreIdex)
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
                    if (cbox.checkState === 2){
                        corename.color = getcolor(coreIdex)
                    }else{
                        corename.color = "grey"
                    }
                    addFigList(cbox.checkState,coretext,coreIdex)
                    chart.removeAllSeries()
                    plot()
                }
            }
        }

        ListView {
            //#============================core list of plot()
            id: listView
            height: coreL.height*0.8
            width: coreL.width*0.9
            anchors.left: coreL.left
            //anchors.fill: coreL
            //anchors.bottom: coreL.bottom
            anchors.top: coreL.top
            anchors.topMargin: 50
            anchors.leftMargin: 10
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            model: coreList(corels)
            clip: true
            delegate: listObj

            ScrollBar.vertical: ScrollBar {}
        }

        ListView {
            //#============================core list of edit()
            id: coreFocus
            height: coreL.height*0.8
            width: coreL.width*0.9
            anchors.left: coreL.left
            anchors.top: coreL.top
            anchors.topMargin: 50
            anchors.leftMargin: 10
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            visible: false
            model: editCoreList()
            clip: true
            delegate: Component{
                id:cButList
                Button{
                    id:cBut
                    width: coreFocus.width
                    height: 30
                    Text {
                        //anchors.bottom: cButBc.bottom
                        anchors.horizontalCenter: cBut.horizontalCenter
                        anchors.verticalCenter: cBut.verticalCenter
                        text: qsTr(coretext)
                        color: textColor
                    }
                    background: Rectangle{
                        id:cButBc
                        color: "#13141A"
                        border.color: "lightblue"
                    }

                    onClicked: {
                        //console.log(coreIdex)
                        //console.log(coretext)
                        cInd = coreIdex
                        for (var i=0;i<coreTextList.count;i++){
                            //console.log(coreTextList.get(i).coretext)
                            if (coreTextList.get(i).coretext == coretext){
                                coreTextList.setProperty(i,"textColor","red")
                            }
                            else{
                                coreTextList.setProperty(i,"textColor","white")
                            }
                        }
                        chart.removeAllSeries()
                        edit()
                    }
                }
            }
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
            fig.anchors.left = listShow.right
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
            //fig.width = plotpage.width*0.8
            fig.anchors.left = listHide.right


        }
    }

    function nextPara(){
        var fignum = figmod.count

        if (pInd > params.length-1){
            pInd = 0
            //console.log(count)
        }

        pInd = pInd + 1
        //console.log(pInd)

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
        //console.log(pInd)

        for (var i=0; i<fignum; i++){
            figmod.setProperty(i, "paraIdex", pInd)
        }

    }

    function plot() {
        //console.log(figmod.count)
        var plotsIndex = []
        for(var i = 0;i <figmod.count;i++){
            if (figmod.get(i).plot == true){
                plotsIndex.push(figmod.get(i).coreIdex)
            }
        }
        //console.log(plotsIndex.length)

        for(var i = 0;i <plotsIndex.length;i++){
            var plotseq = i
            //send lineseries to dataload for update plotting
            yAxis.gridVisible=false
            xAxis.gridVisible=false
            yAxis.max = 1
            yAxis.min = -1-1*plotsIndex.length*yscale//Math.max.apply(Math,yvect)
            xAxis.max = 100
            //chart.title = params[figmod.get(i).paraIdex]
            paraLabel.text = params[pInd-1]
            //var series =chart.createSeries(ChartView.SeriesTypeScatter, figmod.get(plotsIndex[i]).coretext, xAxis, yAxis);
            var series =chart.createSeries(ChartView.SeriesTypeLine, figmod.get(plotsIndex[i]).coretext, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            series.markerSize = 4
            series.color = getcolor(plotsIndex[i])
            //console.log(i,yscale,plotseq*yscale)
            dataload.setXyVect(series,plotsIndex[i],pInd,plotseq*yscale)
            //dataload.setXyVect(series,i,pInd)
        }
    }

    function edit() {
        var plotsIndex = []
        for(var i = 0;i <figmod.count;i++){
            if (figmod.get(i).plot == true){
                plotsIndex.push(figmod.get(i).coreIdex)
            }
        }
        for(var i = 0;i <plotsIndex.length;i++){
            var plotseq = i
            dataload.plot_index(figmod.count-plotsIndex[i]-1)
            //send lineseries to dataload for update plotting
            yAxis.max = 1
            yAxis.min = -1-1*plotsIndex.length*yscale//Math.max.apply(Math,yvect)
            yAxis.gridVisible=false
            //xAxis.max = 100
            xAxis.gridVisible=false
            //chart.title = params[figmod.get(i).paraIdex]
            paraLabel.text = params[pInd-1]
            var series =chart.createSeries(ChartView.SeriesTypeLine,
                                           figmod.get(plotsIndex[i]).coretext, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            //console.log(plotsIndex[i],cInd)
            if (plotsIndex[i] == 0){
                series.color = "blue"
            }
            else{
                if (plotsIndex[i] == cInd){
                    series.color = "red"
                    var ageseries =chart.createSeries(ChartView.SeriesTypeLine,
                                               "", xAxis, yAxis);
                    ageseries.useOpenGL = chart.openGL
                    ageseries.color = "#6baed6"
                    ageseries.width = 0.5
                    //=================reference core has no age model
                    dataload.ageLines(ageseries,cInd,figmod.count)
                }else{
                    series.color = "lightgrey"
                }
            }
            series.markerSize = 4
            dataload.editXyVect(series,plotsIndex[i],pInd,plotseq*yscale)
        }
    }

    function delLine(){

    }

    Rectangle {
        id:fig
        //anchors.fill:parent
        //width: parent.width-coreL.width
        anchors.left: coreL.right
        height: parent.height
        anchors.right: parent.right
        color: "white"

        ListModel {
            id:figmod
        }

        ChartView {
            property real scaleFactor: 1

            id: chart
            //anchors.fill: parent
            anchors.top: fig.top
            anchors.right: fig.right
            anchors.left: fig.left
            width: fig.width
            height: fig.height*0.95
            antialiasing: true
            backgroundRoundness: 0
            legend.visible: false
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

            Menu {
                id: delem //delete menue
                width: 83
                height: 50
                //title: "delete"
                contentItem: ColumnLayout{
                    id:lmenu
                    Label {
                        text: "delte"
                        //anchors.centerIn: parent
                        Layout.alignment: Qt.AlignHCenter
                        //anchors.horizontalCenter: lmenu.horizontalCenter
                    }
                    RowLayout {
                        //Layout.preferredWidth: 10
                        spacing: 2
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 22
                            text: "yes"
                            onClicked: {
                                delem.close()
                                ageonoff = 0
                                dataload.ageDel(delxPos)

                                chart.removeAllSeries()
                                edit()
                            }
                        }
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 22
                            text: "no"
                            onClicked: {
                                delem.close()
                                chart.removeSeries(xLine)
                                ageonoff = 0
                                chart.removeAllSeries()
                                edit()
                            }
                        }
                    }
                }


            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onPressed: {
                    if (mouse.button & Qt.LeftButton){
                        pressX = mouse.x
                        pressY = mouse.y
                        //console.log("Pressed Co-ordinates",pressX,pressY);
                    }
                }

                onReleased: {
                    if (mouse.button & Qt.LeftButton){
                        releaseX = mouse.x
                        releaseY = mouse.y
                        //console.log("Released Co-ordinates",releaseX,releaseY);
                        widthRect = releaseX - pressX
                        heightRect = releaseY - pressY
                        //console.log("width, height:",widthRect,heightRect)
                    }
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
                    if (wheel.modifiers & Qt.ControlModifier){
                        //console.log(wheel.angleDelta)
                        if ((wheel.angleDelta.y >= 0) && (yscale -0.01 >= 0)){
                            yscale = yscale - 0.01
                            //console.log(yscale)

                            chart.removeAllSeries()
                            //plot()
                        }
                        else if ((wheel.angleDelta.y < 0) && (yscale +0.01 <=1)){
                                    yscale = yscale + 0.01
                                    //console.log(yscale)

                                    chart.removeAllSeries()
                                    //plot()
                                 }
                        if(modeChange.checked == true){
                            edit()
                        }
                        else{
                            plot()
                        }
                    }
                    else{
                        var coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                        var xpos = coords.x
                        var p1,p2
                        parent.scaleFactor = wheel.angleDelta.y/(xAxis.max - xAxis.min);
                        p1 = (xpos - xAxis.min)/(xAxis.max - xAxis.min)
                        p2 = (xAxis.max - xpos)/(xAxis.max - xAxis.min)
                        //console.log(p1,p2,parent.scaleFactor)

                        if (xAxis.max + p2*parent.scaleFactor > xAxis.min - p1*parent.scaleFactor){
                            xAxis.max = xAxis.max + p2*parent.scaleFactor
                            xAxis.min = xAxis.min - p1*parent.scaleFactor
                        }
                    }
                }

                onDoubleClicked: {
                    //chart.zoomReset()
                    //===============================set reference axis
                    parent.scaleFactor = 0
                    xAxis.min = 0
                    xAxis.max = 100
                }

                onClicked: {
                    if (modeChange.checked==true){
                        var coords;
                        var xpos;
                        if ((mouse.button & Qt.LeftButton) && (ageonoff==0)){
                            coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                            xpos = coords.x
                            agepoint = xpos
                            //console.log(xpos)

                            xLine =chart.createSeries(ChartView.SeriesTypeLine,
                                   "", xAxis, yAxis);
                            xLine.useOpenGL = chart.openGL
                            xLine.append(xpos,1)
                            xLine.append(xpos,-1*figmod.count)
                            ageonoff = 1
                        }
                        else if ((mouse.button & Qt.LeftButton) && (ageonoff==1)){
                            chart.removeSeries(xLine)
                            coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                            xpos = coords.x
                            ageonoff = 0
                            dataload.ageChange(agepoint,xpos)

                            chart.removeAllSeries()
                            edit()
                        }
                        else if((mouse.button & Qt.RightButton) && (ageonoff==1)){
                            chart.removeSeries(xLine)
                            ageonoff = 0
                            chart.removeAllSeries()
                            edit()
                        }
                        else if ((mouse.button & Qt.RightButton) && (ageonoff==0)){
                            //#==var coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                            coords = chart.mapToValue(Qt.point(mouseX,mouseY))
                            xpos = coords.x
                            delxPos = dataload.searchLine(xpos)

                            xLine =chart.createSeries(ChartView.SeriesTypeLine,
                                    "", xAxis, yAxis);
                            xLine.useOpenGL = chart.openGL
                            xLine.color = "orange"
                            xLine.append(delxPos,1)
                            xLine.append(delxPos,-1*figmod.count)

                            delem.popup()
                        }
                    }
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

            /*
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
            */
        }

        Button {
            id: nextP
            //text: qsTr("Next")
            contentItem: Text {
                text: qsTr("---> Next")
                color: "black"
            }
            anchors.bottom: fig.bottom
            anchors.right: fig.right
            background: Rectangle{
                border.color: "#f0f0f0"
                color: "#f0f0f0"
            }
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
            contentItem: Text {
                text: qsTr("Prev <---")
                color: "black"
            }
            anchors.bottom: fig.bottom
            anchors.left: fig.left
            background: Rectangle{
                border.color: "#f0f0f0"
                color: "#f0f0f0"
            }

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
            color: "#084594"
            font.pixelSize: 22
            anchors.bottom: fig.bottom
            anchors.horizontalCenter: fig.horizontalCenter
        }
    }
}
