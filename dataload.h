#ifndef DATALOAD_H
#define DATALOAD_H


#include <QObject>
#include <QString>
#include <QVector>
#include <QStringList>
#include <QtCore>
#include <QDebug>
#include <QFile>
#include <QVector>
#include <QPointF>
#include <QList>
#include <QMetaType>
#include <QLineSeries>
#include <QtCharts/QAbstractSeries>
using namespace QtCharts;

class mdata {
    Q_GADGET
public:
    std::vector<float> x;
    std::vector<float> y;
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
    Q_PROPERTY(QVector<qreal> xvector READ xvector)
    Q_PROPERTY(QVector<qreal> yvector READ yvector)
    Q_PROPERTY(QVector<qreal> axRange READ axRange)
    Q_PROPERTY(QStringList error_list READ error_list WRITE setError_list NOTIFY error_listChanged)
    Q_PROPERTY(std::vector<std::vector<QString>> mCore READ mCore WRITE setMCore)
    Q_PROPERTY(std::vector<std::vector<mdata>> mDatam READ mDatam WRITE setMDatam)
    Q_PROPERTY(QStringList coreList READ coreList)
    Q_PROPERTY(int coreIndex READ coreIndex WRITE setCoreIndex NOTIFY coreIndexChanged)
    Q_PROPERTY(int paraIndex READ paraIndex WRITE setParaIndex NOTIFY paraIndexChanged)
    //Q_PROPERTY(QAbstractSeries xyvect READ xyvect WRITE setXyvect)


public:

    explicit DataLoad(QObject *parent = 0);

    QString filePrj();
    void setFilePrj(const QString &filePrj);

    QVector<qreal> xvector();
    QVector<qreal> yvector();
    QVector<qreal> axRange();

    QStringList error_list();
    void setError_list(const QStringList &errorlist);

    QString readFile(const QString &filePrj);
    //QVector<float> depth;
    //QVector<float> tod;
    //QVector<float> age;

    void dataMatrix(const QString &filePrj);

    std::vector<std::vector<QString>> mCore();
    void setMCore(std::vector<std::vector<QString>> &mCore);

    std::vector<std::vector<mdata>> mDatam();
    void setMDatam(std::vector<std::vector<mdata>> &mDatam);

    QStringList coreList();

    int coreIndex();
    void setCoreIndex(int &coreIndex);

    int paraIndex();
    void setParaIndex(int &coreIndex);

    //QAbstractSeries *xyvect();

public slots:
    void setXyVect(QAbstractSeries *series);
    void plot_index(int i);

signals:
    void filePrjChanged();
    void error_listChanged();
    void coreIndexChanged(int &coreIndex);
    void paraIndexChanged();

private:
    QString m_filePrj;
    QVector<qreal> m_xvec;
    QVector<qreal> m_yvec;
    QVector<qreal> m_axrange;
    QStringList m_error_list;
    //QVector <float> m_depth;
    std::vector<std::vector<QString>> m_matrixCore;
    std::vector<std::vector<mdata>> m_matrixData;
    QStringList m_coreList;
    int m_coreIn;
    int m_paraIn;
    QList<QVector<QPointF>> m_xy;
    int m_index;
};
#endif // DATALOAD_H
