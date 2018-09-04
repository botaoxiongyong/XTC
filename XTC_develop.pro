#-------------------------------------------------
#
# Project created by QtCreator 2018-05-17T15:38:55
#
#-------------------------------------------------

QT       += core gui
QT	 += charts

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = XTC_develop
TEMPLATE = app


SOURCES += main.cpp\
        xtc.cpp \
    project_load.cpp

HEADERS  += xtc.h \
    project_load.h \
    _mdata.h \
    _cppli.h \
    _randcolor.h

FORMS    += xtc.ui

DISTFILES +=
