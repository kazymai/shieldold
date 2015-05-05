#ifndef SHIELD_H
#error ERROR: Don't include shield_geo.h, include shield.h instead.
#endif

#ifndef SHIELD_GEO_H
#define SHIELD_GEO_H

/* 
 * File:   shield_tree.h
 * Author: A. Timofeev
 *
 * Created on 12 February 2012, 20:01
 */

// Geometry callbacks

typedef float (*GEODISTCALLBACK)(float x, float y, float z, 
                                 float vx, float vy, float vz);

typedef int (*GEONEXTCALLBACK)(float x, float y, float z, 
                               float vx, float vy, float vz);

//typedef int (*GEOMEDIUMCALLBACK)(

SHIELD_API void shield_geo_set_dist_callback(GEODISTCALLBACK function);
SHIELD_API void shield_geo_set_next_callback(GEONEXTCALLBACK function);

#endif
