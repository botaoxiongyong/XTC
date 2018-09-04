#include "project_load.h"
#include "xtc.h"
#include "ui_xtc.h"
#include "_cppli.h"

QString readFile(const QString& fileName){
    if (fileName.isEmpty())
        return "None";
    else {

        QFile file(fileName);

        if (!file.open(QIODevice::ReadOnly)){
            //QMessageBox::information(this, tr("unable to open file"),
            //                         file.errorString());
            return "None";
        }

        QTextStream in(&file);
        QString line;

        while (!in.atEnd()){
             line.append(in.readLine()+"\n");
        }


        //read project file and load all the data
        //project_load()


        file.close();

        return line;
    }
}

QString fileNameGet(){
    QStringList filters;
    filters << "XTC files (*.xtci *.xtc *.icc)"
            << "Any files (*)";

    QList<QUrl> urls;
    urls << QUrl::fromLocalFile("~/");

    QFileDialog dialog;

    dialog.setNameFilters(filters);

    dialog.setSidebarUrls(urls);

    QString fileName = dialog.getOpenFileName();

    return fileName;
}

std::vector<std::vector<mdata>> getMatirx(QString& line, Ui::XTC *ui){

    //QMainWindow *ui = XTC::activateWindow();

    QStringList lines = line.split("#####################################");

    QString header = lines[0].replace("\\\n","\n");
    QStringList headers = header.split("####---------------");
    QStringList head = headers[0].split(QRegExp("(\\s+|\n)"), QString::SkipEmptyParts);

    //NDS = number of cores, including reference core
    //NPC = number of params
    int NDS,NPC;
    NDS = head[1].toFloat();
    NPC = head[3].toFloat();


    //reference param names
    std::vector<QString> refParam;
    int n = 0;
    QStringList params = headers[1].split("\n", QString::SkipEmptyParts).filter("CR");
    for (QString& i :params){
        n++;
        refParam.push_back(i);
    }
    params.clear();


    //core param names
    std::vector<QString> coreParam;
    n = 0;
    QStringList paramsCore = headers[2].split("\n", QString::SkipEmptyParts).filter("CP");
    for (QString& i:paramsCore){
        n++;
        coreParam.push_back(i);
    }

    //matrix of file path
    std::vector<std::vector<QString>> matrixCore(NDS, std::vector<QString>(NPC+1));
    //reference data file path
    QStringList referFilePath = lines.filter(QRegExp("(FR|GR)"))[0].split("\n", QString::SkipEmptyParts).filter(QRegExp("(FR|GR)"));
    //qDebug() << referFilePath;
    for (int m=1;m<NPC+1;m++){
        //qDebug() << referFilePath[m-1].split(QRegExp("(\\s+)"))[1];
        //QStringList referFile = referFilePath[m-1].split("\n");
        matrixCore[0][m] = referFilePath[m-1];//.split(QRegExp("(\\s+)"))[1];
    }


    //every core are sperated by their age model file
    QStringList coreFileList = lines.filter("GC");
    //GC: age model
    n=1;
    ui->tableWidget_matrix->setRowCount(NDS);
    ui->tableWidget_matrix->setColumnCount(NPC+1);
    for (QString &coreLines: coreFileList){
        QStringList ageFile = coreLines.split("\n").filter(".ages");
        QStringList dataFile = coreLines.split("\n").filter(QRegExp("(GP|FP)"));
        matrixCore[n][0] = ageFile[0];
        ui->tableWidget_matrix->setItem(n,0,QTableWidgetItem(ageFile[0]).clone());

        for (int m=1; m<=NPC; m++){
            //matrixCore[0][m] = coreParam[m-1].replace("CP ","");
            matrixCore[n][m] = dataFile[m-1];
            ui->tableWidget_matrix->setItem(0,m,QTableWidgetItem(coreParam[m-1].replace("CP ","")).clone());
            ui->tableWidget_matrix->setItem(n,m,QTableWidgetItem(dataFile[m-1]).clone());
        }
        n++;
    }


    //ui->textBrowser_xtci->setText();


    //#-------------------------------------

    QString dataPath = "/Users/pro/Documents/Qt/QT_practice/PS_XTC/";
    std::vector<std::vector<mdata>> matrixData(NDS, std::vector<mdata>(NPC+1));
    std::vector<std::vector<QString>>::iterator row;
    std::vector<QString>::iterator col;

    ui->textBrowser_xtci->setText(dataPath);
    ui->textBrowser_xtci->append("yrr file");

    //read y aixs settings
    //qDebug() << dataPath+"SEP_DP.xtci"+".yrr";
    QFile yaxisSet(dataPath+"SEP_DP.xtci"+".yrr");
    if (!yaxisSet.open(QIODevice::ReadOnly)){
        //qDebug() << yaxisSet.errorString();
    }
    QTextStream yaxiss(&yaxisSet);
    QStringList yaxsettings;
    while (!yaxiss.atEnd()){
        QString line = yaxiss.readLine();
        yaxsettings.append(line);
        //qDebug() << line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
    }

    for (int n=1;n<NPC+1;n++){
        for (int m=0;m<NDS;m++){
            //yaxis file list yaxis settings from column to column
            int index = (n-1)*NDS + m;
            matrixData[m][n].yaxset = yaxsettings[index].split(QRegExp("(\\s+)"), QString::SkipEmptyParts);
        }
    }


    //add params, for references and cores
    for (int n=1;n<NPC+1;n++){
       QStringList params;
       params.append(refParam[n-1]);
       params.append(coreParam[n-1]);
       matrixData[0][n].params = params;
    }


    //qDebug() << "row finished";


    //first column = age models
    for (int m=1;m<NDS;m++){
        std::vector<float> depth,age;
        //read age model data, skip first row
        //first row = reference data, have no age models
        //QString agemodel = matrixCore[m][0];
        QString fileName = dataPath + matrixCore[m][0].replace("GC ","");

        ui->textBrowser_xtci->append(fileName);

        QFile file(fileName);
        if (!file.open(QIODevice::ReadOnly)){
            qDebug() << file.errorString();
        }

        QTextStream in(&file);

        //qDebug() << fileNa;

        while (!in.atEnd()) {
            QString line = in.readLine();
            QStringList lineData = line.replace("\n","").split(QRegExp("\\s+"), QString::SkipEmptyParts);
            lineData.removeAll(QString(""));
            //qDebug() << lineData[0];
            depth.push_back(lineData[0].toFloat());
            age.push_back(lineData[1].toFloat());
        }

        matrixData[m][0].x = depth;
        matrixData[m][0].y = age;
        matrixData[m][0].coreName = matrixCore[m][0].replace("GC ","");
    }


    //qDebug() << matrixCore[0][1];
    int m=0;
    for (row=matrixCore.begin(); row != matrixCore.end(); row++){
        n = 0;
        std::vector<float> depth,age,newage;
        for (col=row->begin(); col != row-> end(); col++){

            //read the first column as age models
            depth = matrixData[m][0].x;
            age = matrixData[m][0].y;

            //read file name
            QString fileNa = *col;


            if (fileNa.contains("NO_DATA", Qt::CaseSensitive)){
            //pass
            }
            else{
            if (fileNa.contains(QRegExp("(FP|FR)"))){
                //qDebug() << fileNa;
                //"FP" mark data file only has two column
                QString fileName = dataPath+fileNa.replace(QRegExp("(FP |FR )"),"");

                //qDebug() << fileName;
                ui->textBrowser_xtci->append(fileName);

                QFile file(fileName);
                if (!file.open(QIODevice::ReadOnly)){
                    qDebug() << file.errorString();
                //pass
                }
                QTextStream in(&file);
                std::vector<float> x,y;
                while (!in.atEnd()){
                     QString line = in.readLine();
                     QStringList lineData = line.replace("\n","").replace("\\s+",",").split(QRegExp("\\s+"), QString::SkipEmptyParts);
                     if (lineData.size() ==2 ){
                        //if two columns is ture
                        x.push_back(lineData[0].toFloat());
                        y.push_back(lineData[1].toFloat());
                    }
                }

                matrixData[m][n].y = y;
                matrixData[m][n].x = x;

                if (m>0){
                    //skip the reference data, which without age models
                    newage = interp1(depth,age,x);
                    matrixData[m][n].age = newage;
                }else{
                    //reference data only have ages
                    matrixData[m][n].age = x;
                }

            }

            if (fileNa.contains(QRegExp("(GP|GR)"))){
                //data file specify data columns
                QStringList fileConts = fileNa.replace(QRegExp("(GP |GR )"),"").replace("\\s+",",").split(QRegExp("\\s+"));
                //qDebug() << fileConts;
                QString fileName = dataPath+fileConts[0];

                ui->textBrowser_xtci->append(fileName);

                int totalColumns=fileConts[1].toInt(), xColumn=fileConts[2].toInt(), yColumn=fileConts[3].toInt();
                //qDebug() << fileName;
                QFile file(fileName);
                if (!file.open((QIODevice::ReadOnly))){
                //qDebug()<< file.errorString();
                }
                QTextStream in(&file);
                std::vector<float> x,y;
                while (!in.atEnd()){
                QString line = in.readLine();
                QStringList lineData = line.replace("\n","").replace("\\s+",",").split(QRegExp("\\s+"), QString::SkipEmptyParts);
                if (lineData.size() ==totalColumns ){
                    //if two columns is ture
                    x.push_back(lineData[xColumn-1].toFloat());
                    y.push_back(lineData[yColumn-1].toFloat());
                }
                }
                matrixData[m][n].y = y;
                matrixData[m][n].x = x;

                if (m>0){
                    //skip the reference data, which without age models
                    newage = interp1(depth,age,x);
                    matrixData[m][n].age = newage;
                }else{
                    //reference data only have ages
                    matrixData[m][n].age = x;
                }
            }

            }
        n++;
        }
    m++;
    }

    //int a=1;

   return matrixData;
}

