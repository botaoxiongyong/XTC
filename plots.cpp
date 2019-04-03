#include "dataload.h"


std::vector<std::vector<QString>> DataLoad::mCore(){
    return m_matrixCore;
}

void DataLoad::setMCore(std::vector<std::vector<QString>> &mCore){
    return;
}

std::vector<std::vector<mdata>> DataLoad::mDatam(){
    return m_matrixData;
}

void DataLoad::setMDatam(std::vector<std::vector<mdata>> &mDatam){

}

QStringList DataLoad::coreList(){
    return m_coreList;
}

int DataLoad::coreIndex(){
    return m_coreIn;
}

void DataLoad::setCoreIndex(int &coreIndex){

    //qDebug() << coreIndex;
    //connect(this, SIGNAL(coreIndexChanged(int)),this,SLOT(dataByIndex(int)));
    m_coreIn = coreIndex;
    emit coreIndexChanged(m_coreIn);

}

int DataLoad::paraIndex(){
    return m_paraIn;
}

void DataLoad::setParaIndex(int &paraIndex){
    m_paraIn = paraIndex;
    emit paraIndexChanged();
}


QVector<qreal> DataLoad::xvector(){
    //qDebug() << "hello";
    if (m_matrixData.size() != 0){
        QVector<qreal> xtemp,ytemp;
        //double temp = ::m_matrixData[m_coreIn][m_paraIn].x.toDouble();
        std::vector<float> tempx = m_matrixData[m_coreIn][m_paraIn].x;
        for (auto const &value: tempx){
            xtemp.push_back(double(value));
        }
        m_xvec = xtemp;
        return m_xvec;
    }
}


QVector<qreal> DataLoad::yvector(){
    if (m_matrixData.size() != 0){
        QVector<qreal> ytemp;
        //qDebug() << m_coreIn,m_paraIn;
        std::vector<float> tempy = m_matrixData[m_coreIn][m_paraIn].y;
        for (auto const &value: tempy){
            ytemp.push_back(double(value));
        }
        m_yvec = ytemp;
        return m_yvec;
    }
}


QVector<qreal> DataLoad::axRange(){
    return m_axrange;
}

QLineSeries* DataLoad::xy()
{
    return m_xy;
}
void DataLoad::setXy(QLineSeries *xy)
{
    if(m_xy == xy) return;
    if(m_xy){
        for (int i=0; i<m_xvec.count();i++){
            m_xy->append(m_xvec[i],m_yvec[i]);
        }
    }
        //
    m_xy = xy;
    emit xyChanged();
}

