#include "dataload.h"

//Q_DECLARE_METATYPE(QAbstractSeries *)
//Q_DECLARE_METATYPE(QAbstractAxis *)

QStringList DataLoad::coreList(){
    return m_coreList;
}

QStringList DataLoad::paramList(){
    //m_paramList was created in dataload.cpp when reading data file
    return m_paramList;
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

void DataLoad:: editXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,int cInd){
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
        //xySeries->setColor("lightgrey");

        if (coreIndex==0){
            for (int t=0;t< matrix.x.size();t++){
                xySeries->append(matrix.x[t],(matrix.y[t]-min[0])/ymax+m_index);
            }
            xySeries->setColor("blue");
        }else{
            for (int t=0;t< matrix.age.size();t++){
                xySeries->append(QPointF(matrix.age[t],(matrix.y[t]-min[0])/ymax+m_index));
            }
        }
    }
}

void DataLoad::ageLines(QAbstractSeries *series, int cInd, int coreCount){
    std::vector<float> agepoints;
    agepoints = m_matrixData[cInd][0].y;
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    for (int t=0;t< agepoints.size();t++){
        xySeries->append(QPointF(agepoints[t],0));
        xySeries->append(QPointF(agepoints[t],coreCount));
        xySeries->append(QPointF(agepoints[t],NULL));
    }
}

