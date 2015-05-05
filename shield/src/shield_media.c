#define SHIELD_LIB_INTERNAL
#include "shield.h"
#include "shield_common_blocks.h"
#include <stdio.h>

int MediaNum = 0;

int _check_type(int type) {
    return ((type > 0) && (type < 4));
}

int _check_n_el(int n) {
    return ((n > 0) && (n <= 24));
}

int shield_add_medium(struct MediumData *data)
{
    int j = MediaNum; // j is Fortran index
    macrin.NELEMD[j][0] = data->nType;
    if (!_check_type(data->nType)) {
        printf("Warning: Media type for medium %i is invalid (type = %i)\n", 
            MediaNum, data->nType);
        printf("    Medium ignored.\n");
        return MediaNum;
    }
    if (!_check_n_el(data->nChemEl)) {
        printf("Warning: number of chem. el. for medium %i is invalid (= %i)\n", 
            MediaNum, data->nChemEl);
        printf("    Medium ignored.\n");
        return MediaNum;
    }
    int NELEM = data->nChemEl;
    if (data->nType == 1) NELEM = 1;
    macrin.NELEMD[j][1] = NELEM;
    float RHO = data->Rho;
    macrin.RHOMED[j] = RHO;
    
    int k;
    for(k=0; k<data->nChemEl; k++) {
        int Nuclid = data->Elements[k].Nuclid;
        macrin.ELMIX[j][k][0] = (float)(data->Elements[k].Nuclid);
        macrin.ELMIX[j][k][1] = data->Elements[k].Conc;
        macrin.ELMIX[j][k][2] = data->Elements[k].Density;
        macrin.ELMIX[j][k][3] = infel.ZNUC[Nuclid-1];
        macrin.ELMIX[j][k][4] = infel.ATWEI[Nuclid-1];
        if (data->Elements[k].PureDensity != 0) {
            macrin.ELMIX[j][k][5] = data->Elements[k].PureDensity;
        } else {
            macrin.ELMIX[j][k][5] = infel.ZNUC[Nuclid-1]; // Fortran index!
        }
        if (data->Elements[k].ionEv != 0) {
            macrin.ELMIX[j][k][6] = data->Elements[k].ionEv;
        } else {
            macrin.ELMIX[j][k][6] = infel.RIEV[Nuclid-1];
        }
        macrin.ELMIX[j][k][7] = data->Elements[k].reserved;
    }

    const float AVOG = 6.022169e-4;
    float RMOL;
    switch(data->nType) {
        case 1:
            RHO = macrin.ELMIX[j][0][5];
            macrin.RHOMED[j] = RHO;
            macrin.ELMIX[j][0][1] = AVOG * (RHO / macrin.ELMIX[j][0][4]);
            macrin.ELMIX[j][0][2] = RHO;
            break;
        case 2: // accidentally medium 2 and 3 coincide
        case 3:
            RMOL = 0;
            for(k=0; k<NELEM; k++) 
                RMOL += macrin.ELMIX[j][k][1] * macrin.ELMIX[j][k][4];
            for(k=0; k<NELEM; k++) {
                macrin.ELMIX[j][k][1] = (macrin.ELMIX[j][k][1] * RHO * AVOG) / RMOL;
                macrin.ELMIX[j][k][2] = (macrin.ELMIX[j][k][1] * macrin.ELMIX[j][k][4] * RHO) / RMOL;
            }
            break;
/*        case 3:
            float AVER = 0;
            for(k=0; k<NELEM; k++)
                AVER += macrin.ELMIX[j][k][1] * macrin.ELMIX[j][k][4];
            for(k=0; k<NELEM; k++) {
                macrin.ELMIX[j][k][1] = (macrin.ELMIX[j][k][1] * RHO * AVOG) / AVER;
                macrin.ELMIX[j][k][2] = (macrin.ELMIX[j][k][1] * macrin.ELMIX[j][k][4] * RHO) / AVEr;
            }
            break;*/
        case 4:
        default:
            break;
    }

    // success
    MediaNum ++;
    macrin.NUMMED = MediaNum;
    return MediaNum;
}

void shield_media_init()
{
    // dummy function
}
