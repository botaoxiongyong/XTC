#include "dataload.h"
#include "interp_func.h"

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
    //qDebug()<<m_matrixData[1][0].x.size();
    qDebug() << coreIndex;
    qDebug() << size_t(coreIndex);
    m_xy.clear();
    double minn,maxx,yinterv;
    mdata matrix = m_matrixData[size_t(coreIndex)][size_t(paraIndex)];

    minn = matrix.yaxset[3].toDouble();
    maxx = matrix.yaxset[2].toDouble();
    yinterv = maxx-minn;


    if (matrix.y.size()>0){
        //auto max = std::max_element(matrix.y.begin(),matrix.y.end());
        //auto min = std::min_element(matrix.y.begin(),matrix.y.end());
        auto mean = std::accumulate(matrix.y.begin(),matrix.y.end(),0.0)/matrix.y.size();

        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
    //===============================normalize all data and plot by sequences!!!
        if (coreIndex==0){
            for (int t=0;size_t(t)< matrix.x.size();t++){
                xySeries->append(static_cast<double>(matrix.x[size_t(t)]),static_cast<double>(matrix.y[size_t(t)])/yinterv- mean/yinterv);
            }
        }
        else{
            for (int t=0;size_t(t)< matrix.age.size();t++){
                xySeries->append(static_cast<double>(matrix.age[size_t(t)]),static_cast<double>(matrix.y[size_t(t)])/yinterv - mean/yinterv-coreIndex);
            }
        }
    }
}
/*
void DataLoad:: editXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,int cInd){
    m_xy.clear();
    float minn,maxx,yinterv;
    mdata matrix = m_matrixData[coreIndex][paraIndex];

    minn = matrix.yaxset[3].toFloat();
    maxx = matrix.yaxset[2].toFloat();
    yinterv = maxx-minn;


    if (matrix.y.size()>0){
        //auto max = std::max_element(matrix.y.begin(),matrix.y.end());
        //auto min = std::min_element(matrix.y.begin(),matrix.y.end());
        auto mean = std::accumulate(matrix.y.begin(),matrix.y.end(),0.0)/matrix.y.size();

        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
    //===============================normalize all data and plot by sequences!!!
        if (coreIndex==0){
            for (int t=0;t< matrix.x.size();t++){
                xySeries->append(matrix.x[t],matrix.y[t]/yinterv- mean/yinterv);
            }
        }
        else{
            for (int t=0;t< matrix.age.size();t++){
                xySeries->append(matrix.age[t],matrix.y[t]/yinterv - mean/yinterv-coreIndex);
            }
        }
    }
}
*/
void DataLoad::ageLines(QAbstractSeries *series, int cInd, int coreCount){
    m_coreIndex = cInd;
    std::vector<float> agepoints;
    agepoints = m_matrixData[size_t(cInd)][0].y;
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    //qDebug()<<cInd;

    for (int t=0;size_t(t)<=agepoints.size();t++){
        xySeries->append(QPointF(static_cast<double>(agepoints[size_t(t)]),1));
        xySeries->append(QPointF(static_cast<double>(agepoints[size_t(t)]),-1*coreCount));
        xySeries->append(QPointF(static_cast<double>(agepoints[size_t(t)]),static_cast<double>(NULL)));
        xySeries->append(QPointF(static_cast<double>(agepoints[size_t(t)]),1));
    }
}

void DataLoad::ageChange(float age1, float age2){
    int c = 0;
    //float depth;
    std::vector<float> agepoints,newage,depth,newdepth;
    agepoints = m_matrixData[size_t(m_coreIndex)][0].y;
    depth = m_matrixData[size_t(m_coreIndex)][0].x;
    //depth = m_matrixData[m_coreIndex][0].x;
    qDebug()<<m_coreIndex;

    for (int t=0;size_t(t)< agepoints.size();t++){
        if (age1<=agepoints[size_t(t)]){
            //qDebug()<<agepoints[t];
            c = t;
            break;
        }
    }

    //qDebug()<<agepoints;
    //qDebug()<<agepoints[c-1];
    if ((age2<=agepoints[size_t(c)]) && (age2>=agepoints[size_t(c-1)])){
        qDebug()<<"true";

        newage.push_back(age1);
        newdepth = interp1(agepoints,depth,newage);

        agepoints.insert(agepoints.begin()+c,age2);
        depth.insert(depth.begin()+c,newdepth[0]);

        m_matrixData[size_t(m_coreIndex)][0].y = agepoints;//.insert(agepoints.begin()+c,age2);
        m_matrixData[size_t(m_coreIndex)][0].x = depth;//.insert(agepoints.begin()+c,depth[0]);
        qDebug()<<m_matrixData[size_t(m_coreIndex)][0].x.size();
    }

    else if((age2>=agepoints[size_t(c)]) or (age2<=agepoints[size_t(c-1)])){
        qDebug()<<"false";
    }
}

