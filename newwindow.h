#ifndef NEWWINDOW_H
#define NEWWINDOW_H
//#include "ui_newwindow.h"
#include <QMainWindow>

namespace Ui {
    class MainWindow;
}


class newwindow : public QMainWindow
{
    Q_OBJECT
public:
    newwindow(QWidget *parent = 0);
    ~newwindow();

    //Ui::newwindow *ui;

signals:

public slots:

private:
    Ui::MainWindow *ui;
};

#endif // NEWWINDOW_H
