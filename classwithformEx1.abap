class ZCLASSE_SEIXAS definition
  public
  final
  create public .

public section.
*"* public components of class ZCLASSE_SEIXAS
*"* do not include other source files here!!!

  methods CALCULO_DATAS
    importing
      !DATA1 type SY-DATUM
      !DATA2 type SY-DATUM
    exporting
      !RESULTADO type I
    exceptions
      DATA1_MAIOR .
  methods DATA_SEMANA .
protected section.
*"* protected components of class ZCLASSE_SEIXAS
*"* do not include other source files here!!!
private section.
*"* private components of class ZCLASSE_SEIXAS
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCLASSE_SEIXAS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLASSE_SEIXAS->CALCULO_DATAS
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA1                          TYPE        SY-DATUM
* | [--->] DATA2                          TYPE        SY-DATUM
* | [<---] RESULTADO                      TYPE        I
* | [EXC!] DATA1_MAIOR
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CALCULO_DATAS.

  IF DATA2 < DATA1.
    RAISE DATA1_MAIOR.
  ENDIF.

  RESULTADO = DATA2 - DATA1.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLASSE_SEIXAS->DATA_SEMANA
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DATA_SEMANA.
endmethod.
ENDCLASS.



*&---------------------------------------------------------------------*
*& Report  ZMETODO_SEIXAS
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMETODO_SEIXAS.

PARAMETERS: P_DATA1 TYPE SY-DATUM,
            P_DATA2 TYPE SY-DATUM.

START-OF-SELECTION.

DATA: vl_result TYPE I.

DATA cl_class TYPE REF TO ZCLASSE_SEIXAS.

  CALL METHOD cl_class->CALCULO_DATAS
    EXPORTING
      DATA1     = P_DATA1
      DATA2     = P_DATA2
   IMPORTING
      RESULTADO = VL_RESULT.

WRITE VL_RESULT.
