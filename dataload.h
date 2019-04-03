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
#include <QMetaType>
#include <QLineSeries>
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
    Q_PROPERTY(QLineSeries* xy READ xy WRITE setXy NOTIFY xyChanged)

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

    QLineSeries* xy();
    void setXy(QLineSeries *xy);


signals:
    void filePrjChanged();
    void error_listChanged();
    void coreIndexChanged(int &coreIndex);
    void paraIndexChanged();
    void xyChanged();


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
    QLineSeries* m_xy;
};
#endif // DATALOAD_H
