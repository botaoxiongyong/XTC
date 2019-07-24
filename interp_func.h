#ifndef INTERP_FUNC_H
#define INTERP_FUNC_H

#include <vector>
#include <cfloat>
#include <math.h>


int findNearestNeighbourIndex( float value, std::vector< float > &x );
std::vector< float > interp1( std::vector< float > &x, std::vector< float > &y, std::vector< float > &x_new );

#endif // INTERP_FUNC_H
