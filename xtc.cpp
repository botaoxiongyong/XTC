#include "xtc.h"
#include "ui_xtc.h"
#include "project_load.h"
#include "newwindow.h"
#include <QDebug>
#include <QStandardItem>
//#include "dataplotting.h"
#include <math.h>
#include "_randcolor.h"


XTC::XTC(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::XTC)
{
    ui->setupUi(this);
    //ui->chart->hide();
    //ui->groupBoxCore->hide();
    //ui->chart_plot->hide();
    //ui->pushButton_next->hide();
    //ui->groupBox_params->hide();
    ui->groupBoxCore->hide();
    ui->groupBox_params->hide();
    ui->tabWidget->tabBar()->hide();
    ui->tab_rawdata->hide();
    ui->tab_matrix->hide();
    ui->tab_plot->hide();
    ui->tab_plot->setStyleSheet("background-color:white;");
    ui->tab_introduction->show();
    ui->tab_edit->hide();
    ui->pb_back_edit->hide();
    counter = 0;
    colors = rndColors(50);
    //this->window()->size()
}

XTC::~XTC()
{
    delete ui;
}


void XTC::on_actionOpen_project_file_triggered()
{
    ui->tab_introduction->hide();
    ui->tab_rawdata->show();

   //all functions here included in project_load

   QString fileName = fileNameGet();

   //func readFile in project_load.h
   QString line = readFile(fileName);

   //read all data into MatrixData,
   matrixData = getMatirx(line, ui);

   ui->tab_rawdata->hide();
   ui->tab_matrix->show();

   dataPlot();
}

void XTC::dataPlot(){
    //QPushButton *buttonNext = new QPushButton(tr("next"),this);
    //buttonNext->setFixedSize(QSize(50,50));
    //buttonNext->move(500,800);
    //buttonNext->show();
    ui->pushButton_next->show();
    connect(ui->pushButton_next, SIGNAL(clicked(bool)),this, SLOT(buttonNext_clicked()));

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
    connect(ui->paramNext,&QPushButton::clicked,[this](){
        coreItemChecked();});

    connect(ui->paramPrevo,&QPushButton::clicked,[this](){
        coreItemChecked();});


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

        connect(qcbox, &QCheckBox::clicked, [this]() {
            coreItemChecked();});

    }

    ui->groupBoxCore->setLayout(vbox);

    ui->groupBoxCore->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
    ui->groupBox_params->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);


}

void XTC::buttonNext_clicked(){
    //ui->tabWidget->hide();
    ui->tab_matrix->hide();
    ui->tab_plot->show();
    //ui->chart->show();
    //ui->groupBoxCore->show();
    //ui->chart_plot->show();
    //ui->pushButton_next->hide();
    //ui->groupBox_params->show();
    ui->paramNext->clicked();
    ui->stackedWidget->setCurrentIndex(1);
    //ui->buttonNext->move(0,0);
}

void XTC::coreItemChecked(){

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

    float xmax = 0;


    int rows = matrixData.size();

    //vlayout = new QVBoxLayout;

    for (int s=1; s<rows;s++){
        if (std::find(skipCores.begin(),skipCores.end(),s) != skipCores.end()){

        }
        else{
        mdata dat = matrixData[s][paramIndex];
        QStringList yaxset = dat.yaxset;
        //set colors
        QColor color = colors[s];

        line = new QLineSeries;


        //one core data
        for (int i=1; i<dat.x.size();++i){

            if (dat.age[i+1]-dat.age[i]>10){
                t->addSeries(line);
                //t->createDefaultAxes();
                //siglePlot->addSeries(sigline);

                //sigline->setColor(color);
                line->setColor(color);

                line = new QLineSeries;
                //sigline = new QLineSeries;

                //line->append(dat.age[i+1],std::numeric_limits<float>::quiet_NaN());

            }
            else{
                float y = dat.y[i];
                if (yaxset[0]=="G"){
                    y = log10(dat.y[i]);
                    line->append(dat.age[i],y);
                    //sigline->append(dat.age[i],y);
                }
                else{
                    line->append(dat.age[i],y);
                    //sigline->append(dat.age[i],y);
                }
            }
            if (dat.age.back() > xmax){
                xmax = dat.age.back();
            }
        }
        line->setColor(color);
        t->addSeries(line);
        t->createDefaultAxes();
        t->legend()->setVisible(false);

        }
    }


    for (int s=0; s<rows;s++){
        if (std::find(skipCores.begin(),skipCores.end(),s) != skipCores.end()){

        }
        else{

        mdata dat = matrixData[s][paramIndex];
        QStringList yaxset = dat.yaxset;
        QLineSeries *sigline = new QLineSeries();
        charview = new QChartView;

        //add new chart for every plot
        siglePlot = new QChart();
        //siglePlot->createDefaultAxes();

        //set colors
        QColor color = colors[s];

        //set pen
        QPen pen;
        pen.setWidth(2);
        pen.setColor(color);


        //set xaxis
        QValueAxis *axisX = new QValueAxis;
        QValueAxis *axisY = new QValueAxis;

        axisY->setLabelFormat("");

        axisX->setRange(0, xmax);
        axisX->applyNiceNumbers();
        axisX->setMinorTickCount(10);
        if (s < rows-1){
            axisX->setLabelFormat(" ");
            charview->scale(0.976,1);
        }
        if (s == 0){
            charview->scale(1,1);
        }


        //one core data
        for (int i=1; i<dat.x.size();++i){

            if (dat.age[i+1]-dat.age[i]>10){
                siglePlot->addSeries(sigline);
                siglePlot->setAxisX(axisX, sigline);

                sigline->setPen(pen);
                sigline = new QLineSeries;

            }
            else{
                float y = dat.y[i];
                if (yaxset[0]=="G"){
                    y = log10(dat.y[i]);
                    sigline->append(dat.age[i],y);
                }
                else{
                    sigline->append(dat.age[i],y);
                }
            }
        }

        sigline->setPen(pen);

        siglePlot->addSeries(sigline);

        siglePlot->setAxisX(axisX, sigline);


        siglePlot->legend()->setVisible(false);
        siglePlot->setBackgroundBrush(Qt::transparent);
        //siglePlot->axisX()->setVisible(false);
        //siglePlot->axisY()->setVisible(false)


        charview->setChart(siglePlot);
        charview->setBackgroundBrush(Qt::transparent);
        charview->setStyleSheet("background-color: transparent");
        charview->setRubberBand(QChartView::HorizontalRubberBand);
        //charview->adjustSize();
        //charview->setSizePolicy(QSizePolicy::Preferred,QSizePolicy::Preferred)
        ui->verticalLayoutPlots->addWidget(charview, Qt::AlignLeft, Qt::AlignBottom);


        }

    }

    ui->chart->setChart(t);
    //ui->verticalLayoutPlots->setAlignment(Qt::AlignBottom);
    ui->verticalLayoutPlots->setContentsMargins(0,0,0,100);
}

void XTC::on_paramNext_clicked()
{
    counter++;
}

void XTC::on_paramPrevo_clicked()
{
    counter--;
}

void XTC::on_pBshowOp_clicked()
{
    ui->groupBoxCore->show();
    ui->groupBox_params->show();
    ui->stackedWidget->setCurrentIndex(0);
    ui->page->setStyleSheet("background-color: transparent");
}

void XTC::on_pBhideOp_clicked()
{
    ui->groupBoxCore->hide();
    ui->groupBox_params->hide();
    ui->stackedWidget->setCurrentIndex(1);
}

void XTC::on_actionEdit_Mode_triggered()
{
    ui->tab_plot->hide();
    ui->tab_edit->show();
    editMode();
}

void XTC::on_pBshowOp_E_clicked()
{
    ui->tab_edit->hide();
    ui->tab_plot->show();
    ui->pb_back_edit->show();
    //connect(ui->pBhideOp, SIGNAL(cliked(bool)), SLOT(ui->actionEdit_Mode->triggered();));
    ui->pBhideOp->hide();
    ui->pBshowOp->clicked();
}
//connect(ui->paramNext,&QPushButton::clicked,[this,matrixData](){
//    coreItemChecked(matrixData);});

void XTC::on_pb_back_edit_clicked(bool checked)
{
    on_actionEdit_Mode_triggered();
    ui->pb_back_edit->hide();
}

void XTC::editMode(){

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
    if (ui->verticalLayoutPlots_E->layout() != NULL){
        QLayoutItem *witem;
        while ((witem = ui->verticalLayoutPlots_E->layout()->takeAt(0)) != NULL){
            delete witem->widget();
            delete witem;
        }
    }

    QString tiltle = matrixData[0][paramIndex].params[1];
    t->setTitle(tiltle);

    float xmax = 0;


    int rows = matrixData.size();

    //vlayout = new QVBoxLayout;


    for (int s=0; s<rows;s++){
        if (std::find(skipCores.begin(),skipCores.end(),s) != skipCores.end()){

        }
        else{

        mdata dat = matrixData[s][paramIndex];
        QStringList yaxset = dat.yaxset;
        QLineSeries *sigline = new QLineSeries();
        charview = new QChartView;

        //add new chart for every plot
        siglePlot = new QChart();
        //siglePlot->createDefaultAxes();

        //set colors
        QColor color = colors[s];

        //set pen
        QPen pen;
        pen.setWidth(2);
        pen.setColor(color);


        //set xaxis
        QValueAxis *axisX = new QValueAxis;
        QValueAxis *axisY = new QValueAxis;

        axisY->setLabelFormat("");

        axisX->setRange(0, xmax);
        axisX->applyNiceNumbers();
        axisX->setMinorTickCount(10);
        if (s < rows-1){
            axisX->setLabelFormat(" ");
            charview->scale(0.976,1);
        }
        if (s == 0){
            charview->scale(1,1);
        }


        //one core data
        for (int i=1; i<dat.x.size();++i){

            if (dat.age[i+1]-dat.age[i]>10){
                siglePlot->addSeries(sigline);
                siglePlot->setAxisX(axisX, sigline);

                sigline->setPen(pen);
                sigline = new QLineSeries;

            }
            else{
                float y = dat.y[i];
                if (yaxset[0]=="G"){
                    y = log10(dat.y[i]);
                    sigline->append(dat.age[i],y);
                }
                else{
                    sigline->append(dat.age[i],y);
                }
            }
        }

        sigline->setPen(pen);

        siglePlot->addSeries(sigline);

        siglePlot->setAxisX(axisX, sigline);


        siglePlot->legend()->setVisible(false);
        siglePlot->setBackgroundBrush(Qt::transparent);
        //siglePlot->axisX()->setVisible(false);
        //siglePlot->axisY()->setVisible(false)


        charview->setChart(siglePlot);
        charview->setBackgroundBrush(Qt::transparent);
        charview->setStyleSheet("background-color: transparent");
        //charview->adjustSize();
        //charview->setSizePolicy(QSizePolicy::Preferred,QSizePolicy::Preferred)
        ui->verticalLayoutPlots_E->addWidget(charview, Qt::AlignLeft, Qt::AlignBottom);


        }

    }

    //ui->verticalLayoutPlots->setAlignment(Qt::AlignBottom);
    ui->verticalLayoutPlots_E->setContentsMargins(0,0,0,100);
}

void XTC::on_paramPrevo_E_clicked()
{
    counter--;
    editMode();
}

void XTC::on_paramNext_E_clicked()
{
    counter++;
    editMode();
}


void XTC::on_actionCore_Mode_triggered()
{
    ui->tab_edit->hide();
    ui->tab_plot->show();
}

