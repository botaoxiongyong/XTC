import QtQuick 2.9
import QtQuick.Controls 2.1
import QtCharts 2.0
import QtQuick.Layouts 1.12

Item {
    id: plotpage
    anchors.fill: parent

    //property var coreSelected: []
    property string coretext
    signal coreI(int cindex)
    signal paraI(int pindex)
    property int pInd: 2
    property int count: 0

    function coreList(corels){
        count = 0;
        for (var i in corels){
            //coreI(i)
            //paraI(pInd)
            figmod.insert(i,{coretext:corels[i],coreIdex:i,paraIdex:pInd})
            listc.append({coretext:corels[i],check:true,coreIdex:i})
            //figmod.append({coretext:corels[i],check:true,coreIdex:i})
        }
        return listc
    }

    function addFigList(chekstate,text,conInt){
        //console.log(chekstate)
        if (chekstate === 2){
            coreI(conInt)
            paraI(pInd)
            //figmod.append({coretext:text})
            figmod.insert(conInt, {coretext:text,coreIdex:conInt,paraIdex:pInd})
        }
        else {
            figmod.remove(conInt)
        }

    }

    function test(figmod){
        for (var i = 0; i < figmod.count; i++){
            coreI(i)
            paraI(pInd)
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
                    console.log(coretext)
                    //listc.set(coreIdex,{check:cbox.checked})
                    //loopCheckBox()
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
        console.log(figmod.count,t)
        //console.log(listc.get(0).)
        for (var i=figmod.count-1; i>= 0; i--){
            //coreI(i)
            //console.log(pInd+count)

            //console.log(figmod.get(i).coretext)
            //figmod.get(i).paraIdex = pInd+count
            //figmod.setProperty(i,"paraIdex",pInd+count)
            //var t = figmod.get(i).coretext
            var c = figmod.get(i).coreIdex
            //var t = pInd+count
            //figmod.remove(i)
            //figmod.insert(i+1,{coretext:figmod.get(i).coretext,coreIdex:figmod.get(i).coreIdex,paraIdex:pInd+count})
            //console.log(figmod.get(i).paraIdex)

            figmod.insert(i+1, {coreIdex:c,paraIdex:count})
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
                                for (var i in xvector){
                                    series.append(xvector[i],yvector[i])
                                }
                                axisY.max = Math.max.apply(Math,yvector)
                                axisY.min = Math.min.apply(Math,yvector)
                                //plotColum.forceLayout()
                            }
                        }

                    }

                }
            }
            Item {Layout.fillHeight: true}
        }

        Button {
            id: nextP
            text: qsTr("Next")
            anchors.bottom: fig.bottom
            onClicked: {
                count++;
                console.log(count);
                nextPara(count);
            }
        }

        /*
        ChartView {
            title: "Two Series, Common Axes"
            anchors.fill: parent
            legend.visible: false
            antialiasing: true

            ValueAxis {
                id: axisX
                min: 0
                max: 10
                tickCount: 5
            }

            ValueAxis {
                id: axisY
                min: -0.5
                max: 1.5
            }

            ValueAxis {
                id: axisX1
                min: 0
                max: 10
                tickCount: 5
            }

            ValueAxis {
                id: axisY1
                min: -0.5
                max: 1.5
            }

            LineSeries {
                id: series1
                axisX: axisX
                axisY: axisY
            }

            ScatterSeries {
                id: series2
                axisX: axisX1
                axisY: axisY1
            }
        }

        // Add data dynamically to the series
        Component.onCompleted: {
            for (var i = 0; i <= 10; i++) {
                series1.append(i, Math.random());
                series2.append(i, Math.random());
            }
        }
        */

        /*
        ChartView {
            width: fig.width/10
            Layout.alignment: Qt.AlignTop
            anchors.fill: fig
            //anchors.right: fig.right
            SplineSeries {
                id: scatterSeries1
                //color: "red";
                //width: fig.width/10

                XYPoint { x: 0; y: 0}
                XYPoint { x: 0.2; y: 0.2}
                XYPoint { x: 0.4; y: 0.4 }
                XYPoint { x: 0.6; y: 0.6 }
                XYPoint { x: 0.8; y: 0.8 }
                XYPoint { x: 1; y: 1}

            }
        }
        */

    }
}
