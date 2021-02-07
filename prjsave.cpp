#include "dataload.h"

void DataLoad::fileExist(QString filePath){
    //========================================
    //xtc .xtci file exit?
    if(QFileInfo::exists(filePath.replace("file://",""))){
        creatMatrix();
        //qDebug() << "system defaul warining";

        //add new function to open it
        QString line;

        QFile file(filePath.replace("file://",""));

        if (file.exists()==false or !file.open(QIODevice::ReadOnly)==true){
            //qDebug() << file.fileName() +":    "+ file.errorString();
            m_error_list.append(file.fileName() +":    "+ file.errorString());
            //return "";
        }
        else {
            QTextStream in(&file);


            while (!in.atEnd()){
                line.append(in.readLine()+"\n");
            }
            file.close();
            //return line;
        }

        QStringList lines = line.split(QRegExp("#################*"));

        QString header = lines[0].replace("\\\n","\n");
        QStringList headers = header.split(QRegExp("####---------*"));
        QStringList head = headers[0].split(QRegExp("(\\s+|\n)"), QString::SkipEmptyParts);

        //NDS = number of cores, including reference core
        //NPC = number of params
        int NDS,NPC;
        NDS = head[1].toInt();
        NPC = head[3].toInt();
        m_rows = NDS+3;
        m_cols = NPC+2;


        //reference param names
        std::vector<QString> refParam;
        int n = 0;
        QStringList params = headers[1].split("\n", QString::SkipEmptyParts).filter("CR");
        //qDebug() << params;
        for (int n=0;n<params.count();n++){

            //refParam.push_back(i);
            m_matrixCore[0][n+2] = params[n];
            //n++;
        }
        //params.clear();

        //qDebug() << refParam;

        //core param names
        std::vector<QString> coreParam;
        n = 0;
        QStringList paramsCore = headers[2].split("\n", QString::SkipEmptyParts).filter("CP");
        for (int n=0;n<paramsCore.count();n++){
            //n++;
            //coreParam.push_back(i);
            m_matrixCore[2][n+2] = paramsCore[n];
            //m_paramList.append(i.replace("CP ",""));
        }

        QStringList referFilePath = lines[1].split("\n", QString::SkipEmptyParts).filter(QRegExp("(FR|GR)"));
        QStringList coreFileList = lines.filter("GC");
        //GC: age model
        for (int n=0;n<coreFileList.count();n++){
            QString coreLines = coreFileList[n];
            //QStringList ageFile = coreLines.split("\n").filter("GC");
            //qDebug() << coreLines.split("\n").filter("GC");
            m_matrixCore[n+3][1] = coreLines.split("\n").filter("GC")[0];
            QStringList dataFiles = coreLines.split("\n").filter(QRegExp("(GP|FP)"));
            //qDebug() << dataFiles;
            for (int i=0;i<paramsCore.count();i++){

                m_matrixCore[n+3][i+2] = dataFiles[i];
            }
            //
            //qDebug() << coreLines.split("\n").filter(QRegExp("(GP|FP)"));
            //n++;
        }
        //return;
    }
    else{
        qDebug() << filePath;
        qDebug() << "no exist";
        QFile file(filePath.replace("file://",""));
        if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "" << endl;
            }
        file.close();
    }

    //set private value for save data to this filePath
    m_filePrj = filePath;
    //========================================
    //xtc .yrr file exist?
    QString fileYrr = filePath.replace(".xtci",".yrr");
    if(QFileInfo::exists(fileYrr)){
        //qDebug() << "system defaul warining";

        //add new function to open it
        //return;
    }
    else{
        qDebug() << fileYrr;
        qDebug() << "no exist";
        QFile file(fileYrr.replace("file://",""));
        if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "" << endl;
            }
        file.close();
    }
}

void DataLoad::creatMatrix(){
    //qDebug() << m_matrixCore.size();
    int NDS=50;
    int NPC=50;
    std::vector<std::vector<QString>> matrixCore(size_t(NDS), std::vector<QString>(size_t(NPC+1)));

    matrixCore[0][0] = "refer param";
    matrixCore[0][1] = "";
    matrixCore[0][2] = "param1";
    matrixCore[1][0] = "refer data";
    matrixCore[2][0] = "core param";
    matrixCore[2][1] = "Age model";
    matrixCore[2][2] = "param1";
    matrixCore[3][0] = "core1";

    m_matrixCore = matrixCore;

    return;
}

void DataLoad::coreMaxtrix(int row, int col, QString filePath){
    m_matrixCore[row][col] = filePath;
    //qDebug() << m_matrixCore[row][col];
    //std::vector<std::vector<QString>> matrixCore(size_t(NDS), std::vector<QString>(size_t(NPC+1)));
}

QString DataLoad::getMaxtrixValue(int row, int col){
    //qDebug() << m_matrixCore[row][col];
    return m_matrixCore[row][col];
}

QString DataLoad::filePreview(QString filePath){
    QString fileName = filePath;
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

void DataLoad::saveXTCproject(int coreNs,int paramNs){
    qDebug() << QVariant(coreNs).toString();
    qDebug() << paramNs;

    QFile file(m_filePrj.replace("file://",""));
    if (file.open(QIODevice::ReadWrite)) {
            QTextStream stream(&file);
            stream << "NDS  "+QVariant(coreNs).toString()+" NPC  "+QVariant(paramNs).toString()<< endl;
            stream << "####--------------------------------------------------------"<< endl;
            stream << "#### "+QVariant(paramNs).toString()+" comments on reference data :"<< endl;
            for(int i=0;i<paramNs;i++){
                stream << "CR "+m_matrixCore[0][2+i]+" \\"<< endl;
            }
            stream << "####--------------------------------------------------------"<< endl;
            stream << "#### "+QVariant(paramNs).toString()+" comments on parameters to correlate :"<< endl;
            for(int i=0;i<paramNs;i++){
                stream << "CP "+m_matrixCore[2][2+i]+" \\"<< endl;
            }
            stream << "############################################################"<< endl;
            stream << "########  9 blocks with data files :"<< endl;
            stream << "####--------------------------------------------------------"<< endl;
            stream << "#### "+QVariant(paramNs).toString()+" file names for reference data :"<< endl;
            for(int i=0;i<paramNs;i++){
                stream << m_matrixCore[1][2+i]<< endl;
            }
            for(int i=0;i<coreNs;i++){
                stream << "############################################################"<< endl;
                stream << "#### data set "+QVariant(i+1).toString()+" for correlation :"<< endl;
                stream << "####--------------------------------------------------------"<< endl;
                stream << m_matrixCore[3+i][1]<< endl;
                stream << "####--------------------------------------------------------"<< endl;
                for(int t=0;t<coreNs;t++){
                        stream << m_matrixCore[3+i][2+t]<< endl;
                    }
            }


            stream << "############################################################"<< endl;
            stream << "####    This file has been created using   xtc-qt    ####"<< endl;
            stream << "############################################################"<< endl;
            qDebug()<<m_matrixCore[1];
            qDebug()<<m_matrixCore[3];
        }
    file.close();
}

int DataLoad::getRowNum(){
    return m_rows;
}
int DataLoad::getColNum(){
    return m_cols;
}
