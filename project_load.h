#ifndef PROJECT_LOAD_H
#define PROJECT_LOAD_H
#include <QString>
#endif // PROJECT_LOAD_H
#include "xtc.h"

QString readFile(const QString& fileName);

//std::vector<std::vector<QString>> matixCore(const QString& line);
std::vector<std::vector<mdata>> getMatirx(QString& line, QString& fileName, Ui::XTC *ui);

//std::vector<QLineSeries> toChartSeris(std::vector<float> &x,std::vector<float> &y);

QString fileNameGet();
