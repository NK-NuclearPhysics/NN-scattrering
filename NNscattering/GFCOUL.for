
C  **************************************************************      
C                       SUBROUTINE FCOUL                               
C  **************************************************************      
      SUBROUTINE FCOUL(ETA,RLAMB,X,F,FP,G,GP,ERR)                      
C                                                                      
C     CALCULATION OF COULOMB FUNCTIONS FOR REAL ETA, RLAMB.GT.-1       
C  AND X LARGER THAN, OR OF THE ORDER OF XTP0 (THE TURNING POINT       
C  FOR RLAMB=0). STEED'S CONTINUED FRACTION METHOD IS COMBINED         
C  WITH RECURSION RELATIONS AND AN ASYMPTOTIC EXPANSION. THE           
C  OUTPUT VALUE ERR=1.0D0 INDICATES THAT THE ADOPTED EVALUATION        
C  ALGORITHM IS NOT APPLICABLE (X IS TOO SMALL).                       
C                                                                      
C  INPUT ARGUMENTS:                                                    
C     ETA ...... SOMMERFELD'S PARAMETER.                               
C     RLAMB .... ANGULAR MOMENTUM.                                     
C     X ........ VARIABLE (=WAVE NUMBER TIMES RADIAL DISTANCE).        
C                                                                      
C  OUTPUT ARGUMENTS:                                                   
C     F, FP .... REGULAR FUNCTION AND ITS DERIVATIVE.                  
C     G, GP .... IRREGULAR FUNCTION AND ITS DERIVATIVE.                
C     ERR ...... RELATIVE NUMERICAL UNCERTAINTY. A VALUE OF THE        
C                ORDER OF 10**(-N) MEANS THAT THE CALCULATED           
C                FUNCTIONS ARE ACCURATE TO N DECIMAL FIGURES.          
C                THE MAXIMUM ACCURACY ATTAINABLE WITH DOUBLE           
C                PRECISION ARITHMETIC IS ABOUT 1.0D-15.                
C                                                                      
C     OTHER SUBPROGRAMS REQUIRED: SUBROUTINE SUM2F0 AND                
C                                 FUNCTIONS DELTAC AND CLGAM.          
C                                                                      
      IMPLICIT DOUBLE PRECISION (A-B,D-H,O-Z), COMPLEX*16 (C)          
      PARAMETER (PI=3.1415926535897932D0,PIH=0.5D0*PI,TPI=PI+PI,       
     1  EPS=1.0D-16,TOP=1.0D5,NTERM=1000)                              
      COMMON/OFCOUL/DELTA                                              
C                                                                      
      IF(RLAMB.LT.-0.999D0) THEN                                       
        WRITE(6,'(1X,''*** ERROR IN RCOUL: RLAMB.LT.-0.999'')')        
        STOP                                                           
      ENDIF                                                            
      IF(X.LT.EPS) GO TO 10                                            
C                                                                      
C  ****  NUMERICAL CONSTANTS.                                          
C                                                                      
      CI=DCMPLX(0.0D0,1.0D0)                                           
      CI2=2.0D0*CI                                                     
      CIETA=CI*ETA                                                     
      X2=X*X                                                           
      ETA2=ETA*ETA                                                     
C                                                                      
C  ****  TURNING POINT (XTP). (44)                                     
C                                                                      
      IF(RLAMB.GE.0.0D0) THEN                                          
        XTP=ETA+DSQRT(ETA2+RLAMB*(RLAMB+1.0D0))                        
      ELSE                                                             
        XTP=EPS                                                        
      ENDIF                                                            
      ERRS=10.0D0                                                      
      IF(X.LT.XTP) GO TO 1                                             
C                                                                      
C  ************  ASYMPTOTIC EXPANSION. (71-75)                         
C                                                                      
C  ****  COULOMB PHASE-SHIFT.                                          
      DELTA=DELTAC(ETA,RLAMB)                                          
C                                                                      
      CPA=CIETA-RLAMB                                                  
      CPB=CIETA+RLAMB+1.0D0                                            
      CPZ=CI2*X                                                        
      CALL SUM2F0(CPA,CPB,CPZ,C2F0,ERR1)                               
      CQA=CPA+1.0D0                                                    
      CQB=CPB+1.0D0                                                    
      CALL SUM2F0(CQA,CQB,CPZ,C2F0P,ERR2)                              
      C2F0P=CI*C2F0P*CPA*CPB/(2.0D0*X2)                                
C  ****  FUNCTIONS.                                                    
      THETA=X-ETA*DLOG(2.0D0*X)-RLAMB*PIH+DELTA                        
      IF(THETA.GT.1.0D4) THETA=DMOD(THETA,TPI)                         
      CEITH=CDEXP(CI*THETA)                                            
      CGIF=C2F0*CEITH                                                  
      G=CGIF                                                           
      F=-CI*CGIF                                                       
C  ****  DERIVATIVES.                                                  
      CGIFP=(C2F0P+CI*(1.0D0-ETA/X)*C2F0)*CEITH                        
      GP=CGIFP                                                         
      FP=-CI*CGIFP                                                     
C  ****  GLOBAL UNCERTAINTY. THE WRONSKIAN MAY DIFFER FROM 1 DUE       
C        TO TRUNCATION AND ROUNDOFF ERRORS.                            
      ERR=DMAX1(ERR1,ERR2,DABS(G*FP-F*GP-1.0D0))                       
      IF(ERR.LE.EPS) RETURN                                            
      ERRS=ERR                                                         
C                                                                      
C  ************  STEED'S CONTINUED FRACTION METHOD.                    
C                                                                      
    1 CONTINUE                                                         
      CIETA2=CIETA+CIETA                                               
      ETAX=ETA*X                                                       
C                                                                      
C  ****  CONTINUED FRACTION FOR F. (60-70)                             
C                                                                      
      INULL=0                                                          
      RLAMBN=RLAMB+1.0D0                                               
      A1=-(RLAMBN+1.0D0)*(RLAMBN**2+ETA2)*X/RLAMBN                     
      B0=(RLAMBN/X)+(ETA/RLAMBN)                                       
      B1=(2.0D0*RLAMBN+1.0D0)*(RLAMBN*(RLAMBN+1.0D0)+ETAX)             
      FA3=B0                                                           
      FA2=B0*B1+A1                                                     
      FB3=1.0D0                                                        
      FB2=B1                                                           
      RF=FA3                                                           
C                                                                      
      DO 2 N=2,NTERM                                                   
      RFO=RF                                                           
      DAF=DABS(RF)                                                     
      RLAMBN=RLAMB+N                                                   
      AN=-(RLAMBN**2-1.0D0)*(RLAMBN**2+ETA2)*X2                        
      BN=(2.0D0*RLAMBN+1.0D0)*(RLAMBN*(RLAMBN+1.0D0)+ETAX)             
      FA1=FA2*BN+FA3*AN                                                
      FB1=FB2*BN+FB3*AN                                                
      TST=DABS(FB1)                                                    
C                                                                      
      IF(TST.LT.1.0D-25) THEN                                          
        IF(INULL.GT.0) STOP                                            
        INULL=1                                                        
        FA3=FA2                                                        
        FA2=FA1                                                        
        FB3=FB2                                                        
        FB2=FB1                                                        
        RF=RFO                                                         
      ELSE                                                             
        FA3=FA2/TST                                                    
        FA2=FA1/TST                                                    
        FB3=FB2/TST                                                    
        FB2=FB1/TST                                                    
        RF=FA2/FB2                                                     
        IF(DABS(RF-RFO).LT.EPS*DAF) GO TO 3                            
      ENDIF                                                            
    2 CONTINUE                                                         
    3 CONTINUE                                                         
      IF(DAF.GT.1.0D-25) THEN                                          
        ERRF=DABS(RF-RFO)/DAF                                          
      ELSE                                                             
        ERRF=EPS                                                       
      ENDIF                                                            
      IF(ERRF.GT.ERRS) THEN                                            
        ERR=ERRS                                                       
        RETURN                                                         
      ENDIF                                                            
C                                                                      
C  ****  DOWNWARD RECURSION FOR F AND FP. ONLY IF RLAMB.GT.1 AND       
C        X.LT.XTP. (48,49)                                             
C                                                                      
      RLAMB0=RLAMB                                                     
      IF(X.GE.XTP.OR.RLAMB0.LT.1.0D0) THEN                             
        ISHIFT=0                                                       
      ELSE                                                             
        FT=1.0D0                                                       
        FTP=RF                                                         
        IS0=RLAMB0+1.0D-6                                              
        TST=X*(X-2.0D0*ETA)                                            
        DO 4 I=1,IS0                                                   
        ETARL0=ETA/RLAMB0                                              
        RL=DSQRT(1.0D0+ETARL0**2)                                      
        SL=(RLAMB0/X)+ETARL0                                           
        RLAMB0=RLAMB0-1.0D0                                            
        FTO=FT                                                         
        FT=(SL*FT+FTP)/RL                                              
        FTP=SL*FT-RL*FTO                                               
        IF(FT.GT.1.0D10) THEN                                          
          FTP=FTP/FT                                                   
          FT=1.0D0                                                     
        ENDIF                                                          
        RL1T=RLAMB0*(RLAMB0+1.0D0)                                     
        IF(TST.GT.RL1T) THEN                                           
          ISHIFT=I                                                     
          GO TO 5                                                      
        ENDIF                                                          
    4   CONTINUE                                                       
        ISHIFT=IS0                                                     
    5   CONTINUE                                                       
        XTPC=ETA+DSQRT(ETA2+RL1T)                                      
        RFM=FTP/FT                                                     
      ENDIF                                                            
C                                                                      
C  ****  CONTINUED FRACTION FOR P+CI*Q WITH RLAMB0. (76-79)            
C                                                                      
      INULL=0                                                          
      CAN=CIETA-ETA2-RLAMB0*(RLAMB0+1.0D0)                             
      CB0=X-ETA                                                        
      CBN=2.0D0*(X-ETA+CI)                                             
      CFA3=CB0                                                         
      CFA2=CB0*CBN+CAN                                                 
      CFB3=1.0D0                                                       
      CFB2=CBN                                                         
      CPIQ=CFA3                                                        
C                                                                      
      DO 6 N=2,NTERM                                                   
      CPIQO=CPIQ                                                       
      DAPIQ=CDABS(CPIQ)                                                
      CAN=CAN+CIETA2+(N+N-2)                                           
      CBN=CBN+CI2                                                      
      CFA1=CFA2*CBN+CFA3*CAN                                           
      CFB1=CFB2*CBN+CFB3*CAN                                           
      TST=CDABS(CFB1)                                                  
C                                                                      
      IF(TST.LT.1.0D-25) THEN                                          
        IF(INULL.GT.0) STOP                                            
        INULL=1                                                        
        CFA3=CFA2                                                      
        CFA2=CFA1                                                      
        CFB3=CFB2                                                      
        CFB2=CFB1                                                      
        CPIQ=CPIQO                                                     
      ELSE                                                             
        CFA3=CFA2/TST                                                  
        CFA2=CFA1/TST                                                  
        CFB3=CFB2/TST                                                  
        CFB2=CFB1/TST                                                  
        CPIQ=CFA2/CFB2                                                 
        IF(CDABS(CPIQ-CPIQO).LT.EPS*DAPIQ) GO TO 7                     
      ENDIF                                                            
    6 CONTINUE                                                         
    7 CONTINUE                                                         
      IF(DAPIQ.GT.1.0D-25) THEN                                        
        ERRPIQ=CDABS(CPIQ-CPIQO)/DAPIQ                                 
      ELSE                                                             
        ERRPIQ=EPS                                                     
      ENDIF                                                            
      IF(ERRPIQ.GT.ERRS) THEN                                          
        ERR=ERRS                                                       
        RETURN                                                         
      ENDIF                                                            
      CPIQ=CI*CPIQ/X                                                   
C                                                                      
      RP=CPIQ                                                          
      RQ=-CI*CPIQ                                                      
      IF(RQ.LE.1.0D-25) GO TO 10                                       
      ERR=DMAX1(ERRF,ERRPIQ)                                           
C                                                                      
C  ****  INVERTING STEED'S TRANSFORMATION. (57,58)                     
C                                                                      
      IF(ISHIFT.LT.1) THEN                                             
        RFP=RF-RP                                                      
        F=DSQRT(RQ/(RFP**2+RQ**2))                                     
        IF(FB2.LT.0.0D0) F=-F                                          
        FP=RF*F                                                        
        G=RFP*F/RQ                                                     
        GP=(RP*RFP-RQ**2)*F/RQ                                         
        IF(X.LT.XTP.AND.G.GT.TOP*F) GO TO 10                           
      ELSE                                                             
        RFP=RFM-RP                                                     
        FM=DSQRT(RQ/(RFP**2+RQ**2))                                    
        G=RFP*FM/RQ                                                    
        GP=(RP*RFP-RQ**2)*FM/RQ                                        
        IF(X.LT.XTPC.AND.G.GT.TOP*FM) GO TO 10                         
C  ****  UPWARD RECURSION FOR G AND GP (IF ISHIFT.GT.0). (50,51)       
        DO 8 I=1,ISHIFT                                                
        RLAMB0=RLAMB0+1.0D0                                            
        ETARL0=ETA/RLAMB0                                              
        RL=DSQRT(1.0D0+ETARL0**2)                                      
        SL=(RLAMB0/X)+ETARL0                                           
        GO=G                                                           
        G=(SL*GO-GP)/RL                                                
        GP=RL*GO-SL*G                                                  
        IF(G.GT.1.0D35) GO TO 10                                       
    8   CONTINUE                                                       
    9   W=RF*G-GP                                                      
        F=1.0D0/W                                                      
        FP=RF/W                                                        
      ENDIF                                                            
C  ****  THE WRONSKIAN MAY DIFFER FROM 1 DUE TO ROUNDOFF ERRORS.       
      ERR=DMAX1(ERR,DABS(FP*G-F*GP-1.0D0))                             
      RETURN                                                           
C                                                                      
   10 F=0.0D0                                                          
      FP=0.0D0                                                         
      G=1.0D35                                                         
      GP=-1.0D35                                                       
      ERR=1.0D0                                                        
      RETURN                                                           
      END                                                              
C  **************************************************************      
C                       SUBROUTINE SUM2F0                              
C  **************************************************************      
      SUBROUTINE SUM2F0(CA,CB,CZ,CF,ERR)                               
C                                                                      
C     SUMMATION OF THE 2F0(CA,CB;CS) HYPERGEOMETRIC ASYMPTOTIC         
C  SERIES. THE POSITIVE AND NEGATIVE CONTRIBUTIONS TO THE REAL         
C  AND IMAGINARY PARTS ARE ADDED SEPARATELY TO OBTAIN AN ESTIMATE      
C  OF ROUNDING ERRORS.                                                 
C                                                                      
      IMPLICIT DOUBLE PRECISION (A-B,D-H,O-Z), COMPLEX*16 (C)          
      PARAMETER (EPS=1.0D-16,ACCUR=0.5D-15,NTERM=75)                   
      RRP=1.0D0                                                        
      RRN=0.0D0                                                        
      RIP=0.0D0                                                        
      RIN=0.0D0                                                        
      CDF=1.0D0                                                        
      ERR2=0.0D0                                                       
      ERR3=1.0D0                                                       
      DO 1 I=1,NTERM                                                   
      J=I-1                                                            
      CDF=CDF*(CA+J)*(CB+J)/(I*CZ)                                     
      ERR1=ERR2                                                        
      ERR2=ERR3                                                        
      ERR3=CDABS(CDF)                                                  
      IF(ERR1.GT.ERR2.AND.ERR2.LT.ERR3) GO TO 2                        
      AR=CDF                                                           
      IF(AR.GT.0.0D0) THEN                                             
        RRP=RRP+AR                                                     
      ELSE                                                             
        RRN=RRN+AR                                                     
      ENDIF                                                            
      AI=DCMPLX(0.0D0,-1.0D0)*CDF                                      
      IF(AI.GT.0.0D0) THEN                                             
        RIP=RIP+AI                                                     
      ELSE                                                             
        RIN=RIN+AI                                                     
      ENDIF                                                            
      CF=DCMPLX(RRP+RRN,RIP+RIN)                                       
      AF=CDABS(CF)                                                     
      IF(AF.GT.1.0D25) THEN                                            
        CF=0.0D0                                                       
        ERR=1.0D0                                                      
        RETURN                                                         
      ENDIF                                                            
      IF(ERR3.LT.1.0D-25*AF.OR.ERR3.LT.EPS) THEN                       
         ERR=EPS                                                       
         RETURN                                                        
      ENDIF                                                            
    1 CONTINUE                                                         
C  ****  ROUNDOFF ERROR.                                               
    2 CONTINUE                                                         
      TR=DABS(RRP+RRN)                                                 
      IF(TR.GT.1.0D-25) THEN                                           
        ERRR=(RRP-RRN)*ACCUR/TR                                        
      ELSE                                                             
        ERRR=1.0D0                                                     
      ENDIF                                                            
      TI=DABS(RIP+RIN)                                                 
      IF(TI.GT.1.0D-25) THEN                                           
        ERRI=(RIP-RIN)*ACCUR/TI                                        
      ELSE                                                             
        ERRI=1.0D0                                                     
      ENDIF                                                            
C  ****  ... AND TRUNCATION ERROR.                                     
      IF(AR.GT.1.0D-25) THEN                                           
      ERR=DMAX1(ERRR,ERRI)+ERR2/AF                                     
      ELSE                                                             
      ERR=DMAX1(ERRR,ERRI)                                             
      ENDIF                                                            
      RETURN                                                           
      END                                                              
C  **************************************************************      
C                         FUNCTION DELTAC                              
C  **************************************************************      
      FUNCTION DELTAC(ETA,RLAMB)                                       
C                                                                      
C     CALCULATION OF COULOMB PHASE SHIFT (MODULUS 2*PI). (47)          
C                                                                      
      IMPLICIT DOUBLE PRECISION (A-B,D-H,O-Z), COMPLEX*16 (C)          
      PARAMETER (PI=3.1415926535897932D0,TPI=PI+PI)                    
      CI=DCMPLX(0.0D0,1.0D0)                                           
C  ****  COULOMB PHASE-SHIFT.                                          
      DELTAC=-CI*CLGAM(RLAMB+1.0D0+CI*ETA)                             
      IF(DELTAC.GE.0.0D0) THEN                                         
        DELTAC=DMOD(DELTAC,TPI)                                        
      ELSE                                                             
        DELTAC=-DMOD(-DELTAC,TPI)                                      
      ENDIF                                                            
      RETURN                                                           
      END                                                              
C  **************************************************************      
C                       FUNCTION CLGAM                                 
C  **************************************************************      
      FUNCTION CLGAM(CZ)                                               
C                                                                      
C     THIS FUNCTION GIVES LOG(GAMMA(CZ)) FOR COMPLEX ARGUMENTS.        
C                                                                      
C   REF.: M. ABRAMOWITZ AND I.A. STEGUN, 'HANDBOOK OF MATHEMATI-       
C         CAL FUNCTIONS'. DOVER, NEW YORK (1974). PP 255-257.          
C                                                                      
      IMPLICIT DOUBLE PRECISION (A-B,D-H,O-Z), COMPLEX*16 (C)          
      PARAMETER (PI=3.1415926535897932D0)                              
      CZA=CZ                                                           
      ICONJ=0                                                          
      AR=CZA                                                           
      CLGAM=36.84136149D0                                              
      IF(CDABS(CZA).LT.1.0D-16) RETURN                                 
C                                                                      
      AI=CZA*DCMPLX(0.0D0,-1.0D0)                                      
      IF(AI.GT.0.0D0) THEN                                             
        ICONJ=0                                                        
      ELSE                                                             
        ICONJ=1                                                        
        CZA=DCONJG(CZA)                                                
      ENDIF                                                            
C                                                                      
      CZFAC=1.0D0                                                      
      CZFL=0.0D0                                                       
    1 CZFAC=CZFAC/CZA                                                  
      IF(CDABS(CZFAC).GT.1.0D8) THEN                                   
        CZFL=CZFL+CDLOG(CZFAC)                                         
        CZFAC=1.0D0                                                    
      ENDIF                                                            
      CZA=CZA+1.0D0                                                    
      AR=CZA                                                           
      IF(CDABS(CZA).LT.1.0D-16) RETURN                                 
      IF(CDABS(CZA).GT.15.0D0.AND.AR.GT.0.0D0) GO TO 2                 
      GO TO 1                                                          
C  ****  STIRLING'S EXPANSION OF CDLOG(GAMMA(CZA)).                    
    2 CZI2=1.0D0/(CZA*CZA)                                             
      CZS=(43867.0D0/244188.0D0)*CZI2                                  
      CZS=(CZS-3617.0D0/122400.0D0)*CZI2                               
      CZS=(CZS+1.0D0/156.0D0)*CZI2                                     
      CZS=(CZS-691.0D0/360360.0D0)*CZI2                                
      CZS=(CZS+1.0D0/1188.0D0)*CZI2                                    
      CZS=(CZS-1.0D0/1680.0D0)*CZI2                                    
      CZS=(CZS+1.0D0/1260.0D0)*CZI2                                    
      CZS=(CZS-1.0D0/360.0D0)*CZI2                                     
      CZS=(CZS+1.0D0/12.0D0)/CZA                                       
      CLGAM=(CZA-0.5D0)*CDLOG(CZA)-CZA+9.1893853320467274D-1+CZS       
     1     +CZFL+CDLOG(CZFAC)                                          
      IF(ICONJ.EQ.1) CLGAM=DCONJG(CLGAM)                               
      RETURN                                                           
      END                                                              
C  **************************************************************      
C                         FUNCION BESJN                                
C  **************************************************************      
      FUNCTION BESJN(JY,N,X)                                           
C                                                                      
C      THIS FUNCTION COMPUTES THE SPHERICAL BESSEL FUNCTIONS OF        
C   THE FIRST KIND AND SPHERICAL BESSEL FUNCTIONS OF THE SECOND        
C   KIND (ALSO KNOWN AS SPHERICAL NEUMANN FUNCTIONS) FOR REAL          
C   POSITIVE ARGUMENTS.                                                
C                                                                      
C      INPUT:                                                          
C         JY ...... KIND: 1(BESSEL) OR 2(NEUMANN).                     
C         N ....... ORDER (INTEGER).                                   
C         X ....... ARGUMENT (REAL AND POSITIVE).                      
C                                                                      
C   REF.: M. ABRAMOWITZ AND I.A. STEGUN, 'HANDBOOK OF MATHEMATI-       
C         CAL FUNCTIONS'. DOVER, NEW YORK (1974). PP 435-478.          
C                                                                      
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                              
      PARAMETER (PI=3.1415926535897932D0,TPI=PI+PI)                    
      IF(X.LT.0) THEN                                                  
        WRITE(6,1000)                                                  
 1000   FORMAT(1X,'*** NEGATIVE ARGUMENT IN FUNCTION BESJN.')          
        STOP                                                           
      ENDIF                                                            
C  ****  ORDER AND PHASE CORRECTION FOR NEUMANN FUNCTIONS.             
C        ABRAMOWITZ AND STEGUN, EQ. 10.1.15.                           
      IF(JY.EQ.2) THEN                                                 
        NL=-N-1                                                        
        IPH=2*MOD(IABS(N),2)-1                                         
      ELSE                                                             
        NL=N                                                           
        IPH=1                                                          
      ENDIF                                                            
C  ****  SELECTION OF CALCULATION MODE.                                
      IF(NL.LT.0) GO TO 10                                             
      IF(X.GT.1.0D0*NL) GO TO 7                                        
      XI=X*X                                                           
      IF(XI.GT.NL+NL+3.0D0) GO TO 4                                    
C  ****  POWER SERIES FOR SMALL ARGUMENTS AND POSITIVE ORDERS.         
C        ABRAMOWITZ AND STEGUN, EQ. 10.1.2.                            
      F1=1.0D0                                                         
      IP=1                                                             
      IF(NL.NE.0) THEN                                                 
        DO 1 I=1,NL                                                    
        IP=IP+2                                                        
    1   F1=F1*X/IP                                                     
      ENDIF                                                            
      XI=0.5D0*XI                                                      
      BESJN=1.0D0                                                      
      PS=1.0D0                                                         
      DO 2 I=1,500                                                     
      IP=IP+2                                                          
      PS=-PS*XI/(I*IP)                                                 
      BESJN=BESJN+PS                                                   
      IF(DABS(PS).LT.1.0D-18*DABS(BESJN)) GO TO 3                      
    2 CONTINUE                                                         
    3 BESJN=IPH*F1*BESJN                                               
      RETURN                                                           
C  ****  MILLER'S METHOD FOR POSITIVE ORDERS AND INTERMEDIATE          
C        ARGUMENTS. ABRAMOWITZ AND STEGUN, EQ. 10.1.19.                
    4 XI=1.0D0/X                                                       
      F2=0.0D0                                                         
      F3=1.0D-35                                                       
      IP=2*(NL+31)+3                                                   
      DO 5 I=1,31                                                      
      F1=F2                                                            
      F2=F3                                                            
      IP=IP-2                                                          
      F3=IP*XI*F2-F1                                                   
      IF(DABS(F3).GT.1.0D30) THEN                                      
        F2=F2/F3                                                       
        F3=1.0D0                                                       
      ENDIF                                                            
    5 CONTINUE                                                         
      BESJN=1.0D0                                                      
      F2=F2/F3                                                         
      F3=1.0D0                                                         
      DO 6 I=1,NL                                                      
      F1=F2                                                            
      F2=F3                                                            
      IP=IP-2                                                          
      F3=IP*XI*F2-F1                                                   
      IF(DABS(F3).GT.1.0D30) THEN                                      
        BESJN=BESJN/F3                                                 
        F2=F2/F3                                                       
        F3=1.0D0                                                       
      ENDIF                                                            
    6 CONTINUE                                                         
      BESJN=IPH*XI*DSIN(X)*BESJN/F3                                    
      RETURN                                                           
C  ****  RECURRENCE RELATION FOR ARGUMENTS GREATER THAN ORDER.         
C        ABRAMOWITZ AND STEGUN, EQ. 10.1.19.                           
    7 XI=1.0D0/X                                                       
      F3=XI*DSIN(X)                                                    
      IF(NL.EQ.0) GO TO 9                                              
      F2=F3                                                            
      F3=XI*(F2-DCOS(X))                                               
      IF(NL.EQ.1) GO TO 9                                              
      IP=1                                                             
      DO 8 I=2,NL                                                      
      F1=F2                                                            
      F2=F3                                                            
      IP=IP+2                                                          
    8 F3=IP*XI*F2-F1                                                   
    9 BESJN=IPH*F3                                                     
      RETURN                                                           
C  ****  RECURRENCE RELATION FOR NEGATIVE ORDERS.                      
C        ABRAMOWITZ AND STEGUN, EQ. 10.1.19.                           
   10 NL=IABS(NL)                                                      
      IF(X.LT.7.36D-1*(NL+1)*1.0D-35**(1.0D0/(NL+1))) THEN             
        BESJN=-1.0D35                                                  
        RETURN                                                         
      ENDIF                                                            
      XI=1.0D0/X                                                       
      F3=XI*DSIN(X)                                                    
      F2=XI*(F3-DCOS(X))                                               
      IP=3                                                             
      DO 11 I=1,NL                                                     
      F1=F2                                                            
      F2=F3                                                            
      IP=IP-2                                                          
      F3=IP*XI*F2-F1                                                   
      IF(DABS(F3).GT.1.0D35) THEN                                      
        BESJN=-1.0D35                                                  
        RETURN                                                         
      ENDIF                                                            
   11 CONTINUE                                                         
      BESJN=IPH*F3                                                     
      RETURN                                                           
      END                                             

