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

QStringList DataLoad::paramList(){
    //qDebug() << m_paramList;
    return m_paramList;
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


std::vector<float> DataLoad::xvector(){
    //qDebug() << "hello";
    if (m_matrixData.size() != 0){
        /*
        QVector<qreal> xtemp,ytemp;
        //double temp = ::m_matrixData[m_coreIn][m_paraIn].x.toDouble();
        std::vector<float> tempx = m_matrixData[m_coreIn][m_paraIn].x;
        for (auto const &value: tempx){
            xtemp.push_back(double(value));
        }
        */
        m_xvec = m_matrixData[m_coreIn][m_paraIn].x;
        return m_xvec;
    }
}


std::vector<float> DataLoad::yvector(){
    if (m_matrixData.size() != 0){
        /*
        QVector<qreal> ytemp;
        //qDebug() << m_coreIn,m_paraIn;
        std::vector<float> tempy = m_matrixData[m_coreIn][m_paraIn].y;
        for (auto const &value: tempy){
            ytemp.push_back(double(value));
        }
        */
        m_yvec = m_matrixData[m_coreIn][m_paraIn].y;
        return m_yvec;
    }
}


std::vector<float> DataLoad::axRange(){
    return m_axrange;
}


void DataLoad::plot_index(int i){
    m_index = i;
}

void DataLoad:: setXyVect(QAbstractSeries *series,int coreIndex,int paraIndex){
    m_xy.clear();
    //m_xvec = m_matrixData[m_coreIn][m_paraIn].x;
    //m_yvec = m_matrixData[m_coreIn][m_paraIn].y;

    mdata matrix = m_matrixData[coreIndex][paraIndex];

    if (matrix.y.size()>0){
        auto max = std::max_element(matrix.y.begin(),matrix.y.end());
        auto min = std::min_element(matrix.y.begin(),matrix.y.end());

        float ymax=max[0]-min[0];

        /*
        if (-1*min[0]>max[0]){
            ymax = -1*min[0];
            m_index = m_index+1;
        }else{
            ymax = max[0];
        }
        */

        QXYSeries *xySeries = static_cast<QXYSeries *>(series);

        if (coreIndex==0){
            for (int t=0;t< matrix.x.size();t++){
                xySeries->append(matrix.x[t],(matrix.y[t]-min[0])/ymax+m_index);
            }
        }
        else{
            for (int t=0;t< matrix.age.size();t++){
                xySeries->append(matrix.age[t],(matrix.y[t]-min[0])/ymax+m_index);
            }
        }



        //qDebug()<<"tt";
        //xySeries->append(matrix.lineXY);
    }
}

void DataLoad:: editXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,int coreCount){
    m_xy.clear();
    //m_xvec = m_matrixData[m_coreIn][m_paraIn].x;
    //m_yvec = m_matrixData[m_coreIn][m_paraIn].y;
    std::vector<float> agepoints;
    mdata matrix = m_matrixData[coreIndex][paraIndex];
    agepoints = m_matrixData[coreIndex][0].y;

    if (matrix.y.size()>0){
        auto max = std::max_element(matrix.y.begin(),matrix.y.end());
        auto min = std::min_element(matrix.y.begin(),matrix.y.end());

        float ymax=max[0]-min[0];

        /*
        if (-1*min[0]>max[0]){
            ymax = -1*min[0];
            m_index = m_index+1;
        }else{
            ymax = max[0];
        }
        */

        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
        xySeries->setColor("lightgrey");

        if (coreIndex==0){
            for (int t=0;t< matrix.x.size();t++){
                xySeries->append(matrix.x[t],(matrix.y[t]-min[0])/ymax+m_index);
            }
        }
        else{
            for (int t=0;t< matrix.age.size();t++){
                xySeries->append(matrix.age[t],(matrix.y[t]-min[0])/ymax+m_index);
            }
        }

        connect(xySeries,&QXYSeries::doubleClicked,this,&DataLoad::lineChangeColor);

        //qDebug()<<"tt";
        //xySeries->append(matrix.lineXY);
    }
}

void DataLoad::lineChangeColor(const QPointF &point){
    qDebug()<<"test";
}
