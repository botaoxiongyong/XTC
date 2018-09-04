#include "dataplotting.h"
#include "ui_xtc.h"
#include "xtc.h"

void _dataPlot(std::vector<std::vector<mdata>>& matrixData, Ui::XTC *ui)
{
//

    //QPushButton *buttonNext = new QPushButton(tr("next"),this);
    //buttonNext->setFixedSize(QSize(50,50));
    //buttonNext->move(500,800);
    //buttonNext->show();


    //coreItemChecked(matrixCore,matrixData);

    QVBoxLayout *vbox = new QVBoxLayout;
    QVBoxLayout *vboxParams = new QVBoxLayout;

    int rows = matrixData.size();
    int cols = matrixData[0].size();

    for (int i=1;i<cols;i++){
        //params
        QString param = matrixData[0][i].params[1];
        QCheckBox * qcbox = new QCheckBox(param);
        qcbox->setChecked(true);
        vboxParams->addWidget(qcbox);
        vboxParams->addSpacing(1);
    }
    ui->groupBox_params->setLayout(vboxParams);

    //int paramCountNext = 0;
    //int paramCountPrev =-1;
    //int clickCounts = ui->paramNext->
    connect(ui->paramNext,&QPushButton::clicked,[this,matrixData](){
        _coreItemChecked(matrixData);});

    connect(ui->paramPrevo,&QPushButton::clicked,[this,matrixData](){
        _coreItemChecked(matrixData);});


    //matrixCore[0][0] = QString("references");
    for (int s=0; s<rows;s++){
        //first row is params
        //mdata dat = matrixData[s][2];

        QString coreName = matrixData[s][0].coreName;

        QCheckBox * qcbox = new QCheckBox(coreName);
        qcbox->setChecked(true);
        vbox->addWidget(qcbox);
        vbox->addSpacing(1);

        //int a=s-1;
        //a is not used here
        //int a = 0;

        connect(qcbox, &QCheckBox::clicked, [this, matrixData]() {
            _coreItemChecked(matrixData);});

    }


    ui->groupBoxCore->setLayout(vbox);


}

void _coreItemChecked(const std::vector<std::vector<mdata>> matrixData){

    //qDebug() << counter;
    //counter indicate params index
    QList<QCheckBox *> parambox = ui->groupBox_params->findChildren<QCheckBox *>();
    std::vector<int> params;
    for (int i=0;i<parambox.size();i++){
        bool cheked = parambox.at(i)->checkState();
        if (cheked){
            params.push_back(i);
        }
    }

    //qDebug() << params.size();

    int paramIndex,index,residu;

    residu = counter%params.size();

    if (residu<0){
        index = residu+params.size();
    }
    else{
        if (residu>=params.size()){
            index = residu-params.size();
        }
        else{
            index = residu;
        }
    }


    //qDebug() << index;

    paramIndex = params.at(index)+1;

    //qDebug() << paramIndex;





    QList<QCheckBox *> allbox = ui->groupBoxCore->findChildren<QCheckBox *>();
    //bool tt = allbox.at(ckstate)->checkState();
    //qDebug() << tt;
    std::list<int> skipCores;
    for(int i=0;i<allbox.size();i++){
        bool cheked = allbox.at(i)->checkState();
        if (!cheked){
            skipCores.push_back(i);
        }
    }



    QChart* t = new QChart();


    QLineSeries* line = new QLineSeries();

    //QVBoxLayout *vlayout = new QVBoxLayout();

    //QVBoxLayout *vlayout = new QVBoxLayout();

    QChart* siglePlot = new QChart();

    QChartView *charview = new QChartView();

    //to initialize layout every time
    if (ui->verticalLayoutPlots->layout() != NULL){
        QLayoutItem *witem;
        while ((witem = ui->verticalLayoutPlots->layout()->takeAt(0)) != NULL){
            delete witem->widget();
            delete witem;
        }
    }


    QString tiltle = matrixData[0][paramIndex].params[1];
    t->setTitle(tiltle);

    float scale = 0;
    float init,add;


    int rows = matrixData.size();

    //vlayout = new QVBoxLayout;

    for (int s=1; s<rows;s++){
        if (std::find(skipCores.begin(),skipCores.end(),s) != skipCores.end()){

        }
        else{
        mdata dat = matrixData[s][paramIndex];

        QStringList yaxset = dat.yaxset;

        init = yaxset[3].toFloat();
        add = scale;

        line = new QLineSeries;
        QLineSeries *sigline = new QLineSeries();

        //float average = std::accumulate(dat.y.begin(),dat.y.end(),0.0)/dat.y.size();


        //qDebug() << scale;



        //add new chart for every plot
        siglePlot = new QChart();


        //one core data
        for (int i=1; i<dat.x.size();++i){

            if (dat.age[i+1]-dat.age[i]>10){
                t->addSeries(line);
                t->createDefaultAxes();
                siglePlot->addSeries(sigline);

                line = new QLineSeries;
                sigline = new QLineSeries;
            }
            else{
                float y = dat.y[i];
                if (yaxset[0]=="G"){
                    y = log10(dat.y[i]);
                    //float newscale = y+log10(scale);
                    line->append(dat.age[i],y);
                    sigline->append(dat.age[i],y);
                }
                else{
                    line->append(dat.age[i],y);
                    sigline->append(dat.age[i],y);
                }
            }
        }
        scale = init + add;

        siglePlot->addSeries(sigline);

        siglePlot->createDefaultAxes();
        siglePlot->legend()->setVisible(false);
        siglePlot->setBackgroundBrush(Qt::transparent);
        siglePlot->axisX()->setVisible(false);
        siglePlot->axisY()->setVisible(false);

        charview = new QChartView;
        charview->setChart(siglePlot);
        charview->setBackgroundBrush(Qt::transparent);
        charview->setStyleSheet("background-color: transparent");
        //vlayout->addWidget(charview);
        ui->verticalLayoutPlots->addWidget(charview);


        t->addSeries(line);
        t->createDefaultAxes();
        t->legend()->setVisible(false);

        }

    }


    ui->chart->setChart(t);
    ui->verticalLayoutPlots->setStretch(0,10);



}
