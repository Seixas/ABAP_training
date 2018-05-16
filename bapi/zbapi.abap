*&---------------------------------------------------------------------*
*& Report  ZBAPI_SEIXAS
*&---------------------------------------------------------------------*
*& Descrição: Programa Modelo de BAPI
*& Data: 15/05/2018
*&---------------------------------------------------------------------*
REPORT ZBAPI_SEIXAS.

INCLUDE ZBAPI_SEIXAS_TOP.

*----------------------------------------------------------------------*
*  Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-t01.
  PARAMETERS p_file TYPE string.
SELECTION-SCREEN END OF BLOCK blk1.

*----------------------------------------------------------------------*
*  AT Selection Screen - Event
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* Localiza o Arquivo
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      window_title      = 'Usuário'
      default_extension = 'CSV'
      default_file_name = p_file
    IMPORTING
      fullpath          = p_file.

*----------------------------------------------------------------------*
*  Start-of-Selection - Event
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_carrega_arquivo.

  PERFORM f_processa_dados.


*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       Carrega o Arquivo de Usuário
*----------------------------------------------------------------------*
FORM f_carrega_arquivo .

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = p_file
    TABLES
      data_tab                = ti_user1
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
      OTHERS                  = 17.

ENDFORM.                    " F_CARREGA_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
*       Processa Dados
*----------------------------------------------------------------------*
FORM f_processa_dados .

  DATA: wa_address  TYPE bapiaddr3,
        wa_addressx TYPE bapiaddr3x.

  DATA: ti_return   TYPE TABLE OF bapiret2,
        wa_return   type bapiret2.

  LOOP AT ti_user1 INTO wa_user1.

* CSV
    SPLIT wa_user1-line  AT ';' INTO wa_user-usuario
                                     wa_user-depto.

    wa_address-department  = wa_user-depto.
    wa_addressx-department = 'X'.

    CALL FUNCTION 'BAPI_USER_CHANGE'
      EXPORTING
        username = wa_user-usuario
        address  = wa_address
        addressx = wa_addressx
      TABLES
        return   = ti_return.

* log de Processamento
    READ TABLE ti_return INTO wa_return INDEX 1.

    IF wa_return-type = 'S'.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      WRITE: /3 icon_green_light AS ICON,
                wa_return-message(100).

    ELSE.

      WRITE: /3 icon_red_light   AS ICON,
                wa_return-message(100).
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_PROCESSA_DADOS
