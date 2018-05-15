*&---------------------------------------------------------------------*
*& Report  ZBATCHINPUT_SEIXAS
*&---------------------------------------------------------------------*
*& Descrição: Programa modelo de batch-input
*& Data: 14/05/2018 - Autor: Seixas
*&---------------------------------------------------------------------*

REPORT  ZBATCHINPUT_SEIXAS.

INCLUDE ZBATCHINPUT_SEIXAS_TOP.

*--------------------------------------------------------------------*
* Selection Screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS p_file type string.
SELECTION-SCREEN END OF BLOCK blk1.

*--------------------------------------------------------------------*
* AT SELECTION-SCREEN event
*--------------------------------------------------------------------*
AT SELECTION-SCREEN on VALUE-REQUEST FOR p_file. "habilita match-code para pesquisa

  "localiza o arquivo
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      WINDOW_TITLE      = 'Usuário'
      DEFAULT_EXTENSION = 'TXT'
      DEFAULT_FILE_NAME = p_file
    IMPORTING
      FULLPATH          = p_file.

*--------------------------------------------------------------------*
* start of selection event
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM F_CARREGA_ARQUIVO.

  PERFORM F_PROCESSA_DADOS.

*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       Carrega o arquivo de funcionário
*----------------------------------------------------------------------*
FORM F_CARREGA_ARQUIVO .
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = P_FILE
    TABLES
      DATA_TAB                      = TI_USER
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_READ_ERROR               = 2
     NO_BATCH                      = 3
     GUI_REFUSE_FILETRANSFER       = 4
     INVALID_TYPE                  = 5
     NO_AUTHORITY                  = 6
     UNKNOWN_ERROR                 = 7
     BAD_DATA_FORMAT               = 8
     HEADER_NOT_ALLOWED            = 9
     SEPARATOR_NOT_ALLOWED         = 10
     HEADER_TOO_LONG               = 11
     UNKNOWN_DP_ERROR              = 12
     ACCESS_DENIED                 = 13
     DP_OUT_OF_MEMORY              = 14
     DISK_FULL                     = 15
     DP_TIMEOUT                    = 16
     OTHERS                        = 17.
            .
  "BREAK-POINT.
	
  IF SY-SUBRC <> 0.
    MESSAGE 'Erro ao carregar o arquivo' TYPE 'I' DISPLAY LIKE 'E'.
    STOP. "para o programa depois da Informação, se for Error não precisa desse comando (obsoleto)
  ENDIF.

ENDFORM.                    " F_CARREGA_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
*       Processa dados do Batch-input
*----------------------------------------------------------------------*
FORM F_PROCESSA_DADOS .

  LOOP AT TI_USER INTO WA_USER.
    "WRITE: / wa_user.
    PERFORM F_CARREGA_BDCDATA USING: 'X' 'SAPLSUU5'    '0050', "Verificamos os parametros pela SHDB depois de algum record, linha 2 e por ai vai
                                     ' ' 'BDC_OKCODE'  '=CHAN',
                                     ' ' 'USR02-BNAME' WA_USER-USUARIO.
* boas praticas separar por steps de acoro com a SHDB.
    PERFORM F_CARREGA_BDCDATA USING: 'X' 'SAPLSUU5'   '0100',
                                     ' ' 'BDC_OKCODE' '=UPD',
                                     ' ' 'ADDR3_DATA-DEPARTMENT' WA_USER-DEPTO.
  ENDLOOP.

    PERFORM F_CARREGA_BDCDATA USING: 'X' 'SAPLSUU5'   '0050',
                                     ' ' 'BDC_OKCODE' '/EBACK'.

  WA_PARAMS-DISMODE  = 'N'. "A - Visivel(para teste) N - Background(para prod)
  WA_PARAMS-RACOMMIT = 'X'.

  CALL TRANSACTION 'SU01'
                   USING TI_BDC
                   OPTIONS FROM WA_PARAMS
                   MESSAGES INTO TI_MSG.

* impressao do log de retorn
  LOOP AT TI_MSG INTO WA_MSG.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
       MSGID                     = WA_MSG-MSGID
       MSGNR                     = WA_MSG-MSGNR
       MSGV1                     = WA_MSG-MSGV1
       MSGV2                     = WA_MSG-MSGV2
       MSGV3                     = WA_MSG-MSGV3
       MSGV4                     = WA_MSG-MSGV4
     IMPORTING
       MESSAGE_TEXT_OUTPUT       = VG_TEXTO.

    IF WA_MSG-MSGTYP = 'S'.
      WRITE: /3 ICON_GREEN_LIGHT AS ICON,
                VG_TEXTO.
    ELSE.
      WRITE: /3 ICON_RED_LIGHT AS ICON,
                VG_TEXTO.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_PROCESSA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_BDCDATA
*&---------------------------------------------------------------------*
*       Carrega BDCDATA
*----------------------------------------------------------------------*
FORM F_CARREGA_BDCDATA USING P_X P_1 P_2.

  IF P_X = 'X'.
    WA_BDC-PROGRAM  = P_1.
    WA_BDC-DYNPRO   = P_2.
    WA_BDC-DYNBEGIN = P_X.
  ELSE.
    WA_BDC-FNAM     = P_1.
    WA_BDC-FVAL     = P_2.
  ENDIF.
  APPEND WA_BDC TO TI_BDC.
  CLEAR  WA_BDC.

ENDFORM.                    " F_CARREGA_BDCDATA
