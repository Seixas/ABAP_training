*----------------------------------------------------------------------*
*                              xxxx                                    *
*----------------------------------------------------------------------*
* Author.....: Lucas Seixas                                            *
* Date.......: 23.05.2018                                              *
* Module.....:                                                         *
* Project....:                                                         *
* Description:                                                         *
*----------------------------------------------------------------------*
REPORT ZCARALVOO_LUCAS MESSAGE-ID oo.

************************************************************************
**   Referencias Globais para as classes                              **
************************************************************************
DATA: gr_table     TYPE REF TO cl_salv_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_display   TYPE REF TO cl_salv_display_settings.


************************************************************************
**   Data Declarations                                                **
************************************************************************
TABLES: zcar_lucas,
        zcarloc_lucas.

DATA : LV_CNT TYPE I.

*--------------------------------------------------------------------*
* Types / structure
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_joindata,
        idloc    TYPE zcarloc_lucas-idloc,
        ano      TYPE zcar_lucas-ano,
        placa    TYPE zcar_lucas-placa,
        carro    TYPE zcarloc_lucas-carro,
        dtini    TYPE zcarloc_lucas-dtini,
        dtfim    TYPE zcarloc_lucas-dtfim,
      END OF ty_joindata.

*--------------------------------------------------------------------*
*workarea
*--------------------------------------------------------------------*
DATA: wa_joindata TYPE ty_joindata,
      wa_aloc     TYPE zcarloc_lucas,
      wa_car      TYPE zcar_lucas.

*--------------------------------------------------------------------*
*Tabela interna
*--------------------------------------------------------------------*
DATA ti_joindata TYPE TABLE OF ty_joindata.

*--------------------------------------------------------------------*
* SELECT OPTIONS EVENT
*--------------------------------------------------------------------*
SELECT-OPTIONS  s_ano   FOR   zcar_lucas-ano.
SELECT-OPTIONS  s_placa FOR   zcar_lucas-placa.
SELECT-OPTIONS  s_preco FOR   zcar_lucas-preco.
SELECT-OPTIONS  s_idloc FOR   zcarloc_lucas-idloc.
SELECT-OPTIONS  s_carro FOR   zcarloc_lucas-carro.


************************************************************************
**   Blocos de processamento                                          **
************************************************************************
START-OF-SELECTION.

* Filling the data internal table.
  SELECT  *
        FROM  zcar_lucas as car
  INNER JOIN  zcarloc_lucas as carloc
        on    car~placa = carloc~placa
        "INTO TABLE ti_joindata
        INTO CORRESPONDING FIELDS OF TABLE ti_joindata
        "WHERE car~placa = p_placa.
        WHERE car~ano IN s_ano
              and car~placa IN s_placa
              and car~preco IN s_preco
              and carloc~idloc IN s_idloc
              and carloc~carro IN s_carro.
  DESCRIBE TABLE ti_joindata LINES LV_CNT. "contando numero de registros do resultado da query


  cl_salv_table=>factory( IMPORTING r_salv_table = gr_table CHANGING t_table = ti_joindata ).

  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_list_header( 'Heading customizado' ).
  gr_display->set_striped_pattern( abap_true ).

*--------------------------------------------------------------------*
* TOP OF PAGE
*--------------------------------------------------------------------*
DATA: LR_HEADER        TYPE REF TO CL_SALV_FORM_ELEMENT,
      LR_GRID_LAYOUT   TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
      LR_LABEL         TYPE REF TO CL_SALV_FORM_LABEL,
      LR_TEXT          TYPE REF TO CL_SALV_FORM_TEXT,
      L_TEXT           TYPE STRING.
  CREATE OBJECT LR_GRID_LAYOUT.
  L_TEXT = 'Locações'.
  LR_GRID_LAYOUT->CREATE_HEADER_INFORMATION(
    ROW    = 1
    COLUMN = 3
    TEXT    = L_TEXT
    TOOLTIP = L_TEXT ).
  LR_GRID_LAYOUT->ADD_ROW( ).
*  LR_GRID_LAYOUT_1 = LR_GRID_LAYOUT->CREATE_GRID(
*                ROW    = 3
*                COLUMN = 1 ).
  LR_LABEL = LR_GRID_LAYOUT->CREATE_LABEL(
    ROW     = 2
    COLUMN  = 1
    TEXT    = 'Numero de resultados encontrados: '
    TOOLTIP = 'Numero de resultados econtrados conforme o filtro' ).
  LR_TEXT = LR_GRID_LAYOUT->CREATE_TEXT(
    ROW     = 2
    COLUMN  = 2
    TEXT    = LV_CNT
    TOOLTIP = LV_CNT ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_LABEL = LR_GRID_LAYOUT->CREATE_LABEL(
    ROW    = 3
    COLUMN = 1
    TEXT    = 'Data : '
    TOOLTIP = 'Data' ).
  L_TEXT = SY-DATUM.
  LR_TEXT = LR_GRID_LAYOUT->CREATE_TEXT(
    ROW    = 3
    COLUMN = 2
    TEXT    = L_TEXT
    TOOLTIP = L_TEXT ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_HEADER = LR_GRID_LAYOUT.

CALL METHOD gr_table->SET_TOP_OF_LIST
    EXPORTING
      VALUE = LR_HEADER.

*--------------------------------------------------------------------*
* FOOTER
*--------------------------------------------------------------------*
DATA: LR_FOOTER TYPE REF TO CL_SALV_FORM_HEADER_INFO.
  CLEAR L_TEXT.
  L_TEXT = 'FOOTER'.
  CREATE OBJECT LR_FOOTER
    EXPORTING
      TEXT    = L_TEXT
      TOOLTIP = L_TEXT.
  gr_table->SET_END_OF_LIST( LR_FOOTER ).

*mostrando realmente o ALV montado, junto com o header e footer
gr_table->display( ).
