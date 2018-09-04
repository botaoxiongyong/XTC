#include "xtc.h"
#include <QApplication>
QT_CHARTS_USE_NAMESPACE;

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    XTC w;
    w.show();

    return a.exec();
}
