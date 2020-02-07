#include "dataload.h"
#include "interp_func.h"

DataLoad::DataLoad(QObject *parent):
    QObject(parent)
{
    //m_error_list.append("error message");
}

QString DataLoad::filePrj()
{
    //qDebug() << m_sLine;
    return m_filePrj;
}

void DataLoad::setFilePrj(const QString &filePrj)
{
    if (filePrj == m_filePrj)
        return;

    m_filePrj = filePrj;
    m_error_list = QStringList(); //has to be initialised every time
    emit filePrjChanged();
    //qDebug() << filePrj;
    //qDebug() << m_filePrj;
    //qDebug() << m_error_list;

    if (m_filePrj != "") {
        dataMatrix(filePrj);
    }
}



QStringList DataLoad::error_list() {
    //qDebug() << m_error_list;
    return m_error_list;
}

void DataLoad::setError_list(const QStringList &errorlist){
    m_error_list = errorlist;
    emit error_listChanged();
}

QString DataLoad::readFile(const QString &filePrj){
    QString fileName = filePrj;
    QFile file(fileName.replace("file://",""));

    if (file.exists()==false or !file.open(QIODevice::ReadOnly)==true){
        //qDebug() << file.fileName() +":    "+ file.errorString();
        m_error_list.append(file.fileName() +":    "+ file.errorString());
        return "";
    }
    else {
        QTextStream in(&file);
        QString line;

        while (!in.atEnd()){
            line.append(in.readLine()+"\n");
        }
        file.close();
        return line;
    }
}

void DataLoad::dataMatrix(const QString &filePrj){
    QString line = readFile(m_filePrj);

    QStringList lines = line.split("#####################################");

    QString header = lines[0].replace("\\\n","\n");
    QStringList headers = header.split("####---------------");
    QStringList head = headers[0].split(QRegExp("(\\s+|\n)"), QString::SkipEmptyParts);

    //NDS = number of cores, including reference core
    //NPC = number of params
    int NDS,NPC;
    NDS = head[1].toInt();
    NPC = head[3].toInt();


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
        m_paramList.append(i.replace("CP ",""));
    }

    //matrix of file path
    std::vector<std::vector<QString>> matrixCore(size_t(NDS), std::vector<QString>(size_t(NPC+1)));
    //reference data file path
    matrixCore[0][0] = "Refer Data";
    m_coreList.append(matrixCore[0][0]);
    QStringList referFilePath = lines.filter(QRegExp("(FR|GR)"))[0].split("\n", QString::SkipEmptyParts).filter(QRegExp("(FR|GR)"));
    for (int m=1;m<NPC+1;m++){
        //qDebug() << referFilePath[m-1].split(QRegExp("(\\s+)"))[1];
        //QStringList referFile = referFilePath[m-1].split("\n");
        matrixCore[0][size_t(m)] = referFilePath[m-1].split(QRegExp("(\\s+)"))[1];
    }


    //every core are sperated by their age model file
    QStringList coreFileList = lines.filter("GC");
    //GC: age model
    n=1;
    for (QString &coreLines: coreFileList){
        QStringList ageFile = coreLines.split("\n").filter(".ages");
        QStringList dataFile = coreLines.split("\n").filter(QRegExp("(GP|FP)"));
        matrixCore[size_t(n)][0] = ageFile[0];
        m_coreList.append(ageFile[0].replace(".ages",""));

        for (int m=1; m<=NPC; m++){
            //matrixCore[0][m] = coreParam[m-1].replace("CP ","");
            matrixCore[size_t(n)][size_t(m)] = dataFile[m-1];            }
        n++;
    //qDebug() << matrixCore;
    }


    //#-------------------------------------
    QFileInfo d = QFileInfo(m_filePrj);
    QString projName = d.fileName();
    QString dataPath = d.filePath().replace("file://","").replace(d.fileName(),"");//d.absoluteFilePath().replace("file://","");

    //qDebug() << d.filePath().replace(d.fileName(), "");

    std::vector<std::vector<mdata>> matrixData(size_t(NDS), std::vector<mdata>(size_t(NPC+1)));
    std::vector<std::vector<QString>>::iterator row;
    std::vector<QString>::iterator col;

    //==================================read y aixs settings
    //qDebug() << fileName;
    QFile yaxisSet(dataPath+projName+".yrr");
    if (yaxisSet.exists()==false or !yaxisSet.open(QIODevice::ReadOnly)){
        //qDebug() << yaxisSet.fileName() +":    "+ yaxisSet.errorString();
        m_error_list.append(yaxisSet.fileName() +":    "+ yaxisSet.errorString());
        //return;
    }
    else{
        QTextStream yaxiss(&yaxisSet);
        QStringList yaxsettings;
        while (!yaxiss.atEnd()){
            QString line = yaxiss.readLine();
            yaxsettings.append(line);
            //qDebug() << line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
        }
        //==================================read yaxis into data matrix
        for (int n=1;n<NPC+1;n++){
            for (int m=0;m<NDS;m++){
                //yaxis file list yaxis settings from column to column
                int index = (n-1)*NDS + m + 1;
                matrixData[size_t(m)][size_t(n)].yaxset = yaxsettings[index].split(QRegExp("(\\s+)"), QString::SkipEmptyParts);
                //qDebug() << matrixCore[size_t(m)][size_t(n)];
                //qDebug() <<matrixData[size_t(m)][size_t(n)].yaxset;
            }
        }
    }

    //firt row = refernece data
    for (int n=1;n<NPC+1;n++){
       std::vector<float> x,y;
       QString fileName = dataPath + matrixCore[0][size_t(n)];
       QFile file(fileName);
       //qDebug() << fileName;

       if (!file.open(QIODevice::ReadOnly)){
           //qDebug() << file.fileName() +":   "+ file.errorString();
           m_error_list.append(file.fileName() +":   "+ file.errorString());
       }

       QTextStream in(&file);
       //QList<QPointF> lines;
       while (!in.atEnd()) {
           QString line = in.readLine();
           QStringList lineData = line.replace("\n","").split(QRegExp("(\\s+)"), QString::SkipEmptyParts);
           lineData.removeAll(QString(""));
           //qDebug() << lineData;
           if (lineData.size() ==2 ){
             x.push_back(lineData[0].toFloat());
             y.push_back(lineData[1].toFloat());
             //lines.append(QPointF(lineData[0].toFloat(),
             //             lineData[1].toFloat()));
           }
       }

       QStringList params;
       params.append(refParam[size_t(n-1)]);
       params.append(coreParam[size_t(n-1)]);

       matrixData[0][size_t(n)].x = x;
       matrixData[0][size_t(n)].y = y;
       matrixData[0][size_t(n)].params = params;
       //matrixData[0][size_t(n)].lineXY = lines;
    }

    //qDebug() << "row finished";


    //first column = age models
    for (int m=1;m<NDS;m++){
        std::vector<float> depth,age;
        //read age model data, skip first row
        //QString agemodel = matrixCore[m][0];
        QString fileName = dataPath + matrixCore[size_t(m)][0].replace("GC ","");
        QFile file(fileName);
        if (!file.open(QIODevice::ReadOnly)){
            //qDebug() << file.fileName() +":   "+ file.errorString();
            m_error_list.append(file.fileName() +":   "+ file.errorString());
        }

        QTextStream in(&file);

        //qDebug() << fileNa;
        //QList<QPointF> lines;
        while (!in.atEnd()) {
            QString line = in.readLine();
            QStringList lineData = line.replace("\n","").split(QRegExp("\\s+"), QString::SkipEmptyParts);
            lineData.removeAll(QString(""));
            //qDebug() << lineData[0];
            depth.push_back(lineData[0].toFloat());
            age.push_back(lineData[1].toFloat());
            //lines.append(QPointF(lineData[0].toFloat(),
            //             lineData[1].toFloat()));
        }

        matrixData[size_t(m)][0].x = depth;
        matrixData[size_t(m)][0].y = age;
        //matrixData[size_t(m)][0].lineXY = lines;
    }


    int m=0;
    for (row=matrixCore.begin(); row != matrixCore.end(); row++){
        n = 0;
        std::vector<float> depth,age,newage;
        for (col=row->begin(); col != row-> end(); col++){

            depth = matrixData[size_t(m)][0].x;
            age = matrixData[size_t(m)][0].y;



            QString fileNa = *col;
            //qDebug() << n;


            if (fileNa.contains("NO_DATA", Qt::CaseSensitive)){
            //pass
                //QList<QPointF> lines;
                //matrixData[size_t(m)][size_t(n)].lineXY = lines;
            }
            else{
            if (fileNa.contains("FP", Qt::CaseSensitive)){
                //"FP" mark data file only has two column
                QString fileName = dataPath+fileNa.replace("FP ","");
                //qDebug() << fileName;
                QFile file(fileName);
                if (!file.open(QIODevice::ReadOnly)){
                    //qDebug() << file.fileName() +":   "+ file.errorString();
                    m_error_list.append(file.fileName() +":   "+ file.errorString());
                    //pass
                }
                QTextStream in(&file);
                std::vector<float> x,y;
                //QList<QPointF> lines;
                while (!in.atEnd()){
                     QString line = in.readLine();
                     QStringList lineData = line.replace("\n","").replace("\\s+",",").split(QRegExp("\\s+"), QString::SkipEmptyParts);
                     if (lineData.size() ==2 ){
                        //if two columns is ture
                        x.push_back(lineData[0].toFloat());
                        y.push_back(lineData[1].toFloat());
                        //lines.append(QPointF(lineData[0].toFloat(),
                        //             lineData[1].toFloat()));
                    }
                }

                newage = interp1(depth,age,x);

                matrixData[size_t(m)][size_t(n)].x = x;
                matrixData[size_t(m)][size_t(n)].y = y;
                matrixData[size_t(m)][size_t(n)].age = newage;
                //matrixData[size_t(m)][size_t(n)].lineXY = lines;

            }

            if (fileNa.contains("GP", Qt::CaseSensitive)){
                //data file specify data columns
                QStringList fileConts = fileNa.replace("GP ","").replace("\\s+",",").split(QRegExp("\\s+"));
                //qDebug() << fileConts;
                QString fileName = dataPath+fileConts[0];
                int totalColumns=fileConts[1].toInt(), xColumn=fileConts[2].toInt(), yColumn=fileConts[3].toInt();
                //qDebug() << fileName;
                QFile file(fileName);
                if (!file.open((QIODevice::ReadOnly))){
                //qDebug()<< file.errorString();
                }
                QTextStream in(&file);
                std::vector<float> x,y;
                //QList<QPointF> lines;
                while (!in.atEnd()){
                QString line = in.readLine();
                QStringList lineData = line.replace("\n","").replace("\\s+",",").split(QRegExp("\\s+"), QString::SkipEmptyParts);
                if (lineData.size() ==totalColumns ){
                    //if two columns is ture
                    x.push_back(lineData[xColumn-1].toFloat());
                    y.push_back(lineData[yColumn-1].toFloat());
                    //lines.append(QPointF(lineData[xColumn-1].toFloat(),
                    //             lineData[yColumn-1].toFloat()));
                }
                }
                newage = interp1(depth,age,x);
                matrixData[size_t(m)][size_t(n)].x = x;//depth
                matrixData[size_t(m)][size_t(n)].y = y;//value
                matrixData[size_t(m)][size_t(n)].age = newage;//age
                //matrixData[size_t(m)][size_t(n)].lineXY = lines;

            }

            }
        n++;
        }
    m++;
    }

    m_matrixCore = matrixCore;
    m_matrixData = matrixData;
}
