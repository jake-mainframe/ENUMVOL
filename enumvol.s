ENUMVOL  CSECT
***********************************************************************
*    INITIALIZATION
***********************************************************************       
         BALR  R12,0
         USING *,R12
         LA    R13,SAVE
         STM   R14,R12,12(R13)         
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
GETNEXT  LA    R4,152(R4)           GET NEXT UCB FROM MASTER
         B     VOLLOOP
***********************************************************************
*    END OF PROGRAM
***********************************************************************
ENDPROG  CLOSE (OUTDCB)
         LA    R13,SAVE
         LM    R14,R12,12(R13)
         XR    R15,R15
         BR    R14
***********************************************************************
*    DATA
***********************************************************************
DEVNUMP   DC    C' '
DEVNUM    DS    CL3
          DC    C' '
VOLSER    DS    CL6
FILL      DC    80CL1' '
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
         END   ENUMVOL
