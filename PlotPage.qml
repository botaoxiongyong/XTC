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
    property int count: 0
    property int pi
    property var corels
    property var xvect
    property var yvect
    property int coreIdex
    property int paraIdex
    property var params


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
            figmod.insert(i,{coretext:corels[i],coreIdex:i,paraIdex:2})
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
        width: parent.width/5
        height: parent.height
        color: "grey"

        ListModel {
            id: listc
            //ListElement {coretext: "corels";check: true}
        }

        Component {
            id: listObj

            CheckBox{
                id:cbox
                text: coretext
                checked: true
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
            anchors.fill: coreL
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
            paraLabel.text = params[figmod.get(i).paraIdex]
            var series =chart.createSeries(ChartView.SeriesTypeLine, figmod.get(i).coretext, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            dataload.setXyVect(series,figmod.get(i).coreIdex,figmod.get(i).paraIdex)
        }
    }

    Rectangle {
        id:fig
        //anchors.fill:parent
        width: parent.width/5*4
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
            height: fig.height/5*4.5
            antialiasing: true
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
                onWheel: {
                    parent.scaleFactor += 0.02 * wheel.angleDelta.y/2000;
                    if (parent.scaleFactor < 0)
                        parent.scaleFactor = 0;
                    console.log(parent.scaleFactor)
                    chart.zoom(parent.scaleFactor)
                }

                onDoubleClicked: {
                    chart.zoomReset()
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
                plot()
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
                plot()
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
