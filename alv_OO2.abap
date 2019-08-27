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
REPORT zfir004 MESSAGE-ID oo.

************************************************************************
**   Global class references                                          **
************************************************************************
DATA: gr_table     TYPE REF TO cl_salv_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_display   TYPE REF TO cl_salv_display_settings,

      pdf    LIKE tline OCCURS 0,
      g_spool   TYPE tsp01-rqident.


************************************************************************
**  Data Declarations                                                **
************************************************************************
TABLES: regup.

DATA : lv_cnt TYPE i.

*--------------------------------------------------------------------*
* Types / structures
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_output,
         bukrs TYPE regup-bukrs,
         laufd TYPE regup-laufd,
         dmbtr TYPE regup-dmbtr,
         hbkid TYPE regup-hbkid,
         belnr TYPE regup-belnr,
         lifnr TYPE regup-lifnr,
         zfbdt TYPE regup-zfbdt,
         zterm TYPE regup-zterm,
         usnam TYPE bkpf-usnam,
         tcode TYPE bkpf-tcode,
         awkey TYPE bkpf-awkey,
       END OF ty_output.

*--------------------------------------------------------------------*
* Workareas
*--------------------------------------------------------------------*
DATA: wa_output TYPE ty_output.

*--------------------------------------------------------------------*
* Internal tables
*--------------------------------------------------------------------*
DATA ti_output TYPE STANDARD TABLE OF ty_output.

FIELD-SYMBOLS <fs_output> LIKE LINE OF ti_output.

*--------------------------------------------------------------------*
* SELECT OPTIONS and PARAMETERS EVENTS
*--------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK block1
                            WITH FRAME TITLE title.

  "PARAMETERS      p_bukrs   TYPE   regup-bukrs.
  SELECT-OPTIONS  s_bukrs    FOR   regup-bukrs.
  SELECT-OPTIONS  s_laufd    FOR   regup-laufd.
  SELECT-OPTIONS  s_zfbdt    FOR   regup-zfbdt.
  PARAMETERS: p_file TYPE string.

  SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  title = 'Seleção'.
  p_file = 'C:\venkat.pdf'.

************************************************************************
**   Processing block                                                 **
************************************************************************
START-OF-SELECTION.

  SELECT bukrs,
         belnr,
         usnam,
         tcode,
         awkey,
         glvor
       FROM bkpf INTO TABLE @DATA(ti_bkpf).

  SELECT  bukrs,
          laufd,
          dmbtr,
          hbkid,
          belnr,
          lifnr,
          zfbdt,
          zterm
        FROM  regup INTO TABLE @DATA(ti_regup)
        WHERE "bukrs = p_bukrs
              bukrs IN @s_bukrs AND
              laufd IN @s_laufd.

  SORT ti_bkpf  BY bukrs belnr.
  SORT ti_regup BY bukrs belnr.

  FIELD-SYMBOLS <fs_regup> like LINE OF ti_regup.
  FIELD-SYMBOLS <fs_bkpf>  like LINE OF ti_bkpf.

  LOOP AT ti_regup ASSIGNING <fs_regup>.
    LOOP AT ti_bkpf ASSIGNING <fs_bkpf>.
      IF <fs_regup>-bukrs = <fs_bkpf>-bukrs AND <fs_regup>-belnr = <fs_bkpf>-belnr.
        IF <fs_bkpf>-glvor = 'RMRP'.
          <fs_bkpf>-awkey = <fs_bkpf>-awkey(10).
        ELSE.
          <fs_bkpf>-awkey = ''.
        ENDIF.
        wa_output = CORRESPONDING #( BASE ( <fs_regup> ) <fs_bkpf> ).
        APPEND wa_output TO ti_output.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*  LOOP AT ti_output ASSIGNING <fs_output>.
*    <fs_output>-awkey = <fs_output>-awkey(10).
*  ENDLOOP.

  DESCRIBE TABLE ti_output LINES lv_cnt. "contando numero de registros do resultado da query

  SORT ti_output BY laufd.

  cl_salv_table=>factory( IMPORTING r_salv_table  = gr_table
                          CHANGING  t_table       = ti_output ).

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
  l_text = |{ lv_cnt } resultados encontrados|.

  lr_label = lr_grid_layout->create_label(
    row     = 5
    column  = 1
    text    = 'Nº de resultados encontrados: '
    tooltip = 'Numero de resultados econtrados conforme o filtro' ).

  lr_text = lr_grid_layout->create_text(
    row     = 5
    column  = 2
    text    = l_text "lv_cnt
    tooltip = lv_cnt ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 6
    column = 1
    text    = 'Data da extração: '
    tooltip = 'Data' ).

  l_text = data_formatada.

  lr_text = lr_grid_layout->create_text(
    row    = 6
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 3
    column = 1
    text    = 'Empresas: '
    tooltip = 'Empresa' ).

  l_text = texto_empresas.

  lr_text = lr_grid_layout->create_text(
    row    = 3
    column = 2
    text    = l_text
    tooltip = l_text ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_layout->create_label(
    row    = 4
    column = 1
    text    = 'Datas previstas para execução: '
    tooltip = 'Datas' ).

  l_text = texto_datas.

  lr_text = lr_grid_layout->create_text(
    row    = 4
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

  g_spool = sy-spono.
    CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
      EXPORTING
        src_spoolid              = g_spool
      TABLES
        pdf                      = pdf.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename                = p_file
          filetype                = 'BIN'
        TABLES
          data_tab                = pdf.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
