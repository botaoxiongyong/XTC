#include <QApplication>
#include <QQmlApplicationEngine>
#include "dataload.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName("gfz");
    app.setOrganizationDomain("gfz-potsdam.de");
    app.setApplicationName("XTC");

    qmlRegisterType<DataLoad>("io.qt.examples.dataload", 1, 0, "DataLoad");
    qRegisterMetaType<mdata>();
    qRegisterMetaType<std::vector<float>>();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
