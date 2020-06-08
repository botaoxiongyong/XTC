#include "tablemodel.h"

TableModel::TableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

void TableModel::rowNumb(int n){
    //qDebug() << n;
    m_rows = n;
}

void TableModel::colNumb(int n){
    //qDebug() << n;
    m_cols = n;
}

void TableModel::coreList(QStringList corelist){
    //qDebug() << n;
    m_corelist = corelist;
}

void TableModel::paramList(QStringList paramlist){
    //qDebug() << n;
    m_paramlist = paramlist;
}

QVariant TableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(role == Qt::DisplayRole){
        //qDebug() << section;
        //qDebug() << m_corelist;
        if(orientation == Qt::Horizontal)
            //return  m_paramlist.at(section);
            return  QString("hor-%1").arg(section);
        else
            //return m_corelist.at(section);
            return QString("ver-%1").arg(section);
    }
    return QVariant();
}

int TableModel::rowCount(const QModelIndex &parent) const
{
    qDebug() << m_rows;
    if (parent.isValid())
        return 0;
    return m_rows;
}

int TableModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_cols;
}

void TableModel::index_row_col(int row, int col){
    m_row_index = row;
    m_col_index = col;
}

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    //qDebug() << index,role;
    if (!index.isValid())
        return QVariant();
    if(role == Qt::DisplayRole
            && index.row() >= 0 && index.row() < rowCount()
            && index.column() >= 0 && index.column() < columnCount()){
        return QString("%1-%2").arg(index.row()).arg(index.column());
        //return QString(index.row())+QString(index.column());
    }
        //QString("data %1-%2").arg(index.row()).arg(index.column());
    return QVariant();
}
