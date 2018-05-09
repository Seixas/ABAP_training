*&---------------------------------------------------------------------*
*& Report  ZCLIENTES_SEIXAS
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCLIENTES_SEIXAS.

**********************************************************************
* Types/Structure
**********************************************************************
TYPES: BEGIN OF ty_clientes,
        cod(5)    TYPE c,
        nome(30)  TYPE c,
       END OF   ty_clientes.


**********************************************************************
* work area
**********************************************************************
DATA wa_clientes TYPE ty_clientes.

**********************************************************************
* Internal table
**********************************************************************
DATA ti_clients TYPE TABLE OF ty_clientes.


**********************************************************************
* Start of selection - Event
**********************************************************************
START-OF-SELECTION.

  wa_clientes-cod   = '1'.
  wa_clientes-nome  = 'Lucas Seixas'.
  APPEND wa_clientes TO ti_clients.

  wa_clientes-cod   = '2'.
  wa_clientes-nome  = 'Leonardo'.
  APPEND wa_clientes TO ti_clients.

  wa_clientes-cod   = '3'.
  wa_clientes-nome  = 'Danilo'.
  APPEND wa_clientes TO ti_clients.

  wa_clientes-cod   = '4'.
  wa_clientes-nome  = 'Zed'.
  APPEND wa_clientes TO ti_clients.

  "leitura da tabela interna
  LOOP AT ti_clients INTO wa_clientes.
    WRITE: / wa_clientes-cod  COLOR 1,
             wa_clientes-nome COLOR COL_TOTAL.
  ENDLOOP.
