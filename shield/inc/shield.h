/* 
 * File:   shield.h
 * Author: alex
 *
 * Created on 10 February 2012, 15:19
 */

#ifndef SHIELD_H
#define	SHIELD_H

#ifndef SHIELD_LIB_INTERNAL
#ifdef __cplusplus
#define SHIELD_API extern "C"
#else
#define SHIELD_API extern
#endif
#ifdef SHIELD_DOUBLE_UNDERSCORE
#elif SHIELD_SINGLE_UNDERSCORE
#else
#endif
#else
#endif

#ifndef SHIELD_API
#define SHIELD_API
#endif

// STAND-ALONE SHIELD RUN -- USE FOR DEBUG
SHIELD_API void shield_();

SHIELD_API void shield_set_defaults();
SHIELD_API void shield_initialize();
SHIELD_API void shield_run();
SHIELD_API void shield_finalize();


SHIELD_API void shield_set_randomseed(int seed);
SHIELD_API void shield_set_luxcount(int luxcnt);
SHIELD_API void shield_set_incidentparticle(int jpart);
SHIELD_API void shield_set_energy(float energy);
SHIELD_API void shield_set_lcasc(int lcasc); // 1 for CASCAD below 1 GeV
SHIELD_API void shield_set_statistics(int nstat);
SHIELD_API void shield_set_nsave(int nsave);

SHIELD_API void shield_set_aproj(float a);
SHIELD_API void shield_set_zproj(float z);


SHIELD_API int shield_get_randomseed();
SHIELD_API int shield_get_luxcount();
SHIELD_API int shield_get_incidentparticle();
SHIELD_API float shield_get_energy();
SHIELD_API int shield_get_lcasc();
SHIELD_API int shield_get_statistics();
SHIELD_API int shield_get_nsave();

SHIELD_API float shield_get_aproj();
SHIELD_API float shield_get_zproj();

SHIELD_API void shield_set_runpoint(float x, float y, float z);
SHIELD_API void shield_set_rundirection(float cos_theta, float sin_phi, float cos_phi);

// Media
#include "shield_media.h"

SHIELD_API int shield_add_medium(struct MediumData *data);

// Tree
#include "shield_tree.h"

// Geometry
#include "shield_geo.h"

#endif	/* SHIELD_H */

