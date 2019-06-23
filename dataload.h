#ifndef DATALOAD_H
#define DATALOAD_H


#include <QObject>
#include <QString>
#include <QVector>
#include <QStringList>
#include <QList>
#include <QtCore>
#include <QDebug>
#include <QFile>
#include <QVector>
#include <QPointF>
#include <QList>
#include <QMetaType>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>
using namespace QtCharts;

class mdata {
    Q_GADGET
public:
    std::vector<float> x;
    std::vector<float> y;
    QList<QPointF> lineXY;
    std::vector<float> age;
    QStringList params;
    QStringList yaxset;
};
Q_DECLARE_METATYPE(mdata);
Q_DECLARE_METATYPE(QAbstractSeries *);
Q_DECLARE_METATYPE(QAbstractAxis *);

class DataLoad: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePrj READ filePrj WRITE setFilePrj NOTIFY filePrjChanged)
    Q_PROPERTY(std::vector<float> xvector READ xvector)
    Q_PROPERTY(std::vector<float> yvector READ yvector)
    Q_PROPERTY(std::vector<float> axRange READ axRange)
    Q_PROPERTY(QStringList error_list READ error_list WRITE setError_list NOTIFY error_listChanged)
    Q_PROPERTY(std::vector<std::vector<QString>> mCore READ mCore WRITE setMCore)
    Q_PROPERTY(std::vector<std::vector<mdata>> mDatam READ mDatam WRITE setMDatam)
    Q_PROPERTY(QStringList coreList READ coreList)
    Q_PROPERTY(int coreIndex READ coreIndex WRITE setCoreIndex NOTIFY coreIndexChanged)
    Q_PROPERTY(int paraIndex READ paraIndex WRITE setParaIndex NOTIFY paraIndexChanged)
    //Q_PROPERTY(QAbstractSeries xyvect READ xyvect WRITE setXyvect)
    Q_PROPERTY(QStringList paramList READ paramList)

public:

    explicit DataLoad(QObject *parent = 0);

    QString filePrj();
    void setFilePrj(const QString &filePrj);

    std::vector<float> xvector();
    std::vector<float> yvector();
    std::vector<float> axRange();

    QStringList error_list();
    void setError_list(const QStringList &errorlist);

    QString readFile(const QString &filePrj);
    //std::vector<float> depth;
    //std::vector<float> tod;
    //std::vector<float> age;

    void dataMatrix(const QString &filePrj);

    std::vector<std::vector<QString>> mCore();
    void setMCore(std::vector<std::vector<QString>> &mCore);

    std::vector<std::vector<mdata>> mDatam();
    void setMDatam(std::vector<std::vector<mdata>> &mDatam);

    QStringList coreList();

    int coreIndex();
    void setCoreIndex(int &coreIndex);

    int paraIndex();
    void setParaIndex(int &paraIndex);

    //QAbstractSeries *xyvect();

    QStringList paramList();

public slots:
    void setXyVect(QAbstractSeries *series,int coreIndex,int paraIndex);
    void editXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,int cInd);
    void ageLines(QAbstractSeries *series, int cInd, int coreCount);
    void plot_index(int i);
signals:
    void filePrjChanged();
    void error_listChanged();
    void coreIndexChanged(int &coreIndex);
    void paraIndexChanged();

private:
    QString m_filePrj;
    std::vector<float> m_xvec;
    std::vector<float> m_yvec;
    std::vector<float> m_axrange;
    QStringList m_error_list;
    //QVector <float> m_depth;
    std::vector<std::vector<QString>> m_matrixCore;
    std::vector<std::vector<mdata>> m_matrixData;
    QStringList m_coreList;
    QStringList m_paramList;
    int m_coreIn;
    int m_paraIn;
    QList<QVector<QPointF>> m_xy;
    int m_index;
};
#endif // DATALOAD_H
