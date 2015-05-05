#ifndef SHIELD_MEDIA_H
#define SHIELD_MEDIA_H

#ifndef SHIELD_H
#error ERROR: Don't include shield_media.h header, include shield.h instead
#endif

struct Element
{
    float Nuclid;
    float Conc;         // Concentration [10^27/cm^3]
    float Density;      // Partial density [g/cm^3]
    float Z;            // Atomic number Z
    float A;            // Atomic weight A
    float PureDensity;  // Density of pure material [g/cm^3]
    float ionEv;        // Ionization potential [eV]
    float reserved;     // reserved
};

struct MediumData 
{
    int nType;      // Medium type, should be in range 1-4
    int nChemEl;    // up to 24 elements
    float Rho;      // Density of medium
    struct Element Elements[24];    // elements info
};

#endif
