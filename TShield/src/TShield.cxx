// @(#)root/transport/shield:$Id: TShield.cxx
// Authors: Alexander Timofeev 29/02/2012

/*************************************************************************
 * Written by Alexander Timofeev, JINR, Dubna                            *
 * On any questions feel free to contact: antimofeew@gmail.com           *
 *                                                                       *
 * For the licensing terms see $ROOTSYS/LICENSE.                         *
 * For the list of contributors see $ROOTSYS/README/CREDITS.             *
 *************************************************************************/

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// TShield                                                                    //
// is a Interface (wrapper) class for Shield transport code                   //
// Original code of SHIELD package                                            //
// is written by N.M.Sobolevsky                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

#include "TShield.h"
#include "shield.h"     // link to $SIMPATH/generators/shield/shield.h
                        // includes all the lib Interface
#include <cstdlib>
#include <time.h>

// class TShield implementation
TShield *TShield::fInstance = 0;


//______________________________________________________________________________
TShield::TShieldClean::~TShieldClean() {
   // delete the unique copy of TShield
   // if exists
   if (TShield::fInstance)
      delete TShield::fInstance;
}
//______________________________________________________________________________


ClassImp(TShield)

//______________________________________________________________________________
TShield::TShield()
{
    // Check if another instance of TShield already exists
    if (fInstance) {
        Fatal("TShield", "FATAL ERROR: Another instance of TShield class already exists");
    }
    fInstance = this;
    // create static cleaner
    static TShieldClean cleaner;
    
    SetAutoSeed();
    // Create arrays for particles storage
    fParticlesFlyOut = new TClonesArray("TParticle", ParticlesNumFlyOutMax);
    fParticlesAbsorbed = new TClonesArray("TParticle", ParticlesNumAbsorbedMax);
    fGeometry = 0;
    // init the random generator
    srand(time(0));
    // init callbacks for tree generation and geometry
    InitCallbacks();

//   fParticles = new TClonesArray("TParticle", 
//      shield_get_max_stp() + shield_get_max_snu()); 

    // Setting all default
    shield_set_defaults();
}

TShield* TShield::Instance() {
   return fInstance ? fInstance : new TShield();
}

//______________________________________________________________________________
TShield::~TShield() 
{
    // delete TClonesArray's
    delete fParticlesFlyOut;
    delete fParticlesAbsorbed;
    // if deleted, clear the instance
    TShield::fInstance = 0;
    // useful if needed to create a new instance of TShield in future
    // actually TShield object should be automatically cleaned
    // but user can also delete it manually
}

#include <stdio.h>

//______________________________________________________________________________
void TShield::GenerateEvent() {
    // Clean particles arrays
    fParticlesFlyOut->Clear();
    fParticlesAbsorbed->Clear();
    ParticlesNumFlyOut = 0;
    ParticlesNumAbsorbed = 0;
    
    shield_run();
}

//______________________________________________________________________________
void TShield::SetGeometry(TGeoManager *geom) {
    fGeometry = geom;
}

TGeoManager *TShield::GetGeometry() {
    return fGeometry;
}
