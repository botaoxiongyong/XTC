#ifndef XTC_H
#define XTC_H
#include <QMainWindow>
#include <QtCharts>
QT_CHARTS_USE_NAMESPACE;
#include <QFileDialog>
#include <QMessageBox>
#include <QTextStream>
#include <vector>
#include <QSignalMapper>
#include <QtWidgets>
#include <QSize>
#include "_mdata.h"

namespace Ui {
class XTC;
}

class XTC : public QMainWindow
{
    Q_OBJECT

public:
    explicit XTC(QWidget *parent = 0);
    ~XTC();



public slots:

    void dataPlot();

    void coreItemChecked();

    void on_actionOpen_project_file_triggered();

    void on_actionEdit_Mode_triggered();

    void buttonNext_clicked();

    void on_paramNext_clicked();

    void on_paramPrevo_clicked();

    void editMode();

private slots:


    void on_pBshowOp_clicked();

    void on_pBhideOp_clicked();

    void on_pBshowOp_E_clicked();

    void on_pb_back_edit_clicked(bool checked);

    void on_paramPrevo_E_clicked();

    void on_actionCore_Mode_triggered();

    void on_paramNext_E_clicked();

private:
    Ui::XTC *ui;

    QPushButton *buttonNext;

    int counter;

    QVector<QColor> colors;

    std::vector<std::vector<mdata>> matrixData;


};


#endif // XTC_H
