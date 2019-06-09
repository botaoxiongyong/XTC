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


    DataLoad {
        id: dataload
        Component.onCompleted: {
            dataload.filePrj = fileName
            corels = dataload.coreList
            //coreList(corels)
        }
    }



    /*
    //property var corels: dataload.coreList
    property string fName: ""
    property int coreIndex
    property int paraIndex
    property var xvect
    property var yvect

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
        //console.log("print xvector")
        ///console.log(dataload.xvector)
    }
    */


    function coreList(corels){
        console.log(corels)
        count = 0;
        for (var i in corels){
            //coreI(i)
            //paraI(pInd)
            figmod.insert(i,{coretext:corels[i],coreIdex:i,paraIdex:pInd})
            listc.append({coretext:corels[i],check:true,coreIdex:i})
            //figmod.append({coretext:corels[i],check:true,coreIdex:i})
        }

        //console.log(listc.count)
        chart.removeAllSeries()
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
                    //console.log(coretext)
                    //listc.set(coreIdex,{check:cbox.checked})
                    //loopCheckBox()
                    //console.log(figmod.count)
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



    function nextPara(count){
        //console.log(figmod.count,t)
        //console.log(listc.get(0).)
        var fignum = figmod.count
        for (var i=0; i<fignum; i++){
            //coreI(i)
            console.log(count,pInd)
            //console.log(figmod.get(i).coretext)
            //figmod.get(i).paraIdex = pInd+count
            //figmod.setProperty(i,"paraIdex",pInd+count)

            var c = figmod.get(i).coreIdex
            //var t = pInd+count
            //figmod.remove(i)
            //figmod.insert(i+1,{coretext:figmod.get(i).coretext,coreIdex:figmod.get(i).coreIdex,paraIdex:pInd+count})
            //console.log(figmod.get(i).paraIdex)

            figmod.insert(fignum+i, {coretext:"",coreIdex:c,paraIdex:pInd+count})
        }
        for (var i=0; i<fignum; i++){
            figmod.remove(0)
        }
        console.log(figmod.count)

    }

    function plot() {
        for(var i = 0;i < figmod.count;i ++){
            //get data from dataload
            dataload.coreIndex = figmod.get(i).coreIdex
            dataload.paraIndex = figmod.get(i).paraIdex
            xvect = dataload.xvector
            yvect = dataload.yvector
            dataload.plot_index(i)

            //send lineseries to dataload for update plotting
            yAxis.max = figmod.count//Math.max.apply(Math,yvect)
            yAxis.min = 0
            var series =chart.createSeries(ChartView.SeriesTypeLine, "line"+ i, xAxis, yAxis);
            series.useOpenGL = chart.openGL
            dataload.setXyVect(series)
            /*
            yAxis.max = figmod.count//Math.max.apply(Math,yvect)
            yAxis.min = 0//Math.min.apply(Math,yvect)
            var yMax = Math.max.apply(Math,yvect)
            console.log(yvect.length)

            var series =chart.createSeries(ChartView.SeriesTypeLine, "line"+ i, xAxis, yAxis);

            series.useOpenGL = chart.openGL
            for (var t=0;t< xvect.length;t++){
                series.append(xvect[t],yvect[t]/yMax+i)
            }
            */
        }

        /*
        for(var i = 0;i < figmod.count;i ++)
        {
            var series =chart.createSeries(ChartView.SeriesTypeLine, "line"+ i, xAxis, yAxis);
            var x = 0.0;
            console.log("here")

            for(var j = 0;j < 10;j ++)
            {
                x += (Math.random() * 2.0);
                var y = (Math.random() * 10.0);
                series.append(x, y);
            }
        }
        */
    }

    function ptest() {
        //console.log(figmod.get(1))
        var seriesCount = figmod.count //Math.round(Math.random()* 10);
        for(var i = 0;i < seriesCount;i ++)
        {
            var series = chart.createSeries(ChartView.SeriesTypeLine, "line"+ i);
            series.pointsVisible = true;
            series.color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
            series.hovered.connect(function(point, state){ console.log(point); }); // connect onHovered signal to a function
            var pointsCount = Math.round(Math.random()* 20);
            var x = 0.0;
            for(var j = 0;j < pointsCount;j ++)
            {
                x += (Math.random() * 2.0);
                var y = (Math.random() * 10.0);
                series.append(x, y);
            }
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
            id: chart
            anchors.fill: parent
            property bool openGL: true

            ValueAxis {
                id: xAxis
                min: 0
                max: 1500
                tickCount: 5
            }

            ValueAxis {
                id: yAxis
                //min: 0
                //max: figmod.count
            }
        }



        /*
        ColumnLayout {
            id:plotColum
            anchors.fill: fig
            spacing: 0

            Repeater {
                model: figmod
                RowLayout {
                    ChartView {
                        //title: coretext
                        legend.visible: false
                        //anchors.fill: parent
                        //anchors.top: parent.bottom
                        Layout.fillHeight: fig
                        Layout.fillWidth: fig
                        Layout.alignment: Qt.AlignTop
                        margins.top: 0
                        margins.bottom: 0
                        margins.left: 0
                        margins.right: 0
                        backgroundRoundness: 0

                        ValueAxis {
                            id: axisX
                            min: 0
                            max: 1500
                            tickCount: 5
                        }

                        ValueAxis {
                            id: axisY
                            //min: Math.min.apply(Math,yvector)
                            //max: Math.max.apply(Math,yvector)
                        }

                        LineSeries {
                            id: series
                            axisX: axisX
                            axisY: axisY
                            //XYPoint{x:xvector[0];y:xvector[1]}

                            Component.onCompleted: {
                                coreI(coreIdex)
                                paraI(paraIdex)
                                series.useOpenGL = true
                                console.log(xvector.length)
                                for (var i=0;i< xvector.length;i++){
                                    series.append(xvector[i],yvector[i])
                                }
                                ///axisY.max = Math.max.apply(Math,yvector)
                                //axisY.min = Math.min.apply(Math,yvector)
                            }
                        }

                    }



                }
            }
            Item {Layout.fillHeight: true}
        }
        */

        Button {
            id: nextP
            text: qsTr("Next")
            anchors.bottom: fig.bottom
            onClicked: {
                count++;
                //console.log(count);
                nextPara(count);
                chart.removeAllSeries()
                plot()
            }
        }
    }
}
