*&---------------------------------------------------------------------*
*& Report zbapicond
*&---------------------------------------------------------------------*
*& Descrição: Atualizar valores de condição em ordens
*&            a partir de um CSV, o mesmo deve possuir 5 campos
*&            (Ordem, Item, Condiçãoo, Novo Valor)
*&---------------------------------------------------------------------*
REPORT zbapicond.

TYPE-POOLS abap.

*&---------------------------------------------------------------------*
*&  Type structures
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_orderbuild,
         ordem      TYPE vbak-vbeln,
         item       TYPE vbap-posnr,
         cond       TYPE komv-kschl,
         novo_valor TYPE komv-kbetr,
       END OF ty_orderbuild,

       BEGIN OF ty_sdocs,
         ordem TYPE vbak-vbeln,
       END OF ty_sdocs,

       BEGIN OF ty_condsout,
         sd_doc     TYPE vbak-vbeln,
         itm_number TYPE vbap-posnr,
         cond_type  TYPE komv-kschl,
         cond_value TYPE komv-kbetr,
       END OF ty_condsout.

*--------------------------------------------------------------------*
* INTERNAL TABLE
*--------------------------------------------------------------------*
DATA: t_ordem      TYPE STANDARD TABLE OF ty_orderbuild,
      t_documentos TYPE STANDARD TABLE OF ty_sdocs,
      t_cond       TYPE STANDARD TABLE OF bapisdcond,
      t_condout    TYPE STANDARD TABLE OF ty_condsout.

*--------------------------------------------------------------------*
* WORK AREA & SYMBOLS
*--------------------------------------------------------------------*
FIELD-SYMBOLS <fs_ordem>    LIKE LINE OF t_ordem.
FIELD-SYMBOLS <fs_condout>  LIKE LINE OF t_condout.
FIELD-SYMBOLS <fs_cond>     LIKE LINE OF t_cond.
FIELD-SYMBOLS <fs_utab>     TYPE any.

*&-------------------------------------------------------------------*
*&  Vars
*&-------------------------------------------------------------------*
DATA: resultados TYPE filetable,
      retcode    TYPE i,
      fname      TYPE string,
      utab       TYPE TABLE OF char200,
      encode     TYPE abap_encoding.

*--------------------------------------------------------------------*
* Selection Screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
PARAMETERS p_file TYPE string.
SELECTION-SCREEN END OF BLOCK blk1.

*--------------------------------------------------------------------*
* AT SELECTION-SCREEN event
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file. "habilita match-code para pesquisa

  encode = '4110'.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Ordens para serem modificadas'
      default_extension       = 'CSV'
      default_filename        = p_file
      file_filter             = '(*.CSV)|*.CSV'
      with_encoding           = abap_true
*     initial_directory       =
*     multiselection          =
    CHANGING
      file_table              = resultados
      rc                      = retcode
*     user_action             =
      file_encoding           = encode
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE 'Erro' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

  READ TABLE resultados INTO p_file INDEX 1.


*--------------------------------------------------------------------*
* start of selection event
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM z_f_carrega_arquivo.
  PERFORM z_f_get_dados_ordem.
  PERFORM z_f_processa_dados.
  PERFORM z_f_set_dados_ordem.

*&---------------------------------------------------------------------*
*&      Form  Z_F_CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       Carrega o arquivo de funcionário
*----------------------------------------------------------------------*
FORM z_f_carrega_arquivo.

  "DATA utab TYPE LINE OF char200.
  DATA utab TYPE STANDARD TABLE OF char200.

  fname = p_file.

  "localiza o arquivo
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = fname
    CHANGING
      data_tab                = utab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    MESSAGE 'Erro ao carregar o arquivo' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

  DATA dtab TYPE TABLE OF char50.
  FIELD-SYMBOLS <fs_dtab> LIKE LINE OF dtab.

  LOOP AT utab ASSIGNING <fs_utab> FROM 2.

    SPLIT <fs_utab> AT ';' INTO TABLE dtab.
    APPEND INITIAL LINE TO t_ordem ASSIGNING <fs_ordem>.

    LOOP AT dtab ASSIGNING <fs_dtab>.

      CASE sy-tabix.
        WHEN 1.
          <fs_ordem>-ordem      = <fs_dtab>.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_ordem>-ordem
            IMPORTING
              output = <fs_ordem>-ordem.
        WHEN 2.
          <fs_ordem>-item       = <fs_dtab>.
        WHEN 3.
          <fs_ordem>-cond       = <fs_dtab>.
        WHEN 4.
          REPLACE ALL OCCURRENCES OF ',' IN <fs_dtab> WITH '.'.
          <fs_ordem>-novo_valor = <fs_dtab>.
      ENDCASE.

    ENDLOOP.

  ENDLOOP.

  SORT t_ordem.

ENDFORM.                    " Z_F_CARREGA_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  Z_F_GET_DADOS
*&---------------------------------------------------------------------*
*       Utilizando a BAPI a seguir para pegar os dados das ordens
*       de acordo com o CSV informado.
*----------------------------------------------------------------------*
FORM z_f_get_dados_ordem .

  DATA : zsdv_bapi_view TYPE order_view,
         t_sdocs        TYPE TABLE OF sales_key WITH HEADER LINE.

  t_documentos[] = t_ordem[].
  DELETE ADJACENT DUPLICATES FROM t_sdocs.

  REFRESH : t_sdocs, t_cond.
  zsdv_bapi_view-sdcond = 'X'.

  LOOP AT t_documentos INTO t_sdocs.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = t_sdocs
      IMPORTING
        output = t_sdocs.

    APPEND t_sdocs.
  ENDLOOP.

  CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
    EXPORTING
      i_bapi_view          = zsdv_bapi_view
      i_memory_read        = 'X'
    TABLES
      sales_documents      = t_sdocs
      order_conditions_out = t_cond.

  DELETE t_cond WHERE cond_type <> 'ZSER'.

  t_condout = CORRESPONDING #( t_cond ).

  SORT t_condout.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  Z_F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
*       Processa dados da BAPI
*----------------------------------------------------------------------*
FORM z_f_processa_dados.

  FIELD-SYMBOLS <fs_condout> LIKE LINE OF t_condout.

  LOOP AT t_ordem INTO DATA(wa_ordem).
    LOOP AT t_condout ASSIGNING <fs_condout>.
      IF wa_ordem-item = <fs_condout>-itm_number AND wa_ordem-ordem = <fs_condout>-sd_doc.
        IF <fs_condout>-cond_value IS NOT INITIAL.
          <fs_condout>-cond_value = wa_ordem-novo_valor.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  Z_F_SET_DATOS_ORDEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM z_f_set_dados_ordem.

  DATA: salesdocument    LIKE bapivbeln-vbeln,
        order_header_inx LIKE bapisdh1x,
        order_header_in  LIKE bapisdh1,
        return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
        conditions_in    TYPE STANDARD TABLE OF bapicond WITH HEADER LINE,
        conditions_inx   TYPE STANDARD TABLE OF bapicondx WITH HEADER LINE,
        logic_switch     LIKE bapisdls,
        step_nr          LIKE conditions_in-cond_st_no,
        item_nr          LIKE conditions_in-itm_number,
        cond_count       LIKE conditions_in-cond_count,
        cond_type        LIKE conditions_in-cond_type,
        count_aux        LIKE conditions_in-cond_count.


  logic_switch-cond_handl     = 'X'. "evita adicionar nova condição
  order_header_inx-updateflag = 'U'.

  SORT t_condout BY sd_doc itm_number ASCENDING.
  count_aux = '01'.

  LOOP AT t_condout INTO DATA(wa_condout).

    CLEAR conditions_in[].
    CLEAR conditions_inx[].

    CLEAR:  step_nr,
            item_nr,
            cond_count,
            cond_type.

    IF wa_condout-cond_value IS NOT INITIAL.
*      step_nr     = '710'.
*      item_nr     = wa_condout-itm_number.
      cond_count  = count_aux. "'01'.
*      cond_type   = 'ZSER'.

      conditions_in-itm_number = wa_condout-itm_number.
*      CONDITIONS_IN-COND_ST_NO = step_nr.
      conditions_in-cond_count = cond_count.
      conditions_in-cond_type  = wa_condout-cond_type.
      conditions_in-cond_value = wa_condout-cond_value / 10. "divisivel por 10 para adequar a t_code va02
*      CONDITIONS_IN-CURRENCY   = ''.
      APPEND conditions_in.

      conditions_inx-itm_number = wa_condout-itm_number.
*      CONDITIONS_INX-COND_ST_NO = step_nr.
      conditions_inx-cond_count = cond_count.
      conditions_inx-cond_type  = wa_condout-cond_type.
      conditions_inx-updateflag = 'U'.
      conditions_inx-cond_value = 'X'.
      APPEND conditions_inx.

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = wa_condout-sd_doc
          order_header_in  = order_header_in
          order_header_inx = order_header_inx
          logic_switch     = logic_switch
        TABLES
          return           = return
          conditions_in    = conditions_in
          conditions_inx   = conditions_inx.

      IF return-type NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = return.
      ENDIF.

      count_aux = '01'.

    ELSE.
      count_aux = count_aux + 1. "em caso de condição duplicada
    ENDIF.

  ENDLOOP.

  LOOP AT return.
    WRITE / return-message.
  ENDLOOP.

ENDFORM.
