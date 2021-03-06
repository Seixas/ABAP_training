*&---------------------------------------------------------------------*
*& Report ZDBC_FILE
*&---------------------------------------------------------------------*
*& using al11 directory
*&---------------------------------------------------------------------*
REPORT ZDBC_FILE.


TYPES: BEGIN OF ty_lay_ent,
        placa     TYPE zcar-placa,
        ano       TYPE zcar-ano,
*        cor(3)    TYPE c, "sugestão: tratar como char pra não correr risco de overflow
*        valor(15) TYPE c,
        cor       TYPE zcar-cor, "assim é necessário tratar o valor entrando no dbc
        valor     TYPE zcar-valor,
        modelo    TYPE zcar-modelo,
       END OF ty_lay_ent.

DATA:   wa_dados_ent TYPE ty_lay_ent,
        tl_bdcdata   TYPE TABLE OF bdcdata,
        tl_message   TYPE TABLE OF bdcmsgcoll,
        wa_message   TYPE bdcmsgcoll,
        vl_mode      TYPE c VALUE 'N',
        vl_id        TYPE t100-arbgb,
        vl_no        TYPE t100-msgnr,
        vl_msgv1     TYPE balm-msgv1,
        vl_msgv2     TYPE balm-msgv2,
        vl_msgv3     TYPE balm-msgv3,
        vl_msgv4     TYPE balm-msgv4,
        vl_msgtext   TYPE string,
        t_car        TYPE STANDARD TABLE OF ty_lay_ent.

*--------------------------------------------------------------------*
* WORK AREA & SYMBOLS
*--------------------------------------------------------------------*
FIELD-SYMBOLS <fs_car>      LIKE LINE OF t_car.
FIELD-SYMBOLS <fs_utab>     TYPE any.

*--------------------------------------------------------------------*
* WORK AREA
*--------------------------------------------------------------------*
DATA: wa_params type ctu_params,
      wa_bdc    type bdcdata,
      wa_msg    type bdcmsgcoll.

*&-------------------------------------------------------------------*
*&  Vars
*&-------------------------------------------------------------------*
DATA: resultados TYPE filetable,
      retcode    TYPE i,
      fname      TYPE string,
      utab       TYPE TABLE OF char200,
      encode     TYPE abap_encoding,
      vg_texto   TYPE string.

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
      window_title            = 'Entrada de carros'
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

PERFORM f_carrega_arquivo.

PERFORM f_processa_dados.

PERFORM f_executa_dbc.


*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       Carrega o arquivo de carro
*----------------------------------------------------------------------*
FORM f_carrega_arquivo.

  "DATA utab TYPE LINE OF char200.
  DATA utab TYPE STANDARD TABLE OF char200.

  fname = p_file.

  IF sy-batch eq 'X'. "in case of job, fetch from app server AL11

    PERFORM fetch_from_al11.

  ELSE.

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
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE 'Erro ao carregar o arquivo' TYPE 'E' DISPLAY LIKE 'E'.
  ENDIF.

  DATA dtab TYPE TABLE OF char50.
  FIELD-SYMBOLS <fs_dtab> LIKE LINE OF dtab.

  LOOP AT utab ASSIGNING <fs_utab> FROM 2.

    SPLIT <fs_utab> AT ',' INTO TABLE dtab.
    APPEND INITIAL LINE TO t_car ASSIGNING <fs_car>.

    LOOP AT dtab ASSIGNING <fs_dtab>.

      CASE sy-tabix.
        WHEN 1.
          TRANSLATE <fs_dtab> TO UPPER CASE.
          <fs_car>-placa  = <fs_dtab>.
        WHEN 2.
          <fs_car>-ano    = <fs_dtab>(4). "our csv has a complete date in format YYYY/MM/DD
        WHEN 3.
          <fs_car>-cor    = <fs_dtab>.
        WHEN 4.
          REPLACE ALL OCCURRENCES OF ',' IN <fs_dtab> WITH '.'.

          IF <fs_dtab>(1) EQ '$'.
            <fs_car>-valor  = <fs_dtab>+1. "our csv has value with $, so we shift
          ELSE.
            <fs_car>-valor  = <fs_dtab>.
          ENDIF.
        WHEN 5.
          <fs_car>-modelo = <fs_dtab>.
      ENDCASE.

    ENDLOOP.

  ENDLOOP.

  SORT t_car.

ENDFORM.                    " Z_F_CARREGA_ARQUIVO


*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       Carrega o arquivo de carro
*----------------------------------------------------------------------*
FORM f_processa_dados.
  LOOP AT t_car INTO wa_dados_ent.
    PERFORM f_carrega_bdcdata USING: 'X' 'ZCARROS'        '0100', "Verificamos os parametros pela SHDB depois de algum record, linha 2 e por ai vai
                                     ' ' 'BDC_OKCODE'     '=BT_CRIAR',
                                     ' ' 'FLD_CAR-PLACA'  wa_dados_ent-placa ,
                                     ' ' 'FLD_CAR-ANO'    wa_dados_ent-ano   ,
                                     ' ' 'FLD_CAR-COR'    wa_dados_ent-cor   ,
                                     ' ' 'FLD_CAR-VALOR'  wa_dados_ent-valor ,
                                     ' ' 'FLD_CAR-MODELO' wa_dados_ent-modelo.
*   boas praticas separar por steps de acoro com a SHDB em casos de multiplas telas.
  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_BDCDATA
*&---------------------------------------------------------------------*
*       Carrega BDCDATA
*----------------------------------------------------------------------*
FORM f_carrega_bdcdata USING p_x p_1 p_2.

  IF P_X = 'X'.
    wa_bdc-program  = p_1.
    wa_bdc-dynpro   = p_2.
    wa_bdc-dynbegin = p_x.
  ELSE.
    wa_bdc-fnam     = p_1.
    wa_bdc-fval     = p_2.
    SHIFT wa_bdc-fval LEFT DELETING LEADING space.
  ENDIF.
  APPEND wa_bdc TO tl_bdcdata.
  CLEAR  wa_bdc.

ENDFORM.                    " F_CARREGA_BDCDATA

*&---------------------------------------------------------------------*
*& Form F_EXECUTA_DBC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_executa_dbc .

  wa_params-dismode  = 'N'. "A - visivel(para teste) N - background(para prod) E - só mostra com msgs do tipo E
  wa_params-racommit = 'X'.

  "Executar o batch input
  CALL TRANSACTION 'ZCARRO01' "tcode tobe executed
    USING tl_bdcdata          "Actions tobe executed
    MESSAGES INTO tl_message  "Capture all execution messages
    OPTIONS FROM wa_params.

* impressao do log de retorn
  LOOP AT tl_message INTO wa_msg.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
       msgid                     = wa_msg-msgid
       msgnr                     = wa_msg-msgnr
       msgv1                     = wa_msg-msgv1
       msgv2                     = wa_msg-msgv2
       msgv3                     = wa_msg-msgv3
       msgv4                     = wa_msg-msgv4
     IMPORTING
       message_text_output       = vg_texto.

    IF wa_msg-msgtyp = 'S'.
      WRITE: /3 icon_green_light AS ICON,
                vg_texto.
    ELSE.
      WRITE: /3 icon_red_light AS ICON,
                vg_texto.
    ENDIF.

    "in case of job, showm message in log
    IF SY-BATCH eq 'X'.
      MESSAGE vg_texto TYPE 'I' DISPLAY LIKE 'E'.
      "MESSAGE i000(00) WITH vg_texto.
    ENDIF.

  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FETCH_FROM_AL11
*&---------------------------------------------------------------------*
*& using server file system to do manipulation through job
*&---------------------------------------------------------------------*
FORM FETCH_FROM_AL11 .
  DATA: BEGIN OF it_data OCCURS 0,
            p_data(250) TYPE c,            "# seperated data
            "p_file(150) TYPE c,            "filename
          END OF it_data,

          len TYPE i.


  TRANSLATE p_file to LOWER CASE.
  OPEN DATASET p_file FOR INPUT IN TEXT MODE
                            ENCODING DEFAULT. "INPUT IN BINARY MODE.

  data(i_count) = 0.

  IF sy-subrc NE 0.
    CONCATENATE 'File "' p_file '"' 'NOT FOUND' INTO data(err_msg) SEPARATED BY space.
    "it_log-msgtxt = err_msg.
    "APPEND it_log.
  ELSE.
    DO.
      IF it_data IS INITIAL AND sy-index <> 1.
        CLOSE DATASET p_file.
        EXIT.
      ELSE.
        READ DATASET p_file INTO it_data.
        CHECK it_data IS NOT INITIAL.
        "it_data-p_file = p_file. "if we need the root

        len = strlen( it_data-p_data ). "removing char # from last position, lets use regex next please
        len = len - 1.
        it_data-p_data = it_data-p_data+0(len).
        APPEND it_data.
        i_count = i_count + 1.
      ENDIF.
    ENDDO.
    COMMIT WORK.
    CLOSE DATASET p_file.

    APPEND LINES OF it_data TO utab.
  ENDIF.
ENDFORM.
