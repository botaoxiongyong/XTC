#include "dataload.h"

//Q_DECLARE_METATYPE(QAbstractSeries *)
//Q_DECLARE_METATYPE(QAbstractAxis *)

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


void DataLoad::plot_index(int i){
    m_index = i;
}

void DataLoad:: setXyVect(QAbstractSeries *series){
    m_xy.clear();
    qDebug()<<m_index;

    qDebug() << m_xvec.length();
    auto max = std::max_element(m_yvec.begin(), m_yvec.end());
    //qreal ymax = ;
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    QVectorIterator<double> x(m_xvec);
    QVectorIterator<double> y(m_yvec);
    while (x.hasNext()) {
        xySeries->append(x.next(),y.next());
    }

    /*
    for (int t=0;t< m_xvec.length();t++){
        xySeries->append(m_xvec[t],m_yvec[t]);
    }
    */
}
