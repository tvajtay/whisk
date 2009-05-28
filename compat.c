#include "compat.h"

#ifdef _MSC_VER
#define _USE_MATH_DEFINES
#include <math.h>

extern inline long int lround(float x)
{
return (long)(x < 0 ? -floor(fabs(x) + .5) : floor(x + .5));
}

extern inline double round(double x)
{
  return x < 0 ? -floor(fabs(x) + .5) : floor(x + .5);
}

extern inline float roundf(float x)
{
  return x < 0 ? -floorf(fabsf(x) + .5) : floorf(x + .5);
}
#endif