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
    Q_PROPERTY(QStringList error_list READ error_list WRITE setError_list NOTIFY error_listChanged)
    Q_PROPERTY(QStringList coreList READ coreList)
    Q_PROPERTY(QStringList paramList READ paramList)

public:

    explicit DataLoad(QObject *parent = 0);

    QString filePrj();
    void setFilePrj(const QString &filePrj);

    QStringList error_list();
    void setError_list(const QStringList &errorlist);

    QString readFile(const QString &filePrj);

    void dataMatrix(const QString &filePrj);

    QStringList coreList();

    QStringList paramList();

public slots:
    void setXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,float plotseq);
    void editXyVect(QAbstractSeries *series,int coreIndex,int paraIndex,float plotseq);
    void ageLines(QAbstractSeries *series, int cInd, int coreCount);
    void plot_index(int i);
    void ageChange(float age1, float age2);
    float searchLine(float age);
    void ageDel(float age);
    void save();
signals:
    void filePrjChanged();
    void error_listChanged();

private:
    QString m_filePrj;
    QStringList m_error_list;
    std::vector<std::vector<QString>> m_matrixCore;
    std::vector<std::vector<mdata>> m_matrixData;
    QStringList m_coreList;
    QStringList m_paramList;
    QList<QVector<QPointF>> m_xy;
    int m_index;
    int m_coreIndex;
};
#endif // DATALOAD_H
