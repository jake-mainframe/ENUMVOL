ENUMDATA CSECT
***********************************************************************
*    INITIALIZATION
***********************************************************************
         BALR  R12,0
         USING *,R12
         STM   R14,R12,SAVE
         OPEN (OUTDCB,(OUTPUT))
***********************************************************************
*    MAINSTREAM OF PROGRAM
***********************************************************************
         L     R3,CVTPTR
         USING CVTMAP,R3
         L     R4,CVTSYSAD
         USING UCBOB,R4
VOLLOOP  MVC   VOLSER,UCBVOLI       GET MASTER VOLSER
         CLI   UCBID,X'FF'          FF IS UCB IDENT
         BNZ   ENDPROG              IF NOT FF END
         CLI   UCBVOLI,X'00'        MAKE SURE VOLSER ISNT 00
         BZ    GETNEXT
UCBPARSE MVC   DEVNUM(3),UCBNAME
         MVC   VOLSER(6),UCBVOLI
         PUT   OUTDCB,DEVNUMP       WRITE TO OUTPUT
         BAL   R6,LISTDATA
GETNEXT  LA    R4,152(R4)           GET NEXT UCB FROM MASTER
         B     VOLLOOP
***********************************************************************
*    END OF PROGRAM
***********************************************************************
ENDPROG  CLOSE (OUTDCB)
         LM    R14,R12,SAVE
         XR    R15,R15
         BR    R14
***********************************************************************
*    LIST DATASET OF VOLSERS SUB ROUTINE
***********************************************************************
LISTDATA L     R2,MAXLOOP
         L     R3,MAXERR
DATALOOP OBTAIN ACTADDR              VIEW TRACKS
         LA    R9,CCHHR
         LA    R9,1(R9)
         L     R8,0(R9)
         LA    R8,1(R8)
         ST    R8,0(R9)
         CL    R15,ZEROS
         BZ    CONT
         BCT   R3,DATALOOP
         B     RESET
CONT     CLI   READAREA,X'00'
         BZ    NEXTT
         CLC   LASTDSN,READAREA     IF SAME DSN AS BEFORE
         BZ    NEXTT
         MVC   LASTDSN(44),READAREA MOVE DSN
         PUT   OUTDCB,LASTDSNP      WRITE TO OUTPUT
         B     NEXTT
NEXTT    BCT   R2,DATALOOP
         B     RESET
RESET    XC    READAREA,READAREA
         XC    CCHHR,CCHHR
         XC    LASTDSN,LASTDSN
LASTDATA BR    R6
***********************************************************************
*    DATA
***********************************************************************
DEVNUMP   DC    C' '
DEVNUM    DS    CL3
          DC    C' '
VOLSER    DS    CL6
FILL      DC    80CL1' '
ACTADDR   CAMLST   SEEK,CCHHR,VOLSER,READAREA
          DS    0F
CCHHR     DC    XL5'0000000000'  ABSOLUTE TRACK ADDRESS
LASTDSNP  DC    C' '
LASTDSN   DS    CL44
FILL2     DC    80CL1' '
MAXLOOP   DC    XL4'00001000'
MAXERR    DC    XL4'00000A00'
READAREA  DS    140C            140-BYTE WORK AREA
ZEROS     DC    XL4'00000000'
SAVE      DS    18F
***********************************************************************
*    DATASETS
***********************************************************************
OUTDCB   DCB DSORG=PS,MACRF=(PM),DDNAME=SYSPRINT,                      X
               RECFM=FBA,LRECL=80,BLKSIZE=0
***********************************************************************
*    MACROS
***********************************************************************
         CVT   DSECT=YES
         IEFUCBOB
         YREGS
         END   ENUMDATA CSECT
