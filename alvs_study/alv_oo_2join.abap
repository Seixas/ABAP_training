*&---------------------------------------------------------------------*
*& Report ZALV_OBJECT_EX
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZALV_OBJECT_EX MESSAGE-ID oo.

************************************************************************
**   Referencias Globais para as classes                              **
************************************************************************
DATA: gr_table     TYPE REF TO cl_salv_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_display   TYPE REF TO cl_salv_display_settings.


************************************************************************
**   Data Declarations                                                **
************************************************************************

DATA : lv_cnt TYPE i.

*--------------------------------------------------------------------*
* Types / structure
*--------------------------------------------------------------------*

TYPES: BEGIN OF ty_joindata,
   carrname TYPE scarr-carrname,
   connid   TYPE spfli-connid,
   fldate   TYPE sflight-fldate,
 END OF ty_joindata.

*--------------------------------------------------------------------*
*workarea
*--------------------------------------------------------------------*
*DATA: wa_joindata TYPE ty_joindata,

*--------------------------------------------------------------------*
*Tabela interna
*--------------------------------------------------------------------*

DATA itab TYPE TABLE OF ty_joindata.

*--------------------------------------------------------------------*
* SELECT OPTIONS EVENT
*--------------------------------------------------------------------*
*SELECT-OPTIONS:  s_cityfr   FOR   spfli-cityfrom,
*                 s_cityto   FOR   spfli-cityto.

PARAMETERS: p_cityfr TYPE spfli-cityfrom, "de cidade
            p_cityto TYPE spfli-cityto,   "para cidade
            p_datum  LIKE sy-datum.


************************************************************************
**   Blocos de processamento                                          **
************************************************************************
START-OF-SELECTION.

* Filling the data internal table.

"o que queremos mostrar/guardar
*SELECT  c~carrname, " Nome de uma companhia aérea da SCARR - Companhia aérea
*        p~connid,   " Código da conexão de vôo individual da SPFLI - Horário de vôos
*        f~fldate,    " Data do voo da SFLIGHT - Vôo
SELECT  *
"como e onde pegar esses dados que necessitamos
       FROM ( ( SCARR AS c
                INNER JOIN SPFLI   AS p ON p~carrid   = c~carrid
                                       AND p~cityfrom = @p_cityfr
                                       AND p~cityto   = @p_cityto ) "1st join
                INNER JOIN SFLIGHT AS f ON f~carrid = p~carrid
                                       AND f~connid = p~connid  )   "2nd join, depends on first one
"caso precisemos refinar a pesquisa, podemos adicionar filtros
       WHERE f~fldate < @p_datum
"passamos o resultado pra uma tabela interna, da qual só existe em memória durante a execução do programa
       INTO TABLE @data(allitab).
       "INTO CORRESPONDING FIELDS OF TABLE @itab.

  DESCRIBE TABLE itab    LINES lv_cnt. "contando numero de registros do resultado da query
  DESCRIBE TABLE allitab LINES lv_cnt. "contando numero de registros do resultado da query

  cl_salv_table=>factory( IMPORTING r_salv_table = gr_table
                          CHANGING  t_table = allitab ).

  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_list_header( 'Heading customizado' ).
  gr_display->set_striped_pattern( abap_true ).

*--------------------------------------------------------------------*
* TOP OF PAGE
*--------------------------------------------------------------------*
DATA: lr_header        TYPE REF TO cl_salv_form_element,
      lr_grid_layout   TYPE REF TO cl_salv_form_layout_grid,
      lr_label         TYPE REF TO cl_salv_form_label,
      lr_text          TYPE REF TO cl_salv_form_text,
      l_text           TYPE string.
  CREATE OBJECT lr_grid_layout.
  l_text = 'Viagens'.
  lr_grid_layout->create_header_information(
    row    = 1
    column = 3
    text    = l_text
    tooltip = l_text ).
  lr_grid_layout->add_row( ).
*  lr_grid_layout_1 = lr_grid_layout->create_grid(
*                row    = 3
*                column = 1 ).
  lr_label = lr_grid_layout->create_label(
    row     = 2
    column  = 1
    text    = 'Numero de resultados encontrados: '
    tooltip = 'Numero de resultados econtrados conforme o filtro' ).
  lr_text = lr_grid_layout->create_text(
    row     = 2
    column  = 2
    text    = lv_cnt
    tooltip = lv_cnt ).
  lr_label->set_label_for( lr_text ).
  lr_label = lr_grid_layout->create_label(
    row    = 3
    column = 1
    text    = 'Data : '
    tooltip = 'Data' ).
  data(gd_date) = sy-datum.
  CALL FUNCTION 'CONVERSION_EXIT_LDATE_OUTPUT'
    EXPORTING
      input   = gd_date
    IMPORTING
      output  = gd_date.

  DATA month_name TYPE TABLE OF t247 WITH HEADER LINE.
  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language      = sy-langu
    TABLES
      month_names   = month_name.

  DATA(mm)  = p_datum+4(2).
  READ TABLE month_name INDEX mm.
  DATA(mes) = month_name-ltx.

  DATA(date_string) = |{ p_datum+6(2) } { mes(3) } { p_datum(4) }|.
  l_text = date_string.
  lr_text = lr_grid_layout->create_text(
    row    = 3
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).
  lr_header = lr_grid_layout.

CALL METHOD gr_table->set_top_of_list
    EXPORTING
      value = lr_header.

*--------------------------------------------------------------------*
* FOOTER
*--------------------------------------------------------------------*
DATA: lr_footer TYPE REF TO cl_salv_form_header_info.
  CLEAR l_text.
  l_text = 'FOOTER'.
  CREATE OBJECT lr_footer
    EXPORTING
      text    = l_text
      tooltip = l_text.
  gr_table->set_end_of_list( lr_footer ).

*mostrando realmente o ALV montado, junto com o header e footer
gr_table->display( ).
