*&---------------------------------------------------------------------*
*& Report  ZCALC_SEIXAS
*&---------------------------------------------------------------------*
*& Author: Seixas
*& Date: 07/05/2018
*&---------------------------------------------------------------------*

REPORT  ZCALC_SEIXAS.

TABLES : sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK rad1
                          WITH FRAME TITLE title.

DATA: result TYPE i,
      error TYPE c LENGTH 20.

PARAMETERS: numone TYPE i,
            numtwo TYPE i,
            radio1 RADIOBUTTON GROUP q1gr,
            radio2 RADIOBUTTON GROUP q1gr,
            radio3 RADIOBUTTON GROUP q1gr,
            radio4 RADIOBUTTON GROUP q1gr.

IF radio1 = 'X'.
  result = numone + numtwo.
  WRITE / result.
ELSEIF radio2 = 'X'.
  result = numone - numtwo.
  WRITE / result.
ELSEIF radio3 = 'X'.
  result = numone * numtwo.
  WRITE / result.
ELSEIF radio4 = 'X'.
  TRY. "cl_demo_output=>
    result = numone / numtwo.
    WRITE / result.
  CATCH cx_sy_arithmetic_error.
    WRITE / 'Nao é possivel dividir por 0'.
  ENDTRY.
ENDIF.

SELECTION-SCREEN END OF BLOCK rad1.

INITIALIZATION.
  title = 'CALCULADORA'.
