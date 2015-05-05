
*****************************************************************
*                                                               *
*     The following subroutines are written by N.S.Amelin,      *
*     Joint Institute for Nuclear Research, Dubna,              *
*     E-mail: amelin@sirius.jinr.ru                             *
*                                                               *
*****************************************************************

c************ last correction 11.16.94 *********************
      SUBROUTINE HHQGSE 
C                         31-10-94 
      IMPLICIT REAL*8 (A-H,O-Z) 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/IDRUN/IDVER,IDG(2),IEVT 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/NOTRE/ NOTRE 
      LOGICAL NOTRE 
      LOGICAL LPRNT 
      COMMON /BRAN/ BRAN 
C 
C 
      BRAN=0. 
      ITCOM=15 
      ITLIS=16
      ITEVT=17 
      ITDKY=18 
      CALL SETCON 
      CALL READHH(LPRNT,ID1,AM1,PX1,PY1,PZ1, 
     *ID2,AM2,PX2,PY2,PZ2,SIGTOT,SIGEX,SIGAN,SIGEL) 
      CALL SETDKY(LPRNT) 
      DO 1 IEVT=1,NEVENT 
      CALL READHH(LPRNT,ID1,AM1,PX1,PY1,PZ1, 
     *ID2,AM2,PX2,PY2,PZ2,SIGTOT,SIGEX,SIGAN,SIGEL) 
      CALL COLLHH(ID1,AM1,PX1,PY1,PZ1,ID2,AM2,PX2,PY2, 
     *PZ2,SIGTOT,SIGAN,SIGEL) 
      I=IEVT 
1     CALL PRTEVT(I) 
C     IF(.NOT.NOTRE) CALL SPECTR 
C 
C 
      STOP 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE TYPRE(IK1,AM1,IK2,AM2, 
     *SQS,IEL,IDIF,IUNCY,IPLAN,IBINA,SIGTOT,SIGEL) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM1,AM2,SQS,SIGTOT,SIGEL 
C 
C     COMPUTE REACTION CHANNEL AT LOW ENERGY HADRON COLLISION 
C 
C 
C     PRODUCED BY DR.N.S.AMELIN FROM LCTA OF JOINT INSTITUTE FOR NUCLEAR 
C     RESEARCH.  1986 -VERSION (QUARK-GLUON STRINGS MODEL USED) 
C     FOR HADRON HADRON COLLISIONS SIMULATION BY MONTE-CARLO METHOD 
C 
C               WILL BE ONLY,IF 
C     IEL=1-ELASTIC SCATTERING 
C     IDIF=1-DIFFRACTIVE SCATTERING 
C     IUNCY=1-UNDEVELOPED CYLINDER SCATTERING 
C     IPLAN=1-PLANAR SCATTERING 
C     IBINA=1-TWO PARTICLE REACTION 
C     IBINA=IEL=IDIF=IUNCY=IPLAN=0-CYLINDER SCATTERING. 
C 
C         PROJECTILE PARAMETERS 
C     PX1-X MOMENTUM COMPONENT(GEV/C) 
C     PY1-Y MOMENTUM COMPONENT(GEV/C) 
C     PZ1-Z MOMENTUM COMPONENT(GEV/C) 
C     IK1-PARTICLE TABLE NUMBER 
C 
C         TARGET PARAMETERS 
C     PX2-X... 
C     PY2-Y... 
C     PZ2-Z... 
C     IK2- PARTICLE... 
C 
C   FOR EXAMPLE PP-COLLISIONS AT 5GEV/C IN LABORATORY FRAME 
C     IK1=37,IK2=37,PX1=PX2=PY1=PY2=PZ2=0.,PZ1=5. 
C 
C  PARTICLE TABLE NUMBER IK            PARTICLE LABEL 
C           1                                  PI+ 
C           2                                  PI- 
C           3                                  K+ 
C           4                                  K- 
C           5                                  K0 
C           6                                  AK0 
C           7                                  PI0 
C           8                                  ETA 
C           9                                  ETAP 
C          10                                  RHO+ 
C          11                                  RHO- 
C          12                                  K*+ 
C          13                                  K*- 
C          14                                  K*0 
C          15                                  AK*0 
C          16                                  RH0 
C          17                                  OMEGA 
C          18                                  PHI0 
C          37                                  P 
C          38                                  N 
C          39                                  S+ 
C          40                                  S- 
C          41                                  S0 
C          42                                  KSI- 
C          43                                  KSI0 
C          44                                  L 
C          45                                  DL++ 
C          46                                  DL+ 
C          47                                  DL- 
C          48                                  DL0 
C          49                                  S*+ 
C          50                                  S*- 
C          51                                  S*0 
C          52                                  KSI*- 
C          53                                  KSI*0 
C          54                                  OM- 
C 
C    ESSENTIAL PARAMETERS FOR STRING OR CLUSTER DECAY 
C     PUD-STRANGE PARTICLE PRODUCTION PROBABILITY 
C     PS1-VECTOR MESON PRODUCTION PROBABILITY 
C     SIGMA-CONSTANT TO COMPUTE TRANSFERSE MOMENTUM OF PARTICLES 
C     PARM,PARB,SWMAX ARE CUTS FOR STRING DECAY 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /DATA2/ PUD,PS1,SIGMA,CX2 
      COMMON /SIGDIA/ CROSD(5),DST 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON /PRINTS/ IPRINT 
      COMMON /CPRSIG/ ISGCOL 
      COMMON /P0LAB1/ P0,DSM,TKIN 
      COMMON /YESELA/YESELA 
      COMMON/STREXC/STREXC 
      COMMON /ISLERR/ ISLERR   ! HADES1
      LOGICAL IPRINT 
      LOGICAL YESELA 
C     REAL *8 LAB1,LAB2 
      CHARACTER*8 LAB1,LAB2 
      CALL LABEL(LAB1,IDIN(1)) 
      CALL LABEL(LAB2,IDIN(2)) 
      IEL=0 
      IDIF=0 
      IUNCY=0 
      IPLAN=0 
      IBINA=0 
16    SIGIN=SIGTOT-SIGEL 
      IB1=IBLE(IK1) 
      IB2=IBLE(IK2) 
      SBIN   = CROSD(1) 
      SIGDIF = CROSD(2) 
      SUNC   = CROSD(3) 
      SIPLAN = CROSD(4) 
      SCYLIN = CROSD(5) 
      S=SQS**2 
      PS1=0.75 
      IF(.NOT.(IB1.EQ.0.AND.IB2.EQ.1)) GO TO 7655 
      IF(SQS-AM1-AM2.GT.0.30) GO TO 7655 
C  FOR M-N REACTION 
      SIGDIF=0. 
      SCYLIN=0. 
      SUNC=0. 
* ---V.T.  05.11.94 renormalization for strangeness exchange 
      IS1=ISLE(IK1) 
      IS2=ISLE(IK2)
        if(ISLERR.eq.1)return   ! HADES1
c        if(ISLERR.eq.1)then
c          write(25,*)' ISLE#1'
c          return
c        end if
      ICHA=IQLE(IK1)+IQLE(IK2) 
      if(IS1.eq.0.and.IS2.eq.0.and. 
     &  (ICHA.gt.-1.and.ICHA.lt.3) ) then 
      SIGTOT=SIGTOT-SBIN 
      SIGIN=SIGIN-SBIN 
      SBIN=SBIN-STREXC 
      if(SBIN.lt.0.d0) SBIN=0. 
      SIGTOT=SIGTOT+SBIN 
      SIGIN=SIGIN+SBIN 
      endif 
* ----- 
      SIGEL=SIGTOT-SBIN-SIPLAN 
      GO TO 7654 
C      DELTA+NUCLEON 
7655  CONTINUE 
c     IF(SQS-AM1-AM2.GT.0.15) GO TO 7654 
      IF(SQS.GT.3.00) GO TO 7654 
      IF(.NOT.(IK2.EQ.37.OR.IK2.EQ.38)) GO TO 7654 
      IF(.NOT.(IK1.EQ.46.OR.IK1.EQ.45.OR.IK1.EQ.47.OR. 
     *IK1.EQ.48)) GO TO 7654 
      ICHA=IQLE(IK1)+IQLE(IK2) 
      IF(ICHA.EQ.3.OR.ICHA.EQ.-1) GO TO 7654 
      SBIN=CRNDNN(S,ICHA) 
      SIGDIF=0. 
      SCYLIN=0. 
      SUNC=0. 
      SIPLAN=0. 
      SIGEL=SIGTOT-SBIN 
7654  CONTINUE 
       ISGCOL=0 
      IF((ISGCOL.NE.0).OR.(.NOT.IPRINT)) GO TO 525 
      WRITE(ITLIS,1000) LAB1,LAB2,S,P0 
1000  FORMAT(/15X,A8,A8,18H COLLISION AT SCM=,F10.4,7H GEV**2, 
     *'( PLAB OF ',F10.4) 
      IF(SIGEL.GT.0) WRITE(ITLIS,1001)  SIGEL 
      IF(SBIN.GT.0) WRITE(ITLIS,1002)   SBIN 
      IF(SIGDIF.GT.0) WRITE(ITLIS,1003) SIGDIF 
      IF(SUNC  .GT.0) WRITE(ITLIS,1004) SUNC 
      IF(SIPLAN.GT.0) WRITE(ITLIS,1005) SIPLAN 
      IF(SCYLIN.GT.0) WRITE(ITLIS,1006) SCYLIN 
1001  FORMAT(3X,'  ELASTIC  REACTION CROSS SECTION =',F10.4,'MB') 
1002  FORMAT(3X,'    BINAR  DIAGRAM  CROSS SECTION =',F10.4,'MB') 
1003  FORMAT(3X,'DIFRACTION DIAGRAM  CROSS SECTION =',F10.4,'MB') 
1004  FORMAT(3X,'UNDEV.CYL. DIAGRAM  CROSS SECTION =',F10.4,'MB') 
1005  FORMAT(3X,' PLANAR    DIAGRAM  CROSS SECTION =',F10.4,'MB') 
1006  FORMAT(3X,' CYLINDR   DIAGRAM  CROSS SECTION =',F10.4,'MB') 
 525  RND=RNDMD(-1) 
      IF(.NOT.YESELA)         GO TO 526 
      IF(RND.GT.SIGEL/SIGTOT) GO TO 526 
      IEL=1 
      GO TO 10 
  526 IS1=ISLE(IK1) 
      IS2=ISLE(IK2) 
        if(ISLERR.eq.1)return   ! HADES1
c        if(ISLERR.eq.1)then
c          write(25,*)' ISLE#2'
c          return
c        end if
      IF (IS1.NE.0.OR.IS2.NE.0)        GO  TO  6 
      IF (IK1.LE.36.OR.IK2.LE.36)      PS1=0.50 
    6 IF (SIGIN.GT.0.001)              GO  TO  7 
      IEL=1 
                               GO  TO  10 
    7 RND=RNDMD(-1) 
      IF(RND.GT.SBIN/SIGIN)            GO  TO  77 
      IBINA=1 
                               GO  TO  10 
   77 IF(RND.GT.(SIPLAN+SBIN)/SIGIN)   GO  TO  8 
      IPLAN=1 
                               GO  TO  10 
    8 IF(RND.GT.(SIPLAN+SBIN+SIGDIF)/SIGIN) GO  TO  9 
      IDIF=1 
                               GO  TO  10 
    9 IF(RND.GT.(SIPLAN+SIGDIF+SBIN+SUNC)/SIGIN)     GO  TO  10 
      IUNCY=1 
10    CONTINUE 
      ISGCOL=1 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE SLOPE(B,BFOR) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 B,BFOR 
C   SLOPE EVALUATES THE ELASTIC SLOPES B AND BFOR, WHERE THE 
C CROSS-SECTION VARIES AS DEXP(BFOR*TFORWARD)*DEXP(B*(T-TFORWARD)) 
C   *** FOR THE CHOICE OF ISL, ISLFOR 
C 
      COMMON /CUTOF2/BA,BB,BINF,POW,ISL,ISLFOR 
      COMMON /COMKI1/ HLA2,HLB2,W,INUMA 
      COMMON /COMKI2/ELA,ELB,PLALB 
      COMMON /CALC/HA,HB,HA2,HB2 
      DIMENSION  COPE(3),SLFOR(2) 
      S=W**2 
      HLA=DSQRT(HLA2) 
      HLB=DSQRT(HLB2) 
      FACT=ALAMB(1.0D0,HLA2/S,HLB2/S) 
      COPE(1)=0.5*FACT*(BA*(HLA/HA)**POW + BB*(HLB/HB)**POW) 
      COPE(2)=0.5*FACT*(BA+BB) 
      DIFFA=(BA-BINF)*(HLA/HA)**POW 
      DIFFB=(BB-BINF)*(HLB/HB)**POW 
      COPE(3)=0.5*FACT*(BINF+DIFFA+BINF+DIFFB) 
      B0=COPE(ISL) 
      SLFOR(1)=0.0 
      SLFOR(2)=B0 
      BFOR=SLFOR(ISLFOR) 
      IF(INUMA.EQ.0.OR.INUMA.EQ.2) B0=B0*0.8 
C----  FOR MESON-MESON COLLISION 
      TLAB=DSQRT(PLALB**2+HLA2)-HLA 
      IF(INUMA.EQ.2.AND.TLAB.LT.2.4)  B0=2.0 
      B=B0+0.7*DLOG(PLALB) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ANG(TFOR,TBACK,T,Z,PHI) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 TFOR,TBACK,T,Z,PHI 
C   ANG CALCULATES (RANDOMLY) THE POLAR AND AZIMUTHAL SCATTERING ANGLES 
C (Z=DCOS(THETA) AND PHI) FOR THE TWO-BODY PROCESS, USING THE ELASTIC 
C   SLOPES B AND BFOR 
C 
C   TFOR=MOMENTUM TRANSFER FOR FORWARD SCATTERING INTO A AND B 
C   TBACK=MOMENTUM TRANSFER FOR BACKWARD SCATTERING INTO A AND B 
C 
      COMMON /COMKI1/ HLA2,HLB2,W,INUMA 
      COMMON /COMKI2/ELA,ELB,PLALB 
      COMMON /CALC/HA,HB,HA2,HB2 
      COMMON /BEES/B,BFOR 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      S=W**2 
      EA=(S+HA2-HB2)/(2.0*W) 
      EB=(S+HB2-HA2)/(2.0*W) 
      PAB2=EA**2-HA2 
      PAB=DSQRT(PAB2) 
      TFOR=HA2+HLA2-2.0*(EA*ELA-PAB*PLALB) 
      TBACK=HA2+HLA2-2.0*(EA*ELA+PAB*PLALB) 
      TDIFF=TBACK-TFOR 
      TB=B*TDIFF 
      IF(TB.GT.-30.) GO TO 5 
      TBB=0. 
      GO TO 6 
    5 TBB=DEXP(TB) 
    6 R3=RNDMD(-1) 
      ZOT=TBB*(1.0-R3) + R3 
      TPRIME=DLOG(ZOT) 
      TPRIME=TPRIME/B 
      T=TPRIME+TFOR 
      TRAT=TPRIME/TDIFF 
      Z=1.0-2.0*TRAT 
      IF(Z.LT.-1.0) Z=-1.0 
      IF(Z.GT.1.0) Z=1.0 
      R4=RNDMD(-1) 
      PHI=2.0*PI*R4 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ELZPLE(IK1,IK2,TKIN,Z,PHI,IEXE) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 TKIN,Z,PHI 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      PHI=2.*PI*RNDMD(-1) 
      IF(IEXE.EQ.0) GO TO 1 
       Z=COSP(TKIN,12) 
       RETURN 
 1    CALL MARLE(IK1,IK2,KS) 
      IBP=IBLE(IK1) 
      Z=COSAM(IBP,TKIN,KS) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE MARLE(IK01,IK02,KS) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      IK1=IK01 
      IK2=IK02 
      IB1=IBLE(IK1) 
      IF(IK2.EQ.38) GO TO 112 
      IK2=37 
112   IB2=IBLE(IK2) 
      IQ1=IQLE(IK1) 
      IQ2=IQLE(IK2) 
      MQ=IQ1+IQ2 
      IF(IB1+IB2.LE.1) GO TO 1 
C   NUCLEON-NUCLEON COLLISION 
      IF(MQ-1) 3,4,3 
C  MESON-NUCLEON COLLISION 
 1    IF(MQ.EQ.2.OR.MQ.EQ.-1) GO TO 3 
      IF(MQ.EQ.0) GO TO 2 
      IF(IQ1-1) 5,4,5 
 2    IF(IQ1+1) 5,4,5 
 3    KS=1 
      RETURN 
 4    KS=2 
      RETURN 
 5    KS=3 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      DOUBLE PRECISION FUNCTION COSAM(IB1,TKIN,KS)
c   edited by KKG   03.05.08
      IMPLICIT REAL*8 (A-H,O-Z), INTEGER (I-N)
      data hlf, one, two, thr /0.5d0, 1.d0, 2.d0, 3.d0/
c
      IF(IB1.EQ.1) GO TO 4
C  MESON-NUCLEON SCATTERING
      if(TKIN.gt.2.4d0)  then
        cm= 0.140d0 
        cmn=0.940d0
        tcm=two*cm
        tmax=tcm*TKIN*tcm*(TKIN+tcm)/(tcm*TKIN+(cmn+cm)**2)
        tm7=7.5d0*tmax
        r1=RNDMD(-1)  
        COSAM=one+(two*log(one+r1*(exp(-tm7)-one)))/tm7
        return
      endif   
      IF(KS-2) 1,2,3
C  POSITIVE MESON+PROTON
 1    COSAM=COSP(TKIN,4)
      RETURN
C  NEGATIVE MESON+PROTON
 2    COSAM=COSP(TKIN,8)
      RETURN
C   NEUTRAL MESON+PROTON
 3    IF(RNDMD(-1)-hlf) 1,1,2
C  NUCLEON-NUCLEON SCATTERING
 4    IF(KS.EQ.1) GO TO 5
C  NEUTRON-PROTON SCATTERING
      IF(TKIN.GT.0.97d0) GO TO 6
      COSAM=cmjn(TKIN,3)        !  KKG 03.05.08
      RETURN
C  PROTON-PROTON SCATTERING
 5    IF(TKIN.GT.0.46d0) GO TO 6
      COSAM=1.-two*RNDMD(-1)
      RETURN
C  NEUTRON-PROTON AND PROTON-PROTON SCATTERING
 6    IF(TKIN.GT.2.8d0) GO TO 7
      COSAM=(one+cmjn(TKIN,1))/two    !  KKG 03.05.08
      RETURN
 7    if(TKIN.le.10.0d0)  then
        COSAM=0.25d0*(thr+cmjn(TKIN,2))
      else
        tmax= two*TKIN*0.940d0
        tm8 = 8.7d0*tmax
        r1=RNDMD(-1)  
        COSAM = one + (two*log(one + r1*(exp(-tm8)-one)))/tm8
      endif    
      RETURN
      END
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      DOUBLE PRECISION FUNCTION COSP(T,J)
c   edited by KKG   03.05.08
      IMPLICIT REAL*8 (A-H,O-Z), INTEGER (I-N)
c
C  CALCULATION OF SCATTERED ANGLE
      JJ=J                       ! 10.02.2002
      IF(T.LE.0.08) GO TO 1
      IF(T.LE.0.3) GO TO 2
      IF(T.LE.1.) GO TO 3
      IF(J.EQ.12) JJ=8
      COSP=cmjn(T,JJ+3)         
      RETURN
 1    COSP=cmjn(T,J)
      RETURN
 2    COSP=cmjn(T,J+1)
      RETURN
 3    IF(J.EQ.12) JJ=8
      COSP=cmjn(T,JJ+2)
      RETURN
      END
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
c      FUNCTION CMJ(T,J) 
c      IMPLICIT REAL*8 (A-H,O-Z) 
c      REAL*8 CMJ,T 
cC  CALCULATION OF COSINE BY MEANS OF THE TABLE COEFFICIENTS 
c      COMMON /COEF3/ ANKJ(4,4,13) 
c      DIMENSION C(4,4)
cC	 
c*      COMMON /NPOUT/ COSCUR(108),COSFIN(108)   ! Sobol - for HIST
c*      REAL*4 COSCUR,COSFIN                     ! Sobol - for HIST
cC
c      S1=0. 
c      S2=0. 
c      R=RNDMD(-1)
c      R1=DSQRT(R)
cC	 
c      DO 2 K=1,4 
c      DO 2 N=1,4 
c      C(N,K)=ANKJ(N,K,J) 
c 2    CONTINUE
cC  
c      DO 3 N=1,4 
c      DO 3 K=1,4 
c      S1=S1+C(N,K)*(R**(N-1))*(T**(K-1)) 
c 3    S2=S2+C(N,K)*(T**(K-1))
cC  
c      IF(S2.GE.1.)  S2=0.999999 
c      D=2.0*R1*(S1+(1.-S2)*R**4)-1. 
c*      CALL HIST(SNGL(D),-5.0,5.0,0.1,COSCUR,108,1.0)   ! Sobol - HIST	 
cC
c      IF(DABS(D).GT.1.) GO TO 4 
c      CMJ=D
c      RETURN
cC	 
c 4    CMJ=DSIGN(1.D0,D) 
c      RETURN 
c      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      double precision function cmj1(t,j,r1)
      implicit real*8 (a-h, o-z), integer (i-n)
c     written by KKG  03.05.08
cc
C  CALCULATION OF COSINE BY MEANS OF THE TABLE COEFFICIENTS
      COMMON /COEF3/ ankj
      dimension ankj(4,4,13), tk(4), r1n(5)
      data zro, one, two /0.d0, 1.d0, 2.d0/

c ======================================================================

      s1 = zro
      r1n(1) = one
      r1n(2) = r1
      r1n(3) = r1*r1
      r1n(4) = r1*r1n(3)
      r1n(5) = r1n(3)*r1n(3)
      tk(1) = one
      tk(2) = t
      tk(3) = t*t
      tk(4) = t*t*t
      s2 = zro
      do 10 n = 1,4
      do 10 k = 1,4
        term = ankj(n,k,j)*tk(k)
        s1 = s1 + term*r1n(n)
        s2 = s2 + term
   10 continue
      cta = two*sqrt(r1)*(s1 + (one - s2)*r1n(5)) - one
      temp1 = abs(cta)
      if (temp1.le.one) then
        cmj1 = cta
      else
        cmj1 = sign(one, cta)
      endif
      return
      end
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      double precision function cmjn (t0, j0)
c     written by KKG  03.05.08

c ======================================================================
c
c     Cosine calculation for elastic and charge-exchange reactions.
c     cmjn "n" for NEW; extrapolates old approximations from finite
c     angles different from 0 and 180 deg.  The old approximations
c     near 0 and 180 exhibit unphysical "pole-like" behavior.
c
c ======================================================================

      implicit real*8 (a-h, o-z), integer (i-n)

c ======================================================================

      dimension ankj(4,4,13), tk(4), r1n(5)

      common /COEF3/   ankj

      data zro, one, two /0.d0, 1.d0, 2.d0/

c ======================================================================

      t = t0
      j = j0 
      rl1 = 0.2d0
      rl2 = 0.4d0
      rr1 = 0.9d0
      rr2 = 0.95d0
      r1=RNDMD(-1)
      if (r1.lt.rl1 .or. r1.gt.rr2) then
        if (r1.lt.rl1) then
          x1 = zro  
          y1 = -one
          x2 = rl1
          y2 = cmj1 (t, j, x2)           
          x3 = rl2
          y3 = cmj1 (t, j, x3) 
        else          
          x1 = one
          y1 = one
          x2 = rr2
          y2 = cmj1 (t, j, x2)           
          x3 = rr1
          y3 = cmj1 (t, j, x3) 
        endif
        d  = (x2 - x3)*x1*x1 + (x3 - x1)*x2*x2 + (x1 - x2)*x3*x3
        da = (x2 - x3)*y1    + (x3 - x1)*y2    + (x1 - x2)*y3
        db = (y2 - y3)*x1*x1 + (y3 - y1)*x2*x2 + (y1 - y2)*x3*x3
        dc = (x2*y3 - x3*y2)*x1*x1 + (x3*y1 - x1*y3)*x2*x2 +
     &       (x1*y2 - x2*y1)*x3*x3
        a = da/d
        b = db/d
        c = dc/d
        cta = a*r1*r1 + b*r1 +c
        go to 20
      else 
c  Old version of angular distributions;
c  Used for r1 >= rl1 and r1 <= rr2
        r1n(1) = one
        r1n(2) = r1
        r1n(3) = r1*r1
        r1n(4) = r1*r1*r1
        r1n(5) = r1n(3)*r1n(3)
        tk(1) = one
        tk(2) = t
        tk(3) = t*t
        tk(4) = t*t*t
        s1 = zro
        s2 = zro
        do n = 1,4
          do k = 1,4
          term = ankj(n,k,j)*tk(k)
          s1 = s1 + term*r1n(n)
          s2 = s2 + term
          end do
        end do
        cta = two*sqrt(r1)*(s1 + (one - s2)*r1n(5)) - one
      endif
   20 temp1 = abs(cta)
      if (temp1.le.one) then
        cmjn = cta
      else
        cmjn = sign(one, cta)
      endif
      return

c ======================================================================
      end
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION IQLE(IK) 
C  COMPUTE PARTICLE CHARGE 
      COMMON /COMCHA/ ICHAM(18),ICHAB(18) 
      IF(IK.GT.36) GO TO 1 
C   MESON CHARGE 
      IQLE=ICHAM(IK) 
      RETURN 
C  BARION CHARGE 
 1    IQLE=ICHAB(IK-36) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION GAM(IK) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 GAM 
      COMMON /DATA1/CMIX(6,2),PMASM(18),PMASB(18),PGAMM(18), 
     *PGAMB(18),MESO(9,2) 
      IF(IK-36) 1,1,2 
 1    GAM=PGAMM(IK) 
      RETURN 
 2    GAM=PGAMB(IK-36) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION XDIST(XMIN,IB1,IS1,IFL) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 XDIST,XMIN 
      COMMON /COMABM/ ALFAM,BETAM 
      COMMON /COMABB/ ALFAB,BETAB 
      IF(IABS(IB1).EQ.1) GO TO 3 
      IF(IS1.NE.0) GO TO 33 
 2    CALL SBETA(X,ALFAM,BETAM) 
      IF(X.LE.XMIN) GO TO 2 
      IF(RNDMD(-1).GE.0.5) X=1.-X 
      XDIST=X 
      RETURN 
 33   BETAN=1. 
      GO TO 1 
 3    BETAN=BETAB 
      IF(IABS(IFL).GT.1) BETAN=BETAB+1 
 1    CALL SBETA(X,ALFAB,BETAN) 
      IF(X.LE.XMIN) GO TO 1 
      XDIST=X 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE SBETA(X,ALFA,BETA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 X,ALFA,BETA 
C  SIMULATION OF BETA DISTRIBUTION U(X)=C*X**(ALFA-1)*(1-X)**(BETA-1) 
C  IONK,S METHOD 
 1    RAN1=RNDMD(-1) 
      RAN2=RNDMD(-1) 
      R1A=RAN1**(1./ALFA) 
      R2B=RAN2**(1./BETA) 
      R12=R1A+R2B 
      IF(R12.GE.1.) GO TO 1 
      X=R1A/R12 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION WMX(KS,IF1,IF2,PARM,PARB) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 WMX,PARM,PARB 
      COMMON /DATA4/QMAS(9) 
      IF(KS)1,1,2 
 1    WMX=PARM+QMAS(IABS(IF1))+QMAS(IABS(IF2)) 
      RETURN 
 2    WMX=PARB+QMAS(IABS(IF1))+QMAS(IABS(IF2)) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION AMASF(IK) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMASF 
C  COMPUTE FIXED PARTICLE MASS 
      COMMON /DATA1/CMIX(6,2),PMASM(18),PMASB(18),PGAMM(18), 
     *PGAMB(18),MESO(9,2) 
      COMMON /ISOB3/ISOB3 
      IF(IK-36) 1,1,2 
 1    AMASF=PMASM(IK) 
      RETURN 
 2    AMASF=PMASB(IK-36) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION AMAS(IK) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMAS 
C  COMPUTE PARTICLE MASS 
      COMMON /DATA1/CMIX(6,2),PMASM(18),PMASB(18),PGAMM(18), 
     *PGAMB(18),MESO(9,2) 
      COMMON /ISOB3/ISOB3 
      COMMON /INTTYP/ITYP 
      COMMON /ITHEA/ITHEA(11) 
C--------------- HADES2 -----------------------------
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /ISLERR/ ISLERR
      if(IK.le.0)then
        ISLERR=1
        write(25,10)IK,NUMTRE
   10   format(' AMAS check border, IK=',I4,',   Event',I8)
        return
      end if
C--------------- end HADES2 -------------------------
      IF(IK-36) 1,1,3 
 1    AMAS=PMASM(IK) 
      IF(IK.EQ.10.OR.IK.EQ.11.OR.IK.EQ.16) GO  TO  2 
      RETURN 
 2    IF(ISOB3.NE.1)  RETURN 
      CALL MRHO(AMR,GD) 
      AMAS=AMR 
      RETURN 
 3    AMAS=PMASB(IK-36) 
      IF(IK.LT.45.OR.IK.GT.48) RETURN 
      IF(ISOB3.NE.1)  RETURN 
1991  CONTINUE 
C     IF((ITHEA(8).EQ.1).OR.(ITYP.EQ.3))  THEN 
C           CALL  MDELT1(AMD,GD) 
C     ELSE 
          CALL  MDELTA(AMD,GD) 
C     ENDIF 
      AMAS=AMD 
      RETURN 
      END 
C   ****************************************************************** 
      SUBROUTINE MRHO(AMRHO,GD) 
C *** SIMULATION OF RHO_MESON MASS DISTRIBUTION  *** 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMRHO,GD 
      DATA AMPI/0.140/,AMR0/0.770/ 
      DATA AMRMIN/0.281/,AMRMAX/1.200/ 
   10 CONTINUE 
      AMR=AMRMIN+RNDMD(-1)*(AMRMAX-AMRMIN) 
      Q=0.5*DSQRT(AMR*AMR-4.*AMPI*AMPI) 
      GD=0.095 *q*((q/AMPI)/(1.+(q/AMR0)**2))**2 
*ti       GD=0.150 * 
*ti  *  AMR/AMR0*((1.-(2.*AMPI/AMR)**2)/(1.-(2.*AMPI/AMR0)**2))**1.5 
*ti     F=    (GD*AMR0)**2/((AMR**2 -AMR0**2)**2+(AMR0*GD)**2) 
      F=0.25*GD**2/((AMR-AMR0)**2+0.25*GD**2) 
      IF(RNDMD(-1).GT.F)  GO  TO  10 
c       write( 6,*) 'MR,GD,q=', AMR,GD,Q 
      AMRHO=AMR 
      RETURN 
      END 
C   ****************************************************************** 
      SUBROUTINE MDELT1(AMDEL,GD) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMDEL, GD 
      COMMON/IDN12/ ID1,ID2 
      COMMON/SCOLLD/ SCOLLD 
      DATA AMN/0.940/,AMPI/0.140/,AMD0/1.232/ 
      DATA AMDMIN/1.081/,AMDMAX/1.700/ 
      AMD02=AMD0*AMD0 
      IBB=IB(ID1)+IB(ID2) 
      IF(IBB.EQ.0)  write( 6,*) 'MDELT1: IBB', IBB 
      AMX=AMN 
      IF(IBB.EQ.1)  AMX=AMPI 
      S=SCOLLD+0.03 
      SSX=DSQRT(S)-AMX 
      AMDMAXX=AMDMAX 
      IF(SSX.LT.AMDMAX)  AMDMAXX=SSX 
      IF(AMDMAXX.LT.AMDMIN) WRITE( 6,*) 'SSX,ID1,ID2=', SSX,ID1,ID2 
      IF(AMDMAXX.LT.AMDMIN) GO TO 13 
      L=0 
   10 CONTINUE 
      LI=0 
   11 CONTINUE 
      AMD=AMDMIN+RNDMD(-1)*(AMDMAXX-AMDMIN) 
      GD=GDM(AMD) 
      GD2=GD*GD 
      X=DSQRT(1.-1.25*GD2/AMD02) 
      XM=AMD0*DSQRT(0.6+0.4*X) 
      IF(XM.GT.AMDMAXX)  XM=AMDMAXX 
      F1=((AMD02-XM*XM)**2+AMD02*GD2)*AMD / 
     1    (((AMD02-AMD*AMD)**2+AMD02*GD2)*XM ) 
      IF(RNDMD(-1).GT.F1)           GO  TO  11 
      AX=(AMD+AMX)**2 
      IF(AX.GE.S)                 LI=LI+1 
      IF(AX.GE.S.AND.LI.LE.99)    GO  TO  11 
      IF(LI.GT.99)                GO  TO  12 
      XS=((S-AX)*(S-(AMD-AMX)**2)) / 
     1   ((S-(AMDMIN+AMX)**2)*(S-(AMDMIN-AMX)**2) ) 
      F2=DSQRT(XS) 
      L=L+1 
C The diagnostic printout is modified by Sobol, 16.04.2002    ! sobol
      IF(L.GT.50)WRITE(25,1001)L,S                            ! sobol
 1001            FORMAT(' MDELT1 Diagnostic: L,S=',I12,E12.5) ! sobol
      IF(L.GT.50) GO TO 2 
      IF(RNDMD(-1).GT.F2)  GO  TO  10 
    2   AMDEL=AMD 
      RETURN 
   12 write( 6,*) 'MDELT1:S,AMD,SSX,ID1,ID2=', S,AMD,SSX, ID1,ID2 
      AMDEL=AMD 
      RETURN 
   13   AMDEL=AMDMIN 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE KSPIN(IFL1,KS1,IK1,IB1) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C  CALCULATION OF KS1 
C  KS1=0 FOR MESON,KS1=1 FOR DIQUARK WITH S=0, 
C  KS1=2 FOR DIQUARK WITH S=1 
      COMMON /DATA6/POD810(3,6),PODSA(8,3),KBAR(18,2) 
      IF(IB1.EQ.0) KS1=0 
      IF(IB1.EQ.1.AND.IK1.GE.45) KS1=2 
      IF(IB1.EQ.1.AND.IK1.LT.45) 
     *KS1=1+IDINT(PODSA(IK1-36,IFL1)+RNDMD(-1)) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE FLAVD(IFLQ,IFLJ,IFLL) 
C  COMPUTE QUARK FLAVOUR IN DIQUARK 
      REAL*8 RNDMD 
      KD=IFLQ-3 
      GO TO (61,62,63,64,65,66),KD 
 61   IFLJ=1 
      IFLL=1 
      RETURN 
 62   IFLJ=2 
      IFLL=2 
      RETURN 
 63   IFLJ=1 
      IFLL=2 
      IF(RNDMD(-1).GT.0.5) RETURN 
      IFLJ=2 
      IFLL=1 
      RETURN 
 64   IFLJ=1 
      IFLL=3 
      IF(RNDMD(-1).GT.0.5) RETURN 
      IFLJ=3 
      IFLL=1 
      RETURN 
 65   IFLJ=2 
      IFLL=3 
      IF(RNDMD(-1).GT.0.5) RETURN 
      IFLJ=3 
      IFLL=2 
      RETURN 
 66   IFLJ=3 
      IFLL=3 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION KI2(IFL01,IFL02,KSA,IR) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C   TABLE NUMBER FOR MESON OR BARION DETERMINATION 
      COMMON /ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /DATA6/POD810(3,6),PODSA(8,3),KBAR(18,2) 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /DATA1/CMIX(6,2),PMASM(18),PMASB(18),PGAMM(18), 
     *PGAMB(18),MESO(9,2) 
      IFL1=IFL01 
      IFL2=IFL02 
      IF(KSA.NE.0) GO TO 2 
C  TABLE NUMBER FOR MESON 
      IFLSGN=(10-IFL1)/5 
      IFL1=IABS(IFL1) 
      IFL2=IABS(IFL2) 
      IFL12=3*(IFL1-1)+IFL2 
      K1=MESO(IFL12,IFLSGN) 
      ISPIN=IDINT(PS1+RNDMD(-1)) 
      IF(IR.EQ.1) ISPIN=1 
      IF(IR.EQ.2) ISPIN=0 
      K2=9*ISPIN+K1 
      IF(K1.LE.6) GO TO 1 
      TMIX=RNDMD(-1) 
      KM=K1-6+3*ISPIN 
      K2=7+9*ISPIN+IDINT(TMIX+CMIX(KM,1))+IDINT(TMIX+CMIX(KM,2)) 
 1    KI2=K2 
      RETURN 
C  TABLE NUMBER FOR BARION 
 2    IF(KSA.EQ.1)K=1 
      IFLQ=IFL1 
      IFQQ=IFL2 
      IF(IFL2.GT.3) GO TO 21 
      IFLQ=IFL2 
      IFQQ=IFL1 
 21   CONTINUE 
      IF(KSA.EQ.2) K=1+IDINT(POD810(IFLQ,IFQQ-3)+RNDMD(-1)) 
      IF(IR.EQ.1) K=2 
      IF(IR.EQ.2) K=1 
 10   CONTINUE 
      IFQ12=3*(IFQQ-4)+IFLQ 
      K2=KBAR(IFQ12,K) 
      IF(K2.NE.0) GO TO 11 
      K=2 
      GO TO 10 
 11   CONTINUE 
      IF(K2.EQ.41.OR.K2.EQ.44)GO TO 3 
      KI2=K2 
      RETURN 
 3    IF(KSA.EQ.1) GO TO 6 
      IF(IFQQ.EQ.6)GO TO 4 
      K2=41+3*IDINT(0.75+RNDMD(-1)) 
      GO TO 5 
 4    K2=41 
 5    KI2=K2 
      RETURN 
 6    IF(IFQQ.EQ.6)GO TO 7 
      K2=41+3*IDINT(0.25+RNDMD(-1)) 
      GO TO 8 
 7    K2=44 
 8    KI2=K2 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE PTDIST(PX,PY,SIGMA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PX,PY,SIGMA 
C  COMPUTE NEW PRODUCTED QUARK TRANSFERSE MOMENTUM 
C  SIMULATION OF PT DISTRIBUTION FROM U(PT)=DSQRT(1./PI*SIGMA**2) 
C   *DEXP(-PT**2/(SIGMA**2)) 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      DRND=RNDMD(-1) 
      PT=SIGMA*DSQRT(-DLOG(DRND)) 
      PHI=2.*PI*RNDMD(-1) 
      PX=PT*DCOS(PHI) 
      PY=PT*DSIN(PHI) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ROTAM(CT,ST,CFI,SFI,PX1,PX2,J) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 CT,ST,CFI,SFI,PX1,PX2 
C  ROTATE OF VECTOR PX1 
      DIMENSION ROT(3,3),PX1(3),PX2(3) 
      ROT(1,1)=CT*CFI 
      ROT(1,2)=-SFI 
      ROT(1,3)=ST*CFI 
      ROT(2,1)=CT*SFI 
      ROT(2,2)=CFI 
      ROT(2,3)=ST*SFI 
      ROT(3,1)=-ST 
      ROT(3,2)=0. 
      ROT(3,3)=CT 
      IF(J.EQ.0) GO TO 2 
      DO 1 I=1,3 
 1    PX2(I)=ROT(I,1)*PX1(1)+ROT(I,2)*PX1(2)+ROT(I,3)*PX1(3) 
      RETURN 
 2    DO 3 I=1,3 
 3    PX2(I)=ROT(1,I)*PX1(1)+ROT(2,I)*PX1(2)+ROT(3,I)*PX1(3) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ANGLE(PX,CT,ST,CFI,SFI) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PX,CT,ST,CFI,SFI 
C  COMPUTE ROTOR PARAMETERS 
C  AND COSINE,SINE OF THETA AND PHI 
      DIMENSION PX(3) 
      P=DSQRT(SP(PX,PX)) 
      CT=PX(3)/P 
      ST=DSQRT(1.D0-CT*CT) 
      PM=P*ST 
      IF(PM.EQ.0.) GO TO 1 
      CFI=PX(1)/PM 
      SFI=PX(2)/PM 
      RETURN 
 1    CFI=1. 
      SFI=0. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE LORLLE(V,PX,E,L) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 V,PX,E 
C  LORENTZ TRANSFORMATION OF PX MOMENTUM COMPONENTS 
      DIMENSION V(3),PX(3) 
      VV=V(1)*V(1)+V(2)*V(2)+V(3)*V(3) 
      GA=1.D0/DSQRT(DABS(1.D0-VV)) 
      BEP=SP(V,PX) 
      GABEP=GA*(GA*BEP/(1.+GA)-L*E) 
      DO 1 I=1,3 
 1    PX(I)=PX(I)+GABEP*V(I) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION SP(A,B) 
      REAL*8 SP,A,B 
C     SCALAR PRODUCT OF THREE DIMENSIONAL VEKTORS 
      DIMENSION A(3),B(3) 
      SP=A(1)*B(1)+A(2)*B(2)+A(3)*B(3) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE KINEM(PX1,PY1,PZ1,AM1,PX2,PY2,PZ2,AM2,V,S,P1) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PX1,PY1,PZ1,AM1,PX2,PY2,PZ2,AM2,V,S,P1 
C  CALCULATION OF CM VELOCITY V(I),CM TOTAL ENERGY S 
C  AND MOMENTUM COMPONENTS IN CM FRAME 
      DIMENSION V(3),P1(3),P2(3) 
      P1(1)=PX1 
      P1(2)=PY1 
      P1(3)=PZ1 
      P2(1)=PX2 
      P2(2)=PY2 
      P2(3)=PZ2 
      E1=DSQRT(AM1**2+SP(P1,P1)) 
      E2=DSQRT(AM2**2+SP(P2,P2)) 
      E=E1+E2 
      S=AM1**2+AM2**2+2.*E1*E2-2.*SP(P1,P2) 
      V(1)=(P1(1)+P2(1))/E 
      V(2)=(P1(2)+P2(2))/E 
      V(3)=(P1(3)+P2(3))/E 
      CALL LORLLE(V,P1,E1,1) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE FLAVO(IB1,IK1,IB2,IK2,IFL1,IFL2,IFL3,IFL4) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      COMMON /DATA5/IFLM(18,2),IFLB(18,3),DQQ(3,3) 
C  FLAVOUR OF INTERACTING QUARK FOR BARYON AND MESON 
      IF(IB1) 2,2,3 
C  FLAVOURS OF MESON QUARKS 
 2    INR1=IDINT(1.+2.*RNDMD(-1)) 
      IFL1=IFLM(IK1,INR1) 
      I1=1 
      IF(INR1.EQ.1)I1=2 
      IFL2=IFLM(IK1,I1) 
      IF(IK1.EQ.7.OR.IK1.EQ.16.OR.IK1.EQ.17) GO TO 13 
      IF(IK1.EQ.8.OR.IK1.EQ.9)GOTO 12 
      GO TO 4 
 12   IFL1=2+IDINT(0.25+RNDMD(-1)) 
      IF(IFL1.EQ.2) IFL1=1+IDINT(0.5+RNDMD(-1)) 
      IFL1=IFL1*(-1.)**(INR1-1) 
      IFL2=-IFL1 
      GO TO 4 
 13   IFL1=(1+IDINT(0.5+RNDMD(-1)))*(-1.)**(INR1-1) 
      IFL2=-IFL1 
      GO TO 4 
C  FLAVOURS OF BARION QUARKS 
 3    INR1=IDINT(1.+3.*RNDMD(-1)) 
      IFL1=IFLB(IK1-36,INR1) 
      IF(INR1-2)200,201,202 
 200  I1=2 
      I2=3 
      GO TO 205 
 201  I1=1 
      I2=3 
      GO TO 205 
 202  I1=1 
      I2=2 
 205  IF1=IFLB(IK1-36,I1) 
      IF2=IFLB(IK1-36,I2) 
      IFL2=DQQ(IF1,IF2) 
C  FLAVOURS OF TARGET HADRON QUARKS 
 4    IF(IB2) 20,20,30 
 20   INR2=IDINT(1.+2.*RNDMD(-1)) 
      IFL3=IFLM(IK2,INR2) 
      I2=1 
      IF(INR2.EQ.1) I2=2 
      IFL4=IFLM(IK2,I2) 
      IF(IK2.EQ.7.OR.IK2.EQ.16.OR.IK2.EQ.17) GO TO 33 
      IF(IK2.EQ.8.OR.IK2.EQ.9) GO TO 32 
      RETURN 
 32   IFL3=2+IDINT(0.25+RNDMD(-1)) 
      IF(IFL3.EQ.2) IFL3=1+IDINT(0.5+RNDMD(-1)) 
      IFL3=IFL3*(-1.)**(INR2-1) 
      IFL4=-IFL3 
      RETURN 
 33   IFL3=(1+IDINT(0.5+RNDMD(-1)))*(-1.)**(INR2-1) 
      IFL4=-IFL3 
      RETURN 
 30   INR2=IDINT(1.+3.*RNDMD(-1)) 
      IFL3=IFLB(IK2-36,INR2) 
      IF(INR2-2) 500,501,502 
 500  I1=2 
      I2=3 
      GO TO 505 
 501  I1=1 
      I2=3 
      GO TO 505 
 502  I1=1 
      I2=2 
 505  IF1=IFLB(IK2-36,I1) 
      IF2=IFLB(IK2-36,I2) 
      IFL4=DQQ(IF1,IF2) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION IBLE(IK) 
C   CALCULATION OF PARTICLE BARION NUMBER 
      IF(IK-36) 1,1,2 
 1    IBLE=0 
      RETURN 
 2    IBLE=1 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE LORPLE(BV,NIN,NFIN,L) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 BV 
C  LORENTZ TRANSFORMATION OF MOMENTUM COMPONENTS PR(I,J) 
C  AND ENERGY PR(4,J) (L=1) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      DIMENSION BV(3) 
      BVV=BV(1)*BV(1)+BV(2)*BV(2)+BV(3)*BV(3) 
      GA=1.D0/DSQRT(DABS(1.D0-BVV)) 
      DO 1 J=NIN,NFIN 
      BEP=BV(1)*PR(1,J)+BV(2)*PR(2,J)+BV(3)*PR(3,J) 
      GABEP=GA*(GA*BEP/(1.+GA)-L*PR(4,J)) 
      PR(1,J)=PR(1,J)+GABEP*BV(1) 
      PR(2,J)=PR(2,J)+GABEP*BV(2) 
      PR(3,J)=PR(3,J)+GABEP*BV(3) 
 1    PR(4,J)=GA*(PR(4,J)-L*BEP) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE LORCLE(BV,NIN,NFIN,L) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 BV 
C  LORENTZ TRANSFORMATION OF COORDINATES (5,6,7) 
C  AND TIME (8) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      DIMENSION BV(3) 
      BVV=BV(1)*BV(1)+BV(2)*BV(2)+BV(3)*BV(3) 
      GA=1.D0/DSQRT(DABS(1.D0-BVV)) 
      DO 1 J=NIN,NFIN 
      BEV=BV(1)*PR(5,J)+BV(2)*PR(6,J)+BV(3)*PR(7,J) 
      GABEP=GA*(BEV*GA/(GA+1.)-FLOAT(L)*PR(8,J)) 
      PR(5,J)=PR(5,J)+GABEP*BV(1) 
      PR(6,J)=PR(6,J)+GABEP*BV(2) 
      PR(7,J)=PR(7,J)+GABEP*BV(3) 
      PR(8,J)=GA*(PR(8,J)-FLOAT(L)*BEV) 
 1    CONTINUE 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION ISLE(K) 
C  COMPUTE PARTICLE STRANGE 
      COMMON /COMSTR/ ISTR(36) 
C--------------- HADES1 -----------------------------
      COMMON /RANDOM/ IX,IXINIT,NUMTRE,IXFIRS,LASTIX
      COMMON /ISLERR/ ISLERR
      if(K.le.0)then
        ISLERR=1
        write(25,10)K,NUMTRE
   10   format(' ISLE check border, K=',I4,',   Event',I8)
        return
      end if
C--------------- end HADES1 -------------------------
      IF(K.GT.36) GO TO 1 
      ISLE=ISTR(K) 
      RETURN 
 1    ISLE=ISTR(K-18) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION ZDIST(IFL1,IFL2,ZMIN,ZMAX,IBP) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 ZDIST,ZMIN,ZMAX 
C  COMPUTE FRACTION Z FROM E+PZ OF QUARK OR ANTIQUARK 
C  SIMULATION OF Z DISTRIBUTION FROM U(Z)=1.-CX2+3.*CX2*(1.-Z)**2 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      IF(IFL1.LE.3.AND.IBP.EQ.1) GO TO 200 
      IF(IFL1.LE.3.AND.IBP.EQ.0) GO TO 100 
 201  ZDIST=RNDMD(-1)*(ZMAX-ZMIN)+ZMIN 
      YF=0.8+0.2*DEXP(-25.*(1.-ZDIST))/(1.-DEXP(-25.D0)) 
      YP=1. 
      IF(RNDMD(-1)*YP.LE.YF) RETURN 
      GO TO 201 
  100 IF(IABS(IFL2).EQ.3)        GO TO 300 
  150 ZDIST=RNDMD(-1)*(ZMAX-ZMIN)+ZMIN 
      YF=2.*CX2*(1.-ZDIST)+1.-CX2 
      YP=2. 
      IF(RNDMD(-1)*YP.LE.YF)RETURN 
      GO TO 150 
 200  ZDIST=RNDMD(-1)*(ZMAX-ZMIN)+ZMIN 
      YF=3.*(1.-ZDIST)**2 
      YP=3. 
      IF(RNDMD(-1)*YP.LE.YF) RETURN 
      GO TO 200 
  300 ZDIST=ZMIN+RNDMD(-1)*(ZMAX-ZMIN) 
      YF=(1.-ZDIST)**0.5 
      IF(RNDMD(-1).GT.YF)    GO  TO  300 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE CLUSLE(IFL1,IFL2,KSD,AMCTR) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMCTR 
C  HADRONS PRODUCTION BY MEANS CLUSTER BREAKING 
C  WITH QUARK AND ANTIQUARK OR QUARK AND DIQUARK IFL1 AND IFL2 
C  ON ENDS 
C  AMCTR IS MASS OF CLUSTER 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/PRINTS/IPRINT 
      LOGICAL IPRINT 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON /PRODMA/ PPMAS(50) 
      DIMENSION IFL(2),U(3) 
      DOUBLE PRECISION PCM,A,B,C 
      COMMON /COLRET/LRET 
      LOGICAL LRET 
      LRET = .FALSE. 
      NREP=0 
      NFIX=NP 
 100  I=NFIX 
      NREP = NREP + 1 
      IF(NREP.LE.NTRIES) GOTO 102 
      LRET = .TRUE. 
      IF(IPRINT) WRITE(ITLIS,1200) NREP,IFL1,IFL2,AMCTR 
1200  FORMAT(3X,' IN CLUSLE NREP GT ',3I8,' AMCTR=',F12.4) 
      RETURN 
 102  CONTINUE 
      KSPIN=0 
      IFL(1)=IFL1 
      IFL(2)=IFL2 
      I=I+2 
C  CHOOSE SIDE OF BREAK 
      JSIDE=1 
C  IF ANY IFL IS A DIQUARK 
      IF(KSD.NE.0) GO TO 150 
C  IFL(1) AND IFL(2) ARE QUARKS 
C  Q,QBAR PAIR 
      IFLN=ISIGN(IDINT(RNDMD(-1)/PUD)+1,-IFL(JSIDE)) 
      KSD1=KSD 
      KSD2=KSD   
      NREPA=0           ! ADDED BY A.Timofeev 08/17/2011 17:20
      GO TO 200 
C  IFL(1) OR IFL(2) IS DIQUARK 
C Q,QBAR PAIR 
150   IPSIGN=IFL(JSIDE) 
      IF(IFL(JSIDE).GT.3) GO TO 130 
      IPSIGN=-IFL(JSIDE) 
      KSD1=0 
      KSD2=KSD 
      GO TO 135 
130   KSD1=KSD 
      KSD2=0 
135   IFLN=ISIGN(IDINT(RNDMD(-1)/PUD)+1,IPSIGN) 
C+++++++++ SIVOKL 11.11.92 
      NREPA=0 
9100  CONTINUE 
      NREPA=NREPA+1 
      IF(NREPA.GT.10)   GO TO 100 
      IF(NREPA.LT.0) THEN
c         PRINT *,'CLUSLE WARNING, NREPA NEGATIVE'
      END IF
C+++++++++++++++++++++++++ 
C  IDENTS AND MASSES OF PARTICLES 
 200  IPR(I-1)=KI2(IFL(JSIDE),IFLN,KSD1,0) 
      IPR(I)=KI2(IFL(3-JSIDE),-IFLN,KSD2,0) 
      AM1=AMAS(IPR(I-1)) 
      AM2=AMAS(IPR(I)) 
C  IF TOO LOW MASS,START ALL OVER 
C+++++++++ SIVOKL 11.11.92 
c     IF(AMCTR.LE.AM1+AM2) GO TO 100 
      IF(AMCTR.LE.AM1+AM2) GO TO 9100 
C+++++++++++++++++++++++++ 
      A=AMCTR 
      B=AM1 
      C=AM2 
      PCM=DSQRT((A*A-B*B-C*C)**2-(2.D0*B*C)**2)/(2.D0*A) 
      PA=PCM 
C     PROB=2.*PA/AMCTR 
C   PROB IS TWO-BODY PHASE SPACE FACTOR 
C     IF(RNDMD(-1).GT.PROB) GO TO 100 
      U(3)=2.*RNDMD(-1)-1. 
      PHI=2.*PI*RNDMD(-1) 
      ST=DSQRT(1.-U(3)**2) 
      U(1)=ST*DCOS(PHI) 
      U(2)=ST*DSIN(PHI) 
      PR(1,I-1)=PA*U(1) 
      PR(1,I)=-PA*U(1) 
      PR(2,I-1)=PA*U(2) 
      PR(2,I)=-PA*U(2) 
      PR(3,I-1)=PA*U(3) 
      PR(3,I)=-PA*U(3) 
      PA2=PA**2 
      PR(4,I-1)=DSQRT(PA2+AM1**2) 
      PR(4,I)=DSQRT(PA2+AM2**2) 
      PPMAS(I-1)=AM1 
      PPMAS(I)=AM2 
      NP=I 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION ALAMB(X,Y,Z) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 ALAMB,X,Y,Z 
C 
C    COMPUTE KINEMATIC FUNCTION 
C 
      ALAMB=(X-Y-Z)*(X-Y-Z) - 4.*Y*Z 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE GETPT(PT0,SIGMA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PT0,SIGMA 
C   GENERATE DISTRIBUTION WITH 1/(1+B*PT**2)**4 
      DATA CON1/1.697652726/,CON2/-.3333333333/ 
      PT0=CON1*SIGMA*DSQRT(RNDMD(-1)**CON2-1.) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE PTDGET(PX,PY,SIGMA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PX,PY,SIGMA 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
C   GENERATE DISTRIBUTION WITH 1/(1+B*PT**2)**4 
      DATA CON1/1.697652726/,CON2/-.3333333333/ 
      PT0=CON1*SIGMA*DSQRT(RNDMD(-1)**CON2-1.) 
      PHI=2.*PI*RNDMD(-1) 
      PX=PT0*DCOS(PHI) 
      PY=PT0*DSIN(PHI) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE STRILE(IFL1,IFL2,KSD0,ECS) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 ECS 
C  HADRONS PRODUCTION BY MEANS STRING BREAK 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /COMLD/PLDER(50) 
      COMMON /CINSID/ INSIDE 
      COMMON /KAPPA/ XAP 
      COMMON /DATA4/QMAS(9) 
      COMMON /DATA5/IFLM(18,2),IFLB(18,3),DQQ(3,3) 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /COLRET/ LRET 
      COMMON /COMQSE/ QSEE,QVSEE 
      COMMON /PRODMA/ PPMAS(50) 
      LOGICAL QSEE,QVSEE 
      DIMENSION W(2),PX1(2),PY1(2),IFL(2),PMTS(2) 
      DIMENSION PX1L(2),PY1L(2),V(3),NIN(2),NFIN(2) 
      DIMENSION PRR(4,50),PRL(4,50),IPRR(50),IPRL(50) 
      DIMENSION P7(50),P8(50),PPMAL(50),PPMAR(50) 
      LOGICAL LRET 
      LRET = .FALSE. 
      NREP = 0 
      NFIX=NP 
 100  I=NFIX 
      NPR=0 
      NPL=0 
      NP=NFIX 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES) GO TO 102 
      LRET=.TRUE. 
      RETURN 
102   CONTINUE 
      IFL(1)=IFL1 
      IFL(2)=IFL2 
      KSD=KSD0 
      IBP=0 
C     PROPER MOMENTUM OF STRING 
      SIGML=0.000001 
C 
      IF(KSD.EQ.0) GO TO 13 
      CALL PTDGET(PX1L(1),PY1L(1),SIGML) 
      PX1L(2)=-PX1L(1) 
      PY1L(2)=-PY1L(1) 
      IFFL=IFL2 
      IF(IFL2.LE.3)IFFL=IFL1 
      CALL FLAVD(IFFL,IFLJ,IFLL) 
 13   CONTINUE 
      DO 1 JT=1,2 
      W(JT)=ECS 
 1    CONTINUE 
      CALL PTDGET(PX1(1),PY1(1),SIGML) 
      IF(KSD.EQ.0) GO TO 14 
      PX1(1)=PX1L(1) 
      PY1(1)=PY1L(1) 
14    PX1(2)=-PX1(1) 
      PY1(2)=-PY1(1) 
C  IF ENERGY IS LOW,ONLY ONE BREAK 
      WMAX=WMX(KSD,IFL1,IFL2,PARM,PARB) 
      IF(W(1)*W(2).LE.WMAX**2) GO TO 12 
C  CHOOSE SIDE. GENERATE A QUARK-ANTIQUARK PAIR FORM HADRON 
 2    I=I+1 
      JT=1.+2.*RNDMD(-1) 
      IF(JT.EQ.1) NPR=NPR+1 
      IF(JT.EQ.2) NPL=NPL+1 
      KSDN=KSD 
      IF(IFL(JT).LE.3) GO TO 5 
      IF(RNDMD(-1).GT.0.1) GO TO 5 
      IBP=1 
      CALL PTDGET(PXLL,PYLL,SIGMA) 
      PX1(JT)=-PXLL 
      PY1(JT)=-PYLL 
      KSDN=0 
      IFL(JT)=IFLJ 
 5    IFS=-IFL(JT) 
      IF(IFL(JT).GT.3) IFS=IFL(JT) 
      IFLN=ISIGN(1+IDINT(RNDMD(-1)/PUD),IFS) 
      IFQ=IFL(JT) 
      IFQN=IFLN 
      IF(IFQ.LT.4) KSDN=0 
      IPR(I)=KI2(IFQ,IFQN,KSDN,0) 
      IF(KSDN.NE.0) KSD=0 
      CALL PTDGET(PX2,PY2,SIGMA) 
      PR(1,I)=PX1(JT)+PX2 
      PR(2,I)=PY1(JT)+PY2 
      PMAS=AMAS(IPR(I)) 
      PPMAS(I)=PMAS 
C   GENERATE Z 
      PMTS(3-JT)=0.6 
      PMTS(JT)=PMAS**2+PR(1,I)**2+PR(2,I)**2 
      IF(PMTS(1)+PMTS(2).GE.0.9*W(1)*W(2)) GO TO 100 
      ZMIN=PMTS(JT)/(W(1)*W(2)) 
      ZMAX=1.-PMTS(3-JT)/(W(1)*W(2)) 
      IF(ZMIN.GE.ZMAX) GO TO 100 
      Z=ZDIST(IFL(JT),IFQN,ZMIN,ZMAX,IBP) 
      PR(3,I)=0.5*(Z*W(JT)-PMTS(JT)/(Z*W(JT)))*(-1.)**(JT+1) 
      PR(4,I)=0.5*(Z*W(JT)+PMTS(JT)/(Z*W(JT))) 
      IF(.NOT.(JT.EQ.1)) GO TO 282 
      IPRR(NPR)=IPR(I) 
      PRR(1,NPR)=PR(1,I) 
      PRR(2,NPR)=PR(2,I) 
      PRR(3,NPR)=PR(3,I) 
      PRR(4,NPR)=PR(4,I) 
      PPMAR(NPR)=PPMAS(I) 
282   IF(.NOT.(JT.EQ.2)) GO TO 283 
      IPRL(NPL)=IPR(I) 
      PRL(1,NPL)=PR(1,I) 
      PRL(2,NPL)=PR(2,I) 
      PRL(3,NPL)=PR(3,I) 
      PRL(4,NPL)=PR(4,I) 
      PPMAL(NPL)=PPMAS(I) 
283   IF(IBP.EQ.0) GO TO 10 
      IFL(JT)=DQQ(IABS(IFLN),IFLL) 
      IFLJ=IABS(IFLN) 
      PX1L(JT)=PX1L(JT)+PXLL-PX2 
      PY1L(JT)=PY1L(JT)+PYLL-PY2 
      PX1(JT)=PX1L(JT) 
      PY1(JT)=PY1L(JT) 
      IF(IFL(JT).EQ.4.OR.IFL(JT).EQ.5.OR.IFL(JT).EQ.9) KSD=2 
      IBP=0 
      GO TO 11 
 10   CONTINUE 
      IFL(JT)=-IFLN 
      PX1(JT)=-PX2 
      PY1(JT)=-PY2 
 11   CONTINUE 
      W(1)=W(1)-PR(4,I)-PR(3,I) 
      W(2)=W(2)-PR(4,I)+PR(3,I) 
C   IF ENOUCH ENERGY LEFT,CONTINUE GENERATE 
 12   IKB=KI2(IFL(1),IFL(2),KSD,2) 
      PARC=0.2 
      IF(IABS(IFL(1)).EQ.3.OR.IABS(IFL(2)).EQ.3) PARC=0.5 
      AMB=AMAS(IKB)+PARC 
      P1X=PX1(1)+PX1(2) 
      P1Y=PY1(1)+PY1(2) 
      PT12=P1X**2+P1Y**2 
      W12=W(1)*W(2) 
      AMS2=W12-PT12 
      IF(AMS2.LT.AMB**2) GO TO 100 
      WMAX=WMX(KSD,IFL(1),IFL(2),PARM,PARB) 
      IF(W12.GE.WMAX**2) GO TO 2 
C  GIVEN FINAL TWO HADRON 
 3    NP=I 
      AMC=DSQRT(AMS2) 
      EC=(W(1)+W(2))/2.0 
      V(1)=P1X/EC 
      V(2)=P1Y/EC 
      V(3)=(W(1)-W(2))/(2.0*EC) 
      NIN(1)=NP+1 
      CALL CLUSLE(IFL(1),IFL(2),KSD,AMC) 
      IF(LRET) GO TO 100 
      NFIN(1)=NP 
      CALL LORPLE(V,NIN(1),NFIN(1),-1) 
      NI=NIN(1) 
      NF=NFIN(1) 
      NPR=NPR+1 
      NPL=NPL+1 
      IPRR(NPR)=IPR(NI) 
      PRR(1,NPR)=PR(1,NI) 
      PRR(2,NPR)=PR(2,NI) 
      PRR(3,NPR)=PR(3,NI) 
      PRR(4,NPR)=PR(4,NI) 
      PPMAR(NPR)=PPMAS(NI) 
      IPRL(NPL)=IPR(NF) 
      PRL(1,NPL)=PR(1,NF) 
      PRL(2,NPL)=PR(2,NF) 
      PRL(3,NPL)=PR(3,NF) 
      PRL(4,NPL)=PR(4,NF) 
      PPMAL(NPL)=PPMAS(NF) 
      JJ=NFIX 
      DO 284 J=1,NPR 
      JJ=JJ+1 
      IPR(JJ)=IPRR(J) 
      PR(1,JJ)=PRR(1,J) 
      PR(2,JJ)=PRR(2,J) 
      PR(3,JJ)=PRR(3,J) 
      PR(4,JJ)=PRR(4,J) 
      PPMAS(JJ)=PPMAR(J) 
284   CONTINUE 
      JJ=NFIX+NPR 
      DO 285 J=1,NPL 
      JJ=JJ+1 
      K=NPL-J+1 
      IPR(JJ)=IPRL(K) 
      PR(1,JJ)=PRL(1,K) 
      PR(2,JJ)=PRL(2,K) 
      PR(3,JJ)=PRL(3,K) 
      PR(4,JJ)=PRL(4,K) 
      PPMAS(JJ)=PPMAL(K) 
285   CONTINUE 
      N1=NFIX+1 
      N2=NFIX+NPR+NPL-1 
      IF(INSIDE.NE.0) GO TO 1252 
C------------------------------------------------------C 
C-----  CONSTITUENT     TIME           ----------------C 
C------------------------------------------------------C 
      DO 286 J=N1,N2 
      P3S=0. 
      ES=0. 
      DO 287 L=N1,J 
      P3S=P3S+PR(3,L) 
 287  ES=ES+PR(4,L) 
      TI=(ECS-2.*P3S)/(2.*XAP) 
      ZI=(ECS-2.*ES)/(2.*XAP) 
      IF(J.NE.N2) GO TO 288 
      TII=TI 
      ZII=ZI 
 288  PR(5,J)=0. 
      PR(6,J)=0. 
      PR(7,J)=ZI 
      PR(8,J)=TI 
 286  CONTINUE 
      PR(5,N2+1)=0. 
      PR(6,N2+1)=0. 
      PR(7,N2+1)=ZII 
      PR(8,N2+1)=TII 
C]]]]]]]]]]]] 
      IF(N2.LE.1) GO TO 1253 
      LN11=N1+1 
      DO 1389 L=LN11,N2 
      P7(L)=0.5*(PR(7,L-1)+PR(7,L)) 
      P8(L)=0.5*(PR(8,L-1)+PR(8,L)) 
1389  CONTINUE 
      DO 1489 L=LN11,N2 
      PR(7,L)=P7(L) 
      PR(8,L)=P8(L) 
1489  CONTINUE 
C]]]]]]]]]]]] 
      GO TO 1253 
C------------------------------------------------------C 
C-----  INSIDE-OUTSIDE  TIME           ----------------C 
C------------------------------------------------------C 
1252  CONTINUE 
      DO 1286 J=N1,NP 
      P3S=0. 
      ES=0. 
      NJ=J-1 
      IF(NJ.EQ.0) GO TO 1289 
      DO 1287 L=N1,NJ 
      P3S=P3S+PR(3,L) 
1287  ES=ES+PR(4,L) 
1289  TI=(ECS-2.*P3S+PR(4,J)-PR(3,J))/(2.*XAP) 
      ZI=(ECS-2.*ES-PR(4,J)+PR(3,J))/(2.*XAP) 
      PR(5,J)=0. 
      PR(6,J)=0. 
      PR(7,J)=ZI 
      PR(8,J)=TI 
1286  CONTINUE 
1253  CONTINUE 
C------------------------------------------------------------- 
      DO 386 J=N1,NP 
386   PLDER(J)=0. 
      IB1=IBLE(IPR(N1)) 
      IB2=IBLE(IPR(NP)) 
      PLDER(N1)=.667 
      PLDER(NP)=.667 
      IF(IB1.EQ.0) PLDER(N1)=.5 
      IF(IB2.EQ.0) PLDER(NP)=.5 
      IF(.NOT.QVSEE) RETURN 
      IF(IB1.EQ.0.AND.IB2.EQ.0) GO TO 387 
      IF(IB1.EQ.0) PLDER(N1)=0. 
      IF(IB2.EQ.0) PLDER(NP)=0. 
      RETURN 
387   RM=RNDMD(-1) 
      IF(RM.GT.0.5) PLDER(N1)=0. 
      IF(RM.LE.0.5) PLDER(NP)=0. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE PLANLE(IK1,IB1,IK2,IB2,S,IEL) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 S 
C 
C  CALCULATION OF PLANAR GRAPH 
C  ONLY FOR MESON BARYON COLLISION 
C 
      COMMON /COMLD/ PLDER(50) 
      COMMON /DATA5/IFLM(18,2),IFLB(18,3),DQQ(3,3) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /PRODT/ IORD(50) 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /COLRET/ LRET 
      LOGICAL LRET 
      DIMENSION NIN(2),NFIN(2) 
      LRET = .FALSE. 
      IF(IB1.EQ.1) GO TO 1003 
      IF1P=IABS(IFLM(IK1,2)) 
      IF1PN=IFLM(IK1,1) 
      IF1=IFLB(IK2-36,1) 
      IF2=IFLB(IK2-36,2) 
      IF3=IFLB(IK2-36,3) 
      IF(IF1P.EQ.IF1) IF2P=DQQ(IF2,IF3) 
      IF(IF1P.EQ.IF2) IF2P=DQQ(IF1,IF3) 
      IF(IF1P.EQ.IF3) IF2P=DQQ(IF1,IF2) 
      IF(IF1P.NE.IF1.AND.IF1P.NE.IF2.AND.IF1P.NE.IF3) GO TO 100 
      CALL KSPIN(IF1P,KSP,IK2,IB2) 
      GO TO 1004 
 1003 IF1P=IABS(IFLM(IK2,2)) 
      IF1PN=IFLM(IK2,1) 
      IF1=IFLB(IK1-36,1) 
      IF2=IFLB(IK1-36,2) 
      IF3=IFLB(IK1-36,3) 
      IF(IF1P.EQ.IF1) IF2P=DQQ(IF2,IF3) 
      IF(IF1P.EQ.IF2) IF2P=DQQ(IF1,IF3) 
      IF(IF1P.EQ.IF3) IF2P=DQQ(IF1,IF2) 
      IF(IF1P.NE.IF1.AND.IF1P.NE.IF2.AND.IF1P.NE.IF3) GO TO 100 
      CALL KSPIN(IF1P,KSP,IK1,IB1) 
 1004 IKN0=KI2(IF2P,IF1PN,KSP,2) 
      IKN=KI2(IF2P,IF1PN,KSP,1) 
      PAM0=AMAS(IKN0) 
      PAM=AMAS(IKN) 
      NIN(1)=NP+1 
      AMS=DSQRT(S) 
      PARC=0. 
      IF(AMS.GT.PAM0+PARC) GO TO 1007 
      IEL=1 
      GO TO 100 
1007  IF(AMS.GE.PAM+SWMAX) GO TO 1008 
      CALL CLUSLE(IF1PN,IF2P,KSP,AMS) 
      IF(LRET) RETURN 
      CALL TIFILE(NIN(1),NP,AMS) 
      GO TO 1014 
1008  CALL STRILE(IF1PN,IF2P,KSP,AMS) 
      NIN1=NIN(1) 
      IF(LRET) RETURN 
 1014 NFIN(2)=NP 
      NIN1=NIN(1) 
      NFIN2=NFIN(2) 
      DO 1006 JO=NIN1,NFIN2 
 1006 IORD(JO)=0 
      RETURN 
 100  LRET=.TRUE. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE CYLLE(IK1,IB1,AM1,IK2,IB2,AM2,P1,IBINA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM1,AM2,P1 
C 
C  CALCULATION OF CYLINDRICAL GRAPH 
C 
      COMMON /COMLD/ PLDER(50) 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /PRODT/ IORD(50) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /COLRET/ LRET 
      DIMENSION P1(3),NIN(2),NFIN(2),VS1(3),VS2(3) 
      DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      LOGICAL LRET 
C ______   PRIMORDIAL MOMENTUM OF PARTONS  _____________________ 
      DATA SIGMAI/0.4/ 
C ______________________________________________________________ 
      LRET = .FALSE. 
      NREP = 0 
      NPOLD=NP 
      AZ12=AM1**2 
      AZ22=AM2**2 
      PZER2=P1(3)**2 
      P0I=DSQRT(SP(P1,P1)) 
      EI1=DSQRT(AM1**2+P0I**2) 
      EI2=SQRT(AM2**2+P0I**2) 
      IF(EI1+EI2-AM1-AM2.GT.0.3) GO TO 100 
      LRET = .TRUE. 
      IBINA=1 
      RETURN 
100   CONTINUE 
      NP = NPOLD 
      NREP=NREP+1 
      IF(NREP.LT.  NTRIES) GO TO 200 
C     WRITE(ITLIS,1001)IK1,IK2,AM1,AM2,PZER2 
1001  FORMAT(1X,'CYLLE:NREP > NTRIES, IK1,IK2,AM1,AM2,PZER2=',2I5, 
     *3E10.4) 
      IBINA=1 
      LRET = .TRUE. 
      RETURN 
200   CONTINUE 
      CALL FLAVO(IB1,IK1,IB2,IK2,IFL1,IFL2,IFL3,IFL4) 
      CALL KSPIN(IFL3,KS2,IK2,IB2) 
      CALL KSPIN(IFL1,KS1,IK1,IB1) 
C  HADRON GENERATION BY MEANS FORMING AND BREAKING STRINGS 
      IF(IFL1) 1,1,2 
 1    IF11=IFL2 
      IF22=IFL1 
      GO TO 3 
 2    IF11=IFL1 
      IF22=IFL2 
 3    CONTINUE 
      IF(IB2.EQ.1) GO TO 102 
      IF(IFL3) 101,101,102 
 101  IF44=IFL3 
      IF33=IFL4 
      GO TO 103 
 102  IF33=IFL3 
      IF44=IFL4 
 103  CONTINUE 
      IKN1=KI2(IF44,IF11,KS2,1) 
      IKN2=KI2(IF22,IF33,KS1,1) 
      PAM1=AMAS(IKN1) 
      PAM2=AMAS(IKN2) 
C  MOMENTUM OF QUARKS 
      X1MIN=0. 
      X3MIN=0. 
      IS1=ISLE(IK1) 
      IF11S=IF11 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IF11).EQ.3) IF11S=IF22 
      X1=XDIST(X1MIN,IB1,IS1,IF11S) 
      IS2=ISLE(IK2) 
      IF33S=IF33 
      IF(IS2.NE.0.AND.IB2.EQ.0.AND.IABS(IF33).EQ.3) IF33S=IF44 
      X3=XDIST(X3MIN,IB2,IS2,IF33S) 
      X2=1.-X1 
      X4=1.-X3 
      PZ11=P1(3)*X1 
      PZ22=P1(3)*X2 
      PZ33=-P1(3)*X3 
      PZ44=-P1(3)*X4 
C    COMPUTE PT VALUES FOR PARTONS 
      PHI=2.*PI*RNDMD(-1) 
  160 CALL GETPT(PT1,SIGMAI) 
      AMQ21=AZ12*(AZ12+4.*X1*X2*PZER2)/(4.*(PZER2+AZ12))-PT1**2 
      PX11=PT1*DCOS(PHI) 
      PY11=PT1*DSIN(PHI) 
      PX22=-PX11 
      PY22=-PY11 
      PHI=2.*PI*RNDMD(-1) 
  170 CALL GETPT(PT3,SIGMAI) 
      AMQ22=AZ22*(AZ22+4.*X3*X4*PZER2)/(4.*(PZER2+AZ22))-PT3**2 
      PX33=PT3*DCOS(PHI) 
      PY33=PT3*DSIN(PHI) 
      PX44=-PX33 
      PY44=-PY33 
C  COMPUTE OF STABLE PARTICLE MASSES 
      IKN01=KI2(IF44,IF11,KS2,2) 
      IKN02=KI2(IF22,IF33,KS1,2) 
      PAM01=AMAS(IKN01) 
      PAM02=AMAS(IKN02) 
C   WILL BE START ALL OVER 
      PARC1=0.2 
      PARC2=0.2 
C  STRINGS OR CLUSTER DECAY 
      E11=PX11**2+PY11**2+PZ11**2+AMQ21 
      IF(E11.LT.0.) GO TO 100 
      E22=PX22**2+PY22**2+PZ22**2+AMQ21 
      IF(E22.LT.0.) GO TO 100 
      E33=PX33**2+PY33**2+PZ33**2+AMQ22 
      IF(E33.LT.0.) GO TO 100 
      E44=PX44**2+PY44**2+PZ44**2+AMQ22 
      IF(E44.LT.0.) GO TO 100 
      E11=DSQRT(E11) 
      E22=DSQRT(E22) 
      E33=DSQRT(E33) 
      E44=DSQRT(E44) 
      E1=E11+E44 
      E2=E22+E33 
      AMS2=E2**2-(PX22+PX33)**2-(PY22+PY33)**2-(PZ22+PZ33)**2 
      IF(AMS2.LT.(PAM02+PARC2)**2) GO TO 100 
      AMS1=E1**2-(PX11+PX44)**2-(PY11+PY44)**2-(PZ11+PZ44)**2 
      IF(AMS1.LT.(PAM01+PARC1)**2) GO TO 100 
      AMS1=DSQRT(AMS1) 
      AMS2=DSQRT(AMS2) 
C  VELOCITIES OF CM STRINGS 
      VS1(1)=(PX11+PX44)/E1 
      VS1(2)=(PY11+PY44)/E1 
      VS1(3)=(PZ11+PZ44)/E1 
      VS2(1)=(PX22+PX33)/E2 
      VS2(2)=(PY22+PY33)/E2 
      VS2(3)=(PZ22+PZ33)/E2 
C  BREAK OF STRING WITH QUARKS OF NUMBER 1 AND 4 
      NIN(1)=NP+1 
      IF(AMS1.LE.PAM1+SWMAX) GO TO 714 
      CALL STRILE(IF11,IF44,KS2,AMS1) 
      IF(LRET) GO TO 100 
      NFIN(1)=NP 
      GO TO 715 
714   CALL CLUSLE(IF11,IF44,KS2,AMS1) 
      IF(LRET) GO TO 100 
      NFIN(1)=NP 
      CALL TIFILE(NIN(1),NFIN(1),AMS1) 
715   NIN1=NIN(1) 
      NFIN1=NFIN(1) 
      L=1 
      PPX1(1)=PX11 
      PPX1(2)=PY11 
      PPX1(3)=PZ11 
      CALL LORLLE(VS1,PPX1,E11,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PR(1,J) 
      PPX1(2)=PR(2,J) 
      PPX1(3)=PR(3,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PPX1,PPX2,L) 
      PR(1,J)=PPX2(1) 
      PR(2,J)=PPX2(2) 
      PR(3,J)=PPX2(3) 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
510   CONTINUE 
      NIN(2)=NP+1 
      IF(AMS2.LE.PAM2+SWMAX)  GO TO 914 
C  BREAK OF STRING WITH QUARKS OF NUMBER 3 AND 2 ON ENDS 
      CALL STRILE(IF22,IF33,KS1,AMS2) 
      IF(LRET) GO TO 100 
      NFIN(2)=NP 
      GO TO 915 
914   CALL CLUSLE(IF22,IF33,KS1,AMS2) 
      IF(LRET) GO TO 100 
      NFIN(2)=NP 
      CALL TIFILE(NIN(2),NFIN(2),AMS2) 
915   NIN2=NIN(2) 
      NFIN2=NFIN(2) 
      L=1 
      PPX1(1)=PX22 
      PPX1(2)=PY22 
      PPX1(3)=PZ22 
      CALL LORLLE(VS2,PPX1,E22,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN2,NFIN2 
      PPX1(1)=PR(1,J) 
      PPX1(2)=PR(2,J) 
      PPX1(3)=PR(3,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PPX1,PPX2,L) 
      PR(1,J)=PPX2(1) 
      PR(2,J)=PPX2(2) 
      PR(3,J)=PPX2(3) 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
610   CONTINUE 
C  RETURN IN OVERALL CM FRAME 
      CALL LORPLE(VS1,NIN(1),NFIN(1),-1) 
      CALL LORCLE(VS1,NIN(1),NFIN(1),-1) 
      NIN1=NIN(1) 
      NFIN1=NFIN(1) 
      NIN2=NIN(2) 
      NFIN2=NFIN(2) 
      DO 813 JO=NIN1,NFIN1 
 813  IORD(JO)=0 
      DO 814 JO=NIN2,NFIN2 
 814  IORD(JO)=0 
      CALL LORPLE(VS2,NIN(2),NFIN(2),-1) 
      CALL LORCLE(VS2,NIN(2),NFIN(2),-1) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE UNCYLE(IK1,IB1,AM1,IK2,IB2,AM2,P1,IBINA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM1,AM2,P1 
C 
C      COMPUTE UNDEVELOPED CYLINDER DIAGRAM 
C 
      COMMON /COMLD/ PLDER(50) 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /PRODT/ IORD(50) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /COLRET/ LRET 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON /PRODMA/ PPMAS(50) 
      DIMENSION V(3),P1(3) 
      DIMENSION NIN(2),NFIN(2) 
      DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      LOGICAL LRET 
C    INITIALIZE 
      LRET = .FALSE. 
C ______   PRIMORDIAL MOMENTUM OF PARTONS  _____________________ 
      DATA SIGMAI/0.4/ 
C ______________________________________________________________ 
C    INITIALIZE 
      LRET = .FALSE. 
      NREP=0 
      P0=DSQRT(SP(P1,P1)) 
      AZ12=AM1**2 
      AZ22=AM2**2 
      PZER2=P0**2 
      E1=DSQRT(AM1**2+P0**2) 
      E2=DSQRT(AM2**2+P0**2) 
      ECM=E1+E2 
      SCM=ECM**2 
      IF(ECM-AM1-AM2.GT.0.3) GO TO 150 
      LRET = .TRUE. 
      IBINA=1 
      RETURN 
150   PSIGN=-1. 
      NREP = NREP + 1 
      IF(NREP.LE.  NTRIES) GO TO 200 
C     WRITE(ITLIS,1001)IK1,IK2,AMA,AMB,ZER2B 
1001   FORMAT(1X,'UCYLLE:NREP > NTRIES,IK1,IK2,AM1,AM2,PZER2', 
     *2I4,3(1X,F7.3)) 
      IBINA=1 
      LRET = .TRUE. 
      RETURN 
200   CONTINUE 
      CALL FLAVO(IB1,IK1,IB2,IK2,IFL11,IFL22,IFL33,IFL44) 
      CALL KSPIN(IFL11,KS11,IK1,IB1) 
      CALL KSPIN(IFL33,KS22,IK2,IB2) 
C    COMPUTE X VALUES FOR PARTONS 
      XMIN=0. 
      RND=RNDMD(-1) 
      IS1=ISLE(IK1) 
      IFL11S=IFL11 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL11).EQ.3) IFL11S=IFL22 
      X11=XDIST(XMIN,IB1,IS1,IFL11S) 
      X22=1.-X11 
      IS2=ISLE(IK2) 
      IFL33S=IFL33 
      IF(IS2.NE.0.AND.IB2.EQ.0.AND.IABS(IFL33).EQ.3) IFL33S=IFL44 
      X33=XDIST(XMIN,IB2,IS2,IFL33S) 
      X44=1.-X33 
C    COMPUTE PT VALUES FOR PARTONS 
      PHI=2.*PI*RNDMD(-1) 
  160 CALL GETPT(PT11,SIGMAI) 
      AMQ21=AZ12*(AZ12+4.*X11*X22*PZER2)/(4.*(PZER2+AZ12))-PT11**2 
      PX11=PT11*DCOS(PHI) 
      PY11=PT11*DSIN(PHI) 
      PX22=-PX11 
      PY22=-PY11 
      PHI=2.*PI*RNDMD(-1) 
  170 CALL GETPT(PT33,SIGMAI) 
      AMQ22=AZ22*(AZ22+4.*X33*X44*PZER2)/(4.*(PZER2+AZ22))-PT33**2 
      PX33=PT33*DCOS(PHI) 
      PY33=PT33*DSIN(PHI) 
      PX44=-PX33 
      PY44=-PY33 
      IF(IFL11.GT.0) GO TO 130 
      IFL1=IFL22 
      PX1=PX22 
      PY1=PY22 
      IFL2=IFL11 
      PX2=PX11 
      PY2=PY11 
      KS1=KS11 
      X1=X22 
      X2=X11 
      GO TO 140 
130   IFL1=IFL11 
      PX1=PX11 
      PY1=PY11 
      IFL2=IFL22 
      PX2=PX22 
      PY2=PY22 
      KS1=KS11 
      X1=X11 
      X2=X22 
140   IF(IB2.EQ.1) GO TO 102 
      IF(IFL33.GT.0) GO TO 102 
      IFL4=IFL33 
      PX4=PX33 
      PY4=PY33 
      IFL3=IFL44 
      PX3=PX44 
      PY3=PY44 
      KS2=KS22 
      X3=X44 
      X4=X33 
      GO TO 103 
102   IFL3=IFL33 
      PX3=PX33 
      PY3=PY33 
      IFL4=IFL44 
      PX4=PX44 
      KS2=KS22 
      PY4=PY44 
      X3=X33 
      X4=X44 
103   CONTINUE 
      PXH=PX1+PX4 
      PYH=PY1+PY4 
      X01=X2 
      IF(X01.EQ.0.) X01=X1 
      X02=X3 
      IF(X02.EQ.0.) X02=X4 
      PX01=PX2 
      PY01=PY2 
      PX02=PX3 
      PY02=PY3 
      KS02=KS1 
      IDH=KI2(IFL1,IFL4,KS2,0) 
      AMH=AMAS(IDH) 
      IFL01=IFL2 
      IFL02=IFL3 
      IF(RND.GE.0.5) GO TO 100 
      PXH=PX2+PX3 
      PYH=PY2+PY3 
      X01=X1 
      IF(X01.EQ.0.) X01=X2 
      X02=X4 
      IF(X02.EQ.0.) X02=X3 
      IFL01=IFL1 
      IFL02=IFL4 
      IDH=KI2(IFL2,IFL3,KS1,0) 
      AMH=AMAS(IDH) 
      PX01=PX1 
      PY01=PY1 
      PX02=PX4 
      PY02=PY4 
      KS02=KS2 
 100  P01=X01*P0 
      P02=X02*P0*PSIGN 
      E01=AMQ21+P01**2+PX01**2+PY01**2 
      IF(E01.LT.0.) GO TO 150 
      E02=AMQ22+P02**2+PX02**2+PY02**2 
      IF(E02.LT.0.) GO TO 150 
      E01=DSQRT(E01) 
      E02=DSQRT(E02) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-(PX01+PX02)**2- 
     *(PY01+PY02)**2 
      IDH1=KI2(IFL01,IFL02,KS02,2) 
      PARC=0.001 
      AMHB=AMAS(IDH1)+PARC 
      IF(AMDTR.LE.AMHB**2) GO TO 150 
      AMD=DSQRT(AMDTR) 
      IF(ECM.LE.AMD+AMH) GO TO 150 
      ALA=ALAMB(SCM,AMDTR,AMH**2) 
      P0H=DSQRT(ALA)/(2.*ECM) 
      PTHX=-(PX01+PX02) 
      PTHY=-(PY01+PY02) 
      DTRM=P0H**2-PTHX**2-PTHY**2 
      IF(DTRM.LT.0.) GO TO 150 
      PZH0=DSQRT(DTRM) 
      PZH=DSIGN(PZH0,-(P01+P02)) 
      ED=DSQRT(AMDTR+P0H**2) 
      EH=DSQRT(AMH**2+P0H**2) 
      PSIGN=DSIGN(1.D0,-PZH) 
      V(1)=-PTHX/ED 
      V(2)=-PTHY/ED 
      V(3)=PSIGN*PZH0/ED 
      IDHR=KI2(IFL01,IFL02,KS02,1) 
      AMHS=AMAS(IDHR)+SWMAX 
      IF(AMD.GT.AMHS) GO TO 300 
      NFIX=NP 
      NIN(1)=NP+1 
      CALL CLUSLE(IFL01,IFL02,KS02,AMD) 
      IF(LRET) GO TO 150 
      NFIN(1)=NP 
      CALL TIFILE(NIN(1),NFIN(1),AMD) 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      NIN1=NIN(1) 
      NFIN1=NFIN(1) 
      L=1 
      CALL LORLLE(V,PPX1,E01,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN1,NFIN1 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
610   CONTINUE 
      CALL LORPLE(V,NIN(1),NFIN(1),-1) 
      CALL LORCLE(V,NIN(1),NFIN(1),-1) 
      NPRODS=NP-NFIX 
      GO TO 400 
300   NFIX=NP 
      NIN(1)=NP+1 
      CALL STRILE(IFL01,IFL02,KS02,AMD) 
      IF(LRET) GO TO 150 
      NFIN(1)=NP 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      NIN1=NIN(1) 
      NFIN1=NFIN(1) 
      L=1 
      CALL LORLLE(V,PPX1,E01,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PR(1,J) 
      PPX1(2)=PR(2,J) 
      PPX1(3)=PR(3,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PPX1,PPX2,L) 
      PR(1,J)=PPX2(1) 
      PR(2,J)=PPX2(2) 
      PR(3,J)=PPX2(3) 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
510   CONTINUE 
      CALL LORPLE(V,NIN(1),NFIN(1),-1) 
      CALL LORCLE(V,NIN(1),NFIN(1),-1) 
      NPRODS=NP-NFIX 
400   NIN1=NIN(1) 
      NFIN1=NFIN(1) 
      DO 350 J=NIN1,NFIN1 
350   IORD(J)=0 
      NP=NP+1 
      IORD(NP)=0 
      PR(1,NP)=PTHX 
      PR(2,NP)=PTHY 
      PR(3,NP)=PZH 
      PR(4,NP)=EH 
      PPMAS(NP)=AMH 
      IPR(NP)=IDH 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DIFSCA(IFL01,IFL02,KS01,IK1,AM1, 
     *IFL03,IFL04,KS02,IK2,AM2,P1,IBINA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM1,AM2,P1 
C 
C     COMPUTE LOW MASS DIFFRACTION 
C 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /PRODT/ IORD(50) 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON /PRODMA/ PPMAS(50) 
      COMMON /COMLD/ PLDER(50) 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      DIMENSION V(3),P1(3) 
      DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      DIMENSION GAMA(3),AMR(3) 
      COMMON/COLRET/ LRET 
      LOGICAL LRET 
      DATA SIGMA1/0.23/,SIGMA2/0.30/ 
      DATA GAMA/0.032,0.032,0.032/ 
      DATA AMR /1.47,1.10,1.30/ 
      LRET = .FALSE. 
      NREP=0 
      XMIN=0. 
      P0=DSQRT(SP(P1,P1)) 
      E1=DSQRT(P0**2+AM1**2) 
      E2=DSQRT(P0**2+AM2**2) 
      ECM=E1+E2 
      SCM=ECM**2 
      DS=ECM-AM1-AM2 
      IF(DS.GT.0.3) GO TO 150 
      IBINA=1 
      RETURN 
150   CONTINUE 
      AMQ1=0. 
      AMQ2=0. 
      NREP=NREP+1 
      IF(NREP.LE.NTRIES) GO TO 151 
C     WRITE(ITLIS,1001)IK1,IK2,AM1,AM2,P0 
1001   FORMAT(1X,'DIFSCA:NREP > NTRIES,IK1,IK2,AM1,AM2,P0=', 
     *2I4,3(1X,F7.3)) 
      LRET = .TRUE. 
      RETURN 
151   CONTINUE 
      IFL1=IFL01 
      IFL2=IFL02 
      IF(IFL2.GT.3) AMQ2=0 
      KS1=KS01 
      IKA=IK1 
      IKB=IK2 
      AMA=AM1 
      AMB=AM2 
      IRDA=IRD1 
      IRDB=IRD2 
      PSIGN=-1. 
      IF(RNDMD(-1).GT.0.5) GO TO 100 
      PSIGN=1. 
      IFL1=IFL03 
      IFL2=IFL04 
      IF(IFL2.GT.3) AMQ2=0. 
      KS1=KS02 
      IKA=IK2 
      IKB=IK1 
      AMB=AM1 
      AMA=AM2 
      IRDA=IRD2 
      IRDB=IRD1 
C    COMPUTE X VALUES FOR PARTONS 
100   IBA=IBLE(IKA) 
      ISA=ISLE(IKA) 
      IFL1S=IFL1 
      IF(ISA.NE.0.AND.IBA.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      X1=XDIST(XMIN,IBA,ISA,IFL1S) 
      X2=1.-X1 
C     COMPUTE PT VALUE FOR HADRON 
140   CONTINUE 
      CALL GETPT(PT1,SIGMA2) 
      PHI=2.*PI*RNDMD(-1) 
      PX1=PT1*DCOS(PHI) 
      PY1=PT1*DSIN(PHI) 
      CALL GETEXP(PT,SIGMA1) 
      PHI=2.*PI*RNDMD(-1) 
      PTX=PT*DCOS(PHI) 
      PTY=PT*DSIN(PHI) 
      PX2=-PX1+PTX 
      PY2=-PY1+PTY 
      PT2=PX2**2+PY2**2 
      AMH=AMB 
      E1=DSQRT(AMQ1**2+(P0*X1)**2+PX1**2+PY1**2) 
      E2=DSQRT(AMQ2**2+(P0*X2)**2+PX2**2+PY2**2) 
      AMDTR=(E1+E2)**2-P0**2-PT**2 
      IDH=KI2(IFL1,IFL2,KS1,2) 
      IDHR=KI2(IFL1,IFL2,KS1,1) 
      AMHR=AMAS(IDHR) 
      PARC1=0.001 
      AMHB=AMAS(IDH)+PARC1 
      IF(AMDTR.GE.AMHB**2)       GO TO 200 
                         GO TO 140 
 200  AMD=DSQRT(AMDTR) 
      IF(ECM.LE.AMD+AMH)         GO TO 140 
      IBR=IBLE(IDHR) 
      ISR=ISLE(IDHR) 
      GAMRES=GAMA(3) 
      AMRES=AMR(3) 
      IF(IBR.NE.0)               AMRES=AMR(1) 
      IF(IBR.EQ.0.AND.ISR.NE.0)  AMRES=AMR(2) 
      IF(AMD.GT.AMRES)           GO  TO  162 
      IF(DS.LT.1.0.AND.IBA.EQ.0) GO  TO  162 
      ARGWG=-(AMD-AMRES)**2/GAMRES 
      IF(ARGWG.LE.-30.) ARGWG=-30. 
      WG=DEXP(ARGWG) 
      IF(RNDMD(-1).GT.WG)         GO  TO  140 
 162  ALA=ALAMB(SCM,AMDTR,AMH**2) 
      P0H=DSQRT(ALA)/(2.*ECM) 
      DTRM=P0H**2-PT**2 
      IF(DTRM.LT.0.)             GO TO 140 
      PZH=DSIGN(DSQRT(DTRM),-PSIGN) 
      ED=DSQRT(AMD**2+P0H**2) 
      V(1)=PTX/ED 
      V(2)=PTY/ED 
      V(3)=PZH/ED 
      IF(AMD.GT.AMHR+SWMAX) GO TO 300 
      NFIX=NP 
      NIN1=NP+1 
      CALL CLUSLE(IFL1,IFL2,KS1,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NP 
      CALL TIFILE(NIN1,NFIN1,AMD) 
      L=1 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=-PSIGN*P0*X1 
      CALL LORLLE(V,PPX1,E1,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN1,NFIN1 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
610   CONTINUE 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
      GO TO 400 
300   NFIX=NP 
      NIN1=NP+1 
      CALL STRILE(IFL1,IFL2,KS1,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NP 
      L=1 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=-PSIGN*P0*X1 
      CALL LORLLE(V,PPX1,E1,L) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PR(1,J) 
      PPX1(2)=PR(2,J) 
      PPX1(3)=PR(3,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PPX1,PPX2,L) 
      PR(1,J)=PPX2(1) 
      PR(2,J)=PPX2(2) 
      PR(3,J)=PPX2(3) 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,L) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
510   CONTINUE 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
400   CONTINUE 
      DO 350 J=NIN1,NFIN1 
C     PPMAS(J)=AMAS(IPR(J)) 
C     PPMAS(J)=DSQRT(PR(4,J)**2-PR(1,J)**2-PR(2,J)**2-PR(3,J)**2) 
350   IORD(J)=IRDA 
      NP=NP+1 
      IORD(NP)=IRDB 
      IPR(NP)=IKB 
      PR(1,NP)=-PTX 
      PR(2,NP)=-PTY 
      PR(3,NP)=DSIGN(PZH,-PZH) 
      PR(4,NP)=DSQRT(AMH**2+PR(1,NP)**2+ 
     *PR(2,NP)**2+PR(3,NP)**2) 
      PPMAS(NP)=AMH 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE GETEXP(PT,SIGMAD) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PT,SIGMAD 
      DRND=RNDMD(-1) 
      PT=SIGMAD*DSQRT(-DLOG(DRND)) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ELASLE(P,AMA,AMB,IK01,IK02) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 P,AMA,AMB 
C  MONTE CARLO SIMULATION OF ELASTIC HADRONIC COLLISION 
C-------------------------------------------------------- 
C   HADRON-NUCLEON COLLISION ONLY 
C-------------------------------------------------------- 
      COMMON /COMKI1/ HLA2,HLB2,W,INUMA 
      COMMON /COMKI2/ELA,ELB,PLALB 
      COMMON /CALC/HA,HB,HA2,HB2 
      COMMON /BEES/B,BFOR 
      DIMENSION P(3),PA(3) 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /PRODT/ IORD(50) 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON /DATA3/ POPB(10) 
      COMMON /PRODMA/PPMAS(50) 
      COMMON /COMELX/ SIGEL 
      COMMON /COMLD/PLDER(50) 
      COMMON /COMCRO/ SIGTOT 
      COMMON /ISLERR/ ISLERR   ! HADES2
      DIMENSION P1(3),P2(3) 
      IEXE =0 
      HLA=AMA 
      HLB=AMB 
      HLA2=HLA*HLA 
      HLB2=HLB*HLB 
      E1=DSQRT(HLA2+SP(P,P)) 
      E2=DSQRT(HLB2+SP(P,P)) 
      S=(E1+E2)**2 
C   S=(PA+PB)**2 
C   W= CENTRE OF MASS (C.M.) ENERGY 
      W=DSQRT(S) 
C  TKIN=KINETIC ENERGY OF PROJECTILE IN TARGET REST FRAME 
      TKIN=(S-HLA2-HLB2)/(2.0*HLB)-HLA 
C   PLALB=CM MOMENTUM OF A OR B IN ELASTIC EVENTS 
      PLALB=DSQRT(ALAMB(S,HLA2,HLB2))/(2.0*W) 
C   ELA=CM ENERGY OF A IN ELASTIC EVENT *** ELB=SAME FOR B 
      ELA=(S+HLA2-HLB2)/(2.0*W) 
      ELB=(S+HLB2-HLA2)/(2.0*W) 
      IK1=IK01 
      IK2=IK02 
      AMN1=HLA 
      AMN2=HLB 
      HA=AMN1 
      HB=AMN2 
      INUMA=1 
      IF(IK02.LE.36.OR.IK01.LE.36) INUMA=0 
      IF(IK02.LE.36.AND.IK01.LE.36) INUMA=2 
      HA2=HA*HA 
      HB2=HB*HB 
      TOBR=10.0 
      IF(IK01.GE.37) GOTO 71 
      TOBR=2.4 
C
C      IF(AMAS(IK01).GT.0.14) GO TO 71   ! HADES2 
      AMASIK01=AMAS(IK01)                ! HADES2
        if(ISLERR.eq.1)return            ! HADES2
c        if(ISLERR.eq.1)then
c          write(25,*)' AMAS#1'
c          return
c        end if
      IF(AMASIK01.GT.0.14)GOTO 71        ! HADES2
C
C      IF(IK02.LE.36.AND.AMAS(IK02).GT.0.14) GO TO 71   ! HADES2 
      AMASIK02=AMAS(IK02)                ! HADES2
        if(ISLERR.eq.1)return            ! HADES2
c        if(ISLERR.eq.1)then
c          write(25,*)' AMAS#2'
c          return
c        end if
      IF(IK02.LE.36.AND.AMASIK02.GT.0.14)GOTO 71   ! HADES2 
C
      IF(IK02.GT.38) GO TO 71 
      IQSUM = IQLE(IK01)+IQLE(IK02) 
      IF(IQSUM.EQ.-2.OR.IQSUM.EQ.3) GO TO 71 
      IF(IK01.LE.36.AND.IK02.LE.36.AND. 
     *IQSUM.EQ.2) GO TO 71 
C     IF(RNDMD(-1).GT.SIGEX/(SIGEL+SIGEX)) GO TO 79 
C        IK1=7 
C        IK2=38 
C     IF(IK01.EQ.2.AND.IK02.EQ.37) GO TO 75 
C        IK1=1 
C        IK2=38 
C     IF(IK01.EQ.7.AND.IK02.EQ.37) GO TO 75 
C        IK1= 2 
C        IK2=37 
C     IF(IK01.EQ.7.AND.IK02.EQ.38) GO TO 75 
C        IK1= 2 
C        IK2=37 
C     IF(IK01.EQ.1.AND.IK02.EQ.38) GO TO 75 
C        IK1=IK01 
C        IK2=IK02 
C75   IEXE=1 
 79   IF(TKIN.GT.2.5) GO TO 71 
      ISOB=0 
      P1(1)=P(1) 
      P1(2)=P(2) 
      P1(3)=P(3) 
      P2(1)=-P(1) 
      P2(2)=-P(2) 
      P2(3)=-P(3) 
      IF(IK01.GT.36.OR.IK02.GT.36) GO TO 60 
      CALL FOROM(IK1,P1,AMN1,IK2,P2,AMN2,SIGEL, 
     *IKD,PXD,PYD,PZD,DMAS,ISOB) 
      GO TO 61 
60    CALL FISOB(IK1,P1,AMN1,IK2,P2,AMN2,SIGEL, 
     *IKD,PXD,PYD,PZD,DMAS,ISOB) 
61    IF(ISOB.EQ.0) GO TO 71 
      NP=1 
      IORD(NP)=0 
      IPR(NP)=IKD 
      PPMAS(NP)=DMAS 
      PR(1,NP)=PXD 
      PR(2,NP)=PYD 
      PR(3,NP)=PZD 
      PR(4,NP)=DSQRT(DMAS**2+PXD**2+PYD**2+PZD**2) 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      RETURN 
 71   IF(TKIN-TOBR) 72,72,73 
 72   CALL ELZPLE(IK01,IK02,TKIN,Z,PHI,IEXE) 
      GO TO 74 
 73   CONTINUE 
C   SLOPE CALCULATES THE ELASTIC SLOPES FOR THE CHOSEN MASSES 
      CALL SLOPE(B,BFOR) 
C   ANG CALCULATES THE TWO-BODY SCATTERING ANGLES (AZIMUTHAL ANGLE PHI 
C   AND POLAR ANGLE THETA,WHERE Z=DCOS(THETA) 
      CALL ANG(TFOR,TBACK,T,Z,PHI) 
 74   PAMOD=DSQRT(ALAMB(S,HA2,HB2))/(2.0*W) 
      PAN=PAMOD*DSQRT(1.-Z**2) 
      PA(1)=PAN*DCOS(PHI) 
      PA(2)=PAN*DSIN(PHI) 
      PA(3)=PAMOD*Z 
      EA=DSQRT(PAMOD**2+HA**2) 
      EB=DSQRT(PAMOD**2+HB**2) 
      NP=NP+1 
      IPR(NP)=IK1 
      PR(1,NP)=PA(1) 
      PR(2,NP)=PA(2) 
      PR(3,NP)=PA(3) 
      PR(4,NP)=EA 
      IORD(NP)=IRD1 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      PPMAS(NP)=AMN1 
      NP=NP+1 
      IPR(NP)=IK2 
      PR(1,NP)=-PA(1) 
      PR(2,NP)=-PA(2) 
      PR(3,NP)=-PA(3) 
      PR(4,NP)=EB 
      IORD(NP)=IRD2 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PPMAS(NP)=AMN2 
      PLDER(NP)=1. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE FOROM(IK01,P01,AM01,IK02,P02,AM02,SIGEL, 
     *IKD,PXD,PYD,PZD,DMAS,ISOB) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 P01,AM01,P02,AM02,SIGEL,PXD,PYD,PZD,DMAS 
C  FORMATION OF  RHO,OMEGA,PHI AND K* MESONS 
      DIMENSION P01(3),P02(3),P1(3),P2(3) 
      ISOB=0 
      E1=DSQRT( SP(P01,P01)+AM01**2) 
      E2=DSQRT( SP(P02,P02)+AM02**2) 
      S=AM01**2+AM02**2+2.*E1*E2-2.* SP(P01,P02) 
      PXC=DSQRT(ALAMB(S,AM01**2,AM02**2))/(2.*DSQRT(S)) 
      PT=5.067*PXC 
      DM=DSQRT(S) 
      IK1=IK01 
      AM1=AM01 
      IK2=IK02 
      AM2=AM02 
      DO 1 J=1,3 
      P1(J)=P01(J) 
      P2(J)=P02(J) 
 1    CONTINUE 
      Q1=CHARGE(IK1) 
      Q2=CHARGE(IK2) 
      IS1=IS(IK1) 
      IS2=IS(IK2) 
      QS=Q1+Q2 
      IF(IS1.NE.0.OR.IS2.NE.0) GO TO 10 
      IF(Q1.EQ.0..AND.Q2.EQ.0.) RETURN 
C  RHO OR OMEGA MESONS FROM PIONS 
      IF(QS) 3,4,5 
 3    IKD=-121 
      GO TO 7 
 4    IKRHO=111 
      SIGRHO=SGRO(IKRHO,SIGEL,DM,PT) 
      IKOME=221 
      SIGOME=SGRO(IKOME,SIGEL,DM,PT) 
      IKD=IKRHO 
      IF(SIGRHO.LT.SIGOME) IKD=IKOME 
      GO TO 7 
 5    IKD=121 
      GO TO 7 
10    IF(IS1.NE.0.AND.IS2.NE.0) GO TO 20 
C   K* MESONS FROM PI AND K 
C PI0 
      IF(IS1.EQ.0.AND.Q1.EQ.0.) GO TO 21 
      IF(IS2.EQ.0.AND.Q2.EQ.0.) GO TO 22 
C PI+ 
      IF(IS1.EQ.0.AND.Q1.EQ.1.) GO TO 23 
      IF(IS2.EQ.0.AND.Q2.EQ.1.) GO TO 24 
C PI- 
      IF(IS1.EQ.0.AND.Q1.EQ.-1.) GO TO 25 
      IF(IS2.EQ.0.AND.Q2.EQ.-1.) GO TO 26 
      RETURN 
21    IKD=IABS(IK2)+1 
      IKD=ISIGN(IKD,IK2) 
      GO TO 7 
22    IKD=IABS(IK1)+1 
      IKD=ISIGN(IKD,IK1) 
      GO TO 7 
23    IF(IK2.EQ.-230) RETURN 
      IKD=131 
      IF(IK2.EQ.230) GO TO 7 
      IKD=-231 
      GO TO 7 
24    IF(IK1.EQ.-230) RETURN 
      IKD=131 
      IF(IK1.EQ.230) GO TO 7 
      IKD=-231 
      GO TO 7 
25    IF(IK2.EQ.230) RETURN 
      IKD=231 
      IF(IK2.EQ.130) GO TO 7 
      IKD=-131 
      GO TO 7 
26    IF(IK1.EQ.230) RETURN 
      IKD=231 
      IF(IK1.EQ.130) GO TO 7 
      IKD=-131 
      GO TO 7 
C  ******* SIVOKL'S CHANGES ****************************** 
20    IF(IK1+IK2.EQ.0) GO TO 27 
C  ******************************************************* 
C20    IF(IABS(IK1).EQ.130.AND.IABS(IK2).NE.130) GO TO 27 
C      IF(IABS(IK1).EQ.230.AND.IABS(IK2).NE.230) GO TO 27 
      RETURN 
C PHI FROM K+ AND K- OR K0 AND ANTK0 
27    IKD=331 
C  COMPUTE RESONANCE CROSS SECTION 
 7    SIGR=SGRO(IKD,SIGEL,DM,PT) 
      PR=SIGR/SIGEL 
      IF(RNDMD(-1).GE.PR) RETURN 
C  RESONANCE-MESON PARAMETERS 
      PXD=P1(1)+P2(1) 
      PYD=P1(2)+P2(2) 
      PZD=P1(3)+P2(3) 
      DMAS=DM 
      ISOB=1 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION SGRO(IKR,SIGEL,DM,PT) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 SIGEL,DM,PT 
C  CALCULATION OF RESONANCE CROSS SECTION 
      PT2=PT**2 
      DM0=AMASS(IKR) 
      GM=GAMHE(IKR) 
      DMM0=(DM**2-DM0**2)**2 
      DMG=(DM0*GM)**2 
      ANORM=SIGEL*PT2 
      SGRO=ANORM*DMG/(PT2*(DMG+DMM0)) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION WIDTLE(GAM) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 WIDTLE,GAM 
C 
C   COMPUTE WIDTH OF PARTICLE 
C 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      SIGMA=GAM 
100   DRND=RNDMD(-1) 
      IF(DRND.LT.1.0D-10)      GO TO 100 
      GT=SIGMA*DSQRT(-DLOG(DRND)) 
      PHI=2.*PI*RNDMD(-1) 
      WIDTLE=GT*DCOS(PHI) 
      IF(DABS(WIDTLE).GT.GAM) GO TO 100 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE SLOPEB(IB1,IB2,PL,B) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PL,B 
C 
C  COMPUTE SLOPE IN TWO-BODY REACTION 
C 
      COMMON /CALC/HA,HB,HA2,HB2 
      DATA BM/ 3.0/,BB/ 3.0/ 
      IF(IB1.EQ.0.OR.IB2.EQ.0) GO TO 100 
      B0=BB 
      GO TO 200 
100   B0=BM 
200   B=B0+0.7*DLOG(PL) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE XDIST2(X1,X2) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 X1,X2 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
C         U(X)=1./DSQRT(X1*X2)*DELTA(1.-X1-X2) 
        X1=0.5+0.5*DSIN(PI*(RNDMD(-1)-0.5)) 
        X2=1.-X1 
        RETURN 
         END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
       SUBROUTINE XCORLE(IFL1,IFL2,KS1,PX1,PY1,PX2,PY2,X1,X2, 
     *PSIGN,NPRODS,RETU) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PX1,PY1,PX2,PY2,X1,X2,PSIGN 
C 
C   CORRECT X-FRACTION AND DECAY STRING OR CLUSTER 
C 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /COMLD/ PLDER(50) 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
       DIMENSION V(3) 
       DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON/KAPPA/ XAP 
      COMMON/PRIMP0/ P0 
      LOGICAL RETU 
      COMMON/COLRET/LRET 
      COMMON /PRODMA/ PPMAS(50) 
      LOGICAL LRET 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL  QSEE,QVSEE 
      LRET = .FALSE. 
C     INITIALIZE 
      NPRODS=0 
      NRET=0 
      AMQ21=0. 
      AMQ22=0. 
      NFIX=NP 
      RETU=.FALSE. 
      PTX=PX1+PX2 
      PTY=PY1+PY2 
      PT12=PX1**2+PY1**2 
      PT22=PX2**2+PY2**2 
      P1=X1*P0 
      P2=X2*P0*PSIGN 
      E12=P1**2+PT12+AMQ21 
      IF(E12.GE.0.) GO TO 200 
      RETU=.TRUE. 
      RETURN 
200   E22=P2**2+PT22+AMQ22 
      IF(E22.GE.0.) GO TO 210 
      RETU=.TRUE. 
      RETURN 
210   E1=DSQRT(E12) 
      E2=DSQRT(E22) 
      AMSS12=(E1+E2)**2-(P1+P2)**2-PTX**2-PTY**2 
       IKHR1=KI2(IFL1,IFL2,KS1,2) 
      PARBE=0.2 
      IF(IABS(IFL1).EQ.3.OR.IABS(IFL2).EQ.3) PARBE=0.3 
       AMHR =AMAS(IKHR1) 
       AMHRB=AMHR+PARBE 
      IKHR=KI2(IFL1,IFL2,KS1,1) 
      AMHR1=AMAS(IKHR) 
       IF(AMSS12.GE.AMHRB**2) GO TO 400 
      IF(NRET.EQ.1) GO TO 420 
      NP=NP+1 
      NPRODS=1 
      PR(1,NP)=PTX 
      PR(2,NP)=PTY 
      PR(3,NP)=P1+P2 
      PR(4,NP)=E1+E2 
      PPMAS(NP)=AMHR 
      IPR(NP)=IKHR1 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=PR(4,NP)/XAP 
      AMT=DSQRT(PTX**2+PTY**2+AMHR**2) 
      PR(8,NP)=DSQRT(2.D0)*AMT/XAP*PR(4,NP)/AMHR 
      PLDER(NP)=1. 
      IF(QVSEE) PLDER(NP)=0. 
      IF(AMSS12.GE.AMHR**2)  GO  TO  419 
      PR(4,NP)=DSQRT(AMHR**2+PR(1,NP)**2+PR(2,NP)**2+PR(3,NP)**2) 
419   RETURN 
420    RETU=.TRUE. 
       RETURN 
400   AMSS1=DSQRT(AMSS12) 
      PZ1=P1+P2 
      ESS1=E1+E2 
      V(1)=PTX/ESS1 
      V(2)=PTY/ESS1 
      V(3)=PZ1/ESS1 
      NIN1=NP+1 
      IF(AMSS1.GE.AMHR1+SWMAX) GO TO 600 
      CALL CLUSLE(IFL1,IFL2,KS1,AMSS1) 
      IF(LRET) GO TO 800 
      NFIN1=NP 
      CALL TIFILE(NIN1,NFIN1,AMSS1) 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=P1 
      CALL LORLLE(V,PPX1,E1,1) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 710 J=NIN1,NFIN1 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,1) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
710   CONTINUE 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
      NPRODS=NP-NFIX 
      RETURN 
600    CALL STRILE(IFL1,IFL2,KS1,AMSS1) 
      IF(LRET) GO TO 800 
       NFIN1=NP 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=P1 
      CALL LORLLE(V,PPX1,E1,1) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 700 J=NIN1,NFIN1 
      PPX1(1)=PR(1,J) 
      PPX1(2)=PR(2,J) 
      PPX1(3)=PR(3,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PPX1,PPX2,1) 
      PR(1,J)=PPX2(1) 
      PR(2,J)=PPX2(2) 
      PR(3,J)=PPX2(3) 
      PRX1(1)=PR(5,J) 
      PRX1(2)=PR(6,J) 
      PRX1(3)=PR(7,J) 
      CALL ROTAM(CT,ST,CFI,SFI,PRX1,PRX2,1) 
      PR(5,J)=PRX2(1) 
      PR(6,J)=PRX2(2) 
      PR(7,J)=PRX2(3) 
700   CONTINUE 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
      NPRODS=NP-NFIX 
       RETURN 
800   CONTINUE 
      RETU = .TRUE. 
      RETURN 
       END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      FUNCTION XSEE(XMIN) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8  XSEE,XMIN 
C 
C   SIMULATE U(X)=1/X 
C 
      XSEE=XMIN**RNDMD(-1) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DIFTLE(IFL01,IFL02,KS01,IK1,AM1, 
     *                  IFL03,IFL04,KS02,IK2,AM2,P1,IBINA) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM1,AM2,P1 
C 
C     COMPUTE TRIPLE POMERON VERTEX DIFFRACTION 
C 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      LOGICAL RETU 
      COMMON /ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON /DATA2/PUD,PS1,SIGMA,CX2 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /PRODT/ IORD(50) 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON /PRODMA/ PPMAS(50) 
      COMMON /COMCUT/ PARM,PARB,SWMAX 
      COMMON /COLRET/ LRET 
      COMMON /COMLD/PLDER(50) 
      COMMON/PRIMP0/ P0 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/NPTCLZ/ NPTCLZ 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL  QSEE,QVSEE 
      LOGICAL LRET 
      DIMENSION V(3),P1(3),PSUM(5) 
*      DATA SIGMAD/0.45/   ! IT IS NOT USED ?? 11.16.94  V.T. 
      ZER=0.0 
      LRET = .FALSE. 
      QVSEE = .TRUE. 
      NREP=0 
C     INITIALIZE 
C----- DON'T CHANGE ! (?) 
      PARBE=0.15 
C     NPI=NP 
      NPI=0 
      P0=DSQRT(SP(P1,P1)) 
      E1=DSQRT(P0**2+AM1**2) 
      E2=DSQRT(P0**2+AM2**2) 
      ECM=E1+E2 
      SCM=ECM**2 
      IF(ECM-AM1-AM2.GT.0.3) GO TO 856 
      LRET = .TRUE. 
      IBINA=1 
      RETURN 
856   CONTINUE 
      DO  96 I=1,3 
   96 PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      XMIN=0. 
      P0OLD=P0 
100   CONTINUE 
C      NP=NPI 
      PSIGN=-1. 
      PSOR=-1. 
      IKA=IK1 
      IKB=IK2 
      IRDH=IRD2 
      AMH=AM2 
      AMB=AM1 
      IFL1=IFL01 
      IFL2=IFL02 
      KS1=KS01 
      EP=E1 
      IF(RNDMD(-1).GT.0.5) GO TO 150 
      IKA=IK2 
      IKB=IK1 
      IRDH=IRD1 
      AMH=AM1 
      AMB=AM2 
      IFL1=IFL03 
      IFL2=IFL04 
      KS1=KS02 
      EP=E2 
      PSIGN=1. 
      PSOR=1. 
150   XMINS=(PARBE+AMB)**2/SCM 
      P0=P0OLD 
      NREP = NREP + 1 
      IF(NREP.LT.NTRIES) GO TO 102 
C     WRITE(ITLIS,101)IK1,IK2,AM1,AM2,P0 
101   FORMAT(1X,'DIFTLE:NREP > NTRIES,IK1,IK2,AM1,AM2,P0=', 
     *2I4,3(1X,F7.3)) 
      IBINA=1 
      LRET = .TRUE. 
      RETURN 
102   CONTINUE 
C   COMPUTE X VALUE FOR SEE QUARKS 
      XS=XSEE(XMINS) 
C    COMPUTE PT VALUE FOR HADRON 
      CALL GETPT(PTH,SIGMA) 
      PHI=2.*PI*RNDMD(-1) 
      PTHX=PTH*DCOS(PHI) 
      PTHY=PTH*DSIN(PHI) 
      PS=XS*P0 
      ES=PS 
      AMD2=(EP+ES)**2-(P0-PS)**2 
      AMD=DSQRT(AMD2) 
      IF(ECM.LE.AMD+AMH)         GO TO 150 
      ALA=ALAMB(SCM,AMD2,AMH**2) 
      P0H=DSQRT(ALA)/(2.0*ECM) 
      DTRM=P0H**2-PTH**2 
      IF(DTRM.LT.0.)             GO TO 150 
      PZH=DSQRT(DTRM)*PSIGN 
      EH=DSQRT(AMH**2+P0H**2) 
      ED=DSQRT(AMD2+P0H**2) 
      V(1)=-PTHX/ED 
      V(2)=-PTHY/ED 
      V(3)=-PZH/ED 
C    COMPUTE X VALUES FOR PARTONS 
170   IFLS1=1+IDINT(RNDMD(-1)/PUD) 
      IFLS2=IFLS1 
      IBA=IBLE(IKA) 
      ISA=ISLE(IKA) 
      IFL1S=IFL1 
      IF(ISA.NE.0.AND.IBA.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      XQVAL=XDIST(XMIN,IBA,ISA,IFL1S) 
      XQQVA=1.-XQVAL 
C   COMPUTE X VALUE FOR PION 
      CALL XDIST2(XPI,X2PI) 
C     NIN1=NP+1 
      NIN1=1 
      IF(IFL2.GT.0) GO TO 160 
      IFL1T=IFL1 
      IFLS1T=-IFLS1 
      XQVALT=XQVAL 
      XPIT=XPI 
      IFL2T=IFL2 
      IFLS2T=IFLS2 
      XQQVAT=XQQVA 
      XPIT1=1.-XPI 
      PSI=1. 
      IF(PSIGN.LT.0.) GO TO 400 
      IFL1T=-IFLS1 
      IFLS1T=IFL1 
      XQVALT=XPI 
      XPIT=XQVAL 
      IFL2T=IFLS2 
      IFLS2T=IFL2 
      XQQVAT=1.-XPI 
      XPIT1=XQQVA 
      PSI=-1. 
400   PSIGN=PSIGN*PSI 
      P0=AMD/2.0 
      KS1T=0 
      IF(IABS(IFL1T).GT.3.OR.IABS(IFLS1T).GT.3) KS1T=KS1 
      CALL XCORLE(IFL1T,IFLS1T,KS1T,ZER,ZER,ZER,ZER,XQVALT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      KS2T=0 
      IF(IABS(IFL2T).GT.3.OR.IABS(IFLS2T).GT.3) KS2T=0 
      CALL XCORLE(IFL2T,IFLS2T,KS2T,ZER,ZER,ZER,ZER,XQQVAT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NP=NP-NPRD 
      GO TO 170 
130   NFIN1=NP 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
      GO TO 300 
160   IFL1T=IFL1 
      IFLS2T=ISIGN(IFLS2,-IFL1) 
      XQVALT=XQVAL 
      XPIT1=1.-XPI 
      IFL2T=IFL2 
      IFLS1T=IFLS1 
      IF(IFL2.LE.3)  IFLS1T=ISIGN(IFLS1,-IFL2) 
      XQQVAT=XQQVA 
      XPIT=XPI 
      PSI=1. 
      IF(PSIGN.LT.0.) GO TO 450 
      IFL1T =ISIGN(IFLS2,-IFL1) 
      IFLS2T=IFL1 
      XQVALT=1.-XPI 
      XPIT1=XQVAL 
      IFLS1T=IFL2 
      IFL2T=IFLS2 
      IF(IFL2.LE.3)  IFL2T =ISIGN(IFLS2,-IFL2) 
      XQQVAT=XPI 
      XPIT=XQQVA 
      PSI=-1. 
450   PSIGN=PSIGN*PSI 
      P0=AMD/2.0 
      KS1T=0 
      IF(IABS(IFL1T).GT.3.OR.IABS(IFLS2T).GT.3) KS1T=KS1 
      CALL XCORLE(IFL1T,IFLS2T,KS1T,ZER,ZER,ZER,ZER,XQVALT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      KS2T=0 
      IF(IABS(IFL2T).GT.3.OR.IABS(IFLS1T).GT.3) KS2T=KS1 
      CALL XCORLE(IFL2T,IFLS1T,KS2T,ZER,ZER,ZER,ZER,XQQVAT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 140 
      NP=NP-NPRD 
      GO TO 170 
140   NFIN1=NP 
      CALL LORPLE(V,NIN1,NFIN1,-1) 
      CALL LORCLE(V,NIN1,NFIN1,-1) 
300   P0=P0OLD 
      DO 500 I=NIN1,NFIN1 
      IORD(I)=0 
C     PPMAS(I)=AMAS(IPR(I)) 
500   CONTINUE 
      NP=NP+1 
      NFIN1=NP 
      NPRD=NP-NPI 
      PR(1,NP)=PTHX 
      PR(2,NP)=PTHY 
      PR(3,NP)=PZH 
      PR(4,NP)=EH 
      IPR(NP)=IKB 
      IORD(NP)=IRDH 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      PPMAS(NP)=AMH 
      NPTCL=0 
      DO  502  J=NIN1,NFIN1 
      NPTCL=NPTCL+1 
      PPTCL(1,J)=PR(1,J) 
      PPTCL(2,J)=PR(2,J) 
      PPTCL(3,J)=PR(3,J) 
      PPTCL(4,J)=PR(4,J) 
      PPTCL(5,J)=PPMAS(J) 
  502 CONTINUE 
      CALL  RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0)   GO  TO  501 
      NP=NP-NPRD 
      GO  TO  100 
  501 CONTINUE 
      DO  503  J=NIN1,NFIN1 
      PR(1,J)=PPTCL(1,J) 
      PR(2,J)=PPTCL(2,J) 
      PR(3,J)=PPTCL(3,J) 
      PR(4,J)=PPTCL(4,J) 
      PPMAS(J)=PPTCL(5,J) 
  503 CONTINUE 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE BINALE(P,AMA,AMB,IK1,IK2,IEL) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 P,AMA,AMB 
C 
C  SIMULATION TWO PARTICLE REACTION 
C 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /COMKI1/ HLA2,HLB2,W,INUMA 
      COMMON /COMKI2/ELA,ELB,PLALB 
      COMMON /CALC/HA,HB,HA2,HB2 
      COMMON /BEES/B,BFOR 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON /PRODT/ IORD(50) 
      COMMON /PRODMA/PPMAS(50) 
      COMMON /COMLD/PLDER(50) 
      COMMON /COLRET/ LRET 
      COMMON /ISOB3/ISOB3 
      DIMENSION P(3),PA(3) 
      LOGICAL LRET 
      LRET = .FALSE. 
C===== IF DL- + DL- , DL++ + DL++OR FI0 + OM- =====C 
      IF((IK1.EQ.47.AND.IK2.EQ.47).OR. 
     *   (IK1.EQ.18.AND.IK2.EQ.18).OR. 
     *   (IK1.EQ.54.AND.IK2.EQ.54).OR. 
     *   (IK1.EQ.45.AND.IK2.EQ.45).OR. 
     *   (IK1.EQ.18.AND.IK2.EQ.54)) IEL=1 
      IF(IEL.EQ.1) RETURN 
C  INITIALIZE 
      INUMA=0 
      IREP2 =0 
      E1=DSQRT(AMA**2+SP(P,P)) 
      E2=DSQRT(AMB**2+SP(P,P)) 
      S=(E1+E2)**2 
      W=DSQRT(S) 
      IB1=IBLE(IK1) 
      IB2=IBLE(IK2) 
      HLA=AMA 
      HLB=AMB 
      HLA2=HLA*HLA 
      HLB2=HLB*HLB 
      PLALB=DSQRT(ALAMB(S,HLA2,HLB2))/(2.0*W) 
      ELA=(S+HLA2-HLB2)/(2.0*W) 
      ELB=(S+HLB2-HLA2)/(2.0*W) 
C 
c !!!      20.10.92T     DL+N->N+N' 
      IF(W.GT.3.00.OR.(IB1+IB2).NE.2)     GO TO 99 
      IF(AMA.GT.AMB)  THEN 
      IF(.NOT.(IK2.EQ.37.OR.IK2.EQ.38))   GO TO 99 
      IF(.NOT.(IK1.EQ.46.OR.IK1.EQ.45.OR.IK1.EQ.47.OR. 
     *  IK1.EQ.48))                         GO TO 99 
      ELSE 
      IF(.NOT.(IK1.EQ.37.OR.IK1.EQ.38))   GO TO 99 
      IF(.NOT.(IK2.EQ.46.OR.IK2.EQ.45.OR.IK2.EQ.47.OR. 
     * IK2.EQ.48))                         GO TO 99 
      END IF 
      ICHA1=IQLE(IK1)+IQLE(IK2)+1 
      IF(ICHA1.EQ.4.OR.ICHA1.EQ.0)        GO TO 99 
      GOTO (95,96,97), ICHA1 
  95  IKH1=38 
      IKH2=38 
      GO  TO  98 
  96  IKH1=38 
      IKH2=37 
      GO  TO  98 
  97  IKH1=37 
      IKH2=37 
  98  AMP1=AMASF(IKH1) 
      AMP2=AMASF(IKH2) 
      GO  TO  109 
  99  CONTINUE 
c !!! 
C   CHOOSE INTERACTIVE QUARKS 
105   CALL FLAVO(IB1,IK1,IB2,IK2,IFL1,IFL2,IFL3,IFL4) 
      IREP2 = IREP2 + 1 
      IF(IREP2.LE.NTRIES)   GOTO 305 
C     WRITE(ITLIS,1200)IK1,IK2,PLALB 
1200  FORMAT(1X,'BINALE:NREP > NTRIES,IK1,IK2,PLALB=', 
     *2I4,1X,F7.3) 
      IEL=1 
C     LRET=.TRUE. 
      RETURN 
305   CONTINUE 
C   CHOOSE DIQUARK SPIN 
      CALL KSPIN(IFL3,KS2,IK2,IB2) 
      CALL KSPIN(IFL1,KS1,IK1,IB1) 
      IREP1=0 
C  HADRONS GENERATE BY MEANS QUARKS EXCHANGE 
      IF(IFL1)1,1,2 
1     IF11=IFL2 
      IF22=IFL1 
      GO TO 3 
2     IF11=IFL1 
      IF22=IFL2 
3     CONTINUE 
      IF(IB2.EQ.1) GO TO 102 
      IF(IFL3) 101,101,102 
101   IF44=IFL3 
      IF33=IFL4 
      GO TO 103 
102   IF33=IFL3 
      IF44=IFL4 
103   CONTINUE 
104   IKH2=KI2(IF44,IF11,KS2,0) 
      IKH1=KI2(IF22,IF33,KS1,0) 
      IREP1=IREP1+1 
      IF(IREP1.GT.NTRIES) GO TO 105 
C  SELECT ELASTIC COLLISION 
      IF(IKH1.EQ.IK1.AND.IKH2.EQ.IK2.AND.IREP1.LE.NTRIES) 
     *GO  TO  104 
C  CHOOSE TABLE MASSES AND TABLE WIDTH OF HADRONS 
      AMH1=AMASF(IKH1) 
      AMH2=AMASF(IKH2) 
      GAMH1=GAM(IKH1) 
      GAMH2=GAM(IKH2) 
C  COMPUTE MASSES OF PARTICLES 
      IREP3=0 
205   CONTINUE 
      IREP3=IREP3+1 
      IF(IREP3.LE.NTRIES) GO TO 108 
C     WRITE(ITLIS,1200)IK1,IK2,PLALB 
      IEL=1 
      RETURN 
108   GAM1=WIDTLE(GAMH1) 
      GAM2=WIDTLE(GAMH2) 
      AMP1=AMH1+GAM1 
      AMP2=AMH2+GAM2 
      IF(ISOB3.NE.1) GO TO 107 
      IF(IKH1.GE.45.AND.IKH1.LE.48)               AMP1=AMAS(IKH1) 
      IF(IKH2.GE.45.AND.IKH2.LE.48)               AMP2=AMAS(IKH2) 
      IF(IKH1.EQ.10.OR.IKH1.EQ.11.OR.IKH1.EQ.16)  AMP1=AMAS(IKH1) 
      IF(IKH2.EQ.10.OR.IKH2.EQ.11.OR.IKH2.EQ.16)  AMP2=AMAS(IKH2) 
C  CHECK ENERGY THRESHOLD 
107   IF(W.LT.(AMP1+AMP2)) GO TO 205 
109   HA=AMP1 
      HA2=AMP1**2 
      HB=AMP2 
      HB2=AMP2**2 
C  COMPUTE SCATTERING ANGLE 
      CALL SLOPEB(IB1,IB2,PLALB,B) 
      CALL ANG(TFOR,TBACK,T,Z,PHI) 
      PAMOD=DSQRT(ALAMB(S,HA2,HB2))/(2.0*W) 
      PAN=PAMOD*DSQRT(1.-Z**2) 
      PA(1)=PAN*DCOS(PHI) 
      PA(2)=PAN*DSIN(PHI) 
      PA(3)=PAMOD*Z 
      NP=NP+1 
      IPR(NP)=IKH1 
      PR(1,NP)=PA(1) 
      PR(2,NP)=PA(2) 
      PR(3,NP)=PA(3) 
      PR(4,NP)=DSQRT(PAMOD**2+HA2) 
      IORD(NP)=0 
      PPMAS(NP)=AMP1 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      NP=NP+1 
      IPR(NP)=IKH2 
      PR(1,NP)=-PA(1) 
      PR(2,NP)=-PA(2) 
      PR(3,NP)=-PA(3) 
      PR(4,NP)=DSQRT(PAMOD**2+HB2) 
      IORD(NP)=0 
      PPMAS(NP)=AMP2 
      PR(5,NP)=0. 
      PR(6,NP)=0. 
      PR(7,NP)=0. 
      PR(8,NP)=0. 
      PLDER(NP)=1. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE RESCAL(N1,N2,PSUM,IFAIL) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 PSUM 
C          RESCALE MOMENTA OF PARTICLES N1...N2 TO GIVE TOTAL 
C          FOUR-MOMENTUM PSUM. 
C          RETURN IFAIL=0 IF OK, IFAIL=1 IF NO GOOD. 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      DIMENSION PSUM(5),PADD(5),BETA(3) 
      DATA ERRLIM/.00001/ 
C          ORIGIONAL MOMENTUM IS PADD. 
      IFAIL=1 
      IF(N1.GE.N2) RETURN 
      DO 100 K=1,5 
100   PADD(K)=0. 
      DO 110 IP=N1,N2 
      DO 110 K=1,5 
      PADD(K)=PADD(K)+PPTCL(K,IP) 
110   CONTINUE 
      IF(PADD(5).GE.PSUM(5)) RETURN 
      PADD(5)=PADD(4)**2-PADD(1)**2-PADD(2)**2-PADD(3)**2 
      IF(PADD(5).LE.0) RETURN 
      PADD(5)=DSQRT(PADD(5)) 
      DO 120 K=1,3 
120   BETA(K)=-PADD(K)/PADD(5) 
      GAMMA=PADD(4)/PADD(5) 
C          BOOST PARTICLES TO REST. 
200   CONTINUE 
      DO 210 IP=N1,N2 
      BP=0. 
      DO 220 K=1,3 
220   BP=BP+PPTCL(K,IP)*BETA(K) 
      DO 230 K=1,3 
230   PPTCL(K,IP)=PPTCL(K,IP)+BETA(K)*PPTCL(4,IP) 
     $+BETA(K)*BP/(GAMMA+1.) 
      PPTCL(4,IP)=GAMMA*PPTCL(4,IP)+BP 
210   CONTINUE 
      IF(IFAIL.EQ.0) RETURN 
C          RESCALE MOMENTA IN REST FRAME. 
      SCAL=1. 
      DO 301 IPASS=1,500 
      SUM=0. 
      DO 310 IP=N1,N2 
      DO 320 K=1,3 
320   PPTCL(K,IP)=SCAL*PPTCL(K,IP) 
      PPTCL(4,IP)=DSQRT(PPTCL(1,IP)**2+PPTCL(2,IP)**2+PPTCL(3,IP)**2 
     $+PPTCL(5,IP)**2) 
      SUM=SUM+PPTCL(4,IP) 
310   CONTINUE 
      SCAL=PSUM(5)/SUM 
      IF(DABS(SCAL-1.).LE.ERRLIM) GO TO 300 
301   CONTINUE 
300   CONTINUE 
C          BOOST BACK WITH PSUM. 
      BMAG=0. 
      DO 400 K=1,3 
      BETA(K)=PSUM(K)/PSUM(5) 
      BMAG=BMAG+DABS(BETA(K)) 
400   CONTINUE 
      GAMMA=PSUM(4)/PSUM(5) 
      IFAIL=0 
      IF(BMAG.EQ.0.) RETURN 
      GO TO 200 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE COLLHH(ID01,AM01,PX01,PY01,PZ01,ID02,AM02, 
     *PX02,PY02,PZ02,SIGTO0,SIGAN0,SIGEL0) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AM01,PX01,PY01,PZ01, 
     *       AM02,PX02,PY02,PZ02,SIGTO0,SIGAN0,SIGEL0 
C 
C          MAIN SUBROUTINE FOR HHQGS, A MONTE CARLO EVENT GENERATOR 
C          FOR  H+H COLLISION AT LOW AND HIGH ENERGY 
C          JTDKY = +/- UNIT NUMBER FOR DECAY TABLE FILE. 
C                      IF IT IS NEGATIVE, DECAY TABLE IS NOT PRINTED. 
C          JTEVT =     UNIT NUMBER FOR OUTPUT EVENT FILE. 
C          JTCOM =     UNIT NUMBER FOR COMMAND FILE. 
C          JTLIS =     UNIT NUMBER FOR LISTING. 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMELX/ SIGEL 
      COMMON/COMCRO/ SIGTOT 
      COMMON/CSIGA/ SIGAN 
      COMMON/ORDER/ IRD1,IRD2 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL  QSEE,QVSEE 
      COMMON/PROD/PR(8,50),IPR(50),NP 
      COMMON/PRIMP0/ P0 
      COMMON/PRIMPL/ PL 
      COMMON/COMFR/ ICMS 
      COMMON/PRODT/ IORD(50) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/PRODMA/ PPMAS(50) 
      COMMON/COMLID/ PLIDER(499) 
      COMMON/COMLD/ PLDER(50) 
      COMMON/COMASS/ AM1N,AM2N 
      LOGICAL GH1H2 
      COMMON/H1H2/ GH1H2(11) 
      COMMON/COMMUL/ MULTP 
      LOGICAL MULTP 
      DIMENSION P1(3),P2(3),V(3),P1R(3),P2R(3) 
      COMMON/COMENB/ ENBOU 
      COMMON/COLRET/ LRET 
      COMMON /SIGDIA/ CROSD(5),DST 
      COMMON/CPRSIG/ ISGCOL 
      COMMON/PRINTS/IPRINT 
      COMMON/P0LAB1/ P00,DSM,TKIN 
      COMMON/KEYEL/IEL 
      LOGICAL IPRINT 
      COMMON/KEYHH/KEYHH 
      LOGICAL KEYHH 
      COMMON/KEYPLA/KEYPLA 
      LOGICAL KEYPLA 
      COMMON/COMCOR/ PSUM(5) 
      COMMON/VALON/ VALON 
      COMMON/HELE/ IHELE 
      COMMON/NCASCA/ NCAS, NCPRI                 !T. 08.08.95 
      COMMON /ISLERR/ ISLERR   ! HADES1 HADES2
      LOGICAL VALON 
      DIMENSION IK(5),PO(3),IRL(250),ILL(250) 
C      REAL*8 LAB1,LAB2 
      CHARACTER*8 LAB1,LAB2 
      LOGICAL BACK 
      LOGICAL LRET 
      LRET=.FALSE. 
      NREP=0 
C          ENTRY. 
C       PRINT *, ' in COLLHH' 
      DO  110 I=1,11 
  110 GH1H2(I)=.FALSE. 
      IB1=IB(ID01) 
      IB2=IB(ID02) 
      IF(IB1.EQ.0.AND.IB2.EQ.0) GO TO 12 
      IF((ID01.EQ.1120.OR.ID01.EQ.1220) .AND. 
     *    ID02.NE.1120.AND.ID02.NE.1220) GO TO 13 
      IF(IB1.GT.0.AND.IB2.LE.0) GO TO 13 
      IF(IB1.LT.0.AND.IB2.EQ.0) GO TO 13 
C     IF INCIDENT PARTICLE IS MESON OR 
C     IF TARGET PARTICLE IS NUCLEON OR 
C     IF INCIDENT AND TARGET PARTICLES ARE NOT NUCLEONS 
C 
12    ID1=ID01 
      PX1=PX01 
      PY1=PY01 
      PZ1=PZ01 
      AM1=AM01 
      IRD1=1 
      ID2=ID02 
      PX2=PX02 
      PY2=PY02 
      PZ2=PZ02 
      AM2=AM02 
      IRD2=2 
      GO TO 14 
C       ELSE DO EXCHANGE: 
13    CONTINUE 
      ID1=ID02 
      PX1=PX02 
      PY1=PY02 
      PZ1=PZ02 
      AM1=AM02 
      IRD1=2 
      ID2=ID01 
      PX2=PX01 
      PY2=PY01 
      PZ2=PZ01 
      AM2=AM01 
      IRD2=1 
C     DETERMINE THE COMMON/COMELX/ AND /CSIGA/ ELEMENTS 
14    SIGTOT=SIGTO0 
      SIGAN=SIGAN0 
      SIGEL=SIGEL0 
C 
      BACK=.TRUE. 
1912  NP=0 
      IEL=0 
      NREP = NREP + 1 
      IF(NREP.LE.3*NTRIES) GO TO 1913 
      LRET=.TRUE. 
      WRITE(ITLIS,1917)ID01,ID02,PX01,PY01,PZ01,PX02,PY02,PZ02 
     *,S,P00,SIGTOT,SIGEL,SIGAN,CROSD 
1917  FORMAT(5X,' STOP IN COLLHH :ID01,ID02,PX,Y,Z,1-2=', 
     *2I6,6F8.3/,' S=',E10.4,' P0=',E10.4,' SIGTOT=',E10.4, 
     *' SIGEL',E10.4,' SIGAN=',E10.4,/,' CROSD(5)=',5E10.4) 
      RETURN 
C   COMPUTE OF CM MOMENTUM COMPONENTS 
 1913 CALL KINEM(PX1,PY1,PZ1,AM1,PX2,PY2,PZ2, 
     *AM2,V,S,P1) 
C     IN CM SYSTEM: 
      DO  9 I=1,3 
  9      PO(I)=P1(I) 
C     IN LAB SYSTEM: 
      PL=DSQRT(ALAMB(S,AM1**2,AM2**2))/(2.0*AM2) 
C     ROTATE CM SYSTEM 
      CALL ANGLE(P1,CT,ST,CFI,SFI) 
      CALL ROTR(CT,ST,CFI,SFI,P1,P2,BACK) 
      IB1=IB(ID1) 
      IB2=IB(ID2) 
      SQS=DSQRT(S) 
 120  IF(IB1.EQ.0.AND.IB2.EQ.0) GO TO 210 
      ITOT=0 
      IKS=0 
      IF(SQS.GT.ENBOU) GO TO 210 
      CALL PARCRO(ITOT,IK,IKS,ID1,ID2,PX1,PY1, 
     *PZ1,AM1,PX2,PY2,PZ2,AM2) 
      IF(SQS.GT.ENBOU.OR.(IB1.LT.0.OR.IB2.LT.0.)) GO TO 210 
C 
C  COMPUTE LOW ENERGY HADRON-BARION COLLISION ============= 
C       (QUARK-GLUON STRING MODEL) 
C 
      IHELE=1 
      CALL BACKID(ID1,ID1N) 
      CALL BACKID(ID2,ID2N) 
      IDIN(1)=ID01 
      IDIN(2)=ID02 
220   CALL TYPRE(ID1N,AM1,ID2N,AM2, 
     *SQS,IEL,IDIF,IUNCY,IPLAN,IBINA,SIGTOT,SIGEL) 
        if(ISLERR.eq.1)return   ! HADES1
c        if(ISLERR.eq.1)then
c          write(25,*)'  TYPRE'
c          return
c        end if
      DO 10 I=1,3 
 10      P1(I)=P2(I) 
      QVSEE=.FALSE. 
C 
      IF(LRET) IEL=1 
C 
      IF(IEL.EQ.1) GO TO 133 
      IF(IBINA.EQ.1) GO TO 135 
      IF(IDIF.EQ.1) GO TO 132 
      IF(IPLAN.EQ.0) GO TO 100 
C 
C  CALCULATION OF PLANAR GRAPH ------------------------- 
C     NIN1=NP+1 
      NIN1=1 
C       PRINT *, ' TO PLANLE' 
      CALL PLANLE(ID1N,IB1,ID2N,IB2,S,IEL) 
C       PRINT *, 'from PLANLE' 
      IF(IEL.EQ.1) GO TO 133 
      IF(NP.EQ.2.AND.((IPR(1).EQ.ID1N.AND.IPR(2).EQ.ID2N) 
     *.OR.(IPR(2).EQ.ID1N.AND.IPR(1).EQ.ID2N))) GO TO 1912 
      IF(LRET) GO TO 1912 
      GH1H2(2)=.TRUE. 
      NFIN2=NP 
      GO TO 300 
100   CONTINUE 
      IF(IUNCY.EQ.0) GO TO 104 
C     NIN1=NP+1 
      NIN1=1 
C 
C   UNDEVELOPED CYLINDER DIAGRAM ------------------- 
C       PRINT *, ' TO UNCYLE' 
      CALL UNCYLE(ID1N,IB1,AM1,ID2N,IB2,AM2,P1,IBINA) 
C       PRINT *, 'from UNCYLE' 
      IF(IBINA.EQ.1) GO TO 135 
      IF(LRET) GO TO 1912 
      GH1H2(3)=.TRUE. 
      NFIN2=NP 
      GO TO 300 
C 
C   CYLINDER DIAGRAM ------------------------------- 
104   CONTINUE 
C     NIN1=NP+1 
      NIN1=1 
C       PRINT *, ' TO CYLLE' 
      CALL CYLLE(ID1N,IB1,AM1,ID2N,IB2,AM2,P1,IBINA) 
C       PRINT *, 'from CYLLE' 
      IF(IBINA.EQ.1) GO TO 135 
      IF(LRET) GO TO 1912 
      GH1H2(7)=.TRUE. 
      NFIN2=NP 
      GO TO 300 
C 
C  DIFRACTIVE SCATTERING CALCULATION ---------------- 
 132  CONTINUE 
      CALL FLAVO(IB1,ID1N,IB2,ID2N,IFL1,IFL2,IFL3,IFL4) 
      CALL KSPIN(IFL3,KS2,ID2N,IB2) 
      CALL KSPIN(IFL1,KS1,ID1N,IB1) 
C     NIN1=NP+1 
      NIN1=1 
      DRND=RNDMD(-1) 
      IF(DRND.GT.DST)  GO  TO  222 
C       PRINT *, ' TO DIFTLE' 
      CALL DIFTLE(IFL1,IFL2,KS1,ID1N,AM1,IFL3,IFL4,KS2,ID2N,AM2,P1, 
     *IBINA) 
C       PRINT *, 'from DIFTLE' 
      IF(IBINA.EQ.1) GO TO 135 
      IF(LRET) GO TO 1912 
      GH1H2(1)=.TRUE. 
      GO  TO  223 
 222  CONTINUE 
C       PRINT *, 'TO DIFSCA' 
      CALL DIFSCA(IFL1,IFL2,KS1,ID1N,AM1,IFL3,IFL4,KS2,ID2N,AM2,P1, 
     *IBINA) 
C       PRINT *, 'from DIFSCA' 
      IF(IBINA.EQ.1) GO TO 135 
      IF(LRET) GO TO 1912 
      GH1H2(6)=.TRUE. 
 223  CONTINUE 
      NFIN2=NP 
C     GO  TO  302 
 300  CONTINUE 
      DO 301 I=NIN1,NFIN2 
C     PPMAS(I)=AMAS(IPR(I)) 
C     PPMAS(I)=DSQRT(PR(4,I)**2-PR(1,I)**2-PR(2,I)**2-PR(3,I)**2) 
 301  CONTINUE 
      GO TO 302 
C 
C   TWO-PARTICLE REACTION -------------------------------- 
135   CONTINUE 
      DO 1350 I=1,3 
1350  P1(I)=P2(I) 
C     NIN1=NP+1 
      NIN1=1 
C       PRINT *, ' TO BINALE' 
      CALL BINALE(P1,AM1,AM2,ID1N,ID2N,IEL) 
C       PRINT *, 'FROM BINALE' 
      IF(LRET) GO TO 1912 
      IF(IEL.EQ.1) GO TO 133 
      GH1H2(8)=.TRUE. 
      NFIN2=NP 
      GO TO 302 
C 
C   ELASTIC SCATTERING ---------------------------------- 
133   CONTINUE 
      DO 1330 I=1,3 
1330  P1(I)=P2(I) 
C     NIN1=NP+1 
      NIN1=1 
      CALL ELASLE(P1,AM1,AM2,ID1N,ID2N) 
        if(ISLERR.eq.1)return   ! HADES2
c        if(ISLERR.eq.1)then
c          write(25,*)'  ELASLE'
c          return
c        end if
      GH1H2(4)=.TRUE. 
      NFIN2=NP 
 302  CONTINUE 
      GO TO 500 
C 
C   AT HIGH ENERGY===================================== 
C 
210   CONTINUE 
      IHELE=2 
      IRET=0 
      NREP = NREP + 1 
      IF(NREP.LE.3*NTRIES) GO TO 2913 
      LRET=.TRUE. 
      WRITE(ITLIS,1905)ID01,ID02,PX01,PY01,PZ01,PX02,PY02,PZ02 
     *,S,PL,SIGTOT,SIGEL,SIGAN 
1905  FORMAT(5X,' STOP IN COLLHH (HIGH EN.):ID01,ID02,PX,Y,Z,1-2=', 
     *2I6,6F8.3/,' S=',E10.4,' P0=',E10.4,' SIGTOT=',E10.4, 
     *' SIGEL',E10.4,' SIGAN=',E10.4) 
      RETURN 
2913  NPTCL=0 
      NIN1=NPTCL+1 
C FILL  /PRIMAR/ 
      IDIN(1)=ID1 
      IDIN(2)=ID2 
      AM1N=AM1 
      AM2N=AM2 
      SCM=S 
      ECM=SQS 
      P0=DSQRT(SP(P1,P1)) 
      HALFE=ECM/2.0 
      PSUM(1)=0. 
      PSUM(2)=0. 
      PSUM(3)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      CALL LABEL(LAB1,ID01) 
      CALL LABEL(LAB2,ID02) 
      IF(ISGCOL.EQ.0.AND.IPRINT) WRITE(ITLIS,1000) LAB1,LAB2,SCM 
1000  FORMAT(//15X,47HI SELECT THE NEXT REACTIONS WITH CROSS SECTIONS 
     *,/20X,3HFOR,1X,A8,A8,18H COLLISION AT SCM=,E10.4,7H GEV**2/) 
C 
C       HH AND AHH COLLISIONS AT HIGH ENERGY AND ANTIBARION 
C       BARION COLLISION OR MESON-MESON COLISION 
C         (QUARK-GLUON STRINGS MODEL) 
C------- 
      IF(KEYHH) GO TO 521 
      MULTP=.TRUE. 
      QSEE=.FALSE. 
C------- 
 521  CONTINUE 
      DO 399 JJ=1,11 
 399  GH1H2(JJ)=.TRUE. 
      CALL SIGIN 
      CALL REACTL 
      KEYPLA=.FALSE. 
      IF(.NOT.GH1H2(1)) GO TO 600 
c-Sob      if(NCAS.GE.NCPRI)   PRINT *, ' TO DIFTRI', Nrep,Ntries 
      CALL DIFTRI(IRET) 
c-Sob      if(NCAS.GE.NCPRI)   PRINT *, 'FROM DIFTRI', Nrep,Ntries 
      GO TO 707 
600   IF(.NOT.GH1H2(8)) GO TO 700 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO BINAR'  , Nrep,Ntries 
      CALL BINAR(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM BINAR' , Nrep,Ntries 
      GO TO 707 
700   IF(.NOT.GH1H2(10)) GO TO 701 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO REGTRI' , Nrep,Ntries 
      CALL REGTRI(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM REGTRI', Nrep,Ntries 
      GO TO 707 
701   IF(.NOT.GH1H2(2)) GO TO 702 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO PLANAR' , Nrep,Ntries 
      CALL PLANAR(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM PLANAR', Nrep,Ntries 
      GO TO 707 
702   IF(.NOT.GH1H2(3)) GO TO 703 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO UNCYLY' , Nrep,Ntries 
      CALL UNCYLI(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM UNCYLY', Nrep,Ntries 
      GO TO 707 
703   IF(.NOT.GH1H2(4)) GO TO 704 
      IEL=1 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO ELAST'  , Nrep,Ntries 
      CALL ELAST(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM ELAST' , Nrep,Ntries 
      GO TO 707 
704   IF(.NOT.GH1H2(5)) GO TO 705 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO ANNIH'  , Nrep,Ntries 
      CALL ANNIH(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM ANNIH' , Nrep,Ntries 
      GO TO 707 
705   IF(.NOT.GH1H2(6)) GO TO 706 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO DIFSMA' , Nrep,Ntries 
      CALL DIFSMA(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM DIFSMA', Nrep,Ntries 
      GO TO 707 
706   IF(.NOT.GH1H2(7)) GO TO 709 
 
      if(MULTP) then 
c-Sob        if(NCAS.GE.NCPRI) PRINT *, ' TO CHAINS', Nrep,Ntries 
      CALL CHAINS(IRET) 
c-Sob        if(NCAS.GE.NCPRI) PRINT *, 'FROM CHAINS', Nrep,Ntries 
      endif 
      if(.NOT.MULTP) then  
c-Sob        if(NCAS.GE.NCPRI) PRINT *, ' TO CYLIN', Nrep,Ntries 
      CALL CYLIN(IRET) 
c-Sob        if(NCAS.GE.NCPRI) PRINT *, 'FROM CYLIN', Nrep,Ntries 
      endif 
709   IF(.NOT.GH1H2(11)) GO TO 707 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, ' TO DOUBDI', Nrep,Ntries 
      CALL  DOUBDI(IRET) 
c-Sob      if(NCAS.GE.NCPRI)  PRINT *, 'FROM DOUBDI', Nrep,Ntries 
707   IF(IRET.EQ.1) GO TO 210 
      GO TO 520 
500   CONTINUE 
      NPTCL=0 
      DO 510 I=NIN1,NFIN2 
      NPTCL=NPTCL+1 
      CALL FORID(IPR(I),IDENT(NPTCL)) 
      PPTCL(1,NPTCL)=PR(1,I) 
      PPTCL(2,NPTCL)=PR(2,I) 
      PPTCL(3,NPTCL)=PR(3,I) 
      PPTCL(4,NPTCL)=PR(4,I) 
      PPTCL(5,NPTCL)=PPMAS(I) 
      PPTCL(6,NPTCL)=PR(5,I) 
      PPTCL(7,NPTCL)=PR(6,I) 
      PPTCL(8,NPTCL)=PR(7,I) 
      PPTCL(9,NPTCL)=PR(8,I) 
      IDCAY(NPTCL)=0 
      IORIG(NPTCL)=0 
      IORDP(NPTCL)=IORD(I) 
      PLIDER(NPTCL)=PLDER(I) 
510   CONTINUE 
C   BACKWARD ROTATE 
520   CONTINUE 
      NFIN2=NPTCL 
      IF(NFIN2.EQ.1) GO TO 99 
      NRL=0 
      NLL=0 
      DO 530 I=NIN1,NFIN2 
      DO 540 J=1,3 
      P2R(J)=PPTCL(5+J,I) 
540   P2(J)=PPTCL(J,I) 
C   BACKWARD ROTATE 
      BACK=.FALSE. 
      CALL ROTR(CT,ST,CFI,SFI,P2,P1,BACK) 
      CALL ROTR(CT,ST,CFI,SFI,P2R,P1R,BACK) 
      DO 550 J=1,3 
      PPTCL(J+5,I)=P1R(J) 
550   PPTCL(J,I)=P1(J) 
      PPTCL(4,I)=DSQRT(PPTCL(1,I)**2+PPTCL(2,I)**2+ 
     *PPTCL(3,I)**2+PPTCL(5,I)**2) 
      SCAL=PO(1)*PPTCL(1,I)+PO(2)*PPTCL(2,I)+PO(3)*PPTCL(3,I) 
      IF(VALON) GO TO 779 
      IF(SCAL.GT.0.) NRL=NRL+1 
      IF(SCAL.LE.0.) NLL=NLL+1 
      IF(SCAL.GT.0.) IRL(NRL)=I 
      IF(SCAL.LE.0.) ILL(NLL)=I 
779   IF(.NOT.(IORDP(I).EQ.0.AND.PLIDER(I).GT..3)) GO TO 530 
      IF(SCAL.GE.0.) IORDP(I)=IRD1 
      IF(SCAL.LT.0.) IORDP(I)=IRD2 
530   CONTINUE 
      IF(NRL.EQ.0.OR.NLL.EQ.0) GO TO 99 
      IF(VALON) GO TO 99 
      IF(NRL.LE.1) GO TO 1537 
      DO 537 I=1,NRL 
      IF(PLIDER(IRL(I)).LT.0.1.OR.PLIDER(IRL(I)).GT.0.9) GO TO 537 
      PMAX=PPTCL(4,IRL(I)) 
      IMAX=I 
      PLI=PLIDER(IRL(I)) 
      GO TO 1538 
537   CONTINUE 
      GO TO 1537 
1538  CONTINUE 
      DO 533 J=1,NRL 
      IF(PLIDER(IRL(J)).GT..9.OR.PLIDER(IRL(J)).LT.0.1) GO TO 533 
      PLIDER(IRL(J))=0. 
      IF(PPTCL(4,IRL(J)).LT.PMAX) GO TO 533 
      PLIDER(IRL(IMAX))=0. 
      IMAX=J 
      PMAX=PPTCL(4,IRL(J)) 
      PLIDER(IRL(J))=PLI 
533   CONTINUE 
1537  CONTINUE 
      IF(NLL.LE.1) GO TO 99 
      DO 637 I=1,NLL 
      IF(PLIDER(ILL(I)).LT.0.1.OR.PLIDER(ILL(I)).GT.0.9) GO TO 637 
      PMAX=PPTCL(4,ILL(I)) 
      IMAX=I 
      PLI=PLIDER(ILL(I)) 
      GO TO 638 
637   CONTINUE 
      GO TO 99 
638   CONTINUE 
      DO 633 J=1,NLL 
      IF(PLIDER(ILL(J)).GT..9.OR.PLIDER(ILL(J)).LT.0.1) GO TO 633 
      PLIDER(ILL(J))=0. 
      IF(PPTCL(4,ILL(J)).LT.PMAX) GO TO 633 
      PLIDER(ILL(IMAX))=0. 
      IMAX=J 
      PMAX=PPTCL(4,ILL(J)) 
      PLIDER(ILL(J))=PLI 
633   CONTINUE 
C  LORENTZ TRANSFORMATION FROM CMS TO LAB. FRAME 
 99   IF(ICMS.EQ.1) GO TO 9700 
      BACK=.TRUE. 
C LORENTZ BOOST OF ENERGIES & MOMENTA 
      CALL LORTR(V,NIN1,NFIN2,BACK) 
C LORENTZ BOOST OF COORDINATES & TIMES 
      CALL LORCO(V,NIN1,NFIN2,BACK) 
9700   CONTINUE 
C       PRINT *, ' FROM COLLHH' 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DIFSMA(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE LOW MASS DIFFRACTION 
C 
      COMMON/ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMLID/PLIDER(499) 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/PRIMP0/ P0 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PARCUT/ SWMAX 
      COMMON/COMASS/AM1,AM2 
      DIMENSION V(3),PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      LOGICAL BACK 
      LOGICAL SPINT 
      COMMON/COLRET/ LRET 
      LOGICAL LRET 
      DIMENSION GAM(3),AMR(3) 
      DATA SIGMAD/0.23/ 
      DATA GAM/0.03,0.03,0.03/ 
      DATA AMR/1.40,1.10,1.30/ 
C     INITIALIZE 
      NREP=0 
      IRET=0 
      MXPTCL=499 
      XMINO=XMIN 
      SIGMAO=SIGMA 
      IPACK=1000 
      DS=ECM-AM1-AM2 
      PARBE=0.21 
      IF(ECM.GT.AM1+AM2+PARBE) GO TO 150 
      IRET=1 
      RETURN 
150   BACK=.TRUE. 
      SIGMA=SIGMAO 
      XMIN=XMINO 
      SPINT=.TRUE. 
      NREP=NREP+1 
      IF(NREP.LE.NTRIES) GO TO 101 
999   IRET=1 
C     WRITE(ITLIS,1200) NREP 
1200  FORMAT(3X,' IN DIFSMA NREP GT ',I8) 
      RETURN 
101   CONTINUE 
      SIGMA=0.30 
      XMIN=0. 
      IRET=0 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      IRDA=IRD1 
      IRDB=IRD2 
      PSIGN=-1. 
      IF(RNDMD(-1).GT.0.5) GO TO 100 
      PSIGN=1. 
      IKA=IDIN(2) 
      IKB=IDIN(1) 
      AMA=AM2 
      AMB=AM1 
      IRDA=IRD2 
      IRDB=IRD1 
100   CALL FLAVOB(IKA,IFL1,IFL2) 
C    COMPUTE X VALUES FOR PARTONS 
      IB1=IB(IKA) 
      IS1=IS(IKA) 
      IFL1S=IFL1 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      X1=XDIST(XMIN,IB1,IS1,IFL1S) 
      X2=1.-X1 
C     COMPUTE PT VALUE FOR HADRON 
160   CALL GAUSPT(PT2,SIGMA) 
      NREP=NREP+1 
      IF(NREP.LE.NTRIES) GO TO 102 
C   *********** 18.09.91 ************* 
      XMIN=XMINO 
      SIGMA=SIGMAO 
c   ********************************** 
      IRET=1 
      RETURN 
102   CONTINUE 
      PHI=2.*PI*RNDMD(-1) 
      PX2=PT2*DCOS(PHI) 
      PY2=PT2*DSIN(PHI) 
      CALL GAUSPT(PT,SIGMAD) 
      PHI=2.*PI*RNDMD(-1) 
      PTX=PT*DCOS(PHI) 
      PTY=PT*DSIN(PHI) 
      PX1=-PX2+PTX 
      PY1=-PY2+PTY 
      PT1=PX1**2+PY1**2 
      AMH=AMB 
      E1=DSQRT((P0*X1)**2+PX1**2+PY1**2) 
      E2=DSQRT((P0*X2)**2+PX2**2+PY2**2) 
      AMDTR=(E1+E2)**2-P0**2-PT**2 
C     IF(AMDTR.GE.3.3) GO TO 160 
      IDH=IDPARS(IFL1,IFL2,SPINT,2) 
      IDHR=IDPARS(IFL1,IFL2,SPINT,1) 
      AMHR=AMASS(IDHR) 
      PARBE=0.2 
      IF(IABS(IFL1).EQ.3.OR.IABS(IFL2).EQ.3) PARBE=0.3 
      AMHB=AMASS(IDH)+PARBE 
      IF(AMDTR.GE.AMHB**2) GO TO 200 
      GO TO 150 
200   AMD=DSQRT(AMDTR) 
      IF(ECM.LE.AMD+AMH) GO TO 160 
      IBR=IB(IDHR) 
      ISR=IS(IDHR) 
      GAMRES=GAM(3) 
      AMRES=AMR(3) 
      IF(IBR.NE.0) AMRES=AMR(1) 
      IF(IBR.EQ.0.AND.ISR.EQ.0) AMRES=AMR(2) 
      IF(AMD.GE.AMRES) GO TO 162 
      ARGWG=-(AMD-AMRES)**2/GAMRES 
      IF(ARGWG.LE.-30.) ARGWG=-30. 
      WG=DEXP(ARGWG) 
      IF(DS.LE.1.0.AND.IB1.EQ.0) GO TO 162 
      DRND=RNDMD(-1) 
      IF(DRND.GT.WG) GO TO 160 
162   ALA=ALAMB(SCM,AMDTR,AMH**2) 
      P0H=DSQRT(ALA)/(2.*ECM) 
      DTRM=P0H**2-PT**2 
      IF(DTRM.LT.0.) GO TO 160 
      PZH=DSIGN(DSQRT(DTRM),-PSIGN) 
      ED=DSQRT(AMD**2+P0H**2) 
      V(1)=PTX/ED 
      V(2)=PTY/ED 
      V(3)=PZH/ED 
      IF(AMD.GT.AMHR+SWMAX) GO TO 300 
      NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL CLUSTR(IFL1,IFL2,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      CALL TIFILL(NIN1,NFIN1,AMD,IFL1,IFL2) 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=-PSIGN*P0*X1 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E1,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN1,NFIN1 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
610   CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
      NPRODS=NPTCL-NFIX 
      GO TO 400 
300   NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL STRING(IFL1,IFL2,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      NPRODS=NPTCL-NFIX 
      PPX1(1)=PX1 
      PPX1(2)=PY1 
      PPX1(3)=-PSIGN*P0*X1 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E1,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PPTCL(1,J) 
      PPX1(2)=PPTCL(2,J) 
      PPX1(3)=PPTCL(3,J) 
      CALL ROTR(CT,ST,CFI,SFI,PPX1,PPX2,BACK) 
      PPTCL(1,J)=PPX2(1) 
      PPTCL(2,J)=PPX2(2) 
      PPTCL(3,J)=PPX2(3) 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
510   CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
400   CONTINUE 
      DO 500 J=NIN1,NFIN1 
      IORDP(J)=IRDA 
500   IORIG(J)=6 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      PPTCL(5,NPTCL)=AMH 
      PPTCL(1,NPTCL)=-PTX 
      PPTCL(2,NPTCL)=-PTY 
      PPTCL(3,NPTCL)=DSIGN(PZH,-PZH) 
      PPTCL(4,NPTCL)=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+ 
     *PPTCL(2,NPTCL)**2+PPTCL(3,NPTCL)**2) 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IKB 
      IORIG(NPTCL)=6 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=IRDB 
      XMIN=XMINO 
      SIGMA=SIGMAO 
      RETURN 
9999  WRITE(ITLIS,1000) SCM,NPTCL 
1000  FORMAT(//10X,38H....STOP IN DIFSMA..ENRGY TOO LOW SCM=,E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DIFTRI(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE TRIPLE POMERON VERTEX DIFFRACTION 
C 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON/COMLID/PLIDER(499) 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PRIMP0/ P0 
      COMMON/MASQUA/ AMQ21,AMQ22 
      COMMON /NEEDR/ NRET 
      COMMON/COMASS/ AM1,AM2 
      COMMON /COMQSE/ QSEE,QVSEE 
      LOGICAL  QSEE,QVSEE 
      LOGICAL RETU 
      LOGICAL BACK 
      DIMENSION V(3),PSUM(5) 
      DATA SIGMAD/0.45/ 
C     INITIALIZE 
      NREP=0 
      ZER=0.0 
      PARBE=0.30 
      IRET=0 
      IF(ECM.GT.(AM1+AM2+PARBE)) GO TO 999 
      IRET=1 
      RETURN 
999   MXPTCL=499 
      IPACK=1000 
      NPTCLI=NPTCL 
      DO 96 I=1,3 
96    PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      NRET=0 
      XMINO=XMIN 
      XMIN=0. 
      P0OLD=P0 
      AMQ21=0.0 
      AMQ22=0.0 
100   IRET=0 
      P0=P0OLD 
      RETU=.FALSE. 
      BACK=.TRUE. 
      PSIGN=-1. 
      PSOR=-1. 
      EP=DSQRT(P0**2+AM1**2) 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      IRDB=IRD2 
      IF(RNDMD(-1).GT.0.5) GO TO 151 
      IKA=IDIN(2) 
      IKB=IDIN(1) 
      AMA=AM2 
      AMB=AM1 
      IRDB=IRD1 
      PSIGN=1. 
      PSOR=1. 
      EP=DSQRT(P0**2+AM2**2) 
151   B0=1/SIGMAD**2 
      B=B0+0.6*DLOG(SCM/2.0) 
C     IF(IB(IDIN(1)).EQ.-1.AND.IB(IDIN(2)).NE.-1) B=12.0 
      SIGMAN=DSQRT(1./B) 
C   DON'T CHANGE !!! 
      PARBE=0.15 
150   XMINS=(PARBE+AMA)**2/SCM 
      NREP=NREP+1 
C     WRITE(17,1993) NREP,NTRIES 
1993  FORMAT(1X,'150C: ',2(1X,I10)) 
      IF(NREP.LT.NTRIES)  GO  TO 1994 
      P0=P0OLD 
      IRET=1 
      RETURN 
1994  CONTINUE 
C   COMPUTE X VALUE FOR SEE QUARKS 
C      PRINT  *, 'TO XSDIS' 
C     WRITE(17,1995) XMINS,XMAX 
1995  FORMAT(1X,'XMINS,XMAX=',2(F9.5,1X)) 
      CALL XSDIS(XS,XMINS,XMAX) 
C      PRINT  *, 'FROM XSDIS' 
C    COMPUTE PT VALUE FOR HADRON 
C      PRINT *, 'TO GAUSPT' 
      CALL GAUSPT(PTH,SIGMAN) 
C      PRINT  *, 'FROM GAUSPT' 
      PHI=2.*PI*RNDMD(-1) 
      PTHX=PTH*DCOS(PHI) 
      PTHY=PTH*DSIN(PHI) 
      PS=XS*P0 
      ES=PS 
      AMH=AMB 
      AMD2=(EP+ES)**2-(P0-PS)**2 
      AMD=DSQRT(AMD2) 
      IF(ECM.LE.AMD+AMH) GO TO 150 
      ALA=ALAMB(SCM,AMD2,AMH**2) 
      P0H=DSQRT(ALA)/(2.0*ECM) 
      DTRM=P0H**2-PTH**2 
      IF(DTRM.LT.0.) GO TO 150 
      PZH=DSQRT(DTRM)*PSIGN 
      EH=DSQRT(AMH**2+P0H**2) 
      ED=DSQRT(AMD2+P0H**2) 
      V(1)=-PTHX/ED 
      V(2)=-PTHY/ED 
      V(3)=-PZH/ED 
      NREP=0 
170   IFLS1=1+IDINT(RNDMD(-1)/PUD) 
      NREP=NREP+1 
C     WRITE(17,1991) NREP,NTRIES 
1991  FORMAT(1X,'170C: ',2(1X,I10)) 
      IF(NREP.LT.NTRIES)  GO  TO 1992 
      P0=P0OLD 
      IRET=1 
      RETURN 
1992  CONTINUE 
      IFLS2=IFLS1 
C    COMPUTE X VALUES FOR PARTONS 
      CALL FLAVOB(IKA,IFL1,IFL2) 
      IB1=IB(IKA) 
      IS1=IS(IKA) 
      IFL1S=IFL1 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      XQVAL=XDIST(XMIN,IB1,IS1,IFL1S) 
      XQQVA=1.-XQVAL 
C   COMPUTE X VALUE FOR PION 
      CALL XDIST2(XPI,X2PI) 
      NIN1=NPTCL+1 
C   IS THERE ANTIDIQUARK 
      IF(MOD(IFL2,100).EQ.0.AND.IFL2.GT.0) GO TO 160 
      IF(MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 160 
      IFL1T=IFL1 
      IFLS1T=IFLS1 
      XQVALT=XQVAL 
      XPIT=XPI 
      IFL2T=IFL2 
      IFLS2T=-IFLS2 
      XQQVAT=XQQVA 
      XPIT1=1.-XPI 
      PSI=1. 
      IF(PSIGN.LT.0.) GO TO 400 
      IFL1T=IFLS1 
      IFLS1T=IFL1 
      XQVALT=XPI 
      XPIT=XQVAL 
      IFL2T=-IFLS2 
      IFLS2T=IFL2 
      XQQVAT=1.-XPI 
      XPIT1=XQQVA 
      PSI=-1. 
400   PSIGN=PSIGN*PSI 
      P0=AMD/2.0 
      CALL XCORR(IFL1T,IFLS1T,ZER,ZER,ZER,ZER,XQVALT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      CALL XCORR(IFL2T,IFLS2T,ZER,ZER,ZER,ZER,XQQVAT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NPTCL=NPTCL-NPRD 
      GO TO 170 
130   NFIN1=NPTCL 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
      GO TO 300 
160   IFL1T=IFL1 
      IFLS2T=-IFLS2 
      XQVALT=XQVAL 
      XPIT1=1.-XPI 
      IFL2T=IFL2 
      IFLS1T=IFLS1 
      XQQVAT=XQQVA 
      XPIT=XPI 
      PSI=1. 
      IF(PSIGN.LT.0.) GO TO 450 
      IFL1T=-IFLS2 
      IFLS2T=IFL1 
      XQVALT=1.-XPI 
      XPIT1=XQVAL 
      IFL2T=IFLS2 
      IFLS1T=IFL2 
      XQQVAT=XPI 
      XPIT=XQQVA 
      PSI=-1. 
450   PSIGN=PSIGN*PSI 
      P0=AMD/2.0 
      CALL XCORR(IFL1T,IFLS2T,ZER,ZER,ZER,ZER,XQVALT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      CALL XCORR(IFL2T,IFLS1T,ZER,ZER,ZER,ZER,XQQVAT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 140 
      NPTCL=NPTCL-NPRD 
      GO TO 170 
140   NFIN1=NPTCL 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
300   P0=P0OLD 
      DO 500 I=NIN1,NFIN1 
      IORDP(I)=0 
500   IORIG(I)=1 
      NPTCL=NPTCL+1 
      NFIN1=NFIN1+1 
      NPRD=NPTCL-NPTCLI 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      PPTCL(1,NPTCL)=PTHX 
      PPTCL(2,NPTCL)=PTHY 
      PPTCL(3,NPTCL)=PZH 
      PPTCL(4,NPTCL)=EH 
      PPTCL(5,NPTCL)=AMH 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IKB 
      IORIG(NPTCL)=1 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=IRDB 
      CALL RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) GO TO 501 
      NPTCL=NPTCL-NPRD 
      GO TO 100 
501   XMIN=XMINO 
      RETURN 
9999  WRITE(ITLIS,1000) SCM,NPTCL 
1000  FORMAT(//10X,38H...STOP IN DIFTRI..ENERGY TOO LOW SCM=,E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE ANNIH(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C      COMPUTE ANNIHILATION DIAGRAM 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/PRINTS/IPRINT 
      LOGICAL IPRINT 
      COMMON/COMANN/ DIQAN 
      LOGICAL DIQAN 
      COMMON/CANPOM/ POAGEN(15) 
      COMMON/COMCOL/ NAC(100,4),NBC(100,4),NCOL 
      COMMON/COMPLI/ LIMP 
      LOGICAL MULTP 
      COMMON/COMMUL/MULTP 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMENB/ ENBOU 
      COMMON/CSIGA/ SIGAN 
      COMMON/SIGDIA/ CROSD(5),DST 
      DIMENSION IF1(3),IF2(3),IFD1(3),IFD2(3) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      DATA COEFPL/ 300./,COEFTW/100./ 
      DATA ICALL/0/ 
C   INITIALIZE 
      IRET=0 
      ICALL=ICALL+1 
      DIQAN=.TRUE. 
      CALL FLAVOR(IDIN(1),IF1(1),IF1(2),IF1(3),JSPIN1,INDEX1) 
      CALL FLAVOR(IDIN(2),IF2(1),IF2(2),IF2(3),JSPIN2,INDEX2) 
C    CAN BE ONE SHEET OR TWO SHEETS ANNIHILATION 
      DO 3 I=1,3 
      IF1(I)=IABS(IF1(I)) 
      DO 3 J=1,3 
      IF2(J)=IABS(IF2(J)) 
      IF(IF1(I).NE.IF2(J)) GO TO 3 
      GO TO 4 
3     CONTINUE 
      SIGPL=0. 
      SIGTWO=0. 
      GO TO 8 
C   CAN BE ONE SHEET ANNIHILATION 
4     IFD1(1)=IABS(IF1(1))*1000+IABS(IF1(2))*100 
      IFD1(2)=IABS(IF1(2))*1000+IABS(IF1(3))*100 
      IFD1(3)=IABS(IF1(1))*1000+IABS(IF1(3))*100 
      IFD2(1)=IABS(IF2(1))*1000+IABS(IF2(2))*100 
      IFD2(2)=IABS(IF2(2))*1000+IABS(IF2(3))*100 
      IFD2(3)=IABS(IF2(1))*1000+IABS(IF2(3))*100 
      DO 5 I=1,3 
      DO 5 J=1,3 
      IF(IFD1(I).NE.IFD2(J)) GO TO 5 
      GO TO 6 
5     CONTINUE 
      SIGPL=0. 
      GO TO 7 
 6     SIGPL=COEFPL*SCM**(-1.5) 
      IF(ECM.LT.ENBOU) SIGPL=CROSD(4) 
 7     SIGTWO=COEFTW/SCM 
      IF(ECM.LT.ENBOU) SIGTWO=CROSD(5) 
 8     SIGTH=SIGAN-SIGPL-SIGTWO 
      IF(ICALL.EQ.1.AND.IPRINT)WRITE(ITLIS,9540) SIGPL,SIGTWO,SIGTH 
 9540 FORMAT(//10X,' ANNIHILATION CROSS SECTION CONSISTS OF'/ 
     *   10X,' ONE SHEET DIAGRAMM WITH CR.SEC.=',E13.3,' MB'/ 
     *   10X,' TWO SHEET DIAGRAMM WITH CR.SEC.=',E13.3,' MB'/ 
     *   9X,'THREE SHEET DIAGRAMM WITH CR.SEC.=',E13.3,' MB'//) 
      TRY=RNDMD(-1) 
      IF(TRY.GT.SIGPL/SIGAN) GO TO 500 
C   ONE SHEET ANNIHILATION 
      CALL PLANAR(IRET) 
C     SIGMA=SIGMA1 
      RETURN 
500   IF(TRY.GT.(SIGPL+SIGTWO)/SIGAN) GO TO 600 
C    TWO SHEETS ANNIHILATION 
      CALL TWOSHE(IRET) 
C     SIGMA=SIGMA1 
      RETURN 
C   THREE SHEETS ANNIHILATION 
600   IF(.NOT.MULTP) GO TO 700 
C  SELECT NUMBER OF POMERONS 
      TRY=RNDMD(-1) 
      DO 710 NPOM=1,LIMP 
      NC=NPOM 
      IF(POAGEN(NPOM).GT.TRY) GO TO 800 
710   CONTINUE 
800   CONTINUE 
      NCOL=NC 
      DO 900 J=1,NCOL 
      NAC(J,4)=0 
      NBC(J,4)=0 
      NAC(J,3)=0 
      NBC(J,3)=0 
      NAC(J,1)=1 
      NBC(J,1)=1 
      NAC(J,2)=IDIN(1) 
      NBC(J,2)=IDIN(2) 
900   CONTINUE 
      CALL CHAINS(IRET) 
C     SIGMA=SIGMA1 
      RETURN 
700   CALL THREES(IRET) 
C     SIGMA=SIGMA1 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DOUBDI(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C----------------------------------------------------------------------- 
C  COMPUTE DOUBLE DIFFRACTION DISSOCIATION 
C----------------------------------------------------------------------- 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMECB/ ECMB 
      IF(ECM.GT.ECMB) GO TO 95 
      CALL DOUBSM(IRET) 
      RETURN 
95    IF(RNDMD(-1).GT.0.5) GO TO 96 
      CALL DOUBLO(IRET) 
      RETURN 
96    CALL DOUBY(IRET) 
      RETURN 
      END 
C*********************************************************************** 
      SUBROUTINE DOUBLO(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE ENHANCEMENT (LOOP)-POMERONS DIFFRACTION 
C 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMASS/ AM1,AM2 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMECB/ ECMB 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PRIMP0/ P0 
      COMMON/MASQUA/ AMQ21,AMQ22 
      COMMON/REACOE/ COEF(11),COEF1(11) 
      COMMON /COMQSE/ QSEE,QVSEE 
      LOGICAL QSEE,QVSEE 
      COMMON /NEEDR/ NRET 
      LOGICAL RETU 
      LOGICAL BACK 
      DIMENSION V1(3),V2(3),PSUM(5) 
      DATA SIGMAD/0.45/ 
C     INITIALIZE 
      NREP=0 
      ZE=0. 
      PARBE=0.21 
      QVSEE=.TRUE. 
      IRET=0 
      IF(ECM.GT.AM1+AM2+3.*PARBE) GO TO 999 
      IRET=1 
      GO  TO  9999 
999   MXPTCL=499 
      IPACK=1000 
      NPTCLI=NPTCL 
      DO 96 I=1,3 
96    PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      NRET=0 
      XMINO=XMIN 
      XMIN=0. 
      P0OLD=P0 
      AMQ21=0.0 
      AMQ22=0.0 
100   IRET=0 
      P0=P0OLD 
      RETU=.FALSE. 
      BACK=.TRUE. 
      PSIGN=-1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      B0=1/SIGMAD**2 
      B=B0+0.6*DLOG(SCM/2.0) 
C     IF(IB(IKA).EQ.-1.AND.IB(IKB).NE.-1) B=12.0 
      SIGMAN=DSQRT(1./B) 
      PARBE=0.3 
150   XMINS1=(PARBE+AMA)**2/SCM 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES)  GO  TO  1994 
      P0=P0OLD 
      IRET=1 
      RETURN 
1994  CONTINUE 
C   COMPUTE X VALUE FOR SEE QUARKS 
      CALL XSDIS(XS1,XMINS1,XMAX) 
      XS3=1.-XS1 
C    COMPUTE PT VALUE 
      CALL GAUSPT(PTH,SIGMAN) 
      PHI=2.*PI*RNDMD(-1) 
      PTHX=PTH*DCOS(PHI) 
      PTHY=PTH*DSIN(PHI) 
      XMINS2=(PARBE+AMB)**2/SCM 
C   COMPUTE X VALUE FOR SEE QUARKS 
      CALL XSDIS(XS2,XMINS2,XMAX) 
      XS4=1.-XS2 
      P1=P0*XS1 
      P2=PSIGN*P0*XS2 
      P3=P0*XS3 
      P4=PSIGN*P0*XS4 
      E1=P1 
      E2=DABS(P2) 
      E3=P3 
      E4=DABS(P4) 
      E14=E1+E4 
      P14=P1+P4 
      AMD14=E14**2-P14**2 
      E23=E2+E3 
      P23=P2+P3 
      AMD23=E23**2-P23**2 
      AMD1=DSQRT(AMD14) 
      AMD2=DSQRT(AMD23) 
      IF(ECM.LE.AMD1+AMD2) GO TO 150 
      ALA=ALAMB(SCM,AMD14,AMD23) 
      P0H=DSQRT(ALA)/(2.0*ECM) 
      DTRM=P0H**2-PTH**2 
      IF(DTRM.LT.0.) GO TO 150 
      PZH14=DSQRT(DTRM)*PSIGN 
      PZH23=-PZH14 
      V1(1)=PTHX/E14 
      V1(2)=PTHY/E14 
      V1(3)=PZH14/E14 
      V2(1)=-PTHX/E23 
      V2(2)=-PTHY/E23 
      V2(3)=PZH23/E23 
      NIN1=NPTCL+1 
      NREP=0 
170   IFLS1=1+IDINT(RNDMD(-1)/PUD) 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES)  GO  TO  1992 
      P0=P0OLD 
      IRET=1 
      RETURN 
1992  CONTINUE 
      CALL FLAVOB(IKA,IFL1,IFL2) 
      IB1=IB(IKA) 
      IS1=IS(IKA) 
      IFL1S=IFL1 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      XQVAL=XDIST(XMIN,IB1,IS1,IFL1S) 
      XQQVA=1.-XQVAL 
C   COMPUTE X VALUE FOR PION 
      CALL XDIST2(XPI,X2PI) 
C   IS THERE ANTIDIQUARK 
      IF(MOD(IFL2,100).EQ.0.AND.IFL2.GT.0) GO TO 160 
      IF(MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 160 
      IFL1T=IFL1 
      IFLS1T=IFLS1 
      XQVALT=XQVAL 
      XPIT=XPI 
      IFL2T=IFL2 
      IFLS2T=-IFLS1 
      XQQVAT=XQQVA 
      XPIT1=1.-XPI 
      P0=AMD1/2.0 
      CALL XCORR(IFL1T,IFLS1T,ZE,ZE,ZE,ZE,XQVALT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      CALL XCORR(IFL2T,IFLS2T,ZE,ZE,ZE,ZE,XQQVAT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NPTCL=NPTCL-NPRD 
      GO TO 170 
130   NFIN1=NPTCL 
      CALL LORTR(V1,NIN1,NFIN1,BACK) 
      CALL LORCO(V1,NIN1,NFIN1,BACK) 
      GO TO 180 
160   IFL1T=IFL1 
      IFLS2T=-IFLS1 
      XQVALT=XQVAL 
      XPIT1=1.-XPI 
      IFL2T=IFL2 
      IFLS1T=IFLS1 
      XQQVAT=XQQVA 
      XPIT=XPI 
      P0=AMD1/2.0 
      CALL XCORR(IFL1T,IFLS2T,ZE,ZE,ZE,ZE,XQVALT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 170 
      CALL XCORR(IFL2T,IFLS1T,ZE,ZE,ZE,ZE,XQQVAT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 140 
      NPTCL=NPTCL-NPRD 
      GO TO 170 
140   NFIN1=NPTCL 
      CALL LORTR(V1,NIN1,NFIN1,BACK) 
      CALL LORCO(V1,NIN1,NFIN1,BACK) 
180   NPRDAL=NPRD 
      NIN1=NPTCL+1 
      NREP1=0.                    ! Toneev  T16.7.96
181   IFLS1=1+IDINT(RNDMD(-1)/PUD) 
************************************! Toneev  T16.7.96
      NREP1=NREP1+1
      if(NREP1.ge.NTRIES)then
      IRET=1
      RETURN
      end if
************************************
      CALL FLAVOB(IKB,IFL1,IFL2) 
      IB1=IB(IKB) 
      IS1=IS(IKB) 
      IFL1S=IFL1 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      XQVAL=XDIST(XMIN,IB1,IS1,IFL1S) 
      XQQVA=1.-XQVAL 
C   COMPUTE X VALUE FOR PION 
      CALL XDIST2(XPI,X2PI) 
C   IS THERE ANTIDIQUARK 
      IF(MOD(IFL2,100).EQ.0.AND.IFL2.GT.0) GO TO 190 
      IF(MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 190 
      IFL1T=IFLS1 
      IFLS1T=IFL1 
      XQVALT=XPI 
      XPIT=XQVAL 
      IFL2T=-IFLS1 
      IFLS2T=IFL2 
      XQQVAT=1.-XPI 
      XPIT1=XQQVA 
      P0=AMD2/2.0 
      CALL XCORR(IFL1T,IFLS1T,ZE,ZE,ZE,ZE,XQVALT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 181 
      CALL XCORR(IFL2T,IFLS2T,ZE,ZE,ZE,ZE,XQQVAT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 230 
      NPTCL=NPTCL-NPRD 
      GO TO 181 
230   NFIN1=NPTCL 
      CALL LORTR(V2,NIN1,NFIN1,BACK) 
      CALL LORCO(V2,NIN1,NFIN1,BACK) 
      GO TO 250 
190   IFL1T=-IFLS1 
      IFLS2T=IFL1 
      XQVALT=1.-XPI 
      XPIT1=XQVAL 
      IFL2T=IFLS1 
      IFLS1T=IFL2 
      XQQVAT=XPI 
      XPIT=XQQVA 
      P0=AMD2/2.0 
      CALL XCORR(IFL1T,IFLS2T,ZE,ZE,ZE,ZE,XQVALT,XPIT1, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 181 
      CALL XCORR(IFL2T,IFLS1T,ZE,ZE,ZE,ZE,XQQVAT,XPIT, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 240 
      NPTCL=NPTCL-NPRD 
      GO TO 181 
240   NFIN1=NPTCL 
      CALL LORTR(V2,NIN1,NFIN1,BACK) 
      CALL LORCO(V2,NIN1,NFIN1,BACK) 
250   P0=P0OLD 
      NIN1=NPTCLI+1 
      NPRDAL=NPRDAL+NPRD 
      DO 500 I=NIN1,NFIN1 
      IORDP(I)=0 
500   IORIG(I)=11 
      CALL RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) GO TO 501 
      NPTCL=NPTCL-NPRDAL 
      GO TO 100 
501   XMIN=XMINO 
      RETURN 
9999  CONTINUE 
C     WRITE(ITLIS,1000) SCM,NPTCL 
1000  FORMAT(//10X,38H...STOP IN DOUBLO..ENERGY TOO LOW SCM=,E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE DOUBY(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE DOUBLE ENHANCEMENT (Y)-POMERONS DIFFRACTION 
C 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMLID/PLIDER(499) 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMASS/ AM1,AM2 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PRIMP0/ P0 
      COMMON /ORDER/ IRD1,IRD2 
      COMMON/MASQUA/ AMQ21,AMQ22 
      COMMON/REACOE/ COEF(11),COEF1(11) 
      COMMON /COMQSE/ QSEE,QVSEE 
      LOGICAL QSEE,QVSEE 
      COMMON /NEEDR/ NRET 
      LOGICAL RETU 
      LOGICAL BACK 
      DIMENSION V1(3),V2(3),PSUM(5) 
      DATA SIGMAD/0.45/ 
C     INITIALIZE 
      NREP=0 
      PARBE=0.21 
      QSEE=.TRUE. 
      QVSEE=.FALSE. 
      IRET=0 
      IF(ECM.GT.AM1+AM2+3.*PARBE) GO TO 999 
      IRET=1 
      RETURN 
999   MXPTCL=499 
      IPACK=1000 
      NPTCLI=NPTCL 
      DO 96 I=1,3 
96    PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      NRET=0 
      XMINO=XMIN 
      XMIN=0. 
      AMQ21=0.0 
      AMQ22=0.0 
      IRET=0 
      RETU=.FALSE. 
      BACK=.TRUE. 
      PSIGN=-1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      IRDA=IRD1 
      IRDB=IRD2 
      B0=1/SIGMAD**2 
      B=B0+0.6*DLOG(SCM/2.0) 
C     IF(IB(IKA).EQ.-1.AND.IB(IKB).NE.-1) B=12.0 
      SIGMAN=DSQRT(1./B) 
      PARBE=0.3 
150   XMINS1=(PARBE+AMA)**2/SCM 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES)  GO  TO  1992 
      IRET=1 
      RETURN 
1992  CONTINUE 
      NPRDAL=0 
C   COMPUTE X VALUE FOR SEE QUARKS 
      CALL XSDIS(XS1,XMINS1,XMAX) 
      XS3=1.-XS1 
      XS11=XMINS1+(XS1-XMINS1)*RNDMD(-1) 
      XS12=XS1-XS11 
C    COMPUTE PT VALUE 
      CALL GAUSPT(PTH,SIGMAN) 
      PHI=2.*PI*RNDMD(-1) 
      PTHX1=PTH*DCOS(PHI) 
      PTHY1=PTH*DSIN(PHI) 
      PTHX11=PTHX1*RNDMD(-1) 
      PTHX12=PTHX1-PTHX11 
      PTHY11=PTHY1*RNDMD(-1) 
      PTHY12=PTHY1-PTHY11 
      PTHX3=-PTHX1 
      PTHY3=-PTHY1 
      XMINS2=(PARBE+AMB)**2/SCM 
C   COMPUTE X VALUE FOR SEE QUARKS 
      CALL XSDIS(XS2,XMINS2,XMAX) 
      XS4=1.-XS2 
      XS21=XMINS2+(XS2-XMINS2)*RNDMD(-1) 
      XS22=XS2-XS21 
C    COMPUTE PT VALUE 
      CALL GAUSPT(PTH,SIGMAN) 
      PHI=2.*PI*RNDMD(-1) 
      PTHX2=PTH*DCOS(PHI) 
      PTHY2=PTH*DSIN(PHI) 
      PTHX21=PTHX2*RNDMD(-1) 
      PTHX22=PTHX2-PTHX21 
      PTHY21=PTHY2*RNDMD(-1) 
      PTHY22=PTHY2-PTHY21 
      PTHX4=-PTHX2 
      PTHY4=-PTHY2 
      P11=P0*XS11 
      P12=P0*XS12 
      P21=PSIGN*P0*XS21 
      P22=PSIGN*P0*XS22 
      P3=P0*XS3 
      P4=PSIGN*P0*XS4 
      E11=DSQRT(P11**2+PTHX11**2+PTHY11**2) 
      E12=DSQRT(P12**2+PTHX12**2+PTHY12**2) 
      E21=DSQRT(P21**2+PTHX21**2+PTHY21**2) 
      E22=DSQRT(P22**2+PTHX22**2+PTHY22**2) 
      E3=DSQRT(P3**2+PTHX3**2+PTHY3**2+AMA**2) 
      E4=DSQRT(P4**2+PTHX4**2+PTHY4**2+AMB**2) 
C  Q11+Q22 
      E1=E11+E22 
      P1=P11+P22 
      PX1=PTHX11+PTHX22 
      PY1=PTHY11+PTHY22 
      AMD1=E1**2-P1**2-PX1**2-PY1**2 
C  Q12+Q21 
      E2=E12+E21 
      P2=P12+P21 
      PX2=PTHX12+PTHX21 
      PY2=PTHY12+PTHY21 
      AMD2=E2**2-P2**2-PX2**2-PY2**2 
C 
      AMD1=DSQRT(AMD1) 
      AMD2=DSQRT(AMD2) 
      IF(ECM.LE.AMD1+AMD2+2.0) GO TO 150 
      V1(1)=PX1/E1 
      V1(2)=PY1/E1 
      V1(3)=P1/E1 
      V2(1)=PX2/E2 
      V2(2)=PY2/E2 
      V2(3)=P2/E2 
      NIN1=NPTCL+1 
      IFL11=1+IDINT(RNDMD(-1)/PUD) 
      IFL12=-IFL11 
      IFL21=1+IDINT(RNDMD(-1)/PUD) 
      IFL22=-IFL21 
C 
      CALL XCORR(IFL11,IFL22,PTHX11,PTHY11,PTHX22,PTHY22,XS11,XS22, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 150 
      NFIN1=NPTCL 
      CALL LORTR(V1,NIN1,NFIN1,BACK) 
      CALL LORCO(V1,NIN1,NFIN1,BACK) 
      NIN1=NPTCL+1 
      CALL XCORR(IFL12,IFL21,PTHX12,PTHY12,PTHX21,PTHY21,XS12,XS21, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NPTCL=NPTCL-NPRD 
      GO TO 150 
130   NFIN1=NPTCL 
      CALL LORTR(V2,NIN1,NFIN1,BACK) 
      CALL LORCO(V2,NIN1,NFIN1,BACK) 
C 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      PPTCL(1,NPTCL)=PTHX3 
      PPTCL(2,NPTCL)=PTHY3 
      PPTCL(3,NPTCL)=P3 
      PPTCL(4,NPTCL)=E3 
      PPTCL(5,NPTCL)=AMA 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IKA 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=IRDA 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      PPTCL(1,NPTCL)=PTHX4 
      PPTCL(2,NPTCL)=PTHY4 
      PPTCL(3,NPTCL)=P4 
      PPTCL(4,NPTCL)=E4 
      PPTCL(5,NPTCL)=AMB 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IKB 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=IRDB 
      NIN1=NPTCLI+1 
      NPRDAL=NPRDAL+NPRD+2 
      NFIN1=NPTCL 
      DO 500 I=NIN1,NFIN1 
      IF(I.GE.NPTCL-1) GO TO 500 
      IORDP(I)=0 
500   IORIG(I)=11 
      CALL RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) GO TO 501 
      NPTCL=NPTCL-NPRDAL 
      GO TO 150 
501   XMIN=XMINO 
      RETURN 
9999  WRITE(ITLIS,1000) SCM,NPTCL 
1000  FORMAT(//10X,38H...STOP IN DOUBY ..ENERGY TOO LOW SCM=,E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C*********************************************************************** 
      SUBROUTINE DOUBSM(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE DOUBLE SMALL MASS DIFFRACTION 
C 
      COMMON/CONST/ PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/ SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/ITAPES/ ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PRIMP0/ P0 
      COMMON/COMASS/ AM1,AM2 
      COMMON/MASQUA/ AMQ21,AMQ22 
      COMMON /NEEDR/ NRET 
      LOGICAL RETU 
      LOGICAL BACK 
      LOGICAL SPINT 
      DIMENSION PSUM(5),GAM(3),AMR(3) 
      DATA SIGMAN/0.23/ 
      DATA GAM/0.03,0.03,0.03/ 
      DATA AMR/1.40,1.10,1.30/ 
C     INITIALIZE 
      NREP=0 
      PARBE=0.23 
      SPINT=.TRUE. 
      IRET=0 
      IF(ECM.GT.AM1+AM2+2.*PARBE) GO TO 999 
      IRET=1 
      GO  TO  9999 
 999  DS=ECM-AM1-AM2 
      MXPTCL=499 
      IPACK=1000 
      DO 96 I=1,3 
96    PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
      NRET=1 
      XMINO=XMIN 
      XMIN=0. 
      SIGMA0=SIGMA 
      SIGMA=0.3 
      AMQ21=0.0 
      AMQ22=0.0 
100   IRET=0 
      NDRDAL=0 
      RETU=.FALSE. 
      BACK=.TRUE. 
      PSIGN=1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      PARBE=0.22 
150   CALL FLAVOB(IKA,IFL1,IFL2) 
C   COMPUTE X VALUE FOR VALENCE QUARK 
      IB1=IB(IKA) 
      IS1=IS(IKA) 
      IFL1S=IFL1 
      IF(IS1.NE.0.AND.IB1.EQ.0.AND.IABS(IFL1).EQ.3) IFL1S=IFL2 
      X1=XDIST(XMIN,IB1,IS1,IFL1S) 
      X2=1.-X1 
      CALL FLAVOB(IKB,IFL3,IFL4) 
C   COMPUTE X VALUE FOR VALENCE QUARK 
      IB2=IB(IKB) 
      IS2=IS(IKB) 
      IFL3S=IFL3 
      IF(IS2.NE.0.AND.IB2.EQ.0.AND.IABS(IFL3).EQ.3) IFL3S=IFL4 
      X03=XDIST(XMIN,IB2,IS2,IFL3S) 
      X04=1.-X03 
      X3=-X03 
      X4=-X04 
C COMPUTE PT VALUE FOR HADRON 
160   CALL GAUSPT(PTH,SIGMAN) 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES)  GO  TO  1994 
      IRET=1 
      RETURN 
1994  CONTINUE 
      PHI=2.*PI*RNDMD(-1) 
      PTXH=PTH*DCOS(PHI) 
      PTYH=PTH*DSIN(PHI) 
C    COMPUTE PT VALUE 
      CALL GAUSPT(PT1,SIGMA) 
      PHI=2.*PI*RNDMD(-1) 
      PX1=PT1*DCOS(PHI) 
      PY1=PT1*DSIN(PHI) 
      CALL GAUSPT(PT2,SIGMA) 
      PHI=2.*PI*RNDMD(-1) 
      PX2=PT2*DCOS(PHI) 
      PY2=PT2*DSIN(PHI) 
      PX1H=PTXH-PX1 
      PY1H=PTYH-PY1 
      PX2H=-PTXH-PX2 
      PY2H=-PTYH-PY2 
      P1=P0*X1 
      P2=P0*X2 
      P3=P0*X3 
      P4=P0*X4 
      E11=DSQRT(P1**2+PX1**2+PY1**2) 
      E12=DSQRT(P2**2+PX1H**2+PY1H**2) 
      E23=DSQRT(P3**2+PX2**2+PY2**2) 
      E24=DSQRT(P4**2+PX2H**2+PY2H**2) 
      E1=E11+E12 
      E2=E23+E24 
      AMD1=E1**2-P0**2-PTXH**2-PTYH**2 
      IDH1=IDPARS(IFL1,IFL2,SPINT,2) 
      AMHB1=AMASS(IDH1)+PARBE 
      IF(AMD1.LT.AMHB1**2) GO TO 160 
      IDHR1=IDPARS(IFL1,IFL2,SPINT,1) 
      IBR1=IB(IDHR1) 
      ISR1=IS(IDHR1) 
      GAMRES=GAM(3) 
      AMRES=AMR(3) 
      IF(IBR1.NE.0) AMRES=AMR(1) 
      IF(IBR1.EQ.0.AND.ISR1.EQ.0) AMRES=AMR(2) 
      AMD10=DSQRT(AMD1) 
      IF(AMD10.GE.AMRES) GO TO 162 
      ARGWG1=-(AMD10-AMRES)**2/GAMRES 
      IF(ARGWG1.LE.-30.) ARGWG1=-30. 
      WG1=DEXP(ARGWG1) 
      IF(DS.LE.1.0.AND.IB1.EQ.0) GO TO 162 
      IF(RNDMD(-1).GT.WG1) GO TO 160 
162   AMD2=E2**2-P0**2-PTXH**2-PTYH**2 
      IDH2=IDPARS(IFL3,IFL4,SPINT,2) 
      AMHB2=AMASS(IDH2)+PARBE 
      IF(AMD2.LT.AMHB2**2) GO TO 160 
      IDHR2=IDPARS(IFL3,IFL4,SPINT,1) 
      IBR2=IB(IDHR2) 
      ISR2=IS(IDHR2) 
      GAMRES=GAM(3) 
      AMRES=AMR(3) 
      IF(IBR2.NE.0) AMRES=AMR(1) 
      IF(IBR2.EQ.0.AND.ISR2.EQ.0) AMRES=AMR(2) 
      AMD20=DSQRT(AMD2) 
      IF(AMD20.GE.AMRES) GO TO 163 
      ARGWG2=-(AMD20-AMRES)**2/GAMRES 
      IF(ARGWG2.LE.-30.) ARGWG2=-30. 
      WG2=DEXP(ARGWG2) 
      IF(DS.LE.1.0.AND.IB2.EQ.0) GO TO 163 
      IF(RNDMD(-1).GT.WG2) GO TO 160 
163   CONTINUE 
      IF(ECM.LE.AMD10+AMD20) GO TO 160 
      ALA=ALAMB(SCM,AMD1,AMD2) 
      P0H=DSQRT(ALA)/(2.0*ECM) 
      DTRM=P0H**2-PTH**2 
      IF(DTRM.LT.0.) GO TO 160 
      NIN1=NPTCL+1 
      CALL XCORR(IFL1,IFL2,PX1,PY1,PX1H,PY1H,X1,X2, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 160 
      CALL XCORR(IFL3,IFL4,PX2,PY2,PX2H,PY2H,X3,X4, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NPTCL=NPTCL-NPRD 
      GO TO 160 
130   NFIN2=NPTCL 
      NPRDAL=NPRDAL+NPRD 
      IF(NPRDAL.NE.2) GO TO 131 
      IF(IKA.NE.IDENT(NPTCL-1).OR.IKB.NE.IDENT(NPTCL)) GO TO 131 
      NPTCL=NPTCL-NPRDAL 
131   CALL RESCAL(NIN1,NFIN2,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) GO TO 501 
      NPTCL=NPTCL-NPRDAL 
      GO TO 100 
501   XMIN=XMINO 
      SIGMA=SIGMA0 
      DO 500 I=NIN1,NFIN2 
      IORDP(I)=0 
500   IORIG(I)=11 
      RETURN 
9999  CONTINUE 
C     WRITE(ITLIS,1000) SCM,NPTCL 
1000  FORMAT(//10X,38H...STOP IN DOUBSM..ENERGY TOO LOW SCM=,E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
       SUBROUTINE CHAINS(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C   FORM COLOUR NEUTRAL CHAINS FROM QUARKS 
C 
C 
      DIMENSION PSUM(5) 
       COMMON/COMFLA/MNASEA(12),MNBSEA(12),IFLAS(12),IFLBS(12), 
     * NUAVAL, 
     * NUBVAL,IFLQA1,IFLQB1,IFLQA2,IFLQB2,IFAQQ,IFBQQ 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMLID/PLIDER(499) 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL QSEE,QVSEE 
      COMMON/PRIMP0/ P0 
      COMMON/COMCOL/ NAC(100,4),NBC(100,4),NCOL 
       COMMON/COMVA/ XAVAL1,XAVAL2,XAQQ,XASEA1(12), 
     * XASEA2(12),NPOMA 
       COMMON/COMVB/ XBVAL1,XBVAL2,XBQQ,XBSEA1(12), 
     * XBSEA2(12),NPOMB 
       COMMON/COMPYA/ PYAV1,PYAV2,PYAQQ, 
     *PYAS1(12),PYAS2(12) 
       COMMON/COMPXA/ PXAV1,PXAV2,PXAQQ, 
     *PXAS1(12),PXAS2(12) 
       COMMON/COMPXB/ PXBV1,PXBV2,PXBQQ, 
     *PXBS1(12),PXBS2(12) 
       COMMON/COMPYB/ PYBV1,PYBV2,PYBQQ, 
     *PYBS1(12),PYBS2(12) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/COMQMA/ AMQUA1,AMQUA2,AMQQA, 
     *AMQAS1(12),AMQAS2(12) 
      COMMON/COMQMB/ AMQUB1,AMQUB2,AMQQB, 
     *AMQBS1(12),AMQBS2(12) 
      COMMON/MASQUA/ AMQ21,AMQ22 
      DIMENSION JSA0(12),JSB0(12) 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMDIF/ NDIFA,NDIFB 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/NEEDR/ NRET 
      COMMON /UNCYS/ NUNCY 
      COMMON /UNCYS1/ NUNC 
      LOGICAL RETU 
      LOGICAL DIQAN 
      COMMON/COMANN/ DIQAN 
      COMMON/COMASS/ AM1,AM2 
      COMMON/KAPPA/ XAP 
      COMMON/NPTCLZ/NPTCLZ 
C   COMPUTE QUARK PARAMETERS 
C     INITIALIZE 
      MXPTCL=499 
      NUNC=0 
      PARBE=0.3 
      IRET=0 
      IF(ECM.GT.AM1+AM2+3.*PARBE) GO TO 999 
      IRET=1 
      RETURN 
999   IREP=0 
      IPACK=1000 
      NRET=0 
      DO 151 I=1,3 
151   PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
1111  NPTCL=0 
      QSEE=.FALSE. 
      NIN=NPTCL+1 
      IREP=IREP+1 
      IF(IREP.LE.NTRIES) GO TO 1112 
      IRET=1 
      RETURN 
1112  PSIGN=-1. 
       NVSA=0 
       NVSB=0 
       NPOMA=1 
       NPOMB=1 
      NAVAL=0 
      NBVAL=0 
       DO 114 J=1,12 
       JSA0(J)=0 
       JSB0(J)=0 
  114  CONTINUE 
       NASEA=0 
       NBSEA=0 
       DO 206 JC=1,NCOL 
       IPAR=NAC(JC,1) 
       JPAR=NBC(JC,1) 
       IKA=NAC(JC,2) 
       IBA=IB(IKA) 
       IKB=NBC(JC,2) 
       IBB=IB(IKB) 
      IDIF=NAC(JC,3) 
      JDIF=NBC(JC,3) 
      IF(NAVAL.EQ.0) GO TO 102 
       IF(NUAVAL.NE.IPAR) GO TO 101 
       NPOMA=NPOMA+1 
      NASEA=NASEA+1 
      MNASEA(NASEA)=1 
      GO TO 103 
  101  CONTINUE 
102   NAVAL=NAVAL+1 
       CALL FLAVOB(IKA,IFL1,IFL2) 
       IFLQA1=IFL1 
       IFLQA2=0 
       IFAQQ=IFL2 
       IFAHQ=IKA 
      IF(IBA.NE.0) GO TO 123 
      IF(IABS(IFL1).NE.3) GO TO 123 
       IFAQQ=IFL1 
       IFLQA1=IFL2 
123    NUAVAL=IPAR 
      NDIFA=IDIF 
      IF(.NOT.DIQAN) GO TO 103 
      CALL FLAVOR(IFL2,IFLQA2,IFAQQ,IFK ,JSPIN,INDEX) 
      IF(RNDMD(-1).GE.0.5) GO TO 103 
      ISWAP=IFAQQ 
      IFAQQ=IFLQA2 
      IFLQA2=ISWAP 
103   IF(NBVAL.EQ.0) GO TO 105 
       IF(NUBVAL.NE.JPAR) GO TO 104 
       NPOMB=NPOMB+1 
       NBSEA=NBSEA+1 
       MNBSEA(NBSEA)=1 
       GO TO 206 
  104  CONTINUE 
105   NBVAL=NBVAL+1 
       CALL FLAVOB(IKB,IFL1,IFL2) 
       IFLQB1=IFL1 
       IFLQB2=0 
       IFBQQ=IFL2 
       IFBHQ=IKB 
       NUBVAL=JPAR 
       NDIFB=JDIF 
      IF(.NOT.DIQAN) GO TO 206 
      CALL FLAVOR(IFL2,IFLQB2,IFBQQ,IFK ,JSPIN,INDEX) 
      IF(RNDMD(-1).GE.0.5) GO TO 206 
      ISWAP=IFBQQ 
      IFBQQ=IFLQB2 
      IFLQB2=ISWAP 
  206  CONTINUE 
C  COMPUTE X AND PT VALUES FOR PARTONS 
       XMIE=0.015/ECM 
       CALL XQUARK(0,XMIE,XMAX,ALFA,BETA,IBA) 
       CALL XQUARK(1,XMIE,XMAX,ALFA,BETA,IBB) 
       CALL PTQUAR(0) 
       CALL PTQUAR(1) 
       IF(NASEA.EQ.0) GO TO 506 
       JSD=1 
       DO 505 JSA=1,NASEA 
       JSA0(JSA)=JSA0(JSA)+JSD 
       JSD=JSD+1 
  505  CONTINUE 
  506  CONTINUE 
      IF(NBSEA.EQ.0) GO TO 634 
       JSD=1 
       DO 632 JSB=1,NBSEA 
       JSB0(JSB)=JSB0(JSB)+JSD 
       JSD=JSD+1 
  632  CONTINUE 
 634  CONTINUE 
C 
C    SELECT SEA-SEA CHAINS 
C 
      NAVAL=0 
      NBVAL=0 
       NASEA=0 
       NBSEA=0 
       DO 6 JC=1,NCOL 
       IPAR=NAC(JC,1) 
       JPAR=NBC(JC,1) 
       IAA=0 
       IBB=0 
      IF(NAVAL.EQ.0) GO TO 2 
       IF(NUAVAL.NE.IPAR) GO TO 1 
       IAA=1 
       NASEA=NASEA+1 
       JS1=NASEA 
       IFLAS(NASEA)=1+IDINT(RNDMD(-1)/PUD) 
C      IFLAS(NASEA)=IDINT(3.*RNDMD(-1)+1.) 
       GO TO 3 
  1    CONTINUE 
2     NAVAL=NAVAL+1 
3     IF(NBVAL.EQ.0) GO TO 5 
       IF(NUBVAL.NE.JPAR) GO TO 4 
       NBSEA=NBSEA+1 
       IBB=1 
       JS2=NBSEA 
       IFLBS(NBSEA)=1+IDINT(RNDMD(-1)/PUD) 
C      IFLBS(NBSEA)=IDINT(3.*RNDMD(-1)+1.) 
       GO TO 7 
  4    CONTINUE 
5     NBVAL=NBVAL+1 
  7    CONTINUE 
       IF(IAA.EQ.0.OR.IBB.EQ.0) GO TO 6 
C   DECAY OF SEA-SEA CHAINS 
       QSEE = .TRUE. 
       QVSEE =.FALSE. 
       JVA=MNASEA(JS1) 
       JVB=MNBSEA(JS2) 
       JS10=JSA0(JS1) 
       JS20=JSB0(JS2) 
      NIN1=NPTCL+1 
      AMQ21=AMQAS1(JS10) 
      AMQ22=AMQBS2(JS20) 
      CALL XCORR(IFLAS(JS1),-IFLBS(JS2),PXAS1(JS10), 
     1PYAS1(JS10),PXBS2(JS20),PYBS2(JS20), 
     2XASEA1(JS10),XBSEA2(JS20),PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQAS2(JS10) 
      AMQ22=AMQBS1(JS20) 
      CALL XCORR(-IFLAS(JS1),IFLBS(JS2),PXAS2(JS10), 
     1PYAS2(JS10),PXBS1(JS20),PYBS1(JS20), 
     2XASEA2(JS10),XBSEA1(JS20),PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      NFIN1=NPTCL 
      DO 500 J=NIN1,NFIN1 
      IORIG(J)=7+NCOL*10 
      IORDP(J)=0 
      IF(DIQAN) IORIG(J)=5+10*(NCOL+2) 
500   CONTINUE 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
6     CONTINUE 
C 
      IF(NPOMA.NE.1.OR.NDIFA.NE.1) GO TO 177 
      IFLQA2=1+IDINT(RNDMD(-1)/PUD) 
      IFLQA1=-IFLQA2 
      IFAQQ=IFAHQ 
177   CONTINUE 
      IF(NPOMB.NE.1.OR.NDIFB.NE.1) GO TO 178 
      IFLQB2=1+IDINT(RNDMD(-1)/PUD) 
      IFLQB1=-IFLQB2 
      IFBQQ=IFBHQ 
178   CONTINUE 
C 
C        SELECT VALENCE-VALENCE CHAINS 
C 
      QSEE=.FALSE. 
       NAVAL=0 
       NBVAL=0 
       NASEA=0 
       NBSEA=0 
       DO 86 JC=1,NCOL 
      IDIFA=0 
      IDIFB=0 
       IPAR=NAC(JC,1) 
       JPAR=NBC(JC,1) 
       IAA=0 
       IBB=0 
      IF(NAVAL.EQ.0) GO TO 92 
       IF(NUAVAL.NE.IPAR) GO TO 91 
       IAA=1 
       GO TO 93 
  91   CONTINUE 
92    NAVAL=NAVAL+1 
  93   IF(NBVAL.EQ.0) GO TO 95 
       IF(NUBVAL.NE.JPAR) GO TO 94 
       IBB=1 
       GO TO 97 
  94   CONTINUE 
95    NBVAL=NBVAL+1 
  97   IF(IAA.EQ.1.OR.IBB.EQ.1) GO TO 86 
C   DECAY OF VALENCE-VALENCE CHAINS 
      NIN1=NPTCL+1 
      IF(DIQAN) GO TO 914 
      IF(IFLQA1.GT.0) GO TO 815 
      IF(NPOMA.EQ.1.AND.NDIFA.EQ.1) GO TO 951 
      IF(NPOMB.EQ.1.AND.NDIFB.EQ.1) GO TO 952 
C     IS THERE ANTIDIQUARK 
      IF(IFLQB1.GT.0) GO TO 941 
      AMQ21=AMQUA1 
      AMQ22=AMQQB 
      CALL XCORR(IFLQA1,IFBQQ,PXAV1,PYAV1, 
     *PXBQQ,PYBQQ,XAVAL1,1.-XBQQ, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQUB1 
      CALL XCORR(IFAQQ,IFLQB1,PXAQQ,PYAQQ, 
     *PXBV1,PYBV1,1.-XAQQ,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      GO TO 953 
941   AMQ21=AMQUA1 
      AMQ22=AMQUB1 
      CALL XCORR(IFLQA1,IFLQB1,PXAV1,PYAV1, 
     *PXBV1,PYBV1,XAVAL1,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQQB 
      CALL XCORR(IFAQQ,IFBQQ,PXAQQ,PYAQQ, 
     *PXBQQ,PYBQQ,1.-XAQQ,1.-XBQQ, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      GO TO 953 
951   CONTINUE 
      AMQ21=AMQUA1 
      AMQ22=AMQUB1 
      CALL XCORR(IFLQA1,IFLQB1,PXAV1,PYAV1, 
     *PXBV1,PYBV1,XAVAL1,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQUA2 
      AMQ22=AMQQB 
      CALL XCORR(IFLQA2,IFBQQ,PXAV2,PYAV2, 
     *PXBQQ,PYBQQ,XAVAL2,1.-XBQQ, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      IDENT(NPTCL)=IFAHQ 
      IDCAY(NPTCL)=0 
      PPTCL(1,NPTCL)=PXAQQ 
      PPTCL(2,NPTCL)=PYAQQ 
      PPTCL(3,NPTCL)=(1.-XAQQ)*P0 
      PPTCL(5,NPTCL)=AMASS(IDENT(NPTCL)) 
      PPTCL(4,NPTCL)=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+ 
     *PPTCL(2,NPTCL)**2+PPTCL(3,NPTCL)**2) 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=PPTCL(4,NPTCL)/XAP 
      AMT=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+PPTCL(2,NPTCL)**2) 
      PPTCL(9,NPTCL)=DSQRT(2.D0)*AMT/XAP*PPTCL(4,NPTCL)/PPTCL(5,NPTCL) 
      PLIDER(NPTCL)=0. 
      GO TO 953 
952   CONTINUE 
      AMQ21=AMQUA1 
      AMQ22=AMQUB2 
      CALL XCORR(IFLQA1,IFLQB2,PXAV1,PYAV1, 
     *PXBV2,PYBV2,XAVAL1,XBVAL2, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQUB1 
      CALL XCORR(IFAQQ,IFLQB1,PXAQQ,PYAQQ, 
     *PXBV1,PYBV1,1.-XAQQ,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      IDENT(NPTCL)=IFBHQ 
      IDCAY(NPTCL)=0 
      PPTCL(1,NPTCL)=PXBQQ 
      PPTCL(2,NPTCL)=PYBQQ 
      PPTCL(3,NPTCL)=(1.-XBQQ)*P0*PSIGN 
      PPTCL(5,NPTCL)=AMASS(IDENT(NPTCL)) 
      PPTCL(4,NPTCL)=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+ 
     *PPTCL(2,NPTCL)**2+PPTCL(3,NPTCL)**2) 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=PPTCL(4,NPTCL)/XAP 
      AMT=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+PPTCL(2,NPTCL)**2) 
      PPTCL(9,NPTCL)=DSQRT(2.D0)*AMT/XAP*PPTCL(4,NPTCL)/PPTCL(5,NPTCL) 
      PLIDER(NPTCL)=0. 
953   NFIN1=NPTCL 
      DO 750 J=NIN1,NFIN1 
      IORIG(J)=7+10*NCOL 
750   CONTINUE 
      GO TO 86 
815   IF(NPOMB.EQ.1.AND.NDIFB.EQ.1) GO TO 955 
      IF(IFLQB1.GT.0) GO TO 943 
      AMQ21=AMQUA1 
      AMQ22=AMQUB1 
      CALL XCORR(IFLQA1,IFLQB1,PXAV1,PYAV1, 
     *PXBV1,PYBV1,XAVAL1,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQQB 
      CALL XCORR(IFAQQ,IFBQQ,PXAQQ,PYAQQ, 
     *PXBQQ,PYBQQ,1.-XAQQ,1.-XBQQ, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      GO TO 956 
943   AMQ21=AMQUA1 
      AMQ22=AMQQB 
      CALL XCORR(IFLQA1,IFBQQ,PXAV1,PYAV1, 
     1PXBQQ,PYBQQ,XAVAL1,1.-XBQQ, 
     2PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQUB1 
      CALL XCORR(IFAQQ,IFLQB1,PXAQQ, 
     1PYAQQ,PXBV1,PYBV1,1.-XAQQ,XBVAL1, 
     2PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      GO TO 956 
955   CONTINUE 
      AMQ21=AMQUA1 
      AMQ22=AMQUB1 
      CALL XCORR(IFLQA1,IFLQB1,PXAV1,PYAV1, 
     *PXBV1,PYBV1,XAVAL1,XBVAL1, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQUB2 
      CALL XCORR(IFAQQ,IFLQB2,PXAQQ,PYAQQ, 
     *PXBV2,PYBV2,1.-XAQQ,XBVAL2, 
     *PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      NPTCL=NPTCL+1 
      IF(NPTCL.GT.MXPTCL) GO TO 9999 
      IDENT(NPTCL)=IFBHQ 
      IDCAY(NPTCL)=0 
      PPTCL(1,NPTCL)=PXBQQ 
      PPTCL(2,NPTCL)=PYBQQ 
      PPTCL(3,NPTCL)=(1.-XBQQ)*P0*PSIGN 
      PPTCL(5,NPTCL)=AMASS(IDENT(NPTCL)) 
      PPTCL(4,NPTCL)=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+ 
     *PPTCL(2,NPTCL)**2+PPTCL(3,NPTCL)**2) 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=PPTCL(4,NPTCL)/XAP 
      AMT=DSQRT(PPTCL(5,NPTCL)**2+PPTCL(1,NPTCL)**2+PPTCL(2,NPTCL)**2) 
      PPTCL(9,NPTCL)=DSQRT(2.D0)*AMT/XAP*PPTCL(4,NPTCL)/PPTCL(5,NPTCL) 
      PLIDER(NPTCL)=0. 
956   NFIN1=NPTCL 
      DO 700 J=NIN1,NFIN1 
      IORIG(J)=7+10*NCOL 
700   CONTINUE 
      GO TO 86 
C     DECAY OF VALENCE-VALENCE CHAINS IN 
C         ANNIHILATION CASE: 
 914  AMQ21=AMQUA1 
      AMQ22=AMQUB1 
      CALL XCORR(IFLQA1,IFLQB1,PXAV1,PYAV1,PXBV1,PYBV1, 
     *   XAVAL1,XBVAL1,PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQUA2 
      AMQ22=AMQUB2 
      CALL XCORR(IFLQA2,IFLQB2,PXAV2,PYAV2,PXBV2,PYBV2, 
     * XAVAL2,XBVAL2,PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      AMQ21=AMQQA 
      AMQ22=AMQQB 
      CALL XCORR(IFAQQ,IFBQQ,PXAQQ,PYAQQ,PXBQQ,PYBQQ, 
     * XAQQ,XBQQ,PSIGN,NPRODS,RETU) 
      IF(RETU) GO TO 1111 
      IF(NUNCY.EQ.1) NUNC=NUNC+1 
      NFIN1=NPTCL 
      DO 950 J=NIN1,NFIN1 
      IORIG(J)=7+10*NCOL 
      IF(DIQAN) IORIG(J)=5+10*(NCOL+2) 
 950  CONTINUE 
86    CONTINUE 
      NFIN=NPTCL 
      DO 861 J=NIN,NFIN 
861   IORDP(J)=0 
      CALL RESCAL(NIN,NFIN,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) RETURN 
      GO TO 1111 
9999  WRITE(ITLIS,9998) SCM,NPTCL 
9998  FORMAT(//10X,'...STOP IN CHAINS..ENERGY TOO LOW SCM=',E10.4/ 
     *10X,26H..OR NPTCL TOO HIGH NPTCL=,I5) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE REGTRI(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C      COMPUTE TRIPLE REGGEON DIAGRAM 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMLID/PLIDER(499) 
      COMMON /PARCUT/ SWMAX 
      COMMON/CONST/PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/COMASS/ AM1,AM2 
      COMMON/PRIMP0/ P0 
      COMMON/COLRET/ LRET 
      LOGICAL LRET 
      DIMENSION V(3) 
      DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      LOGICAL BACK 
      LOGICAL RETU 
      LOGICAL SPINT 
      LOGICAL DIQQ 
C    INITIALIZE 
      NREP=0 
      IPACK=1000 
      PARBE=0.3 
      IRET=0 
      IF(ECM.GT.AM1+AM2+   PARBE) 
     *GO TO 150 
      IRET=1 
      GO  TO  9999 
150   SPINT=.FALSE. 
      DIQQ=.FALSE. 
      RETU=.FALSE. 
      BACK=.TRUE. 
      NREP=NREP+1 
      IF(NREP.LE.NTRIES) GO TO 102 
      IRET=1 
C     WRITE(ITLIS,1200) NREP 
1200  FORMAT(3X,' IN REGTRI NREP GT ',I8) 
      RETURN 
102   CONTINUE 
      IRET=0 
      PSIGN=-1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      CALL FLAVOB(IKA,IFL01,IFL02) 
      CALL FLAVOB(IKB,IFL03,IFL04) 
      IFL1=IFL01 
      IFL2=IFL02 
      IFL3=IFL03 
      IFL4=IFL04 
      RND=RNDMD(-1) 
C   COMPUTE X VALUES FOR PARTONS 
      IBB=IB(IKB) 
      ISB=IS(IKB) 
      X3=XDIST(XMIN,IBB,ISB,IFL03) 
      X4=1.-X3 
      IBA=IB(IKA) 
      ISA=IS(IKA) 
      IFL01S=IFL01 
      IF(ISA.NE.0.AND.IBA.EQ.0.AND.IABS(IFL01).EQ.3) IFL01S=IFL2 
      X1=XDIST(XMIN,IBA,ISA,IFL01S) 
      X2=1.-X1 
C    COMPUTE PT VALUES FOR PARTONS 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT1,SIGMA) 
      AMZER2=AMA**2 
      PZER2=P0**2 
      AMQ21=AMZER2*(AMZER2+4.*X1*X2*PZER2)/(4.*(AMZER2+PZER2))-PT1**2 
      PX1=PT1*DCOS(PHI) 
      PY1=PT1*DSIN(PHI) 
      PX2=-PX1 
      PY2=-PY1 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT3,SIGMA) 
      AMZER2=AMB**2 
      AMQ22=AMZER2*(AMZER2+4.*X3*X4*PZER2)/(4.*(AMZER2+PZER2))-PT3**2 
      PX3=PT3*DCOS(PHI) 
      PY3=PT3*DSIN(PHI) 
      PX4=-PX3 
      PY4=-PY3 
C    IS THERE ANTIDIQUARK 
      IF(IBB.GT.0.AND.MOD(IFL2,100).EQ.0.AND.IFL2.LT.0) GO TO 140 
      IF(IBB.GT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.GT.0) GO TO 140 
      IF(IBB.LT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 140 
      PXH=PX1+PX4 
      PYH=PY1+PY4 
      X01=1. 
      X02=X3 
      PX01=PX2 
      PY01=PY2 
      PX02=PX3 
      PY02=PY3 
      IDH=IDPARS(IFL1,IFL4,SPINT,0) 
      AMH=AMASS(IDH) 
      IFL01=IFL2 
      IFL02=IFL3 
      IF(RND.GE.0.5) GO TO 100 
      PXH=PX2+PX3 
      PYH=PY2+PY3 
      X01=X1 
      X02=1. 
      IFL01=IFL1 
      IFL02=IFL4 
      IDH=IDPARS(IFL2,IFL3,SPINT,0) 
      AMH=AMASS(IDH) 
      PX01=PX1 
      PY01=PY1 
      PX02=PX4 
      PY02=PY4 
      GO TO 100 
140   PXH=PX1+PX3 
      PYH=PY1+PY3 
      X01=X2 
      X02=1. 
      IF(MOD(IABS(IFL2),100).NE.0) GO TO 141 
      IF(RNDMD(-1).GT.0.5) GO TO 141 
      X01=1. 
      X02=X4 
141   IDH=IDPARS(IFL1,IFL3,SPINT,0) 
      AMH=AMASS(IDH) 
      IFL01=IFL2 
      IFL02=IFL4 
      PX01=PX2 
      PY01=PY2 
      PX02=PX4 
      PY02=PY4 
      IF(MOD(IABS(IFL2),100).EQ.0) GO TO 101 
      IF(RND.GE.0.5) GO TO 100 
      PXH=PX2+PX4 
      PYH=PY2+PY4 
      X01=1. 
      X02=X3 
      IDH=IDPARS(IFL2,IFL4,SPINT,0) 
      IFL01=IFL1 
      IFL02=IFL3 
      AMH=AMASS(IDH) 
      PX01=PX1 
      PY01=PY1 
      PX02=PX3 
      PY02=PY3 
      GO TO 100 
101   DIQQ=.TRUE. 
      IFCN=1 
      IF(RNDMD(-1).GT.0.5) IFCN=2 
      IFLC1=-IFCN 
      IF(IFL01.GT.0) IFLC1=IFCN 
      IFLC2=-IFLC1 
      IKH1=IDPARS(IFL01,IFLC1,SPINT,2) 
      IKHR1=IDPARS(IFL01,IFLC1,SPINT,1) 
      IKH2=IDPARS(IFL02,IFLC2,SPINT,2) 
      IKHR2=IDPARS(IFL02,IFLC2,SPINT,1) 
      AMHB=AMASS(IKH1)+AMASS(IKH2)+SWMAX 
      AMHS=AMASS(IKHR1)+AMASS(IKHR2)+SWMAX 
100   P01=X01*P0 
      AMQ1=0. 
      AMQ2=0. 
      P02=X02*P0*PSIGN 
      E01=DSQRT(AMQ1**2+P01**2+PX01**2+PY01**2) 
      E02=DSQRT(AMQ2**2+P02**2+PX02**2+PY02**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-(PX01+PX02)**2- 
     *(PY01+PY02)**2 
      SPINT=.TRUE. 
      IF(DIQQ) GO TO 160 
      IDH1=IDPARS(IFL01,IFL02,SPINT,2) 
      PARBE=0.2 
      IF(IABS(IFL01).EQ.3.OR.IABS(IFL02).EQ.3) PARBE=0.3 
      AMHB=AMASS(IDH1)+PARBE 
160   IF(AMDTR.LE.AMHB**2) GO TO 150 
      AMD=DSQRT(AMDTR) 
      IF(ECM.LE.AMD+AMH) GO TO 150 
      ALA=ALAMB(SCM,AMDTR,AMH**2) 
      P0H=DSQRT(ALA)/(2.*ECM) 
      PTHX=-(PX01+PX02) 
      PTHY=-(PY01+PY02) 
      DTRM=P0H**2-PTHX**2-PTHY**2 
      IF(DTRM.LT.0.) GO TO 150 
      PZH0=DSQRT(DTRM) 
      PZH=DSIGN(PZH0,-(P01+P02)) 
      ED=DSQRT(AMDTR+P0H**2) 
      EH=DSQRT(AMH**2+P0H**2) 
      PSIGN=DSIGN(1.D0,-PZH) 
      V(1)=-PTHX/ED 
      V(2)=-PTHY/ED 
      V(3)=PSIGN*PZH0/ED 
      IF(DIQQ) GO TO 170 
      IDHR=IDPARS(IFL01,IFL02,SPINT,1) 
      AMHS=AMASS(IDHR)+SWMAX 
170   IF(AMD.GT.AMHS) GO TO 300 
      NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL CLUSTR(IFL01,IFL02,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      CALL TIFILL(NIN1,NFIN1,AMD,IFL01,IFL02) 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E01,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN1,NFIN1 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
 610  CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
      NPRODS=NPTCL-NFIX 
      GO TO 400 
300   NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL STRING(IFL01,IFL02,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      NPRODS=NPTCL-NFIX 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E01,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PPTCL(1,J) 
      PPX1(2)=PPTCL(2,J) 
      PPX1(3)=PPTCL(3,J) 
      CALL ROTR(CT,ST,CFI,SFI,PPX1,PPX2,BACK) 
      PPTCL(1,J)=PPX2(1) 
      PPTCL(2,J)=PPX2(2) 
      PPTCL(3,J)=PPX2(3) 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
510   CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
400   CONTINUE 
      DO 500 I=NIN1,NFIN1 
      IORDP(I)=0 
500   IORIG(I)=10 
      NPTCL=NPTCL+1 
      PPTCL(1,NPTCL)=PTHX 
      PPTCL(2,NPTCL)=PTHY 
      PPTCL(5,NPTCL)=AMH 
      PPTCL(3,NPTCL)=PZH 
      PPTCL(4,NPTCL)=EH 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IDH 
      IORIG(NPTCL)=10 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=0 
      RETURN 
9999  CONTINUE 
C     WRITE(ITLIS,1000) SCM 
1000  FORMAT(//10X,39H...STOP IN REGTRI...ENERGY TOO LOW SCM=,E10.4) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE UNCYLI(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C      COMPUTE UNDEVELOPED CYLINDER DIAGRAM 
C 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/COMLID/PLIDER(499) 
      COMMON /PARCUT/ SWMAX 
      COMMON/CONST/PI,SQRT2,ALF,GF,UNITS 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/PRIMP0/ P0 
      COMMON/COMASS/ AM1,AM2 
      COMMON/COLRET/ LRET 
      LOGICAL LRET 
      DIMENSION V(3) 
      DIMENSION PPX1(3),PPX2(3),PRX1(3),PRX2(3) 
      LOGICAL BACK 
      LOGICAL RETU 
      LOGICAL SPINT 
      LOGICAL DIQQ 
C    INITIALIZE 
      NREP=0 
      IPACK=1000 
      PARBE=0.3 
      IRET=0 
      IF(ECM.GT.AM1+AM2+PARBE) 
     *GO TO 150 
      IRET=1 
      GO  TO  9999 
150   SPINT=.FALSE. 
      DIQQ=.FALSE. 
      RETU=.FALSE. 
      BACK=.TRUE. 
      PARBE=0.2 
      NREP=NREP+1 
      IF(NREP.LE.NTRIES) GO TO 102 
      IRET=1 
C     WRITE(ITLIS,1200) NREP 
1200  FORMAT(3X,' IN UNCYLI NREP GT ',I8) 
      RETURN 
102   CONTINUE 
      IRET=0 
      PSIGN=-1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      CALL FLAVOB(IKA,IFL01,IFL02) 
      CALL FLAVOB(IKB,IFL03,IFL04) 
      IFL1=IFL01 
      IFL2=IFL02 
      IFL3=IFL03 
      IFL4=IFL04 
      RND=RNDMD(-1) 
C   COMPUTE X VALUES FOR PARTONS 
      IBB=IB(IKB) 
      ISB=IS(IKB) 
      X3=XDIST(XMIN,IBB,ISB,IFL03) 
      X4=1.-X3 
      IBA=IB(IKA) 
      ISA=IS(IKA) 
      IFL01S=IFL01 
      IF(ISA.NE.0.AND.IBA.EQ.0.AND.IABS(IFL01).EQ.3) IFL01S=IFL2 
      X1=XDIST(XMIN,IBA,ISA,IFL01S) 
      X2=1.-X1 
C    COMPUTE PT VALUES FOR PARTONS 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT1,SIGMA) 
      AMZER2=AMA**2 
      PZER2=P0**2 
      AMQ21=AMZER2*(AMZER2+4.*X1*X2*PZER2)/(4.*(AMZER2+PZER2))-PT1**2 
      PX1=PT1*DCOS(PHI) 
      PY1=PT1*DSIN(PHI) 
      PX2=-PX1 
      PY2=-PY1 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT3,SIGMA) 
      AMZER2=AMB**2 
      AMQ22=AMZER2*(AMZER2+4.*X3*X4*PZER2)/(4.*(AMZER2+PZER2))-PT3**2 
      PX3=PT3*DCOS(PHI) 
      PY3=PT3*DSIN(PHI) 
      PX4=-PX3 
      PY4=-PY3 
C    IS THERE ANTIDIQUARK 
      IF(IBB.GT.0.AND.MOD(IFL2,100).EQ.0.AND.IFL2.LT.0) GO TO 140 
      IF(IBB.GT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.GT.0) GO TO 140 
      IF(IBB.LT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 140 
      PXH=PX1+PX4 
      PYH=PY1+PY4 
      X01=X2 
      X02=X3 
      PX01=PX2 
      PY01=PY2 
      PX02=PX3 
      PY02=PY3 
      IDH=IDPARS(IFL1,IFL4,SPINT,0) 
      AMH=AMASS(IDH) 
      IFL01=IFL2 
      IFL02=IFL3 
      IDH1=IDPARS(IFL1,IFL4,SPINT,1) 
      AMH1=AMASS(IDH1) 
      P01=X1*P0 
      P02=X4*P0*PSIGN 
      E01=DSQRT(P01**2+PX1**2+PY1**2) 
      E02=DSQRT(P02**2+PX4**2+PY4**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-PXH**2-PYH**2 
      AMHB=AMH1+PARBE 
      IF(AMDTR.LE.AMHB**2) GO TO 100 
      PXH=PX2+PX3 
      PYH=PY2+PY3 
      X01=X1 
      X02=X4 
      IFL01=IFL1 
      IFL02=IFL4 
      IDH=IDPARS(IFL2,IFL3,SPINT,0) 
      AMH=AMASS(IDH) 
      PX01=PX1 
      PY01=PY1 
      PX02=PX4 
      PY02=PY4 
      IDH1=IDPARS(IFL2,IFL3,SPINT,1) 
      AMH1=AMASS(IDH1) 
      AMHB=AMH1+PARBE 
      P01=X2*P0 
      P02=X3*P0*PSIGN 
      E01=DSQRT(P01**2+PX2**2+PY2**2) 
      E02=DSQRT(P02**2+PX3**2+PY3**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-PXH**2-PYH**2 
      IF(AMDTR.LE.AMHB**2) GO TO 100 
      GO TO 150 
140   PXH=PX1+PX3 
      PYH=PY1+PY3 
      X01=X2 
      X02=X4 
      IDH=IDPARS(IFL1,IFL3,SPINT,0) 
      AMH=AMASS(IDH) 
      IFL01=IFL2 
      IFL02=IFL4 
      PX01=PX2 
      PY01=PY2 
      PX02=PX4 
      PY02=PY4 
      IDH1=IDPARS(IFL1,IFL3,SPINT,1) 
      AMH1=AMASS(IDH1) 
      AMHB=AMH1+PARBE 
      P01=X1*P0 
      P02=X3*P0*PSIGN 
      E01=DSQRT(P01**2+PX1**2+PY1**2) 
      E02=DSQRT(P02**2+PX3**2+PY3**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-PXH**2-PYH**2 
      IF(AMDTR.LE.AMHB**2.AND.MOD(IABS(IFL2),100).EQ.0) GO TO 101 
      IF(AMDTR.LE.AMHB**2) GO TO 100 
      IF(MOD(IFL2,100).EQ.0.AND.MOD(IFL4,100).EQ.0) GO TO 150 
      PXH=PX2+PX4 
      PYH=PY2+PY4 
      X01=X1 
      X02=X3 
      IDH=IDPARS(IFL2,IFL4,SPINT,0) 
      IFL01=IFL1 
      IFL02=IFL3 
      AMH=AMASS(IDH) 
      PX01=PX1 
      PY01=PY1 
      PX02=PX3 
      PY02=PY3 
      IDH1=IDPARS(IFL2,IFL4,SPINT,1) 
      AMH1=AMASS(IDH1) 
      AMHB=AMH1+PARBE 
      P01=X2*P0 
      P02=X4*P0*PSIGN 
      E01=DSQRT(P01**2+PX2**2+PY2**2) 
      E02=DSQRT(P02**2+PX4**2+PY4**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-PXH**2-PYH**2 
      IF(AMDTR.LE.AMHB**2) GO TO 100 
      GO TO 150 
101   DIQQ=.TRUE. 
      IFCN=1 
      IF(RNDMD(-1).GT.0.5) IFCN=2 
      IFLC1=-IFCN 
      IF(IFL01.GT.0) IFLC1=IFCN 
      IFLC2=-IFLC1 
      IKH1=IDPARS(IFL01,IFLC1,SPINT,2) 
      IKHR1=IDPARS(IFL01,IFLC1,SPINT,1) 
      IKH2=IDPARS(IFL02,IFLC2,SPINT,2) 
      IKHR2=IDPARS(IFL02,IFLC2,SPINT,1) 
      AMHB=AMASS(IKH1)+AMASS(IKH2)+SWMAX 
      AMHS=AMASS(IKHR1)+AMASS(IKHR2)+SWMAX 
100   P01=X01*P0 
      AMQ1=0. 
      AMQ2=0. 
      P02=X02*P0*PSIGN 
      E01=DSQRT(AMQ1**2+P01**2+PX01**2+PY01**2) 
      E02=DSQRT(AMQ2**2+P02**2+PX02**2+PY02**2) 
      AMDTR=(E01+E02)**2-(P01+P02)**2-(PX01+PX02)**2- 
     *(PY01+PY02)**2 
      SPINT=.TRUE. 
      IF(DIQQ) GO TO 160 
      IDH1=IDPARS(IFL01,IFL02,SPINT,2) 
      PARBE=0.2 
      IF(IABS(IFL01).EQ.3.OR.IABS(IFL02).EQ.3) PARBE=0.3 
      AMHB=AMASS(IDH1)+PARBE 
160   IF(AMDTR.LE.AMHB**2) GO TO 150 
      AMD=DSQRT(AMDTR) 
      IF(ECM.LE.AMD+AMH) GO TO 150 
      ALA=ALAMB(SCM,AMDTR,AMH**2) 
      P0H=DSQRT(ALA)/(2.*ECM) 
      PTHX=-(PX01+PX02) 
      PTHY=-(PY01+PY02) 
      DTRM=P0H**2-PTHX**2-PTHY**2 
      IF(DTRM.LT.0.) GO TO 150 
      PZH0=DSQRT(DTRM) 
      PZH=DSIGN(PZH0,-(P01+P02)) 
      ED=DSQRT(AMDTR+P0H**2) 
      EH=DSQRT(AMH**2+P0H**2) 
      PSIGN=DSIGN(1.D0,-PZH) 
      V(1)=-PTHX/ED 
      V(2)=-PTHY/ED 
      V(3)=PSIGN*PZH0/ED 
      IF(DIQQ) GO TO 170 
      IDHR=IDPARS(IFL01,IFL02,SPINT,1) 
      AMHS=AMASS(IDHR)+SWMAX 
170   IF(AMD.GT.AMHS) GO TO 300 
      NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL CLUSTR(IFL01,IFL02,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      CALL TIFILL(NIN1,NFIN1,AMD,IFL01,IFL02) 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E01,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 610 J=NIN1,NFIN1 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
610   CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
      NPRODS=NPTCL-NFIX 
      GO TO 400 
300   NFIX=NPTCL 
      NIN1=NPTCL+1 
      CALL STRING(IFL01,IFL02,AMD) 
      IF(LRET) GO TO 150 
      NFIN1=NPTCL 
      NPRODS=NPTCL-NFIX 
      PPX1(1)=PX01 
      PPX1(2)=PY01 
      PPX1(3)=P01 
      BACK=.FALSE. 
      CALL LORLC(V,PPX1,E01,BACK) 
      CALL ANGLE(PPX1,CT,ST,CFI,SFI) 
      DO 510 J=NIN1,NFIN1 
      PPX1(1)=PPTCL(1,J) 
      PPX1(2)=PPTCL(2,J) 
      PPX1(3)=PPTCL(3,J) 
      CALL ROTR(CT,ST,CFI,SFI,PPX1,PPX2,BACK) 
      PPTCL(1,J)=PPX2(1) 
      PPTCL(2,J)=PPX2(2) 
      PPTCL(3,J)=PPX2(3) 
      PRX1(1)=PPTCL(6,J) 
      PRX1(2)=PPTCL(7,J) 
      PRX1(3)=PPTCL(8,J) 
      CALL ROTR(CT,ST,CFI,SFI,PRX1,PRX2,BACK) 
      PPTCL(6,J)=PRX2(1) 
      PPTCL(7,J)=PRX2(2) 
      PPTCL(8,J)=PRX2(3) 
510   CONTINUE 
      BACK=.TRUE. 
      CALL LORTR(V,NIN1,NFIN1,BACK) 
      CALL LORCO(V,NIN1,NFIN1,BACK) 
400   CONTINUE 
      DO 500 I=NIN1,NFIN1 
      IORDP(I)=0 
      IORIG(I)=3 
500   CONTINUE 
      NPTCL=NPTCL+1 
      PPTCL(1,NPTCL)=PTHX 
      PPTCL(2,NPTCL)=PTHY 
      PPTCL(5,NPTCL)=AMH 
      PPTCL(3,NPTCL)=PZH 
      PPTCL(4,NPTCL)=EH 
      PPTCL(6,NPTCL)=0. 
      PPTCL(7,NPTCL)=0. 
      PPTCL(8,NPTCL)=0. 
      PPTCL(9,NPTCL)=0. 
      PLIDER(NPTCL)=1. 
      IDENT(NPTCL)=IDH 
      IORIG(NPTCL)=3 
      IDCAY(NPTCL)=0 
      IORDP(NPTCL)=0 
      RETURN 
9999  CONTINUE 
C     WRITE(ITLIS,1000) SCM 
1000  FORMAT(//10X,39H...STOP IN UNCYLI...ENERGY TOO LOW SCM=,E10.4) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE CYLIN(IRET) 
      IMPLICIT REAL*8 (A-H,O-Z) 
C 
C     COMPUTE CYLINDER TYPE DIAGRAM 
C 
      COMMON/CONST/PI,SQRT2,ALF,GF,UNITS 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON /PARCUT/ SWMAX 
      COMMON/PRIMAR/SCM,HALFE,ECM,NJET,IDIN(2),NEVENT,NTRIES 
      COMMON/COMXM/ XMIN,XMAX 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/PARORD/ IORDP(499) 
      COMMON/COMIND/ PUD,SIGMA,ALFA,BETA 
      COMMON/MASQUA/ AMQ21,AMQ22 
      COMMON/NEEDR/ NRET 
      COMMON/COMASS/ AM1,AM2 
      COMMON/PRIMP0/ P0 
      DIMENSION PSUM(5) 
      LOGICAL RETU 
C   INITIALIZE 
      IPACK=1000 
      NRET=1 
      NREP=0 
      PARBE=0.3 
      IF(ECM.GT.AM1+AM2+   PARBE) GO TO 999 
      IRET=1 
      GO  TO  9999 
999   CONTINUE 
      DO 151 I=1,3 
 151  PSUM(I)=0. 
      PSUM(4)=ECM 
      PSUM(5)=ECM 
100   IRET=0 
      NREP=NREP+1 
      IF(NREP.LT.NTRIES) GO TO 101 
      IRET=1 
      RETURN 
101   CONTINUE 
      RETU=.FALSE. 
      PSIGN=-1. 
      IKA=IDIN(1) 
      IKB=IDIN(2) 
      AMA=AM1 
      AMB=AM2 
      AMQ21=0. 
      AMQ22=0. 
      CALL FLAVOB(IKA,IFL01,IFL02) 
      CALL FLAVOB(IKB,IFL03,IFL04) 
      IFL1=IFL01 
      IFL2=IFL02 
      IFL3=IFL03 
      IFL4=IFL04 
C   COMPUTE X VALUES FOR PARTONS 
      IBA=IB(IKA) 
      ISA=IS(IKA) 
      IFL01S=IFL01 
      IF(ISA.NE.0.AND.IBA.EQ.0.AND.IABS(IFL01).EQ.3) IFL01S=IFL2 
      X1=XDIST(XMIN,IBA,ISA,IFL01S) 
      X2=1.-X1 
      IBB=IB(IKB) 
      ISB=IS(IKB) 
      X3=XDIST(XMIN,IBB,ISB,IFL03) 
      X4=1.-X3 
      IF(IBA.EQ.0.AND.IBB.EQ.0) NRET=0 
C   COMPUTE PT VALUES FOR PARTONS 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT1,SIGMA) 
      AMZER2=AMA**2 
      PZER2=P0**2 
      AMQ21=AMZER2*(AMZER2+4.*X1*X2*PZER2)/(4.*(AMZER2+PZER2))-PT1**2 
      PX1=PT1*DCOS(PHI) 
      PY1=PT1*DSIN(PHI) 
      PX2=-PX1 
      PY2=-PY1 
      PHI=2.*PI*RNDMD(-1) 
      CALL GAUSPT(PT3,SIGMA) 
      AMZER2=AMB**2 
      AMQ22=AMZER2*(AMZER2+4.*X3*X4*PZER2)/(4.*(AMZER2+PZER2))-PT3**2 
      PX3=PT3*DCOS(PHI) 
      PY3=PT3*DSIN(PHI) 
      PX4=-PX3 
      PY4=-PY3 
C    IS THERE ANTIDIQUARK 
      NIN1=NPTCL+1 
      IF(IBB.GT.0.AND.MOD(IFL2,100).EQ.0.AND.IFL2.GT.0) GO TO 150 
      IF(IBB.GT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.LT.0) GO TO 150 
      IF(IBB.LT.0.AND.IBA.LT.0) GO TO 150 
      IF(IBB.LT.0.AND.MOD(IFL2,100).NE.0.AND.IFL2.GT.0) GO TO 150 
      IF(.NOT.(IBA.EQ.0.AND.IBB.EQ.0)) GO TO 160 
      IF(IFL1*IFL3.GT.0) GO TO 150 
160   CALL XCORR(IFL1,IFL3,PX1,PY1,PX3,PY3,X1,X3, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 100 
      CALL XCORR(IFL2,IFL4,PX2,PY2,PX4,PY4,X2,X4, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 130 
      NPTCL=NPTCL-NPRD 
      GO TO 100 
130   NFIN1=NPTCL 
      DO 550 I=NIN1,NFIN1 
550   IORIG(I)=7 
C@@@@@@@@ 14.08.91   SIVOKL 
      CALL RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) RETURN 
      NPTCL=NPTCL-NPRD 
      GO TO 100 
C*@@@ RETURN 
150   CALL XCORR(IFL1,IFL4,PX1,PY1,PX4,PY4,X1,X4, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRODS 
      IF(RETU) GO TO 100 
      CALL XCORR(IFL2,IFL3,PX2,PY2,PX3,PY3,X2,X3, 
     *PSIGN,NPRODS,RETU) 
      NPRD=NPRD+NPRODS 
      IF(.NOT.RETU) GO TO 140 
      NPTCL=NPTCL-NPRD 
      GO TO 100 
140   NFIN1=NPTCL 
      DO 500 I=NIN1,NFIN1 
      IORDP(I)=0 
500   IORIG(I)=7 
      CALL RESCAL(NIN1,NFIN1,PSUM,IFAIL) 
      IF(IFAIL.EQ.0) RETURN 
      NPTCL=NPTCL-NPRD 
      GO TO 100 
9999  CONTINUE 
C     WRITE(ITLIS,1000) SCM 
1000  FORMAT(//10X,'...STOP IN CYLIN..ENERGY TOO LOW SCM=',E10.4) 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE TIFILL(N1,N2,AMS,IFL1,IFL2) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMS 
C----  COMPUTE ZI Z-COORD. & TI TIME OF HADRONS AFTER CLUSTER DECAY 
      COMMON/PARTCL/PPTCL(9,499),NPTCL,IORIG(499),IDENT(499) 
     *,IDCAY(499) 
      COMMON/KAPPA/XAP 
      COMMON /CINSID/ INSIDE 
      COMMON/COMLID/PLIDER(499) 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL QSEE,QVSEE 
      IF(INSIDE.NE.0)   GO  TO  1 
C-----  CONSTITUENT   TIME -----------------C 
      TI=(AMS-2.*PPTCL(3,N1))/(2.*XAP) 
      ZI=(AMS-2.*PPTCL(4,N1))/(2.*XAP) 
      PPTCL(6,N1)=0. 
      PPTCL(7,N1)=0. 
      PPTCL(8,N1)=ZI 
      PPTCL(9,N1)=TI 
      PPTCL(6,N2)=0. 
      PPTCL(7,N2)=0. 
      PPTCL(8,N2)=ZI 
      PPTCL(9,N2)=TI 
      GO  TO  2 
   1  CONTINUE 
C-----  INSIDE - OUTSIDE TIME -----------------C 
      T1=(AMS+PPTCL(4,N1)-PPTCL(3,N1))/(2.*XAP) 
      T2=(AMS-2.*PPTCL(3,N1)+PPTCL(4,N2)-PPTCL(3,N2))/(2.*XAP) 
      Z1=(AMS-PPTCL(4,N1)+PPTCL(3,N1))/(2.*XAP) 
      Z2=(AMS-2.*PPTCL(4,N1)-PPTCL(4,N2)+PPTCL(3,N2))/(2.*XAP) 
      PPTCL(6,N1)=0. 
      PPTCL(7,N1)=0. 
      PPTCL(8,N1)=Z1 
      PPTCL(9,N1)=T1 
      PPTCL(6,N2)=0. 
      PPTCL(7,N2)=0. 
      PPTCL(8,N2)=Z2 
      PPTCL(9,N2)=T2 
   2  CONTINUE 
C-------------------------------------------C 
      PLIDER(N1)=0. 
      PLIDER(N2)=0. 
      IF(QSEE) RETURN 
      IB1=IB(IDENT(N1)) 
      IB2=IB(IDENT(N2)) 
      PLIDER(N1)=.667 
      PLIDER(N2)=.667 
      IF(IB1.EQ.0) PLIDER(N1)=.5 
      IF(IB2.EQ.0) PLIDER(N2)=.5 
      IF(PLIDER(N1).GT.0.6.AND.MOD(IFL1,100).NE.0) PLIDER(N1)=0.333 
      IF(PLIDER(N2).GT.0.6.AND.MOD(IFL2,100).NE.0) PLIDER(N2)=0.333 
      IF(.NOT.QVSEE) RETURN 
      IF(IB1.EQ.0.AND.IB2.EQ.0) GO TO 387 
      IF(IB1.EQ.0) PLIDER(N1)=0. 
      IF(IB2.EQ.0) PLIDER(N2)=0. 
      IF(PLIDER(N1).GT.0.6.AND.MOD(IFL1,100).NE.0) PLIDER(N1)=0.333 
      IF(PLIDER(N2).GT.0.6.AND.MOD(IFL2,100).NE.0) PLIDER(N2)=0.333 
      RETURN 
387   RM=RNDMD(-1) 
      IF(RM.GT.0.5) PLIDER(N1)=0. 
      IF(RM.LE.0.5) PLIDER(N2)=0. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE TIFILE(N1,N2,AMS) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      REAL*8 AMS 
C----  COMPUTE ZI Z-COORD. & TI TIME OF HADRONS AFTER CLUSTER DECAY 
      COMMON /PROD/ PR(8,50),IPR(50),NP 
      COMMON/KAPPA/XAP 
      COMMON /CINSID/ INSIDE 
      COMMON/COMLD/PLDER(50) 
      COMMON/COMQSE/QSEE,QVSEE 
      LOGICAL QSEE,QVSEE 
      IF(INSIDE.NE.0)  GO  TO  1 
C-----  CONSTITUENT      TIME -----------------C 
      TI=(AMS-2.*PR(3,N1))/(2.*XAP) 
      ZI=(AMS-2.*PR(4,N1))/(2.*XAP) 
      PR(5,N1)=0. 
      PR(6,N1)=0. 
      PR(7,N1)=ZI 
      PR(8,N1)=TI 
      PR(5,N2)=0. 
      PR(6,N2)=0. 
      PR(7,N2)=ZI 
      PR(8,N2)=TI 
      GO  TO  2 
C-----  INSIDE - OUTSIDE TIME -----------------C 
   1  CONTINUE 
      T1=(AMS+PR(4,N1)-PR(3,N1))/(2.*XAP) 
      T2=(AMS-2.*PR(3,N1)+PR(4,N2)-PR(3,N2))/(2.*XAP) 
      Z1=(AMS-PR(4,N1)+PR(3,N1))/(2.*XAP) 
      Z2=(AMS-2.*PR(4,N1)-PR(4,N2)+PR(3,N2))/(2.*XAP) 
      PR(5,N1)=0. 
      PR(6,N1)=0. 
      PR(7,N1)=Z1 
      PR(8,N1)=T1 
      PR(5,N2)=0. 
      PR(6,N2)=0. 
      PR(7,N2)=Z2 
      PR(8,N2)=T2 
   2  CONTINUE 
C-----------------------------------------------C 
      IB1=IBLE(IPR(N1)) 
      IB2=IBLE(IPR(N2)) 
      PLDER(N1)=.667 
      PLDER(N2)=.667 
      IF(IB1.EQ.0) PLDER(N1)=.5 
      IF(IB2.EQ.0) PLDER(N2)=.5 
      IF(.NOT.QVSEE) RETURN 
      IF(IB1.EQ.0.AND.IB2.EQ.0) GO TO 387 
      IF(IB1.EQ.0) PLDER(N1)=0. 
      IF(IB2.EQ.0) PLDER(N2)=0. 
      RETURN 
387   RM=RNDMD(-1) 
      IF(RM.GT.0.5) PLDER(N1)=0. 
      IF(RM.LE.0.5) PLDER(N2)=0. 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
      SUBROUTINE SETCON 
      IMPLICIT REAL*8 (A-H,O-Z) 
C          THIS SUBROUTINE SETS THE CONSTANTS IN /CONST/. 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/CONST/PI,SQRT2,ALF,GF,UNITS 
      PI=4.*DATAN(1.0D0) 
      SQRT2=DSQRT(2.0D0) 
      ALF=1./137.036 
      GF=1.16570D-5 
      UNITS=1./2.56815 
      RETURN 
      END 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
C Changed by A.Timofeev at 19/07/2011 15:25
C 
C The decay database is implemented in C code
      SUBROUTINE SETDKY(LPRINT) 
      IMPLICIT REAL*8 (A-H,O-Z) 
      CHARACTER*4 IQUIT 
      CHARACTER*8 IBLANK,LREAD(10),LMODE(6),LRES 
C          THIS SUBROUTINE READS IN THE DECAY TABLE FROM TAPE ITDKY 
C          AND SETS UP /DKYTAB/. 
C          QUARK-BASED IDENT CODE 
      COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS 
      COMMON/FORCE/NFORCE,IFORCE(20),MFORCE(5,20) 
C     LOOK MUST BE DIMENSIONED TO THE MAXIMUM VALUE OF INDEX 
      COMMON/DKYTAB/LOOK(400),CBR(600),MODE(5,600) 
      LOGICAL NODCAY,NOETA,NOPI0,NONUNU,NOEVOL,NOHADR,NOKA0 
      COMMON/NODCAY/NODCAY,NOETA,NOPI0,NONUNU,NOEVOL,NOHADR,NOKA0 
C next common block added by A.Timofeev 19/07/2011 15:55
      COMMON /ATABDATA/ IRES1(600),ITYPE1(600),BR1(600),IMODE1(5,600)
      DIMENSION IMODE(6) 
      LOGICAL LPRINT 
      DATA IQUIT/' END'/,IBLANK/'     '/ 
C      IF(LPRINT) WRITE(ITLIS,10) 
C10    FORMAT(1H1,30(1H*)/2H *,28X,1H*/ 
C     1 2H *,5X,17HCOLLI DECAY TABLE,5X,1H*/ 
C     2 2H *,28X,1H*/1X,30(1H*)// 
C     3 6X,4HPART,18X,10HDECAY MODE,19X,6HCUM BR,15X,5HIDENT,17X, 
C     4 11HDECAY IDENT/) 
      LOOP=0 
      IOLD=0 
      DO I=1,400 
      LOOK(I)=0 
      ENDDO
C
      IF(NODCAY) RETURN 
C
c      REWIND ITDKY 

200   LOOP=LOOP+1 
      IF(LOOP.GT.600) GO TO 9999 
C
      DO I=1,5 
      IMODE(I)=0 
      LMODE(I)=IBLANK 
      ENDDO 
C
C  Changed by A.Timofeev at 18/07/2011 15:50
C      READ(ITDKY,*,END=300) IRES,ITYPE,BR,(IMODE(I),I=1,5) 
C Reading not from file/tape, but from memory in ATABDATA
      IRES=IRES1(LOOP)
      ITYPE=ITYPE1(LOOP)
      BR=BR1(LOOP)
      DO I=1,5
         IMODE(I)=IMODE1(I,LOOP)
      ENDDO
      IF(IRES.EQ.0) GO TO 300 
      IF(IRES.EQ.IOLD) GO TO 230 
      CALL FLAVOR(IRES,IFL1,IFL2,IFL3,JSPIN,INDEX) 
      LOOK(INDEX)=LOOP 
230   IOLD=IRES 
      CBR(LOOP)=BR 

      DO I=1,5 
      MODE(I,LOOP)=IMODE(I) 
      IF(IMODE(I).NE.0) CALL LABEL(LMODE(I),IMODE(I)) 
      ENDDO

      CALL LABEL(LRES,IRES) 
      GO TO 200 
C          SET FORCED DECAY MODES 
300   IF(NFORCE.EQ.0) GO TO 400 
      DO I=1,NFORCE 
      LOOP=LOOP+1 
      IF(LOOP.GT.600) GO TO 9999 
      CALL FLAVOR(IFORCE(I),IFL1,IFL2,IFL3,JSPIN,INDEX) 
      LOOK(INDEX)=LOOP 
         DO K=1,5 
         MODE(K,LOOP)=MFORCE(K,I) 
         ENDDO
      CBR(LOOP)=1. 
      ENDDO

400   IF(.NOT.LPRINT) RETURN 
 9999 CONTINUE
      RETURN 
      END 
