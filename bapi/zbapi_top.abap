*&---------------------------------------------------------------------*
*&  Include           ZBAPI_SEIXAS_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  Types / Sctuture
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_user,
        usuario(12) TYPE c,
        depto(40)   TYPE c,
       END OF   ty_user,

       BEGIN OF ty_user1,
        line(150)   TYPE c,
       END OF   ty_user1.

*----------------------------------------------------------------------*
*  Workarea
*----------------------------------------------------------------------*
DATA: wa_user   TYPE ty_user,
      wa_params TYPE ctu_params,
      wa_bdc    TYPE bdcdata,
      wa_msg    TYPE bdcmsgcoll,
      wa_user1  TYPE ty_user1.

*----------------------------------------------------------------------*
*  Workarea
*----------------------------------------------------------------------*
DATA: ti_user  TYPE TABLE OF ty_user,
      ti_bdc   TYPE TABLE OF bdcdata,
      ti_msg   TYPE TABLE OF bdcmsgcoll,
      ti_user1 TYPE TABLE OF ty_user1.

*----------------------------------------------------------------------*
*  Variable
*----------------------------------------------------------------------*
DATA vg_texto TYPE string.
