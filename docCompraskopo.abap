*&---------------------------------------------------------------------*
*& Report  ZCOMPRAS_SEIXAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCOMPRAS_SEIXAS.

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
DATA wa_joindata TYPE ty_joindata.

*--------------------------------------------------------------------*
*Tabela interna
*--------------------------------------------------------------------*
DATA ti_joindata TYPE TABLE OF ty_joindata.


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

* Fetch data from ekko
"open sql
SELECT  ko~ebeln po~ebelp ko~bsart po~matnr
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

*if ti_joindata[] is INITIAL. "STUDY doc

LOOP AT ti_joindata INTO wa_joindata.
  WRITE: /  wa_joindata-ebeln,
            wa_joindata-bsart,
            wa_joindata-ebelp,
            wa_joindata-matnr.
  ULINE.
ENDLOOP.
