
***********************************************************************
*                                                                     *
*        The following subroutines are written by N.M.Sobolevsky,     *
*        Institute for Nuclear Research RAS, Moscow,                  *
*        E-mail: sobolevs@AL20.inr.troitsk.ru                         *
*                                                                     *
***********************************************************************
      SUBROUTINE HADGEN
C PROGRAM changed to SUBROUTINE, the generator is used as a .so lib with 
C FairROOT
C Generator of HADRON-NUCLEUS and NUCLEUS-NUCLEUS inelastic interactions
C of the SHIELD code [Multi Stage Dynamical Model (MSDM) generator].
C
C INPUT:
C       JPART - Incident particle type (1-4,6-11,21-24,25=HI)        !HION2
C    if(JPART.eq.25)then                                             !HION2
C       input APROJ,ZPROJ - A and Z of incident nucleus              !HION2
C       TINT -  Incident kinetic energy: MeV - for particles
C                                        MeV/A - for nuclei
C        NUCLID - Nucleus-Target atomic number (1-100)
C        NSTAT - MONTE CARLO statistics
C OUTPUT:
C        Secondary particles in array SPT and residual nuclei
C        in array SNU
C-------------------------------------------------------------------------
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /SECHAR/ SPT(6,5000),SNU(10,101),LS6,LS100,LS10,LS11  ! GSITR
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
      COMMON /SPECAGT/ SPECAGT(126,30,180)                          ! HISTAGT
C
      COMMON /NUMINT/ INTIN,INTEL  ! No. of inel. and el. interactions
      COMMON /HIPROJ/ APROJ,ZPROJ
      COMMON /ANTLAB/ lanti        ! 1 - Antilab frame (for proton only)
      COMMON /ANTIL/ lantil        ! KarSjh
      COMMON /DEBUG/ LSTAR,LCASC   ! Debug flags (0 to avoid print)
      COMMON /ISLERR/ ISLERR   ! HADES1
      COMMON /OTHER/ NSTAT, LUXCNT
C
C The following variables arise from extranuclear cascade (code SHIELD)
C and don't asffect the HADGEN generator.
      LS6=6
      LS100=5000  ! GSITR
      LS10=10
      LS11=101  ! GSITR
C
        COST=1.
        SINF=0.
        COSF=1.
            KSTATE=2
C
C **********************************************************
!      OPEN(33,FILE='FOR033.DAT',STATUS='OLD')
!      OPEN(34,FILE='FOR034',STATUS='NEW')
!      OPEN(25,FILE='FOR025',STATUS='NEW')
!      OPEN(18,FILE='ATAB.DAT',STATUS='OLD')
!      OPEN(19,FILE='TABNUC.DAT',STATUS='OLD')
!      OPEN(37,FILE='FOR037',FORM='BINARY')       ! HISTAGT
      CALL OPENFILES
c      OPEN(38,FILE='FOR038',STATUS='NEW')        ! HADES
C
C ********************** INPUT and CHECKUP ******************
C Set default flags:
      lanti=0
      lantil=0                                 ! KarSjh
      LSTAR=0
      LCASC=0
C
      READ(33,10)IXFIRS,LUXCNT,                      ! RANLUX
     *           JPART,
     *           TINT,
     *           NUCLID,
     *           NSTAT,
     *           lanti,
     *           LSTAR,
     *           LCASC
C
   10 FORMAT(/20X,2I12, 36X/                            ! RANLUX
     *        20X,I12,  48X/
     *        20X,F12.3,48X/
     *        20X,I12,  48X/
     *        20X,I12,  48X/
     *        20X,I12,  48X/
     *        20X,I12,  48X/
     *        20X,I12,  48X)                                    
C
      if(lanti.ne.1)lanti=0     ! 0 or 1 only!
      if(JPART.ne.2)lanti=0     ! Antilab. system is used
C                               ! for incident proton only!
C
      if(NSTAT.gt.100)LSTAR=0   ! No print more then 100 stars!
      if(LSTAR.ne.1 .and. LSTAR.ne.2)LSTAR=0  ! 0, 1 or 2 only!
C
      if(LCASC.ne.1)LCASC=0     ! 0 or 1 only!
      if(TINT.gt.1000. .or. 
     *   JPART.lt.1 .or. JPART.gt.4 .or.   ! CASCAD can be used at
     *   NUCLID.le.8)LCASC=0               ! these restrictions only!
C
          IF(JPART.le.0 .OR. JPART.eq.5 .OR.                         !HION2
     *       (JPART.ge.12 .and. JPART.le.20) .OR.                    !HION2
     *       JPART.gt.25)                      GO TO 11              !HION2
          IF(TINT.LT.0. .OR. TINT.GT.10000001.)GO TO 11  ! up to 10 TeV
          IF(NUCLID.LT.1 .OR. NUCLID.GT.107)   GO TO 11  ! up to 107, 01.03.2001
                                     GO TO 12
   11 WRITE(25,1001) JPART,TINT,NUCLID
 1001 FORMAT(' HADGEN DIAGNOSTIC: INVALID INPUT, JPART=',I3,', TINT=',
     *         F11.1,' MEV, NUCLID=',I3)
      CLOSE(25)
      RETURN
C
   12 CONTINUE
      IF(JPART.ge.21 .and. NUCLID.eq.1)GO TO 11 !Nucleus cann't ==> H1 !HION2
C                                            ! but can ==> H2, H3, 01.03.2001
C
C Input of incident heavy ion.
C ************************ !HION2 ***********
C ----------------------- Deuteron
      if(JPART.eq.21)then
        APROJ=2.
        ZPROJ=1.
      end if
C ----------------------- Tritium
      if(JPART.eq.22)then
        APROJ=3.
        ZPROJ=1.
      end if
C ----------------------- He3-nucleus
      if(JPART.eq.23)then
        APROJ=3.
        ZPROJ=2.
      end if
C ----------------------- Alpha particle
      if(JPART.eq.24)then
        APROJ=4.
        ZPROJ=2.
      end if
C ***************** end of !HION2 ***********
      IF(JPART.eq.25)THEN                                            !HION2
        READ(33,13)APROJ,
     *               ZPROJ
   13     FORMAT(/20X,F12.3,48X/
     *            20X,F12.3,48X/)
      END IF                                                         !HION2
C
C Check of NUCLEUS-PROJECTILE                                        !HION2
      if(JPART.ge.21 .AND. JPART.le.25)then                          !HION2
        IF(APROJ.lt.2.0 .or. APROJ.gt.260.0 .or.
     *       ZPROJ.lt.1.0 .or. ZPROJ.gt.100.0)THEN
            WRITE(25,1003)APROJ,ZPROJ
 1003         FORMAT(' HADGEN DIAGNOSTIC: INVALID INPUT, APROJ=',F6.1,
     *               ', ZPROJ=',F6.1)
            CLOSE(25)
            RETURN
        END IF
      end if                                                         !HION2
C
      WRITE(37) JPART,TINT,NUCLID,NSTAT,APROJ,ZPROJ            ! HISTAGT
C
C ********************** INITIALIZATION ************************
      IX=IXFIRS           ! Initial state of random generator
C
      IF(JPART.le.11)THEN  ! Cleaning and appropriations             !HION2
      CALL CLEHAD
      ELSE
      CALL CLEION
      END IF
C      
      CALL INITAM    ! AGT initialization
      CALL INITIS    ! Izotope mixture of nucleus-target
      CALL INLEVR    ! Parameters of AGT, PRECO, DEEX and CASCASD
      CALL INIT_LUX(IXFIRS,LUXCNT,34)    ! RANLUX initialization
      CALL MAKEGRID                                              ! HISTAGT
C
      IF(LCASC.eq.1)WRITE(34,*) ' CASCAD (not AGT!)' ! Label to see
C
C ************************* MAIN LOOP ****************************
      IX=IXFIRS           ! Initial state of random generator
cC ============Forced initialization of RANLUX for debug============= HADES1
c        LUXX=3
c        ILT=13457826
c        K11=12406611
c        K22=0
c        CALL RLUXGO(LUXX,ILT,K11,K22)
cC===================================================================
      DO 100 J=1,NSTAT
C
cC================Printout of the first event==================
c         if(J.eq.1)then
      CALL RLUXAT(LUX0,INT0,K1,K2)                           ! RANLUX
      PRINT *,' HADGEN No.',J,LUX0,INT0,K1,K2                ! RANLUX
c      PRINT *,' ...then printout of each 1000th event ...'   ! RANLUX
c         end if
cC================Printout of each 1000th event============
c        J00=INT(FLOAT(J)/1000.)
c        J01=INT(FLOAT(J-1)/1000.)
c        IF(J00.ne.J01)THEN
c          CALL RLUXAT(LUXA,INTA,K11,K22)
c          PRINT *,' HADGEN No.',J,LUXA,INTA,K11,K22
c        END IF
cC=========================================================
C
   99 IXINIT=IX
      NUMTRE=J
      CALL REACT(INOVER)
         IF(INOVER.EQ.0)GO TO 101
         WRITE(25,1000) IXINIT,NUMTRE
 1000       FORMAT(' HADGEN DIAGNOSTIC: ARRAY SPT EXCEEDED, IXINIT=',
     *               I12,', NUMTRE=',I6)
            GO TO 99
  101     CONTINUE
            if(ISLERR.eq.0)goto 102   ! HADES1
            goto 99                   ! HADES1
  102     continue                    ! HADES1
              IF(JPART.le.11)THEN                                    !HION2
              CALL HISHAD     ! Registration for hA and hh
            ELSE
              CALL HISION     ! Registration for AA
            END IF
            CALL STARAGT(J,0)                                     ! HISTAGT
c            CALL BYEVENT(J)                                       ! HADES
        INTIN=J
  100 CONTINUE
C
C ************************* OUTPUT **********************
      IF(JPART.le.11)THEN                                            !HION2
        CALL PRIHAD(NSTAT)   ! Printout for hA and hh       ! HISTAGT inside
      ELSE
        CALL PRIION(NSTAT)   ! Printout for AA        ! HISTAGT inside
      END IF
      CALL OUT_LUX(34)                                     ! RANLUX
C
      CALL CLOSEFILES
!      CLOSE(33)
!      CLOSE(34)
!      IF(LSTAR.eq.1 .or. LSTAR.eq.2)CLOSE(36)
!      CLOSE(25)
!      CLOSE(18)
!      CLOSE(19)
C===================== HISTAGT ====================
!      WRITE(37) (((SPECAGT(I,J,K), I=1,126), J=1,30), K=1,180)
!      CLOSE(37)
c      CLOSE(38)                                      ! HADES
C===================== end HISTAGT ================
C      
      RETURN
      END
c
      SUBROUTINE HADGENSHORT
C PROGRAM changed to SUBROUTINE, the generator is used as a .so lib with 
C FairROOT
C Modified by Alexander Timofeev, 11,07.2011, Dubna
C Originally written by N.M.Sobolevsky
C Generator of HADRON-NUCLEUS and NUCLEUS-NUCLEUS inelastic interactions
C of the SHIELD code [Multi Stage Dynamical Model (MSDM) generator].
C-------------------------------------------------------------------------
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /SECHAR/ SPT(6,5000),SNU(10,101),LS6,LS100,LS10,LS11  ! GSITR
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
      COMMON /SPECAGT/ SPECAGT(126,30,180)                          ! HISTAGT
C
      COMMON /NUMINT/ INTIN,INTEL  ! No. of inel. and el. interactions
      COMMON /HIPROJ/ APROJ,ZPROJ
      COMMON /ANTLAB/ lanti        ! 1 - Antilab frame (for proton only)
      COMMON /ANTIL/ lantil        ! KarSjh
      COMMON /DEBUG/ LSTAR,LCASC   ! Debug flags (0 to avoid print)
      COMMON /ISLERR/ ISLERR   ! HADES1
      COMMON /OTHER/ NSTAT, LUXCNT
C
C
C                          WARNING!
C
C
C ALL INPUT SHOULD BE SET BEFORE EXECUTION OF THIS SUBROUTINE
C
C ********************** INITIALIZATION ************************
C INITIALIZATION should be done externally in C code
C      
      IF(LCASC.eq.1)WRITE(34,*) ' CASCAD (not AGT!)' ! Label to see
C
C ************************* MAIN LOOP ****************************
      DO 100 J=1,NSTAT
      CALL RLUXAT(LUX0,INT0,K1,K2)                           ! RANLUX
c      PRINT *,' HADGEN No.',J,LUX0,INT0,K1,K2                ! RANLUX
   99   IXINIT=IX
        NUMTRE=J+1
        CALL REACT(INOVER)
            IF(INOVER.EQ.0)GO TO 101
            WRITE(34,1000) IXINIT,NUMTRE
 1000         FORMAT(' HADGEN DIAGNOSTIC: ARRAY SPT EXCEEDED, IXINIT=',
     *               I12,', NUMTRE=',I6)
            GO TO 99
  101     CONTINUE
            if(ISLERR.eq.0)goto 102   ! HADES1
            goto 99                   ! HADES1
  102     continue                    ! HADES1
              IF(JPART.le.11)THEN                                    !HION2
              CALL HISHAD     ! Registration for hA and hh
            ELSE
              CALL HISION     ! Registration for AA
            END IF
            CALL STARAGT(J,0)                                     ! HISTAGT
c            CALL BYEVENT(J)                                       ! HADES
        INTIN=J
  100 CONTINUE
      RETURN
      END


      SUBROUTINE REACT(INOVER)
C
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /DEBUG/ LSTAR,LCASC        ! 3.1.97
      COMMON /ISLERR/ ISLERR   ! HADES1
      ISLERR=0                 ! HADES1
C
C GENERATOR BRANCHING 
      IF(TINT.le.1000. .AND. (JPART.ge.1 .and. JPART.le.4)
     *                 .AND. NUCLID.gt.8
     *                 .AND. LCASC.eq.1)THEN
        CALL CASEVP(INOVER)  ! DUBNA-70 cascade model
      ELSE
        CALL GENAGT(INOVER)  ! AGT generator
c        if(ISLERR.eq.1)then   ! HADES1
c          write(25,*)'        GENAGT'
c          write(25,*)'         REACT'
c        end if
      END IF
C
      RETURN
      END



      SUBROUTINE HISHAD
C REGISTRATION OF SHIELD/CG HADRON GENERATOR CHARACTERISTICS
C INPUT:
C       SECONDARY PARTICLES CHARACTERISTICS IN ARRAY SPT
C           SPT(1,J) - COS OF AZIMUTAL ANGLE OF SECONDARY PARTICLE
C           SPT(4,J) - KINETIC ENERGY OF SECONDARY PARTICLE (MEV)
C           SPT(5,J) - SECONDARY PARTICLE TYPE
C           SPT(6,J) - SECONDARY PARTICLE WEIGHT
C       RESIDUAL NUCLEUS CHARACTERISTICS IN SECOND LINE OF ARRAY SNU
C           SNU(1,K) - RESIDUAL NUCLEUS ATOMIC WEIGHT
C           SNU(2,K) - RESIDUAL NUCLEUS ATOMIC NUMBER
C           SNU(3,K) - RESIDUAL EXCITATION ENERGY (MEV)
C           SNU(5,K) - PNX
C           SNU(6,K) - PNY   - RESIDUAL NUCLEUS MOMENTUM
C           SNU(7,K) - PNZ
C       NUCLEUS BEFORE DEEXCITATION IN /BEFORE/
C OUTPUT:
C        PARTICLES SPECTRA AND RESIDUAL NUCLEUS CHARACTERISTICS
C        IN ARRAYS OF COMMON /HADRON/ (SEE COMMENTS BELOW)
C-------------------------------------------------------------------------
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /SECHAR/ SPT(6,5000),SNU(10,101),LS6,LS100,LS10,LS11  ! GSITR
      COMMON /BEFORE/ BUP,BAP,BZP,BPNX,BPNY,BPNZ
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /BLFIS/ FIS,EF,SNT(6,6)
      COMMON /ANTLAB/ lanti
      DATA COS5 /0.99619478/, COS30 /0.86602544/, COS90 /0./
C
C Transformation of SPT, SNU in antilab. system
      if(lanti.EQ.1)CALL LABANT
C
C HISTOGRAMMING OF SECONDARY PARTICLE CHARACTERISTICS
      DO 160 J=1,LS100
      IPART=IFIX(SPT(5,J))
        IF(IPART.EQ.0)GO TO 200
      CT=SPT(1,J)
      T=SPT(4,J)
      W=SPT(6,J)
C
      IF(IPART.GT.12)IPART=IPART-8
      GO TO (1,2,3,4,5,6,7,8,9,10,11,12,21,22,23,24),IPART
C
C-------------------------NEUTRONS-------------------------------
    1 CALL HIST(T,0.,20.,1.,SLNT,28,W)
                  CALL HIST(T,0.,TMAXN,HN,SN18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXN,HN,SN90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXN,HN,SN30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXN,HN,SN05,28,W)
      GO TO 160
C
C-------------------------PROTONS---------------------------------
    2 CALL HIST(T,0.,30.,1.5,SLPR,28,W)
                  CALL HIST(T,0.,TMAXN,HN,SP18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXN,HN,SP90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXN,HN,SP30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXN,HN,SP05,28,W)
      GO TO 160
C
C-------------------------PI-MINUS----------------------------------
    3 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,PM18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXP,HP,PM90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXP,HP,PM30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXP,HP,PM05,28,W)      
      GO TO 160
C
C-------------------------PI-PLUS------------------------------------
    4 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,PP18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXP,HP,PP90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXP,HP,PP30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXP,HP,PP05,28,W)
      GO TO 160
C
C-------------------------PI0----------------------------------------
    5 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,P018,28,W)
      GO TO 160
C
C----------------------ANTINEUTRONS---------------------------------
    6 CALL HIST(T,0.,TMAXP,HP,SAN,28,W)  
      GO TO 160
C
C----------------------ANTIPROTONS----------------------------------
    7 CALL HIST(T,0.,TMAXP,HP,SAP,28,W)  
      GO TO 160
C
C----------------------K - MINUS-------------------------------------
    8 CALL HIST(T,0.,TMAXP,HP,SKM,28,W)
      GO TO 160
C
C----------------------K - PLUS--------------------------------------
    9 CALL HIST(T,0.,TMAXP,HP,SKP,28,W)  
      GO TO 160
C
C----------------------K0--------------------------------------------
   10 CALL HIST(T,0.,TMAXP,HP,SK0,28,W)  
      GO TO 160
C
C----------------------ANTI K0--------------------------------------
   11 CALL HIST(T,0.,TMAXP,HP,SAK0,28,W)  
      GO TO 160 
C
C----------------------GAMMA quant----------------------------------
   12 CALL HIST(T,0.,TMAXN,HN,SG18,28,W)  
      GO TO 160 
C
C-------------------------DEUTRONS----------------------------------
   21 CALL HIST(T,0.,40.,2.,SLDT,28,W)
      GO TO 160
C
C-------------------------TRITONS-----------------------------------
   22 CALL HIST(T,0.,40.,2.,SLTR,28,W)
      GO TO 160
C
C-------------------------HE3---------------------------------------
   23 CALL HIST(T,0.,40.,2.,SLH3,28,W)
      GO TO 160
C
C-------------------------ALPHAS----------------------------------
   24 CALL HIST(T,0.,40.,2.,SLAL,28,W)
      GO TO 160
C
  160 CONTINUE
C
C HISTOGRAMMING OF RESIDUAL NUCLEUS CHARACTERISTICS
  200 CONTINUE
C Histogramming of nucleus before deexcitation
      IF(BAP.LT.2.0 .OR. BZP.LT.0.0 .OR. BUP.LT.0.0)THEN
        CONTINUE
      ELSE
        CALL RESNHS(BUP,BAP,BZP,BPNX,BPNY,BPNZ,1.,
     *            BUSTR,BUSTR2,BUSTR5,BTSTR,BTSTRH,IZAB,IOUTB,IINB)
      END IF
C Registration of number of fissions
      IF(FIS .GT. 0.0)IFISS=IFISS+1
C Residual nuclei (Sobol, correction of 9.8.95)
      DO 210 J=2,LS11
C          IF(SNU(1,J) .GT. 0.)THEN
        IF(SNU(4,J).GT.0. .and. SNU(4,J).ne.6.)THEN
            A=SNU(1,J)
            Z=SNU(2,J)
            U=SNU(3,J)
              PNX=SNU(5,J)
              PNY=SNU(6,J)
              PNZ=SNU(7,J)
        ELSE
C              IF(J.EQ.2)THEN
C             SNU(4,J)=0. or SNU(4,J)=6.
            IF(SNU(4,J).EQ.6.)THEN
C             Full desintegration of residual nucleus
              IDES=IDES+1
              GO TO 210   ! instead RETURN, 26.09.96
            ELSE
              RETURN
            END IF
        END IF
C
C Histogramming of residual nucleus
        CALL RESNHS(U,A,Z,PNX,PNY,PNZ,1.,
     *                USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C
  210 CONTINUE
C
      RETURN
      END



      SUBROUTINE HISION
C REGISTRATION OF SHIELD/CG HADRON GENERATOR CHARACTERISTICS
C INPUT:
C       SECONDARY PARTICLES CHARACTERISTICS IN ARRAY SPT
C           SPT(1,J) - COS OF AZIMUTAL ANGLE OF SECONDARY PARTICLE
C           SPT(4,J) - KINETIC ENERGY OF SECONDARY PARTICLE (MEV)
C           SPT(5,J) - SECONDARY PARTICLE TYPE
C           SPT(6,J) - SECONDARY PARTICLE WEIGHT
C       RESIDUAL NUCLEUS CHARACTERISTICS IN SECOND LINE OF ARRAY SNU
C           SNU(1,K) - RESIDUAL NUCLEUS ATOMIC WEIGHT
C           SNU(2,K) - RESIDUAL NUCLEUS ATOMIC NUMBER
C           SNU(3,K) - RESIDUAL EXCITATION ENERGY (MEV)
C           SNU(5,K) - PNX
C           SNU(6,K) - PNY   - RESIDUAL NUCLEUS MOMENTUM
C           SNU(7,K) - PNZ
C       NUCLEUS BEFORE DEEXCITATION IN /BEFORE/
C OUTPUT:
C        PARTICLES SPECTRA AND RESIDUAL NUCLEUS CHARACTERISTICS
C        IN ARRAYS OF COMMON /HADRON/ (SEE COMMENTS BELOW)
C-------------------------------------------------------------------------
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /SECHAR/ SPT(6,5000),SNU(10,101),LS6,LS100,LS10,LS11  ! GSITR
      COMMON /BEFORE/ BUP,BAP,BZP,BPNX,BPNY,BPNZ
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /BLFIS/ FIS,EF,SNT(6,6)
      COMMON /ANTLAB/ lanti
      DATA COS5 /0.99619478/, COS30 /0.86602544/, COS90 /0./
C
C Transformation of SPT, SNU in antilab. system
      if(lanti.EQ.1)CALL LABANT
C
C HISTOGRAMMING OF SECONDARY PARTICLE CHARACTERISTICS
      DO 160 J=1,LS100
      IPART=IFIX(SPT(5,J))
        IF(IPART.EQ.0)GO TO 200
      CT=SPT(1,J)
      T=SPT(4,J)
      W=SPT(6,J)
C
      IF(IPART.GT.12)IPART=IPART-8
      GO TO (1,2,3,4,5,6,7,8,9,10,11,12,21,22,23,24),IPART
C
C-------------------------NEUTRONS-------------------------------
    1 CALL HIST(T,0.,20.,1.,SLNT,28,W)
                  CALL HIST(T,0.,TMAXN,HN,SN18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXN,HN,SN90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXN,HN,SN30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXN,HN,SN05,28,W)
      GO TO 160
C
C-------------------------PROTONS---------------------------------
    2 CALL HIST(T,0.,30.,1.5,SLPR,28,W)
                  CALL HIST(T,0.,TMAXN,HN,SP18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXN,HN,SP90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXN,HN,SP30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXN,HN,SP05,28,W)
      GO TO 160
C
C-------------------------PI-MINUS----------------------------------
    3 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,PM18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXP,HP,PM90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXP,HP,PM30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXP,HP,PM05,28,W)      
      GO TO 160
C
C-------------------------PI-PLUS------------------------------------
    4 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,PP18,28,W)
      IF(CT.GE.COS90) CALL HIST(T,0.,TMAXP,HP,PP90,28,W)
      IF(CT.GE.COS30) CALL HIST(T,0.,TMAXP,HP,PP30,28,W)
      IF(CT.GE.COS5 ) CALL HIST(T,0.,TMAXP,HP,PP05,28,W)
      GO TO 160
C
C-------------------------PI0----------------------------------------
    5 CONTINUE
                  CALL HIST(T,0.,TMAXP,HP,P018,28,W)
      GO TO 160
C
C----------------------ANTINEUTRONS---------------------------------
    6 CALL HIST(T,0.,TMAXP,HP,SAN,28,W)  
      GO TO 160
C
C----------------------ANTIPROTONS----------------------------------
    7 CALL HIST(T,0.,TMAXP,HP,SAP,28,W)  
      GO TO 160
C
C----------------------K - MINUS-------------------------------------
    8 CALL HIST(T,0.,TMAXP,HP,SKM,28,W)
      GO TO 160
C
C----------------------K - PLUS--------------------------------------
    9 CALL HIST(T,0.,TMAXP,HP,SKP,28,W)  
      GO TO 160
C
C----------------------K0--------------------------------------------
   10 CALL HIST(T,0.,TMAXP,HP,SK0,28,W)  
      GO TO 160
C
C----------------------ANTI K0--------------------------------------
   11 CALL HIST(T,0.,TMAXP,HP,SAK0,28,W)  
      GO TO 160 
C
C----------------------GAMMA quant----------------------------------
   12 CALL HIST(T,0.,TMAXN,HN,SG18,28,W)  
      GO TO 160 
C
C-------------------------DEUTRONS----------------------------------
   21 CALL HIST(T,0.,40.,2.,SLDT,28,W)
      GO TO 160
C
C-------------------------TRITONS-----------------------------------
   22 CALL HIST(T,0.,40.,2.,SLTR,28,W)
      GO TO 160
C
C-------------------------HE3---------------------------------------
   23 CALL HIST(T,0.,40.,2.,SLH3,28,W)
      GO TO 160
C
C-------------------------ALPHAS----------------------------------
   24 CALL HIST(T,0.,40.,2.,SLAL,28,W)
      GO TO 160
C
  160 CONTINUE
C
C HISTOGRAMMING OF RESIDUAL NUCLEUS CHARACTERISTICS
  200 CONTINUE
C Histogramming of nucleus before deexcitation
      IF(BAP.LT.2.0 .OR. BZP.LT.0.0 .OR. BUP.LT.0.0)THEN
        CONTINUE
      ELSE
        CALL RESNHS(BUP,BAP,BZP,BPNX,BPNY,BPNZ,1.,
     *            BUSTR,BUSTR2,BUSTR5,BTSTR,BTSTRH,IZAB,IOUTB,IINB)
      END IF
C Registration of number of fissions
      IF(FIS .GT. 0.0)IFISS=IFISS+1
C Residual nuclei (Sobol, correction of 9.8.95)
      DO 210 J=2,LS11
C          IF(SNU(1,J) .GT. 0.)THEN
        IF(SNU(4,J).GT.0. .and. SNU(4,J).ne.6.)THEN
            A=SNU(1,J)
            Z=SNU(2,J)
            U=SNU(3,J)
              PNX=SNU(5,J)
              PNY=SNU(6,J)
              PNZ=SNU(7,J)
        ELSE
C              IF(J.EQ.2)THEN
C             SNU(4,J)=0. or SNU(4,J)=6.
            IF(SNU(4,J).EQ.6.)THEN
C             Full desintegration of residual nucleus
              IDES=IDES+1
              GO TO 210   ! instead RETURN, 26.09.96
            ELSE
              RETURN
            END IF
        END IF
C
C Histogramming of residual nucleus
        CALL RESNHS(U,A,Z,PNX,PNY,PNZ,1.,
     *                USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C
  210 CONTINUE
C
      RETURN
      END



      SUBROUTINE CLEHAD
C AUXILIARY OPERATIONS FOR SHIELD/CG HADRON GENERATOR HISTOGRAMMING
      COMMON /NUMINT/ INTIN,INTEL
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
      COMMON /SPECAGT/ SPECAGT(126,30,180)                          ! HISTAGT
C
        INTIN=0
        INTEL=0
C
      DO K=1,180
        DO J=1,30
          DO I=1,126
            SPECAGT(I,J,K)=0.                                       ! HISTAGT
          END DO
        END DO
      END DO
C CLEANING OF ARRAYS OF COMMON /HADRON/
      DO 1 J=1,28
      SN05(J)=0.
      SN30(J)=0.
      SN90(J)=0.
      SN18(J)=0.
        SP05(J)=0.
        SP30(J)=0.
        SP90(J)=0.
        SP18(J)=0.
        SG18(J)=0.
            PM05(J)=0.
            PM30(J)=0.
            PM90(J)=0.
            PM18(J)=0.
              PP05(J)=0.
              PP30(J)=0.
              PP90(J)=0.
              PP18(J)=0.
              P018(J)=0.
                  SLNT(J)=0.
                  SLPR(J)=0.
                  SLDT(J)=0.
                  SLTR(J)=0.
                  SLH3(J)=0.
                  SLAL(J)=0.
                    BUSTR(J)=0.
                    BUSTR2(J)=0.
                    BUSTR5(J)=0.
                    BTSTR(J)=0.
                    BTSTRH(J)=0.
                        USTR(J)=0.
                        USTR2(J)=0.
                        USTR5(J)=0.
                        TSTR(J)=0.
                        TSTRH(J)=0.
                          SAN(J)=0.
                          SAP(J)=0.
                          SKM(J)=0.
                          SKP(J)=0.
                          SK0(J)=0.
                          SAK0(J)=0.
    1 CONTINUE
C
        IFISS=0
        IDES=0
      DO 2 J=1,100
      DO 2 I=1,25
      IZAB(I,J)=0
    2 IZA (I,J)=0
             IOUTB=0
             IINB=0
                 IOUT=0
                 IIN=0
C
C LIMITS AND STEPS OF PARTICLE SPECTRA
      IF(TINT.LE.50.)THEN
        TMAXN=50.
        HN=2.5
        TMAXP=50.
        HP=2.5
      ELSE
        TMAXN=TINT
        HN=TINT*0.05
        TMAXP=TINT*0.5
        HP=TINT*0.025
      END IF
C
C ENERGY MESH OF SPECTRA
      DO 3 J=1,20 
      DTN(J)=HN*FLOAT(J)
      DTP(J)=HP*FLOAT(J)
    3 CONTINUE
C
C Auxiliary operations for residual nuclei histogramming
      CALL RESNCL
C
C Auxiliary operations for particle conversion diagnostic
      CALL CLECON
C
      RETURN
      END



      SUBROUTINE CLEION
C AUXILIARY OPERATIONS FOR SHIELD/CG HADRON GENERATOR HISTOGRAMMING
      COMMON /NUMINT/ INTIN,INTEL
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
      COMMON /SPECAGT/ SPECAGT(126,30,180)                          ! HISTAGT
C
        INTIN=0
        INTEL=0
C
      DO K=1,180
        DO J=1,30
          DO I=1,126
            SPECAGT(I,J,K)=0.                                       ! HISTAGT
          END DO
        END DO
      END DO
C CLEANING OF ARRAYS OF COMMON /HADRON/
      DO 1 J=1,28
      SN05(J)=0.
      SN30(J)=0.
      SN90(J)=0.
      SN18(J)=0.
        SP05(J)=0.
        SP30(J)=0.
        SP90(J)=0.
        SP18(J)=0.
        SG18(J)=0.
            PM05(J)=0.
            PM30(J)=0.
            PM90(J)=0.
            PM18(J)=0.
              PP05(J)=0.
              PP30(J)=0.
              PP90(J)=0.
              PP18(J)=0.
              P018(J)=0.
                  SLNT(J)=0.
                  SLPR(J)=0.
                  SLDT(J)=0.
                  SLTR(J)=0.
                  SLH3(J)=0.
                  SLAL(J)=0.
                    BUSTR(J)=0.
                    BUSTR2(J)=0.
                    BUSTR5(J)=0.
                    BTSTR(J)=0.
                    BTSTRH(J)=0.
                        USTR(J)=0.
                        USTR2(J)=0.
                        USTR5(J)=0.
                        TSTR(J)=0.
                        TSTRH(J)=0.
                          SAN(J)=0.
                          SAP(J)=0.
                          SKM(J)=0.
                          SKP(J)=0.
                          SK0(J)=0.
                          SAK0(J)=0.
    1 CONTINUE
C
        IFISS=0
        IDES=0
      DO 2 J=1,100
      DO 2 I=1,25
      IZAB(I,J)=0
    2 IZA (I,J)=0
             IOUTB=0
             IINB=0
                 IOUT=0
                 IIN=0
C
C LIMITS AND STEPS OF PARTICLE SPECTRA
      IF(TINT.LE.50.)THEN
        TMAXN=50.
        HN=2.5
        TMAXP=50.
        HP=2.5
      ELSE
        TMAXN=TINT
        HN=TINT*0.05
        TMAXP=TINT*0.5
        HP=TINT*0.025
      END IF
C
C ENERGY MESH OF SPECTRA
      DO 3 J=1,20 
      DTN(J)=HN*FLOAT(J)
      DTP(J)=HP*FLOAT(J)
    3 CONTINUE
C
C Auxiliary operations for residual nuclei histogramming
      CALL RESNCL
C
C Auxiliary operations for particle conversion diagnostic
      CALL CLECON
C
      RETURN
      END


      
      SUBROUTINE CLECON
C Cleaning of arrays for AGT-conversion diagnostic
      COMMON /CONVEN/ ECONV(65),NCONV(65),JCONV(65),UEXCIT,ENKIN
      DO J=1,65
        ECONV(J)=0.
        NCONV(J)=0
        JCONV(J)=0
      END DO
        UEXCIT=0.
        ENKIN=0.
      RETURN
      END



      SUBROUTINE PRICON
C Printout of AGT-conversion diagnostic
      CHARACTER*8  PNAME
      COMMON /PNAME/ PNAME(65),IDENTP(65)
      COMMON /CONVEN/ ECONV(65),NCONV(65),JCONV(65),UEXCIT,ENKIN
C
      DIMENSION PARTIC(24)
      CHARACTER*7 PARTIC
      DATA PARTIC /'NEUTRON',' PROTON','  PI-  ','  PI+  ','  PI0  ',
     *             ' ANTI N',' ANTI P','  K-   ','  K+   ','  K0   ',
     *             'ANTI K0',' GAMMA ','ELECTRN','POSITRN','  MU-  ',
     *             '  MU+  ','  NU E ','ANTINUE',' NU MU ','ANTINUM',
     *             'DEUTRON','TRITIUM','HELIUM3',' ALPHA '/
C
      DIMENSION IDPSHL(20) ! AGT-codes of particles, accepted in SHIELD
C                   IDENTP[i]  !   i   Particle    JPART
      DATA IDPSHL/             !
     *                  120,   !  [1]   PI+           4
     *                 -120,   !  [2]   PI-           3
     *                  130,   !  [3]   K+            9
     *                 -130,   !  [4]   K-            8
     *                  230,   !  [5]   K0           10
     *                 -230,   !  [6]   AK0          11
     *                  110,   !  [7]   PI0           5
     *                -1120,   ! [19]   AP            7
     *                -1220,   ! [20]   AN            6
     *                 1120,   ! [37]   P             2
     *                 1220,   ! [38]   N             1
     *                   10,   ! [57]   GM           12
     *                   12,   ! [58]   E+           14
     *                  -12,   ! [59]   E-           13
     *                  -14,   ! [60]   MU+          16
     *                   14,   ! [61]   MU-          15
     *                   11,   ! [62]   NUE          17
     *                   13,   ! [63]   NUM          19
     *                  -11,   ! [64]   ANUE         18
     *                  -13/   ! [65]   ANUM         20
C
      WRITE(34,1)
    1 FORMAT(/5X,'----- Protocol of AGT to SHIELD particles',
     *          ' conversion -----')
      WRITE(34,2)
    2 FORMAT(5X,'AGT',23X,'SHIELD     SUM Ekin  No.of Part.')
C
C Counters of total energies and particle numbers
      TSHLD=0.      ! Summary energy of SHIELD particles
      NSHLD=0       ! Total number of SHIELD particles
      TCON=0.     ! Summary energy of CONVERTED particles
      NCON=0      ! Total number of CONVERTED particles
        TIGN=0.   ! Summary energy of IGNORED particles
        NIGN=0    ! Total number of IGNORED particles
C      
C ====================== Main loop ============================     
      DO 100 J=1,65
        IDP=IDENTP(J)   ! AGT particle code
        JPR= JCONV(J)   ! SHIELD particle code
           DO K=1,20
             IF(IDP.EQ.IDPSHL(K))GO TO 20  ! IDP is accepted in SHIELD
           END DO
           GO TO 30                       ! IDP isn't accepted in SHIELD
C
   20     CONTINUE
C---------SHIELD particles   
        IF(NCONV(J).NE.0)THEN    ! Output only if the particles exist
          TSHLD=TSHLD+ECONV(J)
          NSHLD=NSHLD+NCONV(J)
          WRITE(34,21)PARTIC(JCONV(J)),ECONV(J),NCONV(J)
   21       FORMAT(30X,A7,': ',E11.5,I12)
        END IF
        GO TO 100
C
   30     CONTINUE
        IF(NCONV(J).NE.0)THEN    ! Output only if the particles exist
          IF(JPR.NE.0)THEN  
C-------------CONVERTED particles   
            TCON=TCON+ECONV(J)
            NCON=NCON+NCONV(J)
            WRITE(34,31)PNAME(J),PARTIC(JCONV(J)),ECONV(J),NCONV(J)
   31         FORMAT(5X,A8,' is converted to ',A7,': ',E11.5,I12)
            GO TO 100
          ELSE
C-------------IGNORED particles   
            TIGN=TIGN+ECONV(J)
            NIGN=NIGN+NCONV(J)
            WRITE(34,32)PNAME(J),ECONV(J),NCONV(J)
   32         FORMAT(5X,A8,' is ignored',13X,': ',E11.5,I12)
            GO TO 100
          END IF
        END IF
C
  100 CONTINUE
C =======================================================
C
      WRITE(34,40)
   40 FORMAT(5X,'--------------------------------:')
      WRITE(34,41)TSHLD,NSHLD
   41 FORMAT(21X,'SHIELD particles: ',E11.5,I12)
      WRITE(34,42)TCON,NCON
   42 FORMAT(18X,'CONVERTED particles: ',E11.5,I12)
      WRITE(34,43)TIGN,NIGN
   43 FORMAT(20X,'IGNORED particles: ',E11.5,I12)
      WRITE(34,44)UEXCIT
   44 FORMAT(10X,'EXCITATION energy of nuclei: ',E11.5)
      WRITE(34,45)ENKIN
   45 FORMAT(13X,'KINETIC energy of nuclei: ',E11.5)
C
      RETURN
      END



      SUBROUTINE PRIHAD(NSTAT)
C PRINTING OF SHIELD/CG HADRON GENERATOR TOTAL OUTPUT.
C NSTAT - MONTE CARLO STATISTICS.
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
        COMMON /NUMINT/ INTIN,INTEL
        COMMON /HHSIGM/ SITO,SIEL
        REAL*8 SITO,SIEL
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
        COMMON /HIPROJ/ APROJ,ZPROJ
      COMMON /ANTLAB/ lanti
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
C
      DIMENSION NAME(11)
      CHARACTER*8 NAME
      DATA NAME /' NEUTRON',' PROTON ','PI-MINUS',' PI-PLUS',' PI-ZERO',
     *'ANTINEUT','ANTIPROT','K-MINUS','K-PLUS','K0','ANTIK0'/
C
C----------------------- TITLE PRINTING -----------------------------
      WRITE(34,1)
    1 FORMAT(/5X,'SHIELD hA- AND AA- GENERATOR OUTPUT.')
C
C Is projectile Particle or Nucleus?
          IF(JPART.le.11)THEN                                        !HION2
      WRITE(34,2) NAME(JPART),TINT,lanti
    2 FORMAT(5X,'INCIDENT PARTICLE IS ',A8,', T0=',F11.1,' MEV.',
     *          '  ANTILAB=',I1)
        ELSE
            IAPROJ=IFIX(APROJ)
            IZPROJ=IFIX(ZPROJ)
      WRITE(34,52) SYMB(IZPROJ),IZPROJ,IAPROJ,TINT
   52 FORMAT(5X,'INCIDENT HEAVY ION IS ',A2,'(',I2,',',I3,'),',
     *           ' T0=',F11.1,' MEV/A.')
        END IF
C
C Nucleus-target:      
      WRITE(34,3) SYMB(NUCLID),IFIX(ZNUC(NUCLID)),ATWEI(NUCLID)
    3 FORMAT(5X,'NUCLEUS-TARGET IS ',A2,'(',I2,',',F7.3,').')
C
C Calculation of geometric and inelastic cross sections
      CALL SIGEOM(SGEOM,APR,ZPR,ATG,ZTG)
      IF(APR.LT.1.1 .AND. ATG.LE.1.1)THEN
C     ---- hh-interaction ----
        WRITE(34,41) NSTAT
   41     FORMAT(5X,'STATISTICS -',I9,
     *               ' ELASTIC AND INELASTIC INTERACTIONS.')
            SIIN=SITO-SIEL
        WRITE(34,42)SIIN
   42     FORMAT(15X,'INELASTIC CROSS SECTION',F9.2,' MB')
        WRITE(37) SIIN                                        ! HISTAGT
        WRITE(34,43)SIEL
   43     FORMAT(15X,'ELASTIC CROSS SECTION  ',F9.2,' MB')
        WRITE(34,44)SITO
   44     FORMAT(15X,'TOTAL CROSS SECTION    ',F9.2,' MB')
      ELSE
C     ---- hA- and AA- interactions ------
        WRITE(34,45) NSTAT
   45     FORMAT(5X,'STATISTICS -',I9,' INELASTIC INTERACTIONS.')
        INTOT=INTIN+INTEL
            WWW=FLOAT(INTIN)/FLOAT(INTOT)
              SINEL=SGEOM*WWW
        WRITE(34,48)SGEOM                ! Sobol, 23.02.96
   48     FORMAT(15X,'GEOMETRIC CROSS SECTION',F9.2,' MB')
        WRITE(34,46)SINEL
   46     FORMAT(15X,'INELASTIC CROSS SECTION',F9.2,' MB')
        WRITE(37) SINEL                                       ! HISTAGT
        WRITE(34,47)INTEL
   47     FORMAT(15X,'NUMBER OF ELASTIC SCATTERING: ',I8)
      END IF
C
C----------------- PRINTING OF NUCLEON and gamma SPECTRA ----------
      WRITE(34,5)
    5 FORMAT(/28X,'NEUTRONS SPECTRA',37X,'PROTONS SPECTRA',18X,
     *       'GAMMA SPECTRUM')
      WRITE(34,6)
    6 FORMAT('   DELTA T',12X,'POLAR ANGLE INTERVAL (DEGR)',26X,
     *       'POLAR ANGLE INTERVAL (DEGR)')
      WRITE(34,7)
    7 FORMAT('    (MEV)',2(12X,'0-5',8X,'0-30',8X,'0-90',7X,'0-180',2X),
     *8X,'0-180')
C
      DO 100 J=1,20
  100 WRITE(34,8) DTN(J),SN05(J),SN30(J),SN90(J),SN18(J),
     *                   SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
    8 FORMAT(' .-',F8.0,1X,4F12.1,5X,4F12.1,3X,F12.1)
C
      DO J=21,28
C Changed by A.Timofeev at 18/07/2011 14:31
C For compatibility with GNU gfortran
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
      WRITE(34,9) SN05(J),SN30(J),SN90(J),SN18(J),
     *                SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
      ELSE
      WRITE(34,10) SN05(J),SN30(J),SN90(J),SN18(J),
     *                SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
      END IF
      ENDDO
    9 FORMAT(12X,4F12.0,5X,4F12.0,3X,F12.0)
   10 FORMAT(12X,4E12.5,5X,4E12.5,3X,E12.5)
C End of changed block, previous version below
C      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
C        ASSIGN 9 TO LABEL
C      ELSE
C        ASSIGN 10 TO LABEL
C      END IF
C  101 WRITE(34,LABEL) SN05(J),SN30(J),SN90(J),SN18(J),
C     *                SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
C    9 FORMAT(12X,4F12.0,5X,4F12.0,3X,F12.0)
C   10 FORMAT(12X,4E12.5,5X,4E12.5,3X,E12.5)
C end of previous version
C--------------------------PRINTING OF PION SPECTRA --------------------
      WRITE(34,11)
   11 FORMAT(/32X,'PI-  SPECTRA',40X,'PI+  SPECTRA',20X,'PI0 SPECTRUM')
      WRITE(34,6)
      WRITE(34,7)
C
      DO 200 J=1,20
  200 WRITE(34,8) DTP(J),PM05(J),PM30(J),PM90(J),PM18(J),
     *                   PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
C
C Changed by A.Timofeev at 18/07/2011 14:33
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
      WRITE(34,9) PM05(J),PM30(J),PM90(J),PM18(J),
     *                PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
      ELSE
      WRITE(34,10) PM05(J),PM30(J),PM90(J),PM18(J),
     *                PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
      END IF
      ENDDO
C End of changed block
C------------------PRINTING OF ANTINEUTRONS, ANTIPROTONS, KAONS AND -
C-----------------------ANTIKAONS SPECTRA ---------------------------
      WRITE(34,31)
   31 FORMAT(/57X,'ANTINUCLEON AND KAON SPECTRA',
     *   /24X,'ANTINEUTRONS',6X,'ANTIPROTONS',10X,
     *'K-MINUS',11X,'K-PLUS',15X,'K0',11X,'ANTI-K0')
      WRITE(34,32)
   32 FORMAT('   DELTA T ',46X,'POLAR ANGLE INTERVAL (DEGR)',
     *       /'    (MEV)  ',20X,'0-180',5(12X,'0-180'))
      DO 310 J=1,20
  310 WRITE(34,19) DTP(J),SAN(J),SAP(J),SKM(J),SKP(J),SK0(J),SAK0(J)
   19 FORMAT(' .-',F8.0,13X,5(F12.1,5X),F12.1)
      DO M=21,28
      IF(M.EQ.21 .OR. M.EQ.23 .OR. M .EQ.25 .OR. M .EQ. 27)  THEN
         WRITE(34,27) SAN(M),SAP(M),SKM(M),SKP(M),SK0(M),SAK0(M)         
      ELSE
         WRITE(34,28) SAN(M),SAP(M),SKM(M),SKP(M),SK0(M),SAK0(M)         
      END IF
      END DO
   27 FORMAT(24X,5(F12.0,5X),F12.0)
   28 FORMAT(24X,5(E12.5,5X),E12.5)
C
C------------ PRINTING OF LOW ENERGY PARTICLE SPECTRA ---------------
      WRITE(34,13)
   13 FORMAT(/11X,'LOW ENERGY PARTICLES SPECTRA INTO FULL SOLID ANGLE')
      WRITE(34,14)
   14 FORMAT(4X,'NEUTRONS     PROTONS    DEUTRONS     TRITONS',9X,
     *       'HE3',6X,'ALPHAS')
      WRITE(34,15)
   15 FORMAT(2X,'(0-20 MEV)  (0-30 MEV)',4(2X,'(0-40 MEV)'))
C
      DO 300 J=1,20
  300 WRITE(34,16) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
   16 FORMAT(6F12.1)
C
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
         WRITE(34,17) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
      ELSE
         WRITE(34,18) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
      END IF
      END DO
   17 FORMAT(6F12.0)
   18 FORMAT(6E12.5)
C
C Printing of residual nuclei distribution
c      WRITE(34,401)
c  401 FORMAT(/' BEFORE DEEXCITATION:')
c      CALL RESNPR(BUSTR,BUSTR2,BUSTR5,BTSTR,BTSTRH,IZAB,IOUTB,IINB)
      WRITE(34,402)IFISS,IDES
  402 FORMAT(/' AFTER DEEXCITATION:'/' NUMBER OF FISSIONS=',I8,
     *        8X,'NUMBER OF FULL DESINTEGRATIONS=',I8)
      CALL RESNPR(USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C
C Printout of AGT to SHIELD conversion protocol
      CALL PRICON
C
      LASTIX=IX
      WRITE(34,26) IXFIRS,LASTIX
   26 FORMAT(/' RANDOM GENERATOR STATUS: IXFIRS=',I12/26X,'LISTIX=',I12)
C
      RETURN
      END



      SUBROUTINE PRIION(NSTAT)
C PRINTING OF SHIELD/CG HADRON GENERATOR TOTAL OUTPUT.
C NSTAT - MONTE CARLO STATISTICS.
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
        COMMON /NUMINT/ INTIN,INTEL
        COMMON /HHSIGM/ SITO,SIEL
        REAL*8 SITO,SIEL
      COMMON /HADRON/ SN05(28),SN30(28),SN90(28),SN18(28),
     *                SP05(28),SP30(28),SP90(28),SP18(28),SG18(28),
     *                PM05(28),PM30(28),PM90(28),PM18(28),
     *                PP05(28),PP30(28),PP90(28),PP18(28),P018(28),
     *       SLNT(28),SLPR(28),SLDT(28),SLTR(28),SLH3(28),SLAL(28),
     *       SAN(28),SAP(28),SKM(28),SKP(28),SK0(28),SAK0(28),
     *      BUSTR(28),BUSTR2(28),BUSTR5(28),BTSTR(28),BTSTRH(28),
     *       USTR(28), USTR2(28), USTR5(28), TSTR(28), TSTRH(28),
     *                IFISS,IDES,
     *                IZAB(25,100),IOUTB,IINB,
     *                IZA (25,100),IOUT, IIN
      COMMON /HADSER/ TMAXN,HN,TMAXP,HP,DTN(20),DTP(20)
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
        COMMON /HIPROJ/ APROJ,ZPROJ
      COMMON /ANTLAB/ lanti
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
C
      DIMENSION NAME(11)
      CHARACTER*8 NAME
      DATA NAME /' NEUTRON',' PROTON ','PI-MINUS',' PI-PLUS',' PI-ZERO',
     *'ANTINEUT','ANTIPROT','K-MINUS','K-PLUS','K0','ANTIK0'/
C
C----------------------- TITLE PRINTING -----------------------------
      WRITE(34,1)
    1 FORMAT(/5X,'SHIELD hA- AND AA- GENERATOR OUTPUT.')
C
C Is projectile Particle or Nucleus?
          IF(JPART.le.11)THEN                                        !HION2
      WRITE(34,2) NAME(JPART),TINT,lanti
    2 FORMAT(5X,'INCIDENT PARTICLE IS ',A8,', T0=',F11.1,' MEV.',
     *          '  ANTILAB=',I1)
        ELSE
            IAPROJ=IFIX(APROJ)
            IZPROJ=IFIX(ZPROJ)
      WRITE(34,52) SYMB(IZPROJ),IZPROJ,IAPROJ,TINT
   52 FORMAT(5X,'INCIDENT HEAVY ION IS ',A2,'(',I2,',',I3,'),',
     *           ' T0=',F11.1,' MEV/A.')
        END IF
C
C Nucleus-target:      
      WRITE(34,3) SYMB(NUCLID),IFIX(ZNUC(NUCLID)),ATWEI(NUCLID)
    3 FORMAT(5X,'NUCLEUS-TARGET IS ',A2,'(',I2,',',F7.3,').')
C
C Calculation of geometric and inelastic cross sections
      CALL SIGEOM(SGEOM,APR,ZPR,ATG,ZTG)
      IF(APR.LT.1.1 .AND. ATG.LE.1.1)THEN
C     ---- hh-interaction ----
        WRITE(34,41) NSTAT
   41     FORMAT(5X,'STATISTICS -',I9,
     *               ' ELASTIC AND INELASTIC INTERACTIONS.')
            SIIN=SITO-SIEL
        WRITE(34,42)SIIN
   42     FORMAT(15X,'INELASTIC CROSS SECTION',F9.2,' MB')
        WRITE(37) SIIN                                        ! HISTAGT
        WRITE(34,43)SIEL
   43     FORMAT(15X,'ELASTIC CROSS SECTION  ',F9.2,' MB')
        WRITE(34,44)SITO
   44     FORMAT(15X,'TOTAL CROSS SECTION    ',F9.2,' MB')
      ELSE
C     ---- hA- and AA- interactions ------
        WRITE(34,45) NSTAT
   45     FORMAT(5X,'STATISTICS -',I9,' INELASTIC INTERACTIONS.')
        INTOT=INTIN+INTEL
            WWW=FLOAT(INTIN)/FLOAT(INTOT)
              SINEL=SGEOM*WWW
        WRITE(34,48)SGEOM                ! Sobol, 23.02.96
   48     FORMAT(15X,'GEOMETRIC CROSS SECTION',F9.2,' MB')
        WRITE(34,46)SINEL
   46     FORMAT(15X,'INELASTIC CROSS SECTION',F9.2,' MB')
        WRITE(37) SINEL                                       ! HISTAGT
        WRITE(34,47)INTEL
   47     FORMAT(15X,'NUMBER OF ELASTIC SCATTERING: ',I8)
      END IF
C
C----------------- PRINTING OF NUCLEON and gamma SPECTRA ----------
      WRITE(34,5)
    5 FORMAT(/28X,'NEUTRONS SPECTRA',37X,'PROTONS SPECTRA',18X,
     *       'GAMMA SPECTRUM')
      WRITE(34,6)
    6 FORMAT('   DELTA T',12X,'POLAR ANGLE INTERVAL (DEGR)',26X,
     *       'POLAR ANGLE INTERVAL (DEGR)')
      WRITE(34,7)
    7 FORMAT('    (MEV)',2(12X,'0-5',8X,'0-30',8X,'0-90',7X,'0-180',2X),
     *8X,'0-180')
C
      DO 100 J=1,20
  100 WRITE(34,8) DTN(J),SN05(J),SN30(J),SN90(J),SN18(J),
     *                   SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
    8 FORMAT(' .-',F8.0,1X,4F12.1,5X,4F12.1,3X,F12.1)
C
C Changed by A.Timofeev at 18/07/2011 14:39
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
      WRITE(34,9) SN05(J),SN30(J),SN90(J),SN18(J),
     *                SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
      ELSE
      WRITE(34,10) SN05(J),SN30(J),SN90(J),SN18(J),
     *                SP05(J),SP30(J),SP90(J),SP18(J),SG18(J)
      END IF
      ENDDO
    9 FORMAT(12X,4F12.0,5X,4F12.0,3X,F12.0)
   10 FORMAT(12X,4E12.5,5X,4E12.5,3X,E12.5)
C End of changed block
C--------------------------PRINTING OF PION SPECTRA --------------------
      WRITE(34,11)
   11 FORMAT(/32X,'PI-  SPECTRA',40X,'PI+  SPECTRA',20X,'PI0 SPECTRUM')
      WRITE(34,6)
      WRITE(34,7)
C
      DO 200 J=1,20
  200 WRITE(34,8) DTP(J),PM05(J),PM30(J),PM90(J),PM18(J),
     *                   PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
C Changed by A.Timofeev at 18/07/2011 14:40
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
         WRITE(34,9) PM05(J),PM30(J),PM90(J),PM18(J),
     *                PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
      ELSE
         WRITE(34,10) PM05(J),PM30(J),PM90(J),PM18(J),
     *                PP05(J),PP30(J),PP90(J),PP18(J),P018(J)
      END IF
      ENDDO
C End of changed block
C------------------PRINTING OF ANTINEUTRONS, ANTIPROTONS, KAONS AND -
C-----------------------ANTIKAONS SPECTRA ---------------------------
      WRITE(34,31)
   31 FORMAT(/57X,'ANTINUCLEON AND KAON SPECTRA',
     *   /24X,'ANTINEUTRONS',6X,'ANTIPROTONS',10X,
     *'K-MINUS',11X,'K-PLUS',15X,'K0',11X,'ANTI-K0')
      WRITE(34,32)
   32 FORMAT('   DELTA T ',46X,'POLAR ANGLE INTERVAL (DEGR)',
     *       /'    (MEV)  ',20X,'0-180',5(12X,'0-180'))
      DO 310 J=1,20
  310 WRITE(34,19) DTP(J),SAN(J),SAP(J),SKM(J),SKP(J),SK0(J),SAK0(J)
   19 FORMAT(' .-',F8.0,13X,5(F12.1,5X),F12.1)
      DO M=21,28
      IF(M.EQ.21 .OR. M.EQ.23 .OR. M .EQ.25 .OR. M .EQ. 27)  THEN
         WRITE(34,27) SAN(M),SAP(M),SKM(M),SKP(M),SK0(M),SAK0(M)         
      ELSE
         WRITE(34,28) SAN(M),SAP(M),SKM(M),SKP(M),SK0(M),SAK0(M)         
      END IF
      ENDDO
   27 FORMAT(24X,5(F12.0,5X),F12.0)
   28 FORMAT(24X,5(E12.5,5X),E12.5)
C
C------------ PRINTING OF LOW ENERGY PARTICLE SPECTRA ---------------
      WRITE(34,13)
   13 FORMAT(/11X,'LOW ENERGY PARTICLES SPECTRA INTO FULL SOLID ANGLE')
      WRITE(34,14)
   14 FORMAT(4X,'NEUTRONS     PROTONS    DEUTRONS     TRITONS',9X,
     *       'HE3',6X,'ALPHAS')
      WRITE(34,15)
   15 FORMAT(2X,'(0-20 MEV)  (0-30 MEV)',4(2X,'(0-40 MEV)'))
C
      DO 300 J=1,20
  300 WRITE(34,16) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
   16 FORMAT(6F12.1)
C Changed by A.Timofeev at 18/07/2011 14:41
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
         WRITE(34,17) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
      ELSE
         WRITE(34,18) SLNT(J),SLPR(J),SLDT(J),SLTR(J),SLH3(J),SLAL(J)
      END IF
      ENDDO
   17 FORMAT(6F12.0)
   18 FORMAT(6E12.5)
C End og changed block
C Printing of residual nuclei distribution
c      WRITE(34,401)
c  401 FORMAT(/' BEFORE DEEXCITATION:')
c      CALL RESNPR(BUSTR,BUSTR2,BUSTR5,BTSTR,BTSTRH,IZAB,IOUTB,IINB)
      WRITE(34,402)IFISS,IDES
  402 FORMAT(/' AFTER DEEXCITATION:'/' NUMBER OF FISSIONS=',I8,
     *        8X,'NUMBER OF FULL DESINTEGRATIONS=',I8)
      CALL RESNPR(USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C
C Printout of AGT to SHIELD conversion protocol
      CALL PRICON
C
      LASTIX=IX
      WRITE(34,26) IXFIRS,LASTIX
   26 FORMAT(/' RANDOM GENERATOR STATUS: IXFIRS=',I12/26X,'LISTIX=',I12)
C
      RETURN
      END



      SUBROUTINE RESNHS(U,A,Z,PNX,PNY,PNZ,STATW,
     *                  USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C Histogramming of residual nuclei characteristics
C INPUT: U - Excitation energy (MeV) of residual nucleus
C        A,Z - A and Z of residual nucleus
C        PNX,PNY,PNZ - Momentum of residual nucleus (MeV/c)
C        STATW - Statistical weight of residual nucleus
C
C OUTPUT: USTR(28),USTR2(28),USTR5(28) - Excitation energy spectrum 
C                                  (0-10), (0-200), and (0-500) MeV
C         TSTR(28),TSTRH(28) - Kinetic energy spectrum 
C                              (0-20) and (0-100) MeV
C         IZA(25,100) - (A,Z)-distribution
C         IOUT, IIN - number of nuclei outside/inside (A,Z)-distribution
C-----------------------------------------------------------------------
      COMMON /RESN01/ ASTAB(100),IAA(25)
      DIMENSION USTR(28),USTR2(28),USTR5(28),TSTR(28),TSTRH(28),
     *IZA(25,100)
C
      IF(A.GT.0.)THEN
C          TNUC=(PNX**2+PNY**2+PNZ**2)/(1880.*A)   ! Nonrelativistic!
      TNUC=SQRT((PNX**2+PNY**2+PNZ**2)+(940.*A)**2)-940.*A  ! Relativistic!
      ELSE
        RETURN
      END IF
C
C HISTOGRAMMING OF RESIDUAL NUCLEUS ENERGETIC CHARACTERISTICS
        CALL HIST(U,0., 10.,0.5,USTR, 28,STATW)
        CALL HIST(U,0.,200.,10.,USTR2,28,STATW)
        CALL HIST(U,0.,500.,25.,USTR5,28,STATW)
        CALL HIST(TNUC,0., 20.,1.,TSTR, 28,STATW)
        CALL HIST(TNUC,0.,100.,5.,TSTRH,28,STATW)
C
C HISTOGRAMMING OF RESIDUAL NUCLEI (A,Z)-DISTRIBUTION
            IA=IFIX(A)
            IZ=IFIX(Z)
        IF(IZ.LT.1 .OR. IZ.GT.100)THEN
            WRITE(25,1000) IZ
 1000     FORMAT(' RESNHS DIAGNOSTIC: Z*=',I3,' - OUTSIDE OF  [1,100]')
            IOUT=IOUT+1
            RETURN
        END IF
C
              JA=IA-(IFIX(ASTAB(IZ))-12)+1
C
        IF(JA.LT.1 .OR. JA.GT.25)THEN
            IOUT=IOUT+1
            RETURN
        ELSE
            IIN=IIN+1
        END IF
C
              IZA(JA,IZ)=IZA(JA,IZ)+STATW
C
      RETURN
      END



      SUBROUTINE RESNCL
C Auxiliary operations for residual nuclei histogramming 
      COMMON /RESN01/ ASTAB(100),IAA(25)
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
C
C MESH FOR RESIDUAL NUCLEUS (A,Z)-DISTRIBUTION
C     BETHA-STABILITY CURVE A0(Z):
      DO 10 J=1,100
        Z=ZNUC(J)
            ALPHA=Z*(1.25E-07*Z**2+0.99)
            BETHA=Z*SQRT(2.475E-07*Z**2+0.9801)
              U=(ALPHA+BETHA)**0.333333333
              IF(ALPHA.GT.BETHA)THEN
                  V=(ALPHA-BETHA)**0.333333333
              ELSE
                  V=0.
              END IF
        ASTAB(J)=ANINT((U+V+0.005*Z)**3)
   10 CONTINUE
C
        IAA(13)=0
      DO 11 J=1,12
        IAA(13-J)=-J
        IAA(13+J)=+J
   11 CONTINUE
C
      RETURN
      END



      SUBROUTINE RESNPR(USTR,USTR2,USTR5,TSTR,TSTRH,IZA,IOUT,IIN)
C Printing of residual nuclei distributions
C Input: USTR,USTR2,USTR5 - Excitation energy distribution
C        TSTR,TSTRH - Kinetic energy distribution
C        IZA - Residual nuclei (A,Z) distribution
C        IOUT,IIN - Number of nuclei outside/inside (A,Z) distribution
C
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /RESN01/ ASTAB(100),IAA(25)
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
      DIMENSION USTR(28),USTR2(28),USTR5(28),TSTR(28),TSTRH(28),
     *          IZA(25,100)
C
C---------- PRINTING OF RESIDUAL NUCLEI ENERGY SPECTRA -------------
      WRITE(34,13)
   13 FORMAT(30X,'RESIDUAL NUCLEUS SPECTRA')
      WRITE(34,14)
   14 FORMAT(14X,'EXCITATION',21X,'KIN. ENERGY SPECTRUM')
      WRITE(34,15)
   15 FORMAT(3X,'(0-10 MEV)  (0-200 MEV)  (0-500 MEV)',5X,
     *          '(0-20 MEV)  (0-100 MEV)')
C
      DO 300 J=1,20
  300 WRITE(34,16) USTR(J),USTR2(J),USTR5(J),TSTR(J),TSTRH(J)
   16 FORMAT(1X,F12.1,1X,F12.1,1X,F12.1,3X,F12.1,1X,F12.1)
C Chagned by A.Timofeev at 18/07/2011 14:43
      DO J=21,28
      IF(J.EQ.21 .OR. J.EQ.23 .OR. J.EQ.25 .OR. J.EQ.27)THEN
         WRITE(34,17) USTR(J),USTR2(J),USTR5(J),TSTR(J),TSTRH(J)
      ELSE
         WRITE(34,18) USTR(J),USTR2(J),USTR5(J),TSTR(J),TSTRH(J)
      END IF
      ENDDO
   17 FORMAT(1X,F12.0,1X,F12.0,1X,F12.0,3X,F12.0,1X,F12.0)
   18 FORMAT(1X,E12.5,1X,E12.5,1X,E12.5,3X,E12.5,1X,E12.5)
C End of changed block
C --------- PRINTING OF RESIDUAL NUCLEI (A,Z)-DISTRIBUTION --------
      WRITE(34,20)
   20 FORMAT(/1X,'RESIDUAL NUCLEI (A,Z)-DISTRIBUTION. A0(Z) IS THE',
     *       ' BETHA STABILITY CURVE.')
      WRITE(34,21)
   21 FORMAT(21X,'DISPOSITION OF  A  RELATIVE  A0(Z):') 
C
        IMIN0=13
        IMAX0=13
      DO 500 J=1,100
        DO 501 I=1,25
            IF(IZA(I,J).EQ.0)THEN
              GO TO 501
            ELSE
              IMIN=I
              GO TO 510
            END IF
  501     CONTINUE
      GO TO 500
  510     DO 511 I=1,25
            IF(IZA(26-I,J).EQ.0)THEN
              GO TO 511
            ELSE
              IMAX=26-I
              GO TO 520
            END IF
  511     CONTINUE
  520   CONTINUE
        IMIN0=MIN(IMIN0,IMIN)
        IMAX0=MAX(IMAX0,IMAX)
  500 CONTINUE
C
      WRITE(34,22) (IAA(J),J=IMIN0,IMAX0)
   22 FORMAT(20X,25I6)
C
      DO 530 J=1,100
        DO 531 I=1,25
            IF(IZA(I,J).EQ.0)THEN
              GO TO 531
            ELSE
              GO TO 532
            END IF
  531     CONTINUE
      GO TO 530
  532     WRITE(34,23) SYMB(J),IFIX(ZNUC(J)),IFIX(ASTAB(J)),
     *                 (IZA(I,J),I=IMIN0,IMAX0)
   23     FORMAT(1X,A2,' (Z=',I3,',A0=',I3,'): ',25I6)
  530 CONTINUE
C
      WRITE(34,24) IIN
   24 FORMAT(' NUMBER OF NUCLEI  INSIDE DISTRIBUTION IS ',I10)
      WRITE(34,25) IOUT
   25 FORMAT(' NUMBER OF NUCLEI OUTSIDE DISTRIBUTION IS ',I10)
C
      RETURN
      END



      SUBROUTINE HIST(X,A,B,H,RX,N,W)
      DIMENSION RX(N)
      LE=(B-A)/H+8
      IF(LE-N)11,11,12
   12 WRITE(25,13) LE,N   
   13 FORMAT(5X,'ERROR IN DIMENSION IN HIST   L=',I3,'N=',I3)
      RETURN
C
   11 CONTINUE   
      RX(N)=RX(N)+X*W
      RX(N-1)=RX(N-1)+W
C  
      IF(X-A)1,2,2 
    1 RX(N-6)=RX(N-6)+X*W
      RX(N-7)=RX(N-7)+W
      RETURN
C
    2 IF(X-B)4,3,3
    3 RX(N-2)=RX(N-2)+X*W
      RX(N-3)=RX(N-3)+W
      RETURN
C
    4 L=(X-A)/H  
      RX(L+1)=RX(L+1)+W
      RX(N-4)=RX(N-4)+X*W
      RX(N-5)=RX(N-5)+W
      RETURN
      END
 


 
      BLOCK DATA SLAC
      COMMON /INFEL/ ZNUC(110),ATWEI(110),DENS(110),RIEV(110),SYMB(110)
      CHARACTER*2 SYMB
C
      DATA ZNUC/
     *  1.,  2.,  3.,  4.,  5.,  6.,  7.,  8.,  9., 10., 11., 12.,
     * 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24.,
     * 25., 26., 27., 28., 29., 30., 31., 32., 33., 34., 35., 36.,
     * 37., 38., 39., 40., 41., 42., 43., 44., 45., 46., 47., 48.,
     * 49., 50., 51., 52., 53., 54., 55., 56., 57., 58., 59., 60.,
     * 61., 62., 63., 64., 65., 66., 67., 68., 69., 70., 71., 72.,
     * 73., 74., 75., 76., 77., 78., 79., 80., 81., 82., 83., 84.,
     * 85., 86., 87., 88., 89., 90., 91., 92., 93., 94., 95., 96.,
     * 97., 98., 99.,100.,  1.,  1., 92., 7*1./ 
C
      DATA ATWEI/
     *   1.00797,   4.00260,   6.93900,   9.01220,  10.81100,  12.01115,
     *  14.00670,  15.99940,  18.99840,  20.18300,  22.98980,  24.31200,  
     *  26.98150,  28.08800,  30.97380,  32.06400,  35.45300,  39.94800,
     *  39.10200,  40.08000,  44.95600,  47.90000,  50.94200,  51.99800,
     *  54.93800,  55.84700,  58.93320,  58.71000,  63.54000,  65.37000,
     *  69.72000,  72.59000,  74.92160,  78.96000,  79.80800,  83.80000,
     *  85.47000,  87.62000,  88.90500,  91.22000,  92.90600,  95.94000,
     *  99.00000, 101.07000, 102.90500, 106.40000, 107.87000, 112.40000,
     * 114.82000, 118.69000, 121.75000, 127.60000, 126.90440, 131.30000,
     * 132.90500, 137.34000, 138.91000, 140.12000, 140.90700, 144.24001,
     * 147.00000, 150.35001, 151.98000, 157.25000, 158.92400, 162.50000,
     * 164.92999, 167.25999, 168.93401, 173.03999, 174.97000, 178.49001,
     * 180.94800, 183.85001, 186.20000, 190.20000, 192.20000, 195.08000,
     * 196.98700, 200.59000, 204.37000, 207.19000, 208.98000, 210.00000,
     * 210.00000, 222.00000, 223.00000, 226.00000, 227.00000, 232.03600,
     * 231.00000, 238.03000, 237.00000, 242.00000, 243.00000, 247.00000,
     * 247.00000, 248.00000, 254.00000, 253.00000,   2.00000,   3.00000,
     * 235.00000, 7*1.00000/
C
      DATA DENS/
     *   0.0808,    0.1900,    0.5340,    1.8500,    2.5000,    2.2600,
     *   1.1400,    1.5680,    1.5000,    1.0000,    0.9712,    1.7400,
     *   2.7020,    2.4000,    1.8200,    2.0700,    2.2000,    1.6500,
     *   0.8600,    1.5500,    3.0200,    4.5400,    5.8700,    7.1400,
     *   7.3000,    7.8600,    8.7100,    8.9000,    8.9333,    7.1400,
     *   5.9100,    5.3600,    5.7300,    4.8000,    4.2000,    3.4000,
     *   1.5300,    2.6000,    4.4700,    6.4000,    8.5700,    9.0100, 
     *  11.5000,   12.2000,   12.5000,   12.0000,   10.5000,    8.6500,
     *   7.3000,    7.3100,    6.6840,    6.2400,    4.9300,    2.7000,
     *   1.8730,    3.5000,    6.1500,    6.9000,    6.7690,    7.0070,
     *   1.0000,    7.5400,    5.1700,    7.8700,    8.2500,    8.5600,
     *   8.8000,    9.0600,    9.3200,    6.9600,    9.8500,   11.4000,
     *  16.6000,   19.3000,   20.5300,   22.4800,   22.4200,   21.4500,
     *  19.3000,   14.1900,   11.8500,   11.3400,    9.7800,    9.3000,
     *   1.0000,    4.0000,    1.0000,    5.0000,    1.0000,   11.0000,
     *  15.3700,   18.9000,   20.5000,   19.7370,   11.7000,    7.0000,
     *   1.0000,    1.0000,    1.0000,    1.0000,    0.0808,    0.0808,
     *  18.9000,  7*1.0000/
C
      DATA RIEV/
     *  19.2,  41.8,  40.0,  63.7,  76.0,  78.0,  82.0,  95.0, 115.0,
     * 137.0, 149.0, 156.0, 166.0, 173.0, 173.0, 180.0, 174.0, 188.0, 
     * 190.0, 191.0, 216.0, 233.0, 245.0, 257.0, 272.0, 286.0, 297.0, 
     * 311.0, 322.0, 330.0, 334.0, 350.0, 347.0, 348.0, 357.0, 352.0, 
     * 363.0, 366.0, 379.0, 393.0, 417.0, 424.0, 428.0, 441.0, 449.0, 
     * 470.0, 470.0, 469.0, 488.0, 488.0, 487.0, 485.0, 491.0, 482.0, 
     * 488.0, 491.0, 501.0, 523.0, 535.0, 546.0, 560.0, 574.0, 580.0, 
     * 591.0, 614.0, 628.0, 650.0, 658.0, 674.0, 684.0, 694.0, 705.0, 
     * 718.0, 727.0, 736.0, 746.0, 757.0, 790.0, 790.0, 800.0, 810.0, 
     * 823.0, 823.0, 830.0, 825.0, 794.0, 827.0, 826.0, 841.0, 847.0, 
     * 878.0, 890.0, 902.0, 921.0, 934.0, 939.0, 952.0, 966.0, 980.0, 
     * 994.0,  19.2,  19.2, 890.0, 7*1000.0/
C
      DATA SYMB/
     * ' H', 'HE', 'LI', 'BE', ' B', ' C', ' N', ' O', ' F', 'NE', 
     * 'NA', 'MG', 'AL', 'SI', ' P', ' S', 'CL', 'AR', ' K', 'CA', 
     * 'SC', 'TI', ' V', 'CR', 'MN', 'FE', 'CO', 'NI', 'CU', 'ZN', 
     * 'GA', 'GE', 'AS', 'SE', 'BR', 'KR', 'RB', 'SR', ' Y', 'ZR', 
     * 'NB', 'MO', 'TC', 'RU', 'RH', 'PD', 'AG', 'CD', 'IN', 'SN', 
     * 'SB', 'TE', ' I', 'XE', 'CS', 'BA', 'LA', 'CE', 'PR', 'ND', 
     * 'PM', 'SM', 'EU', 'GD', 'TB', 'DY', 'HO', 'ER', 'TM', 'YB', 
     * 'LU', 'HF', 'TA', ' W', 'RE', 'OS', 'IR', 'PT', 'AU', 'HG', 
     * 'TL', 'PB', 'BI', 'PO', 'AT', 'RN', 'FR', 'RA', 'AC', 'TH', 
     * 'PA', ' U', 'NP', 'PU', 'AM', 'CM', 'BK', 'CF', 'ES', 'FM', 
     * ' D', ' T', ' U', 7*'ZZ'/
C
      END



      SUBROUTINE INITIS
C Changed by A. Timofeev, 14/07/2011
C This subroutine is not used in libHadgen.so
C the database is exported from C code
C No input file tabnuc.dat needed
C Input of natural isotope compositions of nuclides (Ai,% for all Z)
C and preparation of probabilities for sampling of specific A for given Z.
C     Input file: name - TABNUC.DAT, file number - 19.
C     Comments on contents of some arrays and variables see below.
C
      COMMON /ABUNUC/ AIST(500),PERC(500),ABUNOR(500),
     *                NUCADR(2,110),IZMAX,L110
      CHARACTER*2 ELEM
C
C --------------------- INITIALISATION -------------------
        IAD1=0
        IAD2=0
      L110=110
C      
      DO I=1,L110
        DO J=1,2
           NUCADR(J,I)=0
        END DO
      END DO
C
      DO I=1,500
        ABUNOR(I)=0.
      END DO
C ----------------------- DATA INPUT -------------------------
      DO J=1,L110+1
C Input of chemical symbol (ELEM) and atomic number (IZ) of the next
C nuclide and number (NISOT) of existing stable isitopes 
        READ(19,10)ELEM,IZ,NISOT
   10     FORMAT(A2,I3,1X,I7,60X)
C
        IF(ELEM.EQ.'ZZ' .OR. IZ.EQ.-1 .OR. NISOT.EQ.-1)THEN 
C         Maximal atomic number IZMAX, which is presented in TABNUC.DAT.
            IZMAX=J-1
            GO TO 100
C         End of file
        END IF
C
c          IF(IZ.NE.J)THEN      ! this checking is commented of 01.03.2001
c              WRITE(25,1000)IZ
c 1000         FORMAT(' INITIS DIAGNOSTIC: Error in TABNUC.DAT at Z=',I3)
c              STOP
c          END IF
C
C Initial and last addresses of data for nuclide IZ 
C in arrays AIST, PERC, ABUNOR
        IAD1=IAD2+1
        IAD2=IAD1+NISOT-1
            NUCADR(1,J)=IAD1
            NUCADR(2,J)=IAD2
C
C Input of stable isotope mass numbers (AIST) and natural abundonces (PERC,%)       
        READ(19,20) (AIST(K),K=IAD1,IAD2)
   20     FORMAT(6X,15F8.4)
        READ(19,30) (PERC(K),K=IAD1,IAD2)
   30     FORMAT(6X,15F8.4)
C End of input cycle on J
      END DO
  100 CONTINUE
C
C --------------- PROBABILITIES FOR SAMPLING -----------------
C Transformation of percentage (PERC) to normalized probabilities 
C (ABUNOR) for A-sampling.
      DO J=1,IZMAX
        IAD1=NUCADR(1,J)
        IAD2=NUCADR(2,J)
C
        DO I=IAD1,IAD2
            ABUNOR(I)=PERC(I)
        END DO
C
        DO I=IAD1,IAD2-1
            ABUNOR(I+1)=ABUNOR(I)+ABUNOR(I+1)
        END DO
C
        DO I=IAD1,IAD2
            ABUNOR(I)=ABUNOR(I)/ABUNOR(IAD2)
        END DO
      END DO
C
cC ----------------- DEBUG PRINTOUT ----------------
cc      DO J=1,IZMAX
cc      WRITE(25,105)J,NUCADR(1,J),NUCADR(2,J),NUCADR(2,J)-NUCADR(1,J)+1
cc  105 FORMAT(I3,3I6)
cc      END DO
ccC
c       DO J=1,IZMAX
c              IAD1=NUCADR(1,J)
c              IAD2=NUCADR(2,J)
c          WRITE(25,110)J,IAD2-IAD1+1
c  110     FORMAT('Z=',I3,':',I7)
c          WRITE(25,120) (AIST(K),K=IAD1,IAD2)
c  120     FORMAT('A',5X,15F8.4)
c          WRITE(25,130) (PERC(K),K=IAD1,IAD2)
c  130     FORMAT('%',5X,15F8.4)
c          WRITE(25,140) (ABUNOR(K),K=IAD1,IAD2)
c  140     FORMAT('prob. ',15F8.4)
c      END DO
C -------------  End of debug printout ------------
C
      PRINT *,'INITIS END'
      CALL INITISTEST
      RETURN
      END


      FUNCTION AMIXIS(NUCLID)
C Sampling of nucleus Atomic mass number from natural MIXture of ISotopes
C according to isotope abundance.
C   NUCLID - Atomic number (input)
C   AMIXIS - Atomic mass number (output)
C
      COMMON /ABUNUC/ AIST(500),PERC(500),ABUNOR(500),
     *                NUCADR(2,110),IZMAX,L110
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
C
C Check of Input compatibility.
      IF(NUCLID.GT.IZMAX)THEN
        WRITE(25,1000)NUCLID,IZMAX,IXINIT,NUMTRE
 1000     FORMAT(' AMIXIS DIAGNOSTIC: NUCLID=',I3,' exceeds IZMAX=',I3,
     *           ';  IXINIT=',I12,'  NUMTRE=',I7)
        STOP
      END IF
C
C Address of applicable information
      IAD1=NUCADR(1,NUCLID)
      IAD2=NUCADR(2,NUCLID)
C
C A-sam.qpling
      B=RAN(IX)
c      WRITE(*,12345)IAD1,IAD2,IZMAX,NUCLID
c12345 FORMAT('AMIXIS DEBUG: ', I12, ' ', I12, ' ', I12, ' ', I12)
cC      
cC Debug printout ===========================
c      WRITE(25,77)B,(ABUNOR(J),J=IAD1,IAD2)
c   77 FORMAT(' B=',F12.10/3X,12F8.4)
cC===========================================
C
      DO J=IAD1,IAD2
        IF(B.LE.ABUNOR(J))THEN
            AMIXIS=AIST(J)
            RETURN
        END IF
      END DO
C
      END



      SUBROUTINE LABANT
C Transformation of SPT, SNU  after hadron-nucleus reaction
C (nucleus-target is at rest in Lab. system) into Antilab. system.
C
C       SECONDARY PARTICLES CHARACTERISTICS IN ARRAY SPT
C           SPT(1,J) - COS OF POLAR ANGLE OF SECONDARY PARTICLE
C           SPT(2,J) -  SIN OF AZIMUTAL ANGLE
C           SPT(3,J) -  COS OF AZIMUTAL ANGLE
C           SPT(4,J) - KINETIC ENERGY OF SECONDARY PARTICLE (MEV)
C           SPT(5,J) - SECONDARY PARTICLE TYPE
C           SPT(6,J) - SECONDARY PARTICLE WEIGHT
C       NUCLEUS CHARACTERISTICS
C         Nucleus-target
C           SNU(1,1) - NUCLEUS-TARGET ATOMIC WEIGHT
C           SNU(2,1) - NUCLEUS-TARGET ATOMIC NUMBER
C         Nuclei-products after deexitation, J=2-11
C           SNU(1,J) - Aprod
C           SNU(2,J)   Zprod
C           SNU(3,J) - Excitation energy (MeV)
C           SNU(5,J)
C           SNU(6,J)   -  Nucleus momentum (MeV/C)
C           SNU(7,J)
C-------------------------------------------------------------------------
      COMMON /SECHAR/ SPT(6,5000),SNU(10,101),LS6,LS100,LS10,LS11  ! GSITR
      COMMON /INREAC/ COST,SINF,COSF,TINT,WINT,JPART,NUCLID,KSTATE
C
      DIMENSION HADMAS(24)  ! Particle's mass (MeV)
      DATA HADMAS /940., 940., 140., 140., 140., 940., 940.,
     *             495., 495., 495., 495.,   0., 0.511, 0.511,
     *             106., 106., 4*0., 1880., 2820., 2820., 3760./
C
C 4-momentum of incident hadron in Lab. system:
      RM0=HADMAS(JPART) ! hadron mass
      E0=TINT+RM0       ! total energy
        P0X=0.                         !
        P0Y=0.                         ! momentum
        P0Z=SQRT(TINT*(TINT+2.0*RM0))  !
C
C -------------TRANSFORMATION LOOP for SPT----------------
      DO J=1,LS100
        IPART=IFIX(SPT(5,J))     ! Type of secondary particle.
        IF(IPART.EQ.0)GO TO 10   ! No more particles in SPT.
C
C     4-momentum of secondary particle No.J  in Lab. system:
        CT=SPT(1,J)
        SF=SPT(2,J)
        CF=SPT(3,J)
        T1=SPT(4,J)
        RM1=HADMAS(IPART)
      CALL MOMSFE(CT,SF,CF,T1,RM1, E1,P1LAB,P1X,P1Y,P1Z)
C
C     4-momentum of secondary particle No.J in AntiLab. system:
      CALL LORENZ(E0,P0X,P0Y,P0Z,  E1,P1X,P1Y,P1Z,
     *            E1al,P1Xal,P1Yal,P1Zal)
C
C     Inversion of AntiLab system (to fly in positive direction of Z axis)
      P1Xal=-P1Xal
      P1Yal=-P1Yal
      P1Zal=-P1Zal
C
C     Spherical angles of secondary particle No.J in AntiLab. system:
      CALL DECARS(P1Xal,P1Yal,P1Zal,P1ALAB,COST1,SINF1,COSF1)
C
C     Appropriations into SPT in Antilab system
        SPT(1,J)=COST1
        SPT(2,J)=SINF1
        SPT(3,J)=COSF1
        SPT(4,J)=E1al-RM1
C
      END DO
C
C -------------TRANSFORMATION LOOP for SNU----------------
   10 CONTINUE
C
      DO 20 J=2,LS11
        IF(SNU(1,J).EQ.0)GO TO 20
C
C 4-momentum of nucleus No.J in Lab. system
        RMN1=940.0*SNU(1,J)
        EN1=SQRT((SNU(5,J)**2+SNU(6,J)**2+SNU(7,J)**2)+RMN1**2)
        PN1X=SNU(5,J)
        PN1Y=SNU(6,J)
        PN1Z=SNU(7,J)
C
C     4-momentum of nucleus No.J in AntiLab. system:
      CALL LORENZ(E0,P0X,P0Y,P0Z,  EN1,PN1X,PN1Y,PN1Z,
     *            EN1al,PN1Xal,PN1Yal,PN1Zal)
C
C     Inversion of AntiLab system (to fly in positive direction of Z axis)
      PN1Xal=-PN1Xal
      PN1Yal=-PN1Yal
      PN1Zal=-PN1Zal
C
C     Appropriations into SNU in Antilab system
        SNU(5,J)=PN1Xal
        SNU(6,J)=PN1Yal
        SNU(7,J)=PN1Zal
C   
   20 CONTINUE
C
      RETURN
      END



      SUBROUTINE MOMSFE(COST,SINF,COSF,TKIN,RMASS,ETOT,PMOD,PX,PY,PZ)
C Calculation of 4-momentum of particle from its kinetic energy and 
C spheric angular direction.
C
C INPUT: COST - Cos(Tetha)
C        SINF - Sin(Phi)
C        COSF - Cos(Phi)
C        TKIN - Kinetic energy (MeV)
C        RMASS - Mass (MeV)
C
C OUTPUT: ETOT - Total energy (MeV)
C         PMOD - Modulus of 3-momentum (MeV/c)
C         PX, PY, PZ - Cartesius components of 3-momentum (MeV/c)
C
      REAL*8 DCT,DSF,DCF,DST,DTKIN,DRMASS,DETOT,DPMOD,DPX,DPY,DPZ
C
      DCT=DBLE(COST)
      DSF=DBLE(SINF)
      DCF=DBLE(COSF)
      DST=DSQRT(1.0-DCT*DCT)     ! Sin(Tetha)
        DTKIN=DBLE(TKIN)
        DRMASS=DBLE(RMASS)
        DETOT=DTKIN+DRMASS                      ! Etot
        DPMOD=DSQRT(DTKIN*(DTKIN+2.0*DRMASS))   ! Pmod
            DPX=DPMOD*DST*DCF                   ! Px
            DPY=DPMOD*DST*DSF                   ! Py
            DPZ=DPMOD*DCT                       ! Pz
C
      ETOT=SNGL(DETOT)
      PMOD=SNGL(DPMOD)
      PX=SNGL(DPX)
      PY=SNGL(DPY)
      PZ=SNGL(DPZ)
C
      RETURN
      END



      SUBROUTINE LORENZ(E0,P0X,P0Y,P0Z,  E1,P1X,P1Y,P1Z,
     *                                   E1str,P1Xstr,P1Ystr,P1Zstr)
C Lorenz transformation.
C Let in some reference system (Lab. system) particles 0 and 1 
C have 4-momenta  (E0,P0X,P0Y,P0Z)  and  (E1,P1X,P1Y,P1Z).
C Then in reference system where particle 0 is in rest (Antilab. syst.),
C particle 1 has 4-momentum E1str,P1Xstr,P1Ystr,P1Zstr.
C      [see. Kopylov, page 23, eq. (26), (27)]
C
C INPUT: E0,P0X,P0Y,P0Z - 4-momentum of incident particle in Lab.system
C        E1,P1X,P1Y,P1Z - 4-momentum of secondary particle in Lab.system
C
C OUTPUT: E1str,P1Xstr,P1Ystr,P1Zstr - 4-momentum of secondary particle 
C                                      in AntiLab.system
C
      REAL*8 DE0,DP0X,DP0Y,DP0Z,DE1,DP1X,DP1Y,DP1Z,DRM0,DTMP,
     *       DE1s,DP1Xs,DP1Ys,DP1Zs
C
      DE0 =DBLE(E0)
      DP0X=DBLE(P0X)
      DP0Y=DBLE(P0Y)
      DP0Z=DBLE(P0Z)
      DE1 =DBLE(E1)
      DP1X=DBLE(P1X)
      DP1Y=DBLE(P1Y)
      DP1Z=DBLE(P1Z)
C
      DRM0=DSQRT(DE0*DE0-(P0X*P0X+P0Y*P0Y+P0Z*P0Z)) ! RM0 mass of inc. part.
      DE1s=(DE0*DE1-(P0X*P1X+P0Y*P1Y+P0Z*P1Z))/DRM0 ! E1star
        DTMP=(DE1+DE1s)/(DE0+DRM0)
      DP1Xs=DP1X-DP0X*DTMP                          ! P1Xstar
      DP1Ys=DP1Y-DP0Y*DTMP                          ! P1Ystar
      DP1Zs=DP1Z-DP0Z*DTMP                          ! P1Zstar
C
      E1str =SNGL(DE1s)
      P1Xstr=SNGL(DP1Xs)
      P1Ystr=SNGL(DP1Ys)
      P1Zstr=SNGL(DP1Zs)
C
      RETURN
      END



      subroutine PRILOR(E,PX,PY,PZ)
C Debug printout of 4-momentum
      write(34,1)E,PX,PY,PZ
    1 format(' E, Px, Py, Pz: ',4E12.5)
C
      P2=PX**2+PY**2+PZ**2
      P=SQRT(P2)
      RM=SQRT(E**2-P2)
      T=E-RM
C
      write(34,2)P2,P,RM,T
    2 format(' P2, P, RM, T : ',4E12.5)
C
      RETURN
      END



      SUBROUTINE INLEVR
C This program provides an initialization of values of some parameters
C for the MSDM generator. By varying of these values (in COMMON /LEVERS/)
C one can affect the results of simulation.
C
C -------------------PARAMETERS of the AGT generator-----------------
C COMMONs of AGT-generator which contain the parameters (all are REAL*8):
C      COMMON /PIDABS/ PIDABS
C      COMMON /TLIMIT/ TLIMIT
C      COMMON /MMATUR/ MMES,MBAR
C      COMMON /HCASC/ ANUCL1,ANUCL2,ZNUCL1,ZNUCL2,T0,EPS1,EPS2,VPI,A1,A2,
C     *               C1,C2,D1,D2,R0N1,R0N2,TF01,TF02,RM1,RM2
C
C STATEMENTs in GENAGT which set the parameter values
C General AGT parameters
C      PIDABS=0.01      ! absorbtion via pi-D !
C      TLIMIT=25.       ! total interaction time in fm/c !
C      MMES=0.2         ! for T0<1 GeV one may use MMES=999.9 (?)!
C      MBAR=999.999
C
C Parameters of nuclear density distribution (A>10)
C     EPS2=0.007      ! average (for product far from target) !
C     VPI=0.025
C     D2=0.05
C     C2=0.545    ! for A>10 ! ! for A<10 don't used !
C     R0N2=1.07   ! for A>10 !
C
C Parameter R0N for light nuclei (A<=10)
C     IF(LA.EQ.2 .AND. LZ.EQ.1)R0N2=2.31
C     IF(LA.EQ.3 .AND. LZ.EQ.1)R0N2=2.4
C     IF(LA.EQ.3 .AND. LZ.EQ.2)R0N2=2.4
C     IF(LA.EQ.4 .AND. LZ.EQ.2)R0N2=1.60
C     IF(LA.EQ.6 .AND. LZ.EQ.3)R0N2=2.4
C     IF(LA.EQ.7 .AND. LZ.EQ.3)R0N2=2.4
C     IF(LA.EQ.9 .AND. LZ.EQ.4)R0N2=2.48
C     IF(LA.EQ.10 .AND. LZ.EQ.5)R0N2=2.48
C              Absent in GENAGT!  For enhancement in future.
C     IF(LA.EQ.11 .AND. LZ.EQ.5)R0N2=2.48 !
C     IF((LA.EQ.12 .OR. LA.EQ.13) .AND. LZ.EQ.6)R0N2=2.48 !
C     IF((LA.EQ.14 .OR. LA.EQ.15) .AND. LZ.EQ.7)R0N2=2.48 !
C     IF((LA.EQ.16 .OR. LA.EQ.17 .OR. LA.EQ.18) .AND. LZ.EQ.8)R0N2=2.48 !
C
C -------------------PARAMETERS of the PRECOmpound emission----------
C COMMON of PRECO which contain the parameter:
C     COMMON /PRECOM/ PRECOM  ! (0<PRECOM<1)
C STATEMENT in PRECO which set the parameter value
C     PRECOM=1.
C     NSP=NINT(SQRT((1.19*AM*A*U+0.5)*PRECOM))
C
C -------------------PARAMETERS of DEEXcitation----------------------
* Parameters of DEEX.F which are defined by BLOCK DATA.
* Parameters which are labelled by [*] will be overwritten by PARLEV
* -----------------------------------------------------------------
* BLOCK DATA DEFALT
* COMMON /BLMULF/ IMULF 
* COMMON /BLIMA/  IMA [*]
* COMMON /BLPARA/ EPSIL0 [*], FKAPPA, FKACOL [*]
* COMMON /BPLACE/ RFI
* COMMON /ADDNUC/ IZPN,IAPN
* COMMON /RESNU0/ EMIN,EMAX,YMIN,YMAX - not used anywhere 
*  DATA IMULF  /1/   - IMULF is changed inside Subroutine DEEX during simulation 
*  DATA IMA    /3/   - IMA is overwritten by PARLEV [*]
*  DATA EPSIL0 /16./ - EPSIL0 is overwritten by PARLEV [*]
*  DATA FKAPPA /1./  - FKAPPA is used in ZVEZD1
*  DATA FKACOL /2./  - FKACOL is overwritten by PARLEV [*]
*   DATA IZPN   /0/  - IZPN is used in ZVEZD1
*   DATA IAPN   /0/  - IAPN is used in ZVEZD1
*   DATA RFI    /0./ - RFI is used in CULIMP
*   DATA EMIN   /0./ - not used anywhere
*   DATA EMAX   /0./ - not used anywhere
*   DATA YMIN   /0./ - not used anywhere
*   DATA YMAX   /0./ - not used anywhere
* 
* BLOCK DATA DMAS02
* COMMON /BL0999/ RNCL [*]
* COMMON /BL1100/ AMS [*], AMFS [*]
* COMMON /BLCAN/  ICAN [*]
* COMMON /BLSEC/  ISEC
* COMMON ......
* DATA RNCL /0.0/   - RNCL is overwritten by PARLEV [*]
* DATA AMS  /0.125/ - AMS is overwritten by PARLEV [*]
* DATA AMFS /0.125/ - AMFS is overwritten by PARLEV [*]
* DATA ICAN /1/     - ICAN is overwritten by PARLEV [*]
* DATA ISEC /1/     - ISEC is used in GAMMAC, TKIN
* DATA ........
* 
* 
* Parameters of DEEX.F which are taken from COMMON /LEVERS/ PARLEV(40)
* and overwrite [*] the BLOCK DATA DEFALT 
* -------------------------------------------------------------------
*                   ! No.  COMMON    Parameter     DEFAULT in DFLT(40)
* PARLEV(23)=0.     ! 23  /BLCAN/    ICAN [*]              0
* PARLEV(24)=3.     ! 24  /BLIMA/    IMA [*]               3
* PARLEV(25)=16.    ! 25  /BLPARA/   EPSIL0 [*]           16.
* PARLEV(26)=2.     ! 26  /BLPARA/   FKACOL [*]            2.
* PARLEV(27)=1.3    ! 27  /BL0999/   RNCL [*]              0.
* PARLEV(28)=0.1    ! 28  /BL1100/   AMS [*]           0.125
* PARLEV(29)=0.1    ! 29  /BL1100/   AMFS [*]          0.125
* PARLEV(30)=16.    ! 30             Amax for Fermi       16.
* PARLEV(31)=0.002  ! 31             Min Umulf(GeV/A)  0.002
* PARLEV(32)=2.     ! 32  /ILEVRA/   ILEVRA                2   ! DKFZg
* PARLEV(33)=1.     ! 33  /FKAP/     FKAP1 - Coulomb       1.  ! DKFZg
* PARLEV(34)=1.     ! 34  /FKAP/     FKAP2 - Volume        1.  ! DKFZg
C===================================================================
C
      COMMON /LEVERS/ PARLEV(40)  ! Values of the parameters
      DIMENSION DFLT(40)          ! Default values of the parameters
C
      DATA DFLT /
     *0.01,     25.,      0.2,      999.999,  0.007, !  5
     *0.025,    0.545,    0.05,     1.07,     2.31,  ! 10
     *2.4,      2.4,      1.60,     2.4,      2.4,   ! 15
     *2.48,     2.48,     2.48,     2.48,     2.48,  ! 20
     *2.48,     1.,       0.,       3.,       16.,   ! 25
     *2.,       0.,       0.125,    0.125,    16.,   ! 30
     *0.002,    2.,       1.0,      1.0,      0.,    ! 35   ! DKFZg
     *0.,       0.,       0.,       0.75,     1.0/   ! 40   ! DKFZf
C
      DO J=1,40
      PARLEV(J)=DFLT(J)
      END DO
C
C Appropriation of the parameter values
C                        ! No.  COMMON    Parameter         DEFAULT
      PARLEV( 1)=0.01    !  1  /PIDABS/   PIDABS            0.01
      PARLEV( 2)=25.     !  2  /TLIMIT/   TLIMIT            25.
      PARLEV( 3)=999.999 !  3  /MMATUR/   MMES              0.2
      PARLEV( 4)=999.999 !  4  /MMATUR/   MBAR              999.999
      PARLEV( 5)=0.007   !  5  /HCASC/    EPS1,EPS2         0.007
      PARLEV( 6)=0.025   !  6  /HCASC/    VPI               0.025
      PARLEV( 7)=0.545   !  7  /HCASC/    C1,C2             0.545
      PARLEV( 8)=0.05    !  8  /HCASC/    D1,D2             0.05
      PARLEV( 9)=1.07    !  9  /HCASC/    R0N1,R0N2         1.07
      PARLEV(10)=2.31    ! 10             R0N for H(2,1)    2.31
      PARLEV(11)=2.4     ! 11             R0N for H(3,1)    2.4
      PARLEV(12)=2.4     ! 12             R0N for He(3,2)   2.4
      PARLEV(13)=1.60    ! 13             R0N for He(4,2)   1.60
      PARLEV(14)=2.4     ! 14             R0N for Li(6,3)   2.4
      PARLEV(15)=2.4     ! 15             R0N for Li(7,3)   2.4
      PARLEV(16)=2.48    ! 16             R0N for Be(4,9)   2.48
      PARLEV(17)=2.48    ! 17             R0N for B(10,5)   2.48
c      PARLEV(18)=2.48   ! 18             R0N for B(11,5)   2.48 ! Absent
c      PARLEV(19)=2.48   ! 19             R0N for C(Nat,6)  2.48 ! in GENAGT
c      PARLEV(20)=2.48   ! 20             R0N for N(Nat,7)  2.48 !
c      PARLEV(21)=2.48   ! 21             R0N for O(Nat,8)  2.48 !
C
      PARLEV(22)=1.      ! 22  /PRECOM/   PRECOM            1.
C
      PARLEV(23)=1.      ! 23  /BLCAN/    ICAN              0
      PARLEV(24)=3.      ! 24  /BLIMA/    IMA               3
      PARLEV(25)=16.     ! 25  /BLPARA/   EPSIL0            16.
      PARLEV(26)=2.      ! 26  /BLPARA/   FKACOL            2.
      PARLEV(27)=1.3     ! 27  /BL0999/   RNCL              0.
      PARLEV(28)=0.1     ! 28  /BL1100/   AMS               0.125
      PARLEV(29)=0.1     ! 29  /BL1100/   AMFS              0.125
      PARLEV(30)=16.     ! 30             Amax for Fermi    16.
      PARLEV(31)=0.002   ! 31             Min of Umulf/A    0.002 GeV/A
      PARLEV(32)=2.      ! 32  /ILEVRA/   ILEVRA            2     ! DKFZg
      PARLEV(33)=1.      ! 33  /FKAP/     FKAP1 - Coulomb   1.    ! DKFZg
      PARLEV(34)=1.      ! 34  /FKAP/     FKAP2 - Volume    1.    ! DKFZg
C
      PARLEV(39)=1.0     ! 39             Renorm AA-SIGION  0.75  ! DKFZf
      PARLEV(40)=1.0     ! 40             Renorm hA-MICROD  1.0   ! DKFZf
C
C Printout of the parameter values (if differ from default value only!)
      WRITE(34,100)
  100 FORMAT(/10X,'PARAMETERS of the SHIELD hA- and AA-GENERATOR'/
     *        10X,'HAVE BEEN ESTABLISHED. The following values'/
     *        10X,'differ from default ones:')
C
      IF(PARLEV( 1) .ne. DFLT( 1)) WRITE(34, 1) 1,PARLEV( 1)
      IF(PARLEV( 2) .ne. DFLT( 2)) WRITE(34, 2) 2,PARLEV( 2)
      IF(PARLEV( 3) .ne. DFLT( 3)) WRITE(34, 3) 3,PARLEV( 3)
      IF(PARLEV( 4) .ne. DFLT( 4)) WRITE(34, 4) 4,PARLEV( 4)
      IF(PARLEV( 5) .ne. DFLT( 5)) WRITE(34, 5) 5,PARLEV( 5)
      IF(PARLEV( 6) .ne. DFLT( 6)) WRITE(34, 6) 6,PARLEV( 6)
      IF(PARLEV( 7) .ne. DFLT( 7)) WRITE(34, 7) 7,PARLEV( 7)
      IF(PARLEV( 8) .ne. DFLT( 8)) WRITE(34, 8) 8,PARLEV( 8)
      IF(PARLEV( 9) .ne. DFLT( 9)) WRITE(34, 9) 9,PARLEV( 9)
      IF(PARLEV(10) .ne. DFLT(10)) WRITE(34,10)10,PARLEV(10)
      IF(PARLEV(11) .ne. DFLT(11)) WRITE(34,11)11,PARLEV(11)
      IF(PARLEV(12) .ne. DFLT(12)) WRITE(34,12)12,PARLEV(12)
      IF(PARLEV(13) .ne. DFLT(13)) WRITE(34,13)13,PARLEV(13)
      IF(PARLEV(14) .ne. DFLT(14)) WRITE(34,14)14,PARLEV(14)
      IF(PARLEV(15) .ne. DFLT(15)) WRITE(34,15)15,PARLEV(15)
      IF(PARLEV(16) .ne. DFLT(16)) WRITE(34,16)16,PARLEV(16)
      IF(PARLEV(17) .ne. DFLT(17)) WRITE(34,17)17,PARLEV(17)
c      IF(PARLEV(18) .ne. DFLT(18)) WRITE(34,18)18,PARLEV(18)
c      IF(PARLEV(19) .ne. DFLT(19)) WRITE(34,19)19,PARLEV(19)
c      IF(PARLEV(20) .ne. DFLT(20)) WRITE(34,20)20,PARLEV(20)
c      IF(PARLEV(21) .ne. DFLT(21)) WRITE(34,21)21,PARLEV(21)
C
      IF(PARLEV(22) .ne. DFLT(22)) WRITE(34,22)22,PARLEV(22)
C
      IF(PARLEV(23) .ne. DFLT(23)) WRITE(34,23)23,INT(PARLEV(23))
      IF(PARLEV(24) .ne. DFLT(24)) WRITE(34,24)24,INT(PARLEV(24))
      IF(PARLEV(25) .ne. DFLT(25)) WRITE(34,25)25,PARLEV(25)
      IF(PARLEV(26) .ne. DFLT(26)) WRITE(34,26)26,PARLEV(26)
      IF(PARLEV(27) .ne. DFLT(27)) WRITE(34,27)27,PARLEV(27)
      IF(PARLEV(28) .ne. DFLT(28)) WRITE(34,28)28,PARLEV(28)
      IF(PARLEV(29) .ne. DFLT(29)) WRITE(34,29)29,PARLEV(29)
      IF(PARLEV(30) .ne. DFLT(30)) WRITE(34,30)30,PARLEV(30)
      IF(PARLEV(31) .ne. DFLT(31)) WRITE(34,31)31,PARLEV(31)
      IF(PARLEV(32) .ne. DFLT(32)) WRITE(34,32)32,INT(PARLEV(32))   ! DKFZg
      IF(PARLEV(33) .ne. DFLT(33)) WRITE(34,33)33,PARLEV(33)   ! DKFZg
      IF(PARLEV(34) .ne. DFLT(34)) WRITE(34,34)34,PARLEV(34)   ! DKFZg
C
      IF(PARLEV(39) .ne. DFLT(39)) WRITE(34,39)39,PARLEV(39)   ! DKFZf
      IF(PARLEV(40) .ne. DFLT(40)) WRITE(34,40)40,PARLEV(40)   ! DKFZf
C
    1 FORMAT(6X,I2,'. ','AGT parameter PIDABS:          ',F10.5)
    2 FORMAT(6X,I2,'. ','AGT parameter TLIMIT:          ',F10.5)
    3 FORMAT(6X,I2,'. ','AGT parameter MMES:            ',F10.5)
    4 FORMAT(6X,I2,'. ','AGT parameter MBAR:            ',F10.5)
    5 FORMAT(6X,I2,'. ','AGT parameter EPS1,EPS2:       ',F10.5)
    6 FORMAT(6X,I2,'. ','AGT parameter VPI:             ',F10.5)
    7 FORMAT(6X,I2,'. ','AGT parameter C1,C2:           ',F10.5)
    8 FORMAT(6X,I2,'. ','AGT parameter D1,D2:           ',F10.5)
    9 FORMAT(6X,I2,'. ','AGT parameter R0N1,R0N2:       ',F10.5)
   10 FORMAT(6X,I2,'. ','AGT parameter R0N for H(2,1):  ',F10.5)
   11 FORMAT(6X,I2,'. ','AGT parameter R0N for H(3,1):  ',F10.5)
   12 FORMAT(6X,I2,'. ','AGT parameter R0N for He(3,2): ',F10.5)
   13 FORMAT(6X,I2,'. ','AGT parameter R0N for He(4,2): ',F10.5)
   14 FORMAT(6X,I2,'. ','AGT parameter R0N for Li(6,3): ',F10.5)
   15 FORMAT(6X,I2,'. ','AGT parameter R0N for Li(7,3): ',F10.5)
   16 FORMAT(6X,I2,'. ','AGT parameter R0N for Be(4,9): ',F10.5)
   17 FORMAT(6X,I2,'. ','AGT parameter R0N for B(10,5): ',F10.5)
c   18 FORMAT(6X,I2,'. ','AGT parameter R0N for B(11,5): ',F10.5)
c   19 FORMAT(6X,I2,'. ','AGT parameter R0N for C(Nat,6):',F10.5)
c   20 FORMAT(6X,I2,'. ','AGT parameter R0N for N(Nat,7):',F10.5)
c   21 FORMAT(6X,I2,'. ','AGT parameter R0N for O(Nat,8):',F10.5)
C
   22 FORMAT(6X,I2,'. ','PRECO parameter PRECOM:        ',F10.5)
C
   23 FORMAT(6X,I2,'. ','DEEX parameter ICAN:           ',I10)
   24 FORMAT(6X,I2,'. ','DEEX parameter IMA:            ',I10)
   25 FORMAT(6X,I2,'. ','DEEX parameter EPSIL0:         ',F10.5)
   26 FORMAT(6X,I2,'. ','DEEX parameter FKACOL:         ',F10.5)
   27 FORMAT(6X,I2,'. ','DEEX parameter RNCL:           ',F10.5)
   28 FORMAT(6X,I2,'. ','DEEX parameter AMS:            ',F10.5)
   29 FORMAT(6X,I2,'. ','DEEX parameter AMFS:           ',F10.5)
   30 FORMAT(6X,I2,'. ','DEEX parameter Amax for Fermi: ',F10.5)
   31 FORMAT(6X,I2,'. ','DEEX parameter Min(Umulf/A):   ',F10.5)
   32 FORMAT(6X,I2,'. ','DEEX parameter ILEVRA:         ',I10)     ! DKFZg
   33 FORMAT(6X,I2,'. ','DEEX parameter FKAP1-Coulomb:  ',F10.5)   ! DKFZg
   34 FORMAT(6X,I2,'. ','DEEX parameter FKAP2-Volume:   ',F10.5)   ! DKFZg
C
   39 FORMAT(6X,I2,'. ','SIGION AA-Renorm parameter:    ',F10.5)   ! DKFZf
   40 FORMAT(6X,I2,'. ','MICROD hA-Renorm parameter:    ',F10.5)   ! DKFZf
C
      RETURN
      END
