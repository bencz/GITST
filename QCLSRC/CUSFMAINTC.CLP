             PGM
             DCL        VAR(&CUSTOMER) TYPE(*DEC) LEN(5 0) VALUE(0)
             DCL        VAR(&UPDATED) TYPE(*CHAR) LEN(1) VALUE(' ')

             ADDLIBLE   LIB(XAN4TUTOR) POSITION(*LAST)
             MONMSG     MSGID(CPF0000)

             CALL       PGM(*LIBL/CUSFMAINT) PARM(&CUSTOMER &UPDATED)
        /*   MONMSG     MSGID(CPF0000)   */

             ENDPGM
