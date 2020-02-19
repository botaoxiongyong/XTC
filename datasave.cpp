#include "dataload.h"
#include "interp_func.h"

void DataLoad::save(){
    qDebug() << m_filePrj;
    //std::vector<float> agepoints,newage,depth,newdepth;
    //qDebug() << m_matrixCore[1][0];
    //qDebug() << m_matrixCore.size();
    //================================
    //*.ages file
    //m_matrixData[][].x - depth
    //m_matrixData[][].y - age
    QString filePath;
    float depth,age;
    QFileInfo d = QFileInfo(m_filePrj);
    QString projName = d.fileName();
    QString dataPath = d.filePath().replace("file://","").replace(d.fileName(),"");//d.absoluteFilePath().replace("file://","");


    qDebug() << dataPath;

    for (size_t i = 1; i < m_matrixCore.size(); i++){
        filePath = dataPath + m_matrixCore[i][0];
        QFile file(filePath);
        if ( file.open(QIODevice::ReadWrite | QIODevice::Truncate) ){
            //file.resize(0);
            QTextStream out(&file);
            //qDebug() << filePath;
            for (size_t m = 0; m < m_matrixData[i][0].x.size(); m++){
                depth = m_matrixData[i][0].x[m];
                age = m_matrixData[i][0].y[m];
                //out << QString(m_matrixData[i][0].x[m]);
                out << "    ";
                out << depth;
                out << "       ";
                out << age;
                out << "  ";
                //out << m_matrixData[i][0].y[m];
                out << "\n";
            }
        }
        file.close();
    }
}
