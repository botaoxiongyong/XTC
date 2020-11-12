#include "dataload.h"

void DataLoad::fileExist(QString filePath){

    if(QFileInfo::exists(filePath)){
        //qDebug() << "system defaul warining";
        return;
    }
    else{
        qDebug() << filePath;
        qDebug() << "no exist";
        QFile file(filePath.replace("file://",""));
        if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something" << endl;
            }
        file.close();
    }
}

void DataLoad::creatMatrix(){
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
