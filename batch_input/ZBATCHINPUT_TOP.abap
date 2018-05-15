*&---------------------------------------------------------------------*
*&  Include           ZBATCHINPUT_SEIXAS_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Types structure
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_USER,
        USUARIO(12) TYPE C,
        DEPTO(40) TYPE C,
       END OF TY_USER.

*--------------------------------------------------------------------*
* WORK AREA
*--------------------------------------------------------------------*
DATA: WA_USER   TYPE TY_USER,
      WA_PARAMS TYPE CTU_PARAMS,
      WA_BDC    TYPE BDCDATA,
      WA_MSG    TYPE BDCMSGCOLL.

*--------------------------------------------------------------------*
* INTERNAL TABLE
*--------------------------------------------------------------------*
DATA: TI_USER TYPE TABLE OF TY_USER,
      TI_BDC  TYPE TABLE OF BDCDATA,
      TI_MSG  TYPE TABLE OF BDCMSGCOLL.

*&-------------------------------------------------------------------*
*&  Vars
*&-------------------------------------------------------------------*
DATA VG_TEXTO TYPE STRING.
