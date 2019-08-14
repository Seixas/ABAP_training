*---------------------------------------------------------------------------
* Report     : ZXXXX
* Cliente    : xxxx
* Módulo     : FI-GL
* Transação  : ZXXXX
* Descrição  : Relatório de leitura da tabela REGUP
*              para atender a área usuária.
* Responsável: xxxxx
* Autor      : Lucas Seixas                                 Data: xx/xx/2019
*---------------------------------------------------------------------------
* Histórico de Alterações:
*---------------------------------------------------------------------------
* Data       |Change #    |Autor                  |Alteração
*---------------------------------------------------------------------------
* 07/08/2019 |xxxxxxxxxxx |Lucas Seixas           |Desenvolvimento Inicial
* dd/mm/aaaa |            |Codificador02          |Descrição da Alteração
*---------------------------------------------------------------------------
REPORT zxxxx MESSAGE-ID oo.

************************************************************************
**   Global class references                                          **
************************************************************************
DATA: gr_table     TYPE REF TO cl_salv_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_display   TYPE REF TO cl_salv_display_settings.


************************************************************************
**  Data Declarations                                                **
************************************************************************
TABLES: regup.

DATA : lv_cnt TYPE i.

*--------------------------------------------------------------------*
* Types / structures
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_regup,
         bukrs TYPE regup-bukrs,
         laufd TYPE regup-laufd,
         dmbtr TYPE regup-dmbtr,
         hbkid TYPE regup-hbkid,
         belnr TYPE regup-belnr,
       END OF ty_regup.

*--------------------------------------------------------------------*
* Workareas
*--------------------------------------------------------------------*
DATA: wa_regup TYPE ty_regup.

*--------------------------------------------------------------------*
* Internal tables
*--------------------------------------------------------------------*
DATA ti_regup TYPE TABLE OF ty_regup.

*--------------------------------------------------------------------*
* SELECT OPTIONS and PARAMETERS EVENTS
*--------------------------------------------------------------------*
  SELECTION-SCREEN BEGIN OF BLOCK block1
                            WITH FRAME TITLE title.

  "PARAMETERS      p_bukrs   TYPE   regup-bukrs.
  SELECT-OPTIONS  s_bukrs    FOR   regup-bukrs.
  SELECT-OPTIONS  s_laufd    FOR   regup-laufd.

  SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  title = 'Seleção'.

************************************************************************
**   Processing block                                                 **
************************************************************************
START-OF-SELECTION.

  SELECT  bukrs
          laufd
          dmbtr
          hbkid
          belnr
        FROM  regup INTO TABLE ti_regup
        WHERE "bukrs = p_bukrs
              bukrs IN s_bukrs AND
              laufd IN s_laufd.

  DESCRIBE TABLE ti_regup LINES lv_cnt. "contando numero de registros do resultado da query

  SORT ti_regup BY laufd.

  cl_salv_table=>factory( IMPORTING r_salv_table  = gr_table
                          CHANGING  t_table       = ti_regup ).

  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_list_header( 'Heading customizado' ).
  gr_display->set_striped_pattern( abap_true ).

*--------------------------------------------------------------------*
* TOP OF PAGE
*--------------------------------------------------------------------*
  DATA: lr_header      TYPE REF TO cl_salv_form_element,
        lr_text        TYPE REF TO cl_salv_form_text,
        lr_label       TYPE REF TO cl_salv_form_label,
        lr_h_flow      TYPE REF TO cl_salv_form_layout_flow,
        lr_h_logo      TYPE REF TO cl_salv_form_layout_logo,
        l_text         TYPE string,
        texto_empresas TYPE string,
        texto_datas    TYPE string.

  DATA(lr_grid_layout) = NEW cl_salv_form_layout_grid( ).
  DATA(lr_logo)        = NEW cl_salv_form_layout_logo( ).

  CONCATENATE  sy-datum+6(2)
               sy-datum+4(2)
               sy-datum(4)
               INTO data(data_formatada)
               SEPARATED BY '/'.

  CONCATENATE  s_laufd-low+6(2)
               s_laufd-low+4(2)
               s_laufd-low(4)
               INTO data(data_de)
               SEPARATED BY '/'.

  CONCATENATE  s_laufd-high+6(2)
               s_laufd-high+4(2)
               s_laufd-high(4)
               INTO data(data_ate)
               SEPARATED BY '/'.

  IF s_bukrs-low IS NOT INITIAL AND  s_bukrs-high IS NOT INITIAL.
    texto_empresas = |{ s_bukrs-low } até { s_bukrs-high }|.
  ELSEIF s_bukrs IS INITIAL.
    texto_empresas = 'Todas'.
  ELSE.
    texto_empresas = s_bukrs-low.
  ENDIF.

  IF s_laufd-low IS NOT INITIAL AND  s_laufd-high IS NOT INITIAL.
    texto_datas = |{ data_de } até { data_ate }|.
  ELSEIF s_laufd IS INITIAL.
    texto_datas = 'Todas'.
  ELSE.
    IF s_laufd-low is INITIAL.
      texto_datas = |até { data_ate }|.
    ELSE.
      texto_datas = s_laufd-low.
    ENDIF.
  ENDIF.

  l_text = 'Itens processados do programa de pagamento'.

  lr_grid_layout->create_header_information(
    row    = 1
    column = 2
    text    = l_text
    tooltip = l_text ).

  lr_grid_layout->add_row( ).
*  LR_GRID_LAYOUT_1 = LR_GRID_LAYOUT->CREATE_GRID(
*                ROW    = 3
*                COLUMN = 1 ).
  lr_label = lr_grid_layout->create_label(
    row     = 3
    column  = 1
    text    = 'Nº de resultados encontrados: '
    tooltip = 'Numero de resultados econtrados conforme o filtro' ).

  lr_text = lr_grid_layout->create_text(
    row     = 3
    column  = 2
    text    = lv_cnt
    tooltip = lv_cnt ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 4
    column = 1
    text    = 'Data da extração: '
    tooltip = 'Data' ).

  l_text = data_formatada.

  lr_text = lr_grid_layout->create_text(
    row    = 4
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 5
    column = 1
    text    = 'Empresas: '
    tooltip = 'Empresa' ).

  l_text = texto_empresas.

  lr_text = lr_grid_layout->create_text(
    row    = 5
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 6
    column = 1
    text    = 'Datas previstas para execução: '
    tooltip = 'Datas' ).

  l_text = texto_datas.

  lr_text = lr_grid_layout->create_text(
    row    = 6
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).


**   information in Bold
*    lr_label = lr_grid_layout->create_label( row = 1 column = 1 ).
*    lr_label->set_text( 'Header in Bold' ).
**   information in tabular format
*    lr_h_flow = lr_grid_layout->create_flow( row = 2  column = 1 ).
*    lr_h_flow->create_text( text = 'This is text of flow' ).

  lr_header = lr_grid_layout.

*call method
  "gr_table->set_top_of_list( value = lr_header ).
  lr_logo->set_left_content( lr_grid_layout ).
  lr_logo->set_right_logo( 'LOGO_CTEEP_03' ). "T_code OAOR, class PICTURES, type OT
  gr_table->set_top_of_list( lr_logo ).

**--------------------------------------------------------------------*
** FOOTER
**--------------------------------------------------------------------*
*  CLEAR l_text.
*  l_text = 'FOOTER'.
*
*  DATA(lr_footer) = NEW cl_salv_form_header_info( text    = l_text
*                                                  tooltip = l_text ).
*  gr_table->set_end_of_list( lr_footer ).

*mostrando o ALV montado, junto com o header e footer
  gr_table->display( ).
