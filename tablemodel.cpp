#include "tablemodel.h"

TableModel::TableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

void TableModel::rowNumb(int n){
    qDebug() << n;
    m_rows = n;
}

QVariant TableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(role == Qt::DisplayRole){
        if(orientation == Qt::Horizontal)
            return  QString("hor-%1").arg(section);
        else
            return QString("ver-%1").arg(section);
    }
    return QVariant();
}

int TableModel::rowCount(const QModelIndex &parent) const
{
    qDebug() << parent.isValid();
    if (parent.isValid())
        return 0;
    return m_rows;
}

int TableModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return 1;
}

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    //qDebug() << role;
    if (!index.isValid())
        return QVariant();
    if(role == Qt::DisplayRole
            && index.row() >= 0 && index.row() < rowCount()
            && index.column() >= 0 && index.column() < columnCount())
        return QString("data %1-%2").arg(index.row()).arg(index.column());
    return QVariant();
}
