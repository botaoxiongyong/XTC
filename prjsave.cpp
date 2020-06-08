#include "dataload.h"

void DataLoad::creatMatrix(){
    int NDS=50;
    int NPC=50;
    std::vector<std::vector<QString>> matrixCore(size_t(NDS), std::vector<QString>(size_t(NPC+1)));
    m_matrixCore = matrixCore;
}

void DataLoad::coreMaxtrix(int row, int col, QString filePath){
    m_matrixCore[row][col] = filePath;
    //std::vector<std::vector<QString>> matrixCore(size_t(NDS), std::vector<QString>(size_t(NPC+1)));
}
