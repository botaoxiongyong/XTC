#ifndef TABLEMODEL_H
#define TABLEMODEL_H
#include <QQmlContext>
#include <QAbstractTableModel>
#include <QDebug>
#include <QModelIndex>
#include <QList>
#include <QPushButton>
#include <QQmlComponent>
#include <QQmlApplicationEngine>
/*
 * the table is copy from github, author eyllanesc
 * https://github.com/eyllanesc/stackoverflow/tree/master/questions/55610163
 */
Q_DECLARE_METATYPE(QPushButton*)

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
    void colNumb(int n);
    void coreList(QStringList corelist);
    void paramList(QStringList paramlist);
    void index_row_col(int row, int col);

private:
    int m_rows = 1;
    int m_cols = 1;
    int m_row_index = 0;
    int m_col_index = 0;
    QStringList m_corelist;
    QStringList m_paramlist;
};

#endif // TABLEMODEL_H
