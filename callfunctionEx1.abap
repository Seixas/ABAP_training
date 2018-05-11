*&---------------------------------------------------------------------*
*& Report  ZFUNCAO_SEIXAS
*&---------------------------------------------------------------------*
*& Description: Modelo de função para mostrar o ultimo dia do mes
*& Date: 10/05/18 - Author: Seixas
*&---------------------------------------------------------------------*

REPORT  ZFUNCAO_SEIXAS.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
  PARAMETERS p_data TYPE sy-datum.
SELECTION-SCREEN end of BLOCK blk1.

START-OF-SELECTION.

DATA vl_date TYPE sy-datum.

CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
  EXPORTING
    DAY_IN                  = P_DATA  "entrando
  IMPORTING
   LAST_DAY_OF_MONTH        = vl_date "saindo
  EXCEPTIONS
    DAY_IN_NO_DATE          = 1
    OTHERS                  = 2
          .
IF SY-SUBRC <> 0.
  MESSAGE 'Problemas na funcao'(001) TYPE 'E'.
ENDIF.

WRITE: 'O ultimo dia do mes e: '(002), vl_date.
