       PROCESS DATETIME.
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     CBCUSTS.
       AUTHOR.         Databorough India.
       DATE-WRITTEN.   10 MAR. 2009.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       SPECIAL-NAMES. LOCAL-DATA IS LOCALDATA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT CUSTS-FILE
               ASSIGN TO DATABASE-CUSTS
               ORGANIZATION IS INDEXED
               ACCESS IS DYNAMIC
               RECORD KEY IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS IS CUSTS-FILE-STATUS.

           SELECT DISPLAY-FILE
               ASSIGN TO WORKSTATION-CBCUSTSD-SI
               ORGANIZATION TRANSACTION
               ACCESS MODE DYNAMIC
               RELATIVE KEY RECNO
               FILE STATUS IS SFL-STATUS
               CONTROL-AREA SCRN-CONTROL.

           SELECT SLMEN-FILE
               ASSIGN TO DATABASE-SLMEN
               ORGANIZATION IS INDEXED
               ACCESS IS DYNAMIC
               RECORD KEY IS EXTERNALLY-DESCRIBED-KEY
                        WITH DUPLICATES.

           SELECT DISTS-FILE
               ASSIGN TO DATABASE-DISTS
               ORGANIZATION IS INDEXED
               ACCESS IS DYNAMIC
               RECORD KEY IS EXTERNALLY-DESCRIBED-KEY
                        WITH DUPLICATES.

           SELECT CUSGRP-FILE
               ASSIGN TO DATABASE-CUSGRP
               ORGANIZATION IS INDEXED
               ACCESS IS DYNAMIC
               RECORD KEY IS EXTERNALLY-DESCRIBED-KEY.

           SELECT CUSFL3-FILE
               ASSIGN TO DATABASE-CUSFL3
               ORGANIZATION IS INDEXED
               ACCESS IS DYNAMIC
               RECORD KEY IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS IS CUSTS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  CUSTS-FILE
           LABEL RECORDS ARE STANDARD.
       01  CUSTS-RECORD.
           COPY DDS-CUSTSR      OF  CUSTS.

       FD  DISPLAY-FILE
           LABEL RECORDS STANDARD.
       01  DISPLAY-REC          PIC X(1920).

       FD  SLMEN-FILE
           LABEL RECORDS ARE STANDARD.
       01  SLMEN-RECORD.
           COPY DDS-RSLMEN  OF  SLMEN.

       FD  DISTS-FILE
           LABEL RECORDS ARE STANDARD.
       01  DISTS-RECORD.
           COPY DDS-RPRODS  OF  DISTS.

       FD  CUSGRP-FILE
           LABEL RECORDS ARE STANDARD.
       01  CUSGRP-RECORD.
           COPY DDS-CUSGRPR OF  CUSGRP.

       FD  CUSFL3-FILE
           LABEL RECORDS ARE STANDARD.
       01  CUSFL3-RECORD.
           COPY DDS-RCUSF  OF  CUSFL3.

       WORKING-STORAGE SECTION.
       01  MSGID                       PIC X(7).
       01  WS-ERRMSG                   PIC X(132).
       01  WS-PAGENO                   PIC S9(2).
       01  WS-NO-OF-PAGES              PIC S9(2) VALUE 2.
       01  CUSTS-FILE-STATUS           PIC X(2) VALUE SPACES.
       01  WS-VARIABLES.
           02  WS-ERROR                PIC X   VALUE SPACE.
           02  WS-SDIFF                PIC S9(12)V99.
           02  NO-ERR-SFL              PIC X   VALUE SPACE.
           02  NEW-REQUEST             PIC X   VALUE SPACE.
           02  WS-STATUS               PIC X   VALUE SPACE.
           02  I       PIC 999 VALUE 0.
           02  RECNO   PIC 99 VALUE 0.
           02  NO-OF-ROLL  PIC 9 VALUE 0.
           02  RECORD-FOUND-SFL       PIC  X VALUE SPACES.
           02  RECORD-FOUND-CUSTS     PIC  X VALUE SPACES.
           02  RECORD-FOUND-DISTS     PIC  X VALUE SPACES.
           02  RECORD-FOUND-SLMEN     PIC  X VALUE SPACES.
           02  RECORD-FOUND-CUSGRP    PIC  X VALUE SPACES.
           02  RECORD-FOUND           PIC  X VALUE SPACES.
           02  RECORD-PROCESS         PIC  X VALUE SPACES.
           02  RECORD-FOUND-CUSFL3    PIC  X VALUE SPACES.
       01  WSCUSPRM                   PIC 9(5).

       01  WS-FLAGS.
           02  SFL-STATUS PIC XX.
              88 SFL-FULL VALUE "9M".
           02  INDIC-ON      PIC 1 VALUE B"1".
           02  INDIC-OFF     PIC 1 VALUE B"0".

       01  DISPLAY-INDICATORS.
           COPY DDS-ZZSF01-INDICATORS     OF  CBCUSTSD.
           COPY DDS-ZZCT01-INDICATORS     OF  CBCUSTSD.
           COPY DDS-ZZFT01-INDICATORS     OF  CBCUSTSD.
           COPY DDS-ZZFT02-INDICATORS     OF  CBCUSTSD
                  REPLACING IN94 BY IN95.

       01  WS-CONSTANTS.
           02  MAX-SFL-RECORDS  PIC 99 VALUE 50.
           02  NEW-LINES        PIC 99 VALUE 5.

       01  WS-OPR-SWITCH.
           02  SFLCTL-SW                PIC 1  VALUE B"0".
               88  SFL-CONTROL          VALUE B"1".
               88  SFL-CONTROL-OFF      VALUE B"0".

       01  WS-INPUT-INDIC.
           02  IN04          PIC 1 VALUE B"0".
               88  PROMPT-F4          VALUE B"1".
           02  IN12          PIC 1 VALUE B"0".
               88  CANCEL-KEY         VALUE B"1".
           02  IN03          PIC 1 VALUE B"0".
               88  EXIT-KEY           VALUE B"1".
           02  IN25          PIC 1 VALUE B"0".
               88  ROLLUP-KEY         VALUE B"1".
           02  IN26          PIC 1 VALUE B"0".
               88  ROLLDOWN-KEY       VALUE B"1".

       01  WORK-FIELDS.
           05 ARE-THERE-MORE-RECORDS PIC X(3) VALUE 'YES'.
               88 NO-MORE-RECORDS             VALUE  'NO'.
           05 MATT-RECORD-RRN        PIC 9(2) VALUE   0.

      *�SCREEN RECORD FORMATS
       01  SFL-IN.
           COPY DDS-ZZSF01-I        OF CBCUSTSD.
       01  SFL-OUT.
           COPY DDS-ZZSF01-O        OF CBCUSTSD.
       01  SFC-IN.
           COPY DDS-ZZCT01-I        OF CBCUSTSD.
       01  SFC-OUT.
           COPY DDS-ZZCT01-O        OF CBCUSTSD.
       01  MSG-OUT.
           COPY DDS-ZZTR01-O        OF CBCUSTSD.

       01  ZZFT01-IN.
           COPY DDS-ZZFT01-I        OF CBCUSTSD
               REPLACING ZMSAGE  BY  FT01-ZMSAGE
                         PNAME   BY  FT01-PNAME.
       01  ZZFT01-OUT.
           COPY DDS-ZZFT01-O        OF CBCUSTSD
               REPLACING ZMSAGE  BY  FT01-ZMSAGE
                         PNAME   BY  FT01-PNAME.
       01  ZZFT02-IN.
           COPY DDS-ZZFT02-I        OF CBCUSTSD
               REPLACING ZMSAGE  BY  FT02-ZMSAGE.
       01  ZZFT02-OUT.
           COPY DDS-ZZFT02-O        OF CBCUSTSD
               REPLACING ZMSAGE  BY  FT02-ZMSAGE.

       01  SCRN-CONTROL.
           02 FUNCT       PIC XX.
           02 DEVICEFILE  PIC X(10).
           02 RECFORMAT   PIC X(10).


       PROCEDURE DIVISION.

       MAIN-PROCESSING.
           PERFORM OPEN-FILES.
           PERFORM INIT-ROUTINE  THRU  INIT-EXIT.
           PERFORM PROCESS-ROUTINE   THRU  PP-EXIT
                   UNTIL  EXIT-KEY.

       PROGRAM-EXIT.
           PERFORM CLOSE-FILES.
           STOP RUN.

       PROCESS-ROUTINE.
           PERFORM   DISPLAY-SFLCTL-FILE     THRU   DSFCF-EXIT.
           EVALUATE  TRUE
           WHEN   EXIT-KEY
                        CONTINUE
           WHEN   CANCEL-KEY
                  PERFORM INITIALIZE-SFLCTL
           WHEN   OTHER
                  PERFORM SUBFILE-PROCESS-PARA  THRU  SPROP-EXIT
           END-EVALUATE.
       PP-EXIT.       EXIT.

       SUBFILE-PROCESS-PARA.
           MOVE 0 TO RECNO.
           MOVE "Y" TO RECORD-FOUND-CUSTS.
           READ  CUSTS-FILE NEXT RECORD
               AT END   MOVE "N"  TO  RECORD-FOUND-CUSTS
               NOT AT END
                     MOVE "Y"  TO  RECORD-FOUND-CUSTS
                        GO SPROP-EXIT.
           IF  RECORD-FOUND-CUSTS  =  "Y"
               PERFORM CREATE-SFL-FILE    THRU    CSFLF-EXIT
           ELSE
               MOVE  "No Records are available."  TO ZMSAGE
               GO SPROP-EXIT
           END-IF.
      *    IF  NEW-REQUEST = "Y"
      *       PERFORM  FILL-BLANK-LINES    THRU   FBLAL-EXIT
      *    END-IF

      *    IF  OLD-REQUEST = "Y"
      *    END-IF

           IF  RECNO > 0
              PERFORM DISPLAY-SFL-FILE   THRU    DSFLF-EXIT
                 UNTIL  EXIT-KEY OR CANCEL-KEY
           END-IF.
           MOVE INDIC-OFF TO IN03  OF WS-INPUT-INDIC.
       SPROP-EXIT.   EXIT.

       CREATE-SFL-FILE.
           MOVE  0  TO  RECNO.
           MOVE  SPACES  TO  WS-STATUS.
           PERFORM  FILL-SFL-FILE     THRU   FSFLF-EXIT
                    UNTIL   RECORD-FOUND-CUSTS = "N".
       CSFLF-EXIT.   EXIT.

       FILL-SFL-FILE.
           IF  RECNO > MAX-SFL-RECORDS
               MOVE "N"   TO  RECORD-FOUND-CUSTS
               GO  FSFLF-EXIT.
           PERFORM  MOVE-CUSTS-TO-SFL   THRU   MCTSFL-EXIT.
           ADD  1  TO  RECNO
           PERFORM   WRITE-SFL-RECORD   THRU   WSFLR-EXIT.
           PERFORM   READ-NEXT-CUSTS-FILE          THRU  RNDTLF-EXIT.
       FSFLF-EXIT. EXIT.

       FILL-BLANK-LINES.
           INITIALIZE  ZZSF01-O  REPLACING  ALPHANUMERIC BY SPACES
                                            NUMERIC      BY ZEROS.
           PERFORM  VARYING I FROM 1 BY 1
                    UNTIL   I      >  NEW-LINES
                    OR      RECNO  >  MAX-SFL-RECORDS
             ADD   1       TO  RECNO
      **     MOVE  "E"     TO  STAT OF ZZSF01-O
             PERFORM  WRITE-SFL-RECORD  THRU   WSFLR-EXIT
           END-PERFORM.
       FBLAL-EXIT.  EXIT.

       DISPLAY-SFL-FILE.
           PERFORM  WRITE-READ-SFC   THRU   WRSFC-EXIT.
           MOVE  0  TO   RECNO.
           MOVE "Y" TO   RECORD-FOUND-SFL NO-ERR-SFL.
           EVALUATE  TRUE
           WHEN EXIT-KEY
                CONTINUE
           WHEN CANCEL-KEY
                CONTINUE
      *    WHEN REFRESH-KEY
      *         CONTINUE
           WHEN OTHER
                PERFORM PROCESS-SFL-RECORD  THRU  PSFLR-EXIT
                          UNTIL  RECORD-FOUND-SFL = "N"
                PERFORM  SFL-ACTION-PARA       THRU  SFLACTP-EXIT
           END-EVALUATE.
       DSFLF-EXIT.   EXIT.

       PROCESS-SFL-RECORD.
           PERFORM READ-NEXT-SFL-FILE   THRU   RNSFLF-EXIT.
           IF  RECORD-FOUND-SFL = "N"
               GO PSFLR-EXIT.
           EVALUATE  TRUE
             WHEN  DSSEL OF ZZSF01-I = "2"
      *      WHEN  DSSEL OF ZZSF01-I = "3"
               PERFORM CHGREC-ROUTINE  THRU  CHGREC-EXIT
               PERFORM CHGREC2-ROUTINE  THRU  CHGREC2-EXIT
             WHEN  DSSEL OF ZZSF01-I = "5"
               PERFORM DSPREC-ROUTINE  THRU  DSPREC-EXIT
             WHEN  DSSEL  OF ZZSF01-I = "6"
      *�Program with Long field names. Otherwise call CBCUSTMNT1
               CALL "CBCUSTMNT2"
                      USING XWBCCD OF ZZSF01-I
               CANCEL "CBCUSTMNT1"
             WHEN  DSSEL  OF ZZSF01-I = "8"
               PERFORM ZORDER-ROUTINE  THRU  ZORDER-EXIT
             WHEN  DSSEL  OF ZZSF01-I = "9"
               PERFORM ZHISTO-ROUTINE  THRU  ZHISTO-EXIT
           END-EVALUATE.
           MOVE  SPACES TO DSSEL OF ZZSF01-I.
      **   PERFORM SFL-REWRITE-PARA     THRU    SFLRWP-EXIT.
           PERFORM REWRITE-SFL-RECORD   THRU    RWSFLR-EXIT.
       PSFLR-EXIT.   EXIT.

       SFL-REWRITE-PARA.
      *    IF  DSSEL OF ZZSF01-I = "D"
      *        MOVE 0 TO SFLSL OF SFL-O
      *    ENDIF.
       SFLRWP-EXIT.  EXIT.

       SFL-ACTION-PARA.
                MOVE  SPACES   TO    NO-ERR-SFL.
      *         IF INQUIRY-MODE       GO  SFLACTP-EXIT.
       SFLACTP-EXIT.   EXIT.

       READ-MODIFIED-SFL-FILE.
           READ SUBFILE DISPLAY-FILE NEXT MODIFIED RECORD INTO SFL-IN
                FORMAT "ZZSF01" AT END
                MOVE "N" TO RECORD-FOUND-SFL
                GO RMSFLF-EXIT.
           MOVE  CORR  ZZSF01-I   TO   ZZSF01-O.
       RMSFLF-EXIT.  EXIT.

      *    IF  DSSEL OF ZZSF01-I = "D"
      *        MOVE 0 TO SFLSL OF SFL-O
      *    ENDIF.

       WRITE-SFL-RECORD.
           WRITE SUBFILE DISPLAY-REC FROM SFL-OUT FORMAT "ZZSF01"
      **         INDICATORS ZZSF01-O-INDIC
                 INVALID KEY DISPLAY "PROBLEM IN SUBFILE WRITING-P1".
           INITIALIZE  ZZSF01-O  REPLACING ALPHANUMERIC BY SPACES
                                        NUMERIC BY ZEROS.
       WSFLR-EXIT.  EXIT.

       READ-NEXT-SFL-FILE.
           ADD 1 TO RECNO.
           MOVE "Y" TO RECORD-FOUND-SFL.
           READ SUBFILE DISPLAY-FILE INTO SFL-IN   FORMAT "ZZSF01"
             INVALID MOVE "N" TO RECORD-FOUND-SFL
                     GO RNSFLF-EXIT.
           MOVE CORR ZZSF01-I     TO   ZZSF01-O.
       RNSFLF-EXIT.   EXIT.

       READ-MATT.
           ADD 1 TO MATT-RECORD-RRN.
           MOVE XWBCCD OF CUSTS-RECORD TO XWBCCD OF ZZSF01-O.
           MOVE XWG4TX OF CUSTS-RECORD TO XWG4TX OF ZZSF01-O.
           WRITE DISPLAY-REC FROM SFL-OUT FORMAT "ZZSF01".
           READ CUSTS-FILE NEXT RECORD
              AT END  SET NO-MORE-RECORDS TO TRUE.
       MATT-EXIT.

       WRITE-READ-SFC.
           IF  SHWREC  OF ZZCT01-O  = 0
                  MOVE 1 TO SHWREC OF ZZCT01-O.
           WRITE  DISPLAY-REC   FROM  MSG-OUT    FORMAT "ZZTR01"
           WRITE  DISPLAY-REC   FROM  SFC-OUT    FORMAT "ZZCT01"
                       INDICATORS ARE ZZCT01-O-INDIC.
           READ DISPLAY-FILE  INTO  SFC-IN
                   INDICATORS ARE ZZCT01-I-INDIC.
           MOVE    SPACES   TO    ZMSAGE.
           MOVE CORR ZZCT01-I-INDIC      TO  WS-INPUT-INDIC.
           MOVE CORR ZZCT01-I            TO  ZZCT01-O.
       WRSFC-EXIT.   EXIT.

       REWRITE-SFL-RECORD.
           REWRITE SUBFILE DISPLAY-REC FROM SFL-OUT FORMAT "ZZSF01"
      ****       INDICATORS  ZZSF01-O-INDIC
      ****       INDICATORS  ZZSF02-O-INDIC
                 INVALID KEY DISPLAY "PROBLEM IN SUBFILE REWRITING-P2"
                 MOVE B"1"  TO  IN03 OF  WS-INPUT-INDIC
           END-REWRITE.
       RWSFLR-EXIT.  EXIT.

       INIT-ROUTINE.
           MOVE ALL B"0"  TO  WS-INPUT-INDIC  DISPLAY-INDICATORS.
           INITIALIZE   SFL-IN  SFL-OUT  SFC-OUT SFC-IN
              WS-VARIABLES MSG-OUT
              REPLACING NUMERIC BY ZEROS ALPHANUMERIC BY SPACES.
       INIT-EXIT.  EXIT.

       OPEN-FILES.
               OPEN  INPUT  SLMEN-FILE
                            DISTS-FILE
                            CUSGRP-FILE
                            CUSFL3-FILE
                     I-O    CUSTS-FILE
                            DISPLAY-FILE.

       CLOSE-FILES.
               CLOSE   CUSTS-FILE
                       DISPLAY-FILE
                       SLMEN-FILE
                       DISTS-FILE
                       CUSGRP-FILE
                       CUSFL3-FILE.

       START-READ-NEXT-CUSTS.
           PERFORM  START-CUSTS-FILE   THRU   SDTLF-EXIT.
           IF   RECORD-FOUND-CUSTS NOT = "N"
                PERFORM  READ-NEXT-CUSTS-FILE   THRU  RNDTLF-EXIT
           END-IF.
       SRNDTLF-EXIT.   EXIT.

       START-CUSTS-FILE.
           MOVE "Y"  TO RECORD-FOUND-CUSTS.
           START CUSTS-FILE KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID  MOVE "N" TO RECORD-FOUND-CUSTS.
       SDTLF-EXIT.  EXIT.

       READ-NEXT-CUSTS-FILE.
           MOVE "Y"   TO RECORD-FOUND-CUSTS.
           READ  CUSTS-FILE   NEXT RECORD
              AT END  MOVE "N"  TO  RECORD-FOUND-CUSTS
              NOT AT END  MOVE "Y"  TO  RECORD-FOUND-CUSTS
                      GO RNDTLF-EXIT.
       RNDTLF-EXIT. EXIT.

       READ-CUSTS-FILE.
           MOVE "Y"   TO RECORD-FOUND-CUSTS.
           READ  CUSTS-FILE   INVALID
                 MOVE "N"  TO  RECORD-FOUND-CUSTS.
       RDTLF-EXIT. EXIT.

       MATT-FUN.
            MOVE "YES" TO ARE-THERE-MORE-RECORDS.
            READ CUSTS-FILE NEXT RECORD.
            PERFORM READ-MATT THRU MATT-EXIT.
       MATT-FUN-EXIT.

       DISPLAY-SFLCTL-FILE.
           PERFORM MATT-FUN THRU MATT-FUN-EXIT.
           MOVE INDIC-ON   TO   IN72 IN74.
           MOVE INDIC-OFF  TO   IN71.
      *    SET SFL-CONTROL TO   TRUE.
      *    SET SFL-CONTROL-ON TO   TRUE.
           PERFORM  WRITE-READ-SFC      THRU    WRSFC-EXIT.
      **   SET SFL-CONTROL-OFF TO   TRUE.
           MOVE INDIC-ON   TO   IN81 IN71.
           MOVE INDIC-OFF TO    IN74.
       DSFCF-EXIT.  EXIT.

       MOVE-CUSTS-TO-SFL.
           INITIALIZE  ZZSF01-O   REPLACING  ALPHANUMERIC BY SPACES
                                          NUMERIC BY ZEROS.
           MOVE XWBCCD OF CUSTS-RECORD TO XWBCCD OF ZZSF01-O.
           MOVE XWG4TX OF CUSTS-RECORD TO XWG4TX OF ZZSF01-O.
       MCTSFL-EXIT.  EXIT.

       INITIALIZE-SFLCTL.
           INITIALIZE ZZCT01-O.

       CHGREC-ROUTINE.
           INITIALIZE  ZZFT01-I  ZZFT01-O  ZZFT02-I  ZZFT02-O.
           MOVE INDIC-OFF  TO   IN94.
           MOVE INDIC-OFF  TO   IN96.
      *    MOVE INDIC-OFF  TO   IN97.
      *    MOVE INDIC-OFF  TO   IN98.
           MOVE "  UPDATE" TO ACTDSP OF ZZFT01-O
                              ACTDSP OF ZZFT02-O.
           PERFORM OFFIND-ROUTINE  THRU OFFIND-EXIT.
           PERFORM GETREC-ROUTINE  THRU GETREC-EXIT.

      *�If no error (Record/File)
           IF RECORD-FOUND-CUSTS = "Y"
                  AND CUSTS-FILE-STATUS = "00"

             MOVE 1 TO WS-PAGENO
             PERFORM UNTIL  WS-PAGENO > WS-NO-OF-PAGES
             PERFORM DSPSCNS-ROUTINE  THRU  DSPSCNS-EXIT
             IF IN03 OF ZZFT01-I-INDIC = INDIC-ON
                OR IN03 OF ZZFT02-I-INDIC = INDIC-ON
                  GO CHGREC-EXIT
             END-IF
             IF IN04 OF ZZFT01-I-INDIC = INDIC-ON
                   OR IN04 OF ZZFT02-I-INDIC = INDIC-ON
                   OR IN08 OF ZZFT01-I-INDIC = INDIC-ON
                   OR IN08 OF ZZFT02-I-INDIC = INDIC-ON
                   OR IN09 OF ZZFT01-I-INDIC = INDIC-ON
                   OR IN09 OF ZZFT02-I-INDIC = INDIC-ON
                GO CHGREC-ROUTINE
             END-IF

             EVALUATE TRUE
               WHEN  WS-PAGENO = 1
                 PERFORM VALID1-ROUTINE  THRU  VALID1-EXIT
               WHEN  WS-PAGENO = 2
                 PERFORM VALID2-ROUTINE  THRU  VALID2-EXIT
             END-EVALUATE

             IF WS-ERROR = "Y"
                MOVE WS-ERRMSG  TO  FT01-ZMSAGE OF ZZFT01-O
                PERFORM  MVDBSC-ROUTINE  THRU  MVDBSC-EXIT
                GO CHGREC-ROUTINE
             END-IF

             ADD 1 TO WS-PAGENO
           END-PERFORM

      *�If no error (Record/File)
           END-IF.
       CHGREC-EXIT. EXIT.

       CHGREC2-ROUTINE.
           IF IN03 OF ZZFT01-I-INDIC = INDIC-OFF
                AND IN03 OF ZZFT02-I-INDIC = INDIC-OFF
                AND IN12 OF ZZFT01-I-INDIC = INDIC-OFF
                AND IN12 OF ZZFT02-I-INDIC = INDIC-OFF
      *�Request confirmation
                  MOVE "CONFIRM..." TO ACTDSP OF ZZFT02-O
                  MOVE INDIC-ON  TO IN95 OF ZZFT02-O-INDIC
                  WRITE DISPLAY-REC  FROM ZZFT02-OUT
                      FORMAT IS "ZZFT02"
                      INDICATORS ARE ZZFT02-O-INDIC
                  READ DISPLAY-FILE INTO ZZFT02-IN
                      FORMAT IS "ZZFT02"
                      INDICATORS ARE ZZFT02-I-INDIC
                  IF IN03 OF ZZFT01-I-INDIC = INDIC-OFF
                       AND IN03 OF ZZFT02-I-INDIC = INDIC-OFF
                       AND IN12 OF ZZFT01-I-INDIC = INDIC-OFF
                       AND IN12 OF ZZFT02-I-INDIC = INDIC-OFF
                    MOVE XWBCCD OF ZZSF01-I
                                    TO  XWBCCD OF CUSTS-RECORD
                    MOVE "Y" TO RECORD-FOUND-CUSTS
                    READ  CUSTS-FILE
                        INVALID KEY
                          MOVE "N" TO RECORD-FOUND-CUSTS
                    END-READ
                    IF RECORD-FOUND-CUSTS = "Y"
                       PERFORM MVSCDB-ROUTINE  THRU  MVSCDB-EXIT
                       MOVE "Y" TO RECORD-PROCESS
      *                MOVE "Y" TO RECORD-PROCESS
                       WRITE CUSTS-RECORD
                           INVALID KEY
                              MOVE "N" TO RECORD-PROCESS
                    END-IF
                  END-IF
           END-IF
             .
       CHGREC2-EXIT. EXIT.

       DSPREC-ROUTINE.
           INITIALIZE  ZZFT01-I  ZZFT01-O  ZZFT02-I  ZZFT02-O.
           MOVE INDIC-ON   TO   IN94.
           MOVE INDIC-OFF  TO   IN96.
      ***  MOVE INDIC-OFF  TO   IN97.
           MOVE "DISPLAY" TO ACTDSP OF ZZFT01-O
                             ACTDSP OF ZZFT02-O.
           PERFORM OFFIND-ROUTINE  THRU OFFIND-EXIT.
           PERFORM GETREC-ROUTINE  THRU GETREC-EXIT.
           MOVE 1 TO WS-PAGENO.
           PERFORM UNTIL  WS-PAGENO > WS-NO-OF-PAGES
               PERFORM DSPSCNS-ROUTINE  THRU  DSPSCNS-EXIT
      *        IF EXIT-KEY
      *           GO DSPREC-EXIT
      *        ENDIF
               ADD 1 TO WS-PAGENO
           END-PERFORM.
       DSPREC-EXIT. EXIT.

       GETREC-ROUTINE.
           MOVE SPACES  TO  CUSTS-FILE-STATUS.
           MOVE XWBCCD OF ZZSF01-I  TO  XWBCCD OF CUSTS-RECORD.
           MOVE "Y" TO RECORD-FOUND-CUSTS.
           READ  CUSTS-FILE
              INVALID KEY
                 MOVE "N" TO RECORD-FOUND-CUSTS.

           EVALUATE TRUE
             WHEN RECORD-FOUND-CUSTS = "N"
                MOVE  "OES0115" TO MSGID
                CALL "RTNMTX" USING MSGID,
                                    WS-ERRMSG
                MOVE  WS-ERRMSG  TO  FT01-ZMSAGE
             WHEN CUSTS-FILE-STATUS = "9D"
                MOVE  "Y3U9999" TO  MSGID
                CALL "RTNMTX"
                              USING MSGID  WS-ERRMSG
                MOVE  WS-ERRMSG  TO  FT01-ZMSAGE
             WHEN OTHER

      *�RETRIEVE SALESMAN'S NAME
                MOVE PERSON OF CUSTS-RECORD TO  PERSON OF SLMEN-RECORD
                READ  SLMEN-FILE
                    INVALID KEY
                         MOVE ALL "-"  TO  FT01-PNAME OF ZZFT01-OUT
                END-READ

      *�RETRIEVE DISTRIBUTOR'S NAME
                MOVE DSDCDE OF CUSTS-RECORD  TO  DSDCDE OF DISTS-RECORD
                READ  DISTS-FILE
                    INVALID KEY
                      MOVE ALL "-"  TO  DNAME OF ZZFT01-OUT
                END-READ

      *�RETRIEVE CUSTOMER GROUP'S NAME
                MOVE XWBNCD OF CUSTS-RECORD TO XWBNCD OF CUSGRP-RECORD
                READ  CUSGRP-FILE
                    INVALID KEY
                      MOVE ALL "-"  TO  XWKHTX  OF  CUSGRP-RECORD
                END-READ
             PERFORM MVDBSC-ROUTINE  THRU  MVDBSC-EXIT
           END-EVALUATE.

       GETREC-EXIT. EXIT.

       OFFIND-ROUTINE.
      **   MOVE INDIC-OFF  TO   IN99.
           MOVE INDIC-OFF  TO   IN31.
           MOVE INDIC-OFF  TO   IN32.
           MOVE INDIC-OFF  TO   IN33.
           MOVE INDIC-OFF  TO   IN34.
           MOVE INDIC-OFF  TO   IN35.
           MOVE INDIC-OFF  TO   IN36.
           MOVE INDIC-OFF  TO   IN37.
           MOVE SPACES TO FT01-ZMSAGE.
       OFFIND-EXIT. EXIT.

       DSPSCNS-ROUTINE.
           EVALUATE TRUE
              WHEN WS-PAGENO = 1
                  WRITE  DISPLAY-REC  FROM ZZFT01-OUT
                           FORMAT IS "ZZFT01"
                           INDICATORS ARE ZZFT01-O-INDIC
                  READ   DISPLAY-FILE  INTO  ZZFT01-IN
                           INDICATORS ARE ZZFT01-I-INDIC
MH19M             MOVE CORR ZZCT01-I-INDIC  TO  WS-INPUT-INDIC
              WHEN WS-PAGENO = 2
                  WRITE DISPLAY-REC  FROM ZZFT02-OUT
                      FORMAT IS "ZZFT02"
                      INDICATORS ARE ZZFT02-O-INDIC
                  READ DISPLAY-FILE INTO ZZFT02-IN
                      FORMAT IS "ZZFT02"
      **              INDICATORS ARE ZZFT02-I-INDIC
           END-EVALUATE.
           PERFORM MVSCDB-ROUTINE  THRU  MVSCDB-EXIT.
           CALL "XBCCLMSG".
           PERFORM OFFIND-ROUTINE  THRU OFFIND-EXIT.
           EVALUATE TRUE
             WHEN IN04  OF ZZFT01-I-INDIC = INDIC-ON
                PERFORM SRPROM-ROUTINE  THRU  SRPROM-EXIT
             WHEN IN08  OF ZZFT01-I-INDIC = INDIC-ON
                PERFORM ZORDER-ROUTINE  THRU  ZORDER-EXIT
             WHEN IN09  OF ZZFT01-I-INDIC = INDIC-ON
                PERFORM ZHISTO-ROUTINE  THRU  ZHISTO-EXIT
           END-EVALUATE.
       DSPSCNS-EXIT. EXIT.

       MVDBSC-ROUTINE.
           MOVE XWBCCD OF CUSTS-RECORD TO ZWBCCD OF ZZFT01-O.
           MOVE XWG4TX OF CUSTS-RECORD TO ZWG4TX OF ZZFT01-O.
           MOVE XWB2CD OF CUSTS-RECORD TO ZWB2CD OF ZZFT01-O.
           MOVE XWB3CD OF CUSTS-RECORD TO ZWB3CD OF ZZFT01-O.
           MOVE XWHITX OF CUSTS-RECORD TO ZWHITX OF ZZFT01-O.
           MOVE XWE0NB OF CUSTS-RECORD TO ZWE0NB OF ZZFT01-O.
           MOVE XWJUN0 OF CUSTS-RECORD TO ZWJUN0 OF ZZFT01-O.
           MOVE XWDVCD OF CUSTS-RECORD TO ZWDVCD OF ZZFT01-O.
           MOVE XWBNCD OF CUSTS-RECORD TO ZWBNCD OF ZZFT01-O.
           MOVE PERSON OF CUSTS-RECORD TO ZPERSON OF ZZFT01-O.
           MOVE DSDCDE OF CUSTS-RECORD TO ZDSDCDE OF ZZFT01-O.
           MOVE XWBTCD OF CUSTS-RECORD TO ZWBTCD OF ZZFT01-O.
           MOVE XWGIVA OF CUSTS-RECORD TO ZWGIVA OF ZZFT01-O.
           MOVE XWAOCD OF CUSTS-RECORD TO ZWAOCD OF ZZFT01-O.
           MOVE XWBBCD OF CUSTS-RECORD TO ZWBBCD OF ZZFT01-O.
           MOVE XWG4T0 OF CUSTS-RECORD TO ZWG4T0 OF ZZFT01-O.
           MOVE XWC7ST OF CUSTS-RECORD TO ZWC7ST OF ZZFT01-O.
           MOVE XWDAST OF CUSTS-RECORD TO ZWDAST OF ZZFT01-O.
           MOVE XWBPD0 OF CUSTS-RECORD TO ZWBPD0 OF ZZFT01-O.
           MOVE XWBAD0 OF CUSTS-RECORD TO ZWBAD0 OF ZZFT01-O.
           MOVE XWKHTX OF CUSGRP-RECORD TO ZWKHTX OF ZZFT01-O.
           MOVE XWF0VA OF CUSTS-RECORD TO ZWF0VA OF ZZFT02-O.
           MOVE XWASDT OF CUSTS-RECORD TO ZWASDT OF ZZFT02-O.
           MOVE XWF0V0 OF CUSTS-RECORD TO ZWF0V0 OF ZZFT02-O.
           MOVE XWBQDT OF CUSTS-RECORD TO ZWBQDT OF ZZFT02-O.
           MOVE XWF1VA OF CUSTS-RECORD TO ZWF1VA OF ZZFT02-O.
           MOVE XWF1V0 OF CUSTS-RECORD TO ZWF1V0 OF ZZFT02-O.
           MOVE XWF2VA OF CUSTS-RECORD TO ZWF2VA OF ZZFT02-O.
           MOVE XWF3VA OF CUSTS-RECORD TO ZWF3VA OF ZZFT02-O.
           MOVE XWF4VA OF CUSTS-RECORD TO ZWF4VA OF ZZFT02-O.
           MOVE XWF6VA OF CUSTS-RECORD TO ZWF6VA OF ZZFT02-O.
           MOVE XWIDV0 OF CUSTS-RECORD TO ZWIDV0 OF ZZFT02-O.
           MOVE XWGAVA OF CUSTS-RECORD TO ZWGAVA OF ZZFT02-O.
           MOVE XWGBVA OF CUSTS-RECORD TO ZWGBVA OF ZZFT02-O.
           MOVE XWGCVA OF CUSTS-RECORD TO ZWGCVA OF ZZFT02-O.
           MOVE XWGDVA OF CUSTS-RECORD TO ZWGDVA OF ZZFT02-O.
           MOVE XWGEVA OF CUSTS-RECORD TO ZWGEVA OF ZZFT02-O.
           MOVE XWGFVA OF CUSTS-RECORD TO ZWGFVA OF ZZFT02-O.
           MOVE XWGGVA OF CUSTS-RECORD TO ZWGGVA OF ZZFT02-O.
           MOVE CUSNO  OF CUSTS-RECORD TO ZCUSNO OF ZZFT02-O.
       MVDBSC-EXIT. EXIT.

       ZORDER-ROUTINE.
           CALL "CBCONHDR"
                  USING XWBCCD OF ZZSF01-I.
       ZORDER-EXIT. EXIT.

       ZHISTO-ROUTINE.
           CALL "CBTRNHST"
                  USING XWBCCD OF ZZSF01-I.
       ZHISTO-EXIT. EXIT.

       VALID1-ROUTINE.
      *�in99 = ws-error
           MOVE SPACES     TO WS-ERRMSG
                              WS-ERROR.
           IF XWBCCD OF ZZSF01-I = SPACES
             MOVE "Y" TO WS-ERROR
             MOVE INDIC-ON  TO IN31 OF ZZFT01-O-INDIC
             MOVE "OEM0002" TO  MSGID
             CALL "RTNMSGTEXT"
                           USING  MSGID  WS-ERRMSG
             GO VALID1-EXIT
           END-IF.
      *�In ADD mode, Customer must not exist
           IF ACTDSP OF ZZFT01-O = "ADDITION"
              MOVE "Y" TO RECORD-FOUND
              MOVE ZWBCCD OF ZZFT01-I  TO  XWBCCD OF CUSTS-RECORD
              START CUSTS-FILE KEY EQUAL EXTERNALLY-DESCRIBED-KEY
                   INVALID KEY
                      MOVE "N" TO RECORD-FOUND
              END-START
              IF RECORD-FOUND = "N"
                 MOVE  INDIC-ON TO IN31 OF ZZFT01-O-INDIC
                 MOVE "Y2U0003" TO  MSGID
                 MOVE ALL "-"   TO ZWG4TX OF ZZFT01-O
                 CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
                 GO VALID1-EXIT
              END-IF
           END-IF

      *�Customer name
           IF ZWG4TX OF ZZFT01-I = SPACES
               MOVE INDIC-ON  TO  IN32 OF ZZFT01-O-INDIC
               MOVE "Y" TO WS-ERROR
               MOVE "N" TO RECORD-FOUND-CUSTS
               MOVE "OEM0012" TO  MSGID
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID1-EXIT
           END-IF

      *�Customer group
           MOVE ZWBNCD OF ZZFT01-I  TO  XWBNCD OF CUSGRP-RECORD
           MOVE "Y"  TO  RECORD-FOUND-CUSGRP
           READ  CUSGRP-FILE
                 INVALID KEY
                     MOVE "N"  TO  RECORD-FOUND-CUSGRP
           END-READ
           IF RECORD-FOUND-CUSGRP = "N"
               MOVE INDIC-ON  TO  IN33 OF ZZFT01-O-INDIC
               MOVE "OES0374" TO  MSGID
               MOVE ALL "-"   TO  XWKHTX OF CUSGRP-RECORD
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID1-EXIT
           END-IF

      *�Salesman
           MOVE ZPERSON OF ZZFT01-I  TO  PERSON OF SLMEN-RECORD
           MOVE "Y"  TO  RECORD-FOUND-SLMEN
           READ  SLMEN-FILE
                 INVALID KEY
                     MOVE "N"  TO  RECORD-FOUND-SLMEN
           END-READ
           IF RECORD-FOUND-SLMEN = "N"
               MOVE INDIC-ON  TO  IN34 OF ZZFT01-O-INDIC
               MOVE "OEM0023" TO  MSGID
               MOVE ALL "-"   TO  FT01-PNAME  OF ZZFT01-O
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID1-EXIT
           END-IF

      *�Distributor
           MOVE ZDSDCDE OF ZZFT01-I  TO  DSDCDE OF DISTS-RECORD
           MOVE "Y"  TO  RECORD-FOUND-DISTS
           READ  DISTS-FILE
                 INVALID KEY
                     MOVE "N"  TO  RECORD-FOUND-DISTS
           END-READ
           IF RECORD-FOUND-DISTS = "N"
               MOVE INDIC-ON  TO  IN35 OF ZZFT01-O-INDIC
               MOVE "OEM0018" TO  MSGID
               MOVE ALL "-"   TO DNAME  OF ZZFT01-O
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID1-EXIT
           END-IF.
       VALID1-EXIT. EXIT.

       VALID2-ROUTINE.
      *�in99 = ws-error
           MOVE SPACES     TO WS-ERRMSG
                              WS-ERROR.
      *�If in Change mode
           IF ACTDSP OF ZZFT02-O  NOT =  "ADDITION"
              SUBTRACT ZWGIVA OF ZZFT01-I  FROM ZWIDV0 OF ZZFT02-I
                   GIVING  WS-SDIFF
             IF WS-SDIFF < ZERO
                 MOVE "Y"  TO  WS-ERROR
                 MOVE INDIC-ON  TO IN36 OF ZZFT02-O-INDIC
                 MOVE "OES0373" TO MSGID
                 CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
                 GO VALID2-EXIT
             END-IF
           END-IF

      *�Customer cannot be zero
           IF ZCUSNO OF ZZFT02-I = ZEROS
               MOVE "Y"  TO  WS-ERROR
               MOVE INDIC-ON  TO IN37 OF ZZFT02-O-INDIC
               MOVE "CNP0008" TO  MSGID
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID2-EXIT
           END-IF

      *�Customer
           MOVE ZCUSNO  OF ZZFT02-I  TO  CUSNO  OF CUSFL3-RECORD
           MOVE "Y"  TO  RECORD-FOUND-CUSFL3
           READ  CUSFL3-FILE
                 INVALID KEY
                     MOVE "N"  TO  RECORD-FOUND-CUSFL3
           END-READ
           IF RECORD-FOUND-CUSFL3 = "N"
               MOVE INDIC-ON  TO  IN37 OF ZZFT02-O-INDIC
               MOVE "CNP0002" TO  MSGID
               CALL "RTNMSGTEXT"  USING  MSGID  WS-ERRMSG
               GO VALID2-EXIT
           END-IF.
       VALID2-EXIT. EXIT.

       MVSCDB-ROUTINE.
           MOVE ZWBCCD OF ZZFT01-O  TO  XWBCCD OF CUSTS-RECORD.
           MOVE ZWG4TX OF ZZFT01-O  TO  XWG4TX OF CUSTS-RECORD.
           MOVE ZWB2CD OF ZZFT01-O  TO  XWB2CD OF CUSTS-RECORD.
           MOVE ZWB3CD OF ZZFT01-O  TO  XWB3CD OF CUSTS-RECORD.
           MOVE ZWHITX OF ZZFT01-O  TO  XWHITX OF CUSTS-RECORD.
           MOVE ZWE0NB OF ZZFT01-O  TO  XWE0NB OF CUSTS-RECORD.
           MOVE ZWJUN0  OF ZZFT01-O  TO  XWJUN0 OF CUSTS-RECORD.
           MOVE ZWDVCD  OF ZZFT01-O  TO  XWDVCD OF CUSTS-RECORD.
           MOVE ZWBNCD  OF ZZFT01-O  TO  XWBNCD OF CUSTS-RECORD.
           MOVE ZPERSON OF ZZFT01-O  TO  PERSON OF CUSTS-RECORD.
           MOVE ZDSDCDE OF ZZFT01-O  TO  DSDCDE OF CUSTS-RECORD.
           MOVE ZWBTCD  OF ZZFT01-O  TO  XWBTCD OF CUSTS-RECORD.
           MOVE ZWGIVA  OF ZZFT01-O  TO  XWGIVA OF CUSTS-RECORD.
           MOVE ZWAOCD  OF ZZFT01-O  TO  XWAOCD OF CUSTS-RECORD.
           MOVE ZWBBCD  OF ZZFT01-O  TO  XWBBCD OF CUSTS-RECORD.
           MOVE ZWG4T0  OF ZZFT01-O  TO  XWG4T0 OF CUSTS-RECORD.
           MOVE ZWC7ST  OF ZZFT01-O  TO  XWC7ST OF CUSTS-RECORD.
           MOVE ZWDAST  OF ZZFT01-O  TO  XWDAST OF CUSTS-RECORD.
           MOVE ZWBPD0  OF ZZFT01-O  TO  XWBPD0 OF CUSTS-RECORD.
           MOVE ZWBAD0  OF ZZFT01-O  TO  XWBAD0 OF CUSTS-RECORD.
      *    MOVE ZWKHTX  OF ZZFT01-O  TO  XWKHTX OF CUSTS-RECORD.
           MOVE ZWF0VA  OF ZZFT02-O  TO  XWF0VA OF CUSTS-RECORD.
           MOVE ZWASDT  OF ZZFT02-O  TO  XWASDT OF CUSTS-RECORD.
           MOVE ZWF0V0  OF ZZFT02-O  TO  XWF0V0 OF CUSTS-RECORD.
           MOVE ZWBQDT  OF ZZFT02-O  TO  XWBQDT OF CUSTS-RECORD.
           MOVE ZWF1VA  OF ZZFT02-O  TO  XWF1VA OF CUSTS-RECORD.
           MOVE ZWF1V0  OF ZZFT02-O  TO  XWF1V0 OF CUSTS-RECORD.
           MOVE ZWF2VA  OF ZZFT02-O  TO  XWF2VA OF CUSTS-RECORD.
           MOVE ZWF3VA  OF ZZFT02-O  TO  XWF3VA OF CUSTS-RECORD.
           MOVE ZWF4VA  OF ZZFT02-O  TO  XWF4VA OF CUSTS-RECORD.
           MOVE ZWF6VA  OF ZZFT02-O  TO  XWF6VA OF CUSTS-RECORD.
           MOVE ZWIDV0  OF ZZFT02-O  TO  XWIDV0 OF CUSTS-RECORD.
           MOVE ZWGAVA  OF ZZFT02-O  TO  XWGAVA OF CUSTS-RECORD.
           MOVE ZWGBVA  OF ZZFT02-O  TO  XWGBVA OF CUSTS-RECORD.
           MOVE ZWGCVA  OF ZZFT02-O  TO  XWGCVA OF CUSTS-RECORD.
           MOVE ZWGDVA  OF ZZFT02-O  TO  XWGDVA OF CUSTS-RECORD.
           MOVE ZWGEVA  OF ZZFT02-O  TO  XWGEVA OF CUSTS-RECORD.
           MOVE ZWGFVA  OF ZZFT02-O  TO  XWGFVA OF CUSTS-RECORD.
           MOVE ZWGGVA  OF ZZFT02-O  TO  XWGGVA OF CUSTS-RECORD.
           MOVE ZCUSNO  OF ZZFT02-O  TO  CUSNO  OF CUSTS-RECORD.
       MVSCDB-EXIT. EXIT.

       SRPROM-ROUTINE.
           EVALUATE TRUE
              WHEN SFIELD OF ZZFT02-I = "ZPERSON"
                CALL "SLMENSEL" USING ZPERSON OF ZZFT01-I
                                      FT01-PNAME OF ZZFT01-O
              WHEN SFIELD OF ZZFT02-I = "ZCUSNO"
                CALL "CUSFSEL" USING WSCUSPRM
                IF WSCUSPRM NOT = ZEROS
                   MOVE WSCUSPRM TO ZCUSNO OF ZZFT02-O
                END-IF
              WHEN SFIELD OF ZZFT02-I = "ZWBNCD"
                CALL "CUSGRSEL" USING ZWBNCD OF ZZFT01-O
                                      ZWKHTX OF ZZFT01-O
              WHEN SFIELD OF ZZFT02-I = "ZDSDCDE"
                CALL "DISTSSEL" USING ZDSDCDE OF ZZFT01-O
                                      DNAME OF ZZFT01-O

           END-EVALUATE.

       SRPROM-EXIT. EXIT.

