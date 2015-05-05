#define SHIELD_LIB_INTERNAL
#include "shield.h"
#include "shield_common_blocks.h"
#include <stdio.h>

GEODISTCALLBACK geo_dist_callback = 0;
GEONEXTCALLBACK geo_next_callback = 0;

#ifndef gdatap
#define gdatap gdatap_
struct Gdatap_t {
    double x, y, z, cx, cy, cz;
    double xn, yn, zn, cxn, cyn, czn;
    int NZONO,MEDOLD,NBPO,NSO;
    int NZONC,MEDCUR,NBPC,NSCI,NSCO;
    int PINSFL,PARTZD;
} extern gdatap; 
#endif

void shield_geo_set_dist_callback(GEODISTCALLBACK function)
{
    geo_dist_callback = function;
}

void shield_geo_set_next_callback(GEONEXTCALLBACK function)
{
    geo_next_callback = function;
}

#ifndef USE_GEMCA
void gcurzl(int *zone_in, float *dist_out)
{
    if (geo_dist_callback != 0) {
        *dist_out = geo_dist_callback(gdatap.x, gdatap.y, gdatap.z, gdatap.cx, gdatap.cy, gdatap.cz);
    } else {
        // should never happen 
        printf("FATAL ERROR: GEO DIST CALLBACK NOT SET\n");
//        exit(1);
    }
}

void gnextz(int *next_out)
{
    // determinition of next zone
    if (geo_next_callback != 0) {
        *next_out = geo_next_callback(gdatap.x, gdatap.y, gdatap.z, gdatap.cx, gdatap.cy, gdatap.cz);
    } else {
        // should never happen
        printf("FATAL ERROR: GEO NEXT CALLBACK NOT SET\n");
//        exit(1);
    }
}

void gzmed(int *zone)
{
    // Determinition of zone medium
}
#endif

