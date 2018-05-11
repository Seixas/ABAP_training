~include ZCOMPRAS_SEIXAS_top~
*&---------------------------------------------------------------------*
*&  Include           ZCOMPRAS_SEIXAS_TOP
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
*Tables
*--------------------------------------------------------------------*
TABLES: ekko,
        ekpo,
        ekbe. "history per doc num, usefull fields gjahr belnr buzei

*--------------------------------------------------------------------*
* Types / structure
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_joindata,
        ebeln TYPE ekko-ebeln,
        bsart TYPE ekko-bsart,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
      END OF ty_joindata.


*--------------------------------------------------------------------*
*workarea
*--------------------------------------------------------------------*
DATA: wa_joindata TYPE ty_joindata,
      wa_alv      TYPE ty_joindata,
      wa_fieldcat TYPE slis_fieldcat_alv.

*--------------------------------------------------------------------*
*Tabela interna
*--------------------------------------------------------------------*
DATA: ti_joindata TYPE TABLE OF ty_joindata,
      ti_alv      TYPE TABLE OF ty_joindata,
      ti_fieldcat TYPE slis_t_fieldcat_alv. "sem table of, a estrutura já é uma tabela

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*&---------------------------------------------------------------------*
*& Report  ZCOMPRAS_SEIXAS
*&---------------------------------------------------------------------*

REPORT  ZCOMPRAS_ALV_SEIXAS.

INCLUDE ZCOMPRAS_SEIXAS_top.

PERFORM seleciona_dados.
PERFORM imprime_dados.
PERFORM exibe_alv.


*--------------------------------------------------------------------*
* selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN begin of BLOCK blk1 WITH FRAME TITLE text-001.

  "PARAMETERS:     p_kunnr TYPE  kna1-kunnr.
  SELECT-OPTIONS  s_ebeln FOR   ekko-ebeln. "ty_joindata-ebeln

SELECTION-SCREEN END OF BLOCK blk1.

*--------------------------------------------------------------------*
* start of selection event
*--------------------------------------------------------------------*
START-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECIONA_DADOS .
*   Fetch data from ekko
  "open sql
  SELECT  po~ebeln po~ebelp ko~bsart po~matnr
          FROM  ekko as ko
    INNER JOIN  ekpo as po
          on    ko~ebeln = po~ebeln
    "we can use EKBE too, with left outer in EKPO on ebeln and ebelp
          "INTO TABLE ti_joindata
          INTO CORRESPONDING FIELDS OF TABLE ti_joindata
          WHERE ko~ebeln IN s_ebeln.

  IF sy-subrc NE 0.
    "MESSAGE iNumber.
    WRITE / 'Error while joining tables ekko ekpo'.
    LEAVE LIST-PROCESSING.
  ELSE.
    WRITE: 'SY-SUBRC: ', sy-subrc.
    SORT ti_joindata BY ebeln.
  ENDIF.
ENDFORM.        " SELECIONA_DADOS

*&---------------------------------------------------------------------*
*&      Form  IMPRIME_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM IMPRIME_DADOS .

*if ti_joindata[] is INITIAL. "STUDY doc

*  grava tabela de saida do ALV
  LOOP AT ti_joindata INTO wa_joindata.

    WA_ALV-EBELN = wa_joindata-ebeln.
    WA_ALV-bsart = wa_joindata-bsart.
    WA_ALV-ebelp = wa_joindata-ebelp.
    WA_ALV-matnr = wa_joindata-matnr.
    APPEND wa_alv TO ti_alv.

  ENDLOOP.
ENDFORM.                    " IMPRIME_DADOS

*&---------------------------------------------------------------------*
*&      Form  EXIBE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIBE_ALV .

   "preenchimento do fieldcat
  REFRESH ti_fieldcat. "fieldcat = catalogo de campos

  wa_fieldcat-col_pos   = 1.
  wa_fieldcat-tabname   = 'TI_ALV'.
  wa_fieldcat-fieldname = 'EBELN'.
  wa_fieldcat-outputlen = 12.
  wa_fieldcat-seltext_L = 'Doc.Compras'.
  APPEND wa_fieldcat TO ti_fieldcat.

  wa_fieldcat-col_pos   = 2.
  wa_fieldcat-tabname   = 'TI_ALV'.
  wa_fieldcat-fieldname = 'EBELP'.
  wa_fieldcat-outputlen = 04.
  wa_fieldcat-seltext_L = 'Item'.
  APPEND wa_fieldcat TO ti_fieldcat.

  wa_fieldcat-col_pos   = 3.
  wa_fieldcat-tabname   = 'TI_ALV'.
  wa_fieldcat-fieldname = 'BSART'.
  wa_fieldcat-outputlen = 04.
  wa_fieldcat-seltext_L = 'Tp.Doc'.
  APPEND wa_fieldcat TO ti_fieldcat.

  wa_fieldcat-col_pos   = 4.
  wa_fieldcat-tabname   = 'TI_ALV'.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-outputlen = 20.
  wa_fieldcat-seltext_L = 'Material'.
  APPEND wa_fieldcat TO ti_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "click modelo/pattern
   EXPORTING
     it_fieldcat = TI_FIELDCAT
    TABLES
      T_OUTTAB   = TI_ALV
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2.
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " EXIBE_ALV
