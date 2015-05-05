#define SHIELD_LIB_INTERNAL
#include "hadgen.h"
#include "hadgen_common_blocks.h"
#include "shield.h"
#include "shield_common_blocks.h"
#include <stdio.h>

void shield_set_defaults()
{
    // setting default parameters
    antlab.lanti = 0;
    debug.LCASC = 0;
    debug.LSTAR = 0;
    random.IXFIRS = 213835419;
    t0jpr0.JPART0 = 25;
    t0jpr0.TMAX0 = 1000;
    other.NSTAT = 1;    // 1 event by default
    other.LUXCNT = 0;
    oln.OLN = 0.0;
    hipro0.APROJ = 238;
    hipro0.ZPROJ = 92;
    
    wrpr.WP[0] = 0;
    wrpr.WP[1] = 0;
    wrpr.WP[2] = 0;
    wrpr.WP[3] = 1;
    wrpr.WP[4] = 0;
    wrpr.WP[5] = 1;    

//    printf("shield : setting defaults [done]\n");
}

extern void _hadgen_initis();

void shield_initialize()
{
#ifdef USE_GEMCA
    opensh();
#endif    
//    if (oln.OLN < 0.215e-6) oln.OLN = 0.215e-6;
    if (debug.LCASC != 1) debug.LCASC = 0;
    dimar();    // Arrays dimensions
    
    inlevr();   // Parameters for AGT, PRECO, DEEX, CASCAD
    // hadgen_initialize();
    
    // initialisation of Isotopes array
    shield_set_iso();
    
    // MEDIA INPUT
#ifdef USE_GEMCA
//    printf("inmacr...          ");
    inmacr();
//    printf("[done]\n");
#else
    // media input is not from file,
    // but through function shield_add_medium()
    shield_media_init();
#endif

    // the following subr. is used for output only - truncated
    //bdprin();
//    printf("calmac...          ");
    // macroscopic cross-sections calculation for JPART=1-24
    calmac();
//    printf("[done]\n");
    // range-energy dependence and optical depth for JPART=1-24
//    printf("roptpr...          ");
    roptpr();
//    printf("[done]\n");
    if (t0jpr0.JPART0 == 25) {
        int IPRINT = 0;
        hiproj.APROJ = hipro0.APROJ;
        hiproj.ZPROJ = hipro0.ZPROJ;
//        printf("calmhi/ropthi...    ");
        calmhi(&IPRINT);        // IPRINT == 0, NO PRINTOUT
        ropthi(&IPRINT);
//        printf("[done]\n");
    }
//    printf("lnmacr...          ");
    lnmacr();
//    printf("[done]\n");
//    printf("clear arrays...    ");
    cletot();
    clerln();
//    printf("[done]\n");
    
#ifdef USE_GEMCA
    geoini();
#else
     // A PART TO CHANGE TODO
#endif

    cutoff();
    _hadgen_setdky();   // ATAB
    initam();           // ATAB
    _hadgen_initis();   // TABNUC
    //initis(); //
    //inlevr();
    // Random number generator initialisation
    init_luxs(&random.IXFIRS, &other.LUXCNT); 
    random.IX = random.IXFIRS;
//    printf("SHIELD: init complete.\n");
}

extern void printr_();
extern void prstar_();

void shield_run() {
    shield_initialize();
    float TMAX = t0jpr0.TMAX0;
    int J;
    // MAIN LOOP
    int LUX, IMT, K1, K2;
    int LOWENT = 0;
    for(J=1; J<=other.NSTAT; J++) {
//	printf("SHIELD mainloop: rluxat\n");
        rluxat(&LUX, &IMT, &K1, &K2);
//        printf("RLUXAT: %i LUX = %i %i %i %i\n", J, LUX, IMT, K1, K2);
//    	printf("SHIELD mainloop: gentre\n");
        gentre(&J);
//        printf("SHIELD mainloop: dectre\n");
        dectre();
//        printf("SHIELD");
//        outtot(&LOWENT, &TMAX);   // output truncated at the moment
//        neutlo();                 //
	printr_();
	prstar_();
    }
    shield_finalize();
}

void shield_finalize()
{
#ifdef USE_GEMCA
    clossh();
#endif
    // nothing to finalise at the moment
    // may be files or something
}
