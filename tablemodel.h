#ifndef TABLEMODEL_H
#define TABLEMODEL_H
#include <QQmlContext>
#include <QAbstractTableModel>
#include <QDebug>
#include <QModelIndex>
/*
 * the table is copy from github, author eyllanesc
 * https://github.com/eyllanesc/stackoverflow/tree/master/questions/55610163
 */
class TableModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    explicit TableModel(QObject *parent = nullptr);
    Q_INVOKABLE QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
public slots:
    void rowNumb(int n);

private:
    int m_rows = 1;
};

#endif // TABLEMODEL_H
