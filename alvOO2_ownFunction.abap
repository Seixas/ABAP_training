*&---------------------------------------------------------------------*
*& Report ZTESTALVSEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTESTALVSEL.

*... §5 Definition is later
CLASS lcl_handle_events DEFINITION DEFERRED.
*... §5 object for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.
"DATA: g_okcode TYPE syucomm.

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

  SELECT-OPTIONS  s_bukrs    FOR   regup-bukrs.
  SELECT-OPTIONS  s_laufd    FOR   regup-laufd.
  SELECT-OPTIONS  s_zfbdt    FOR   regup-zfbdt.

  SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  title = 'Seleção'.


*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* §5.1 define a local class for handling events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    perform handle_user_command using e_salv_function.
  ENDMETHOD.                    "on_user_command
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


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

**********************************************************************
* ALV Config
**********************************************************************

DATA l_text TYPE string.

  cl_salv_table=>factory( IMPORTING r_salv_table  = gr_table
                          CHANGING  t_table       = ti_output ).

*... §3.2 include own functions by setting own status



*gr_functions = gr_table->get_functions( ).
*
*gr_table->set_screen_status( pfstatus = 'SALV_STANDARD'
*                             report = 'ZTESTALVSEL'
*                             set_functions = gr_table->c_functions_all ).

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_list_header( 'Heading customizado' ).
  gr_display->set_striped_pattern( abap_true ).

*--------------------------------------------------------------------*
* Functions and Events for such
*--------------------------------------------------------------------*
*... §6 register to the events of cl_salv_table
  data: lr_events type ref to cl_salv_events_table.

gr_functions = gr_table->get_functions( ).

gr_table->set_screen_status( pfstatus = 'SALV_STANDARD'
                             report = 'ZTESTALVSEL'
                             set_functions = gr_table->c_functions_all ).

  lr_events = gr_table->get_event( ).

  create object gr_events.

*... §6.1 register to the event USER_COMMAND
  set handler gr_events->on_user_command for lr_events.


  data: lo_selections type ref to cl_salv_selections.
  data lt_rows type salv_t_row.
  data ls_row type i.

  lo_selections = gr_table->get_selections( ).
*... §7.1 set selection mode
  lo_selections->set_selection_mode( if_salv_c_selection_mode=>ROW_COLUMN ).

  gr_table->display( ).
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_SALV_FUNCTION  text
*----------------------------------------------------------------------*
FORM handle_user_command  USING  i_ucomm type  salv_de_function.
    case i_ucomm.
    when '&NEW'.
      perform get_selections.
    ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selections .

  lt_rows = lo_selections->get_selected_rows( ).
  loop at lt_rows into ls_row.
    read table ti_output ASSIGNING <fs_output> index ls_row.
  ENDLOOP.
  BREAK-POINT.
ENDFORM.
