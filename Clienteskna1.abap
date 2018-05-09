*&---------------------------------------------------------------------*
*& Report  ZCLIENTE_SEIXAS
*&---------------------------------------------------------------------*
*& Author: Seixas
*& Date: 08/05/2018
*&---------------------------------------------------------------------*

REPORT  ZCLIENTE_SEIXAS NO STANDARD PAGE HEADING line-SIZE 94
                                                  LINE-COUNT 10. "tirando cabeçalho padrao

*--------------------------------------------------------------------*
*Tables
*--------------------------------------------------------------------*
TABLES: kna1.

*types / structure
TYPES: BEGIN OF ty_kna1,
        kunnr TYPE kna1-kunnr,
        land1 TYPE kna1-land1,
        name1 TYPE kna1-name1,
        regio TYPE kna1-regio,
        telf1 TYPE kna1-telf1,
      END OF ty_kna1.

*--------------------------------------------------------------------*
*workarea
*--------------------------------------------------------------------*
DATA wa_kna1 TYPE ty_kna1.

*--------------------------------------------------------------------*
*Tabela interna
*--------------------------------------------------------------------*
DATA ti_kna1 TYPE TABLE OF ty_kna1.

*--------------------------------------------------------------------*
* top of page
*--------------------------------------------------------------------*
TOP-OF-PAGE.

WRITE:    text-t01, "'Rel de Clientes',
      35  text-t02, "'Data:',
      41  sy-datum,
      44  'Hora:'(t03),
      49  sy-uzeit,
      54  'Nome',
      59  sy-uname,
      64  'Pagina',
      65  sy-pagno.

ULINE.

WRITE:  'Codigo',
        12 'P.',
        16 'Nome',
        52 'UF',
        56 'Telefone'.
ULINE.

*--------------------------------------------------------------------*
* selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN begin of BLOCK blk1 WITH FRAME TITLE text-001.

  "PARAMETERS:     p_kunnr TYPE  kna1-kunnr.
  SELECT-OPTIONS  s_kunnr FOR   kna1-kunnr.

SELECTION-SCREEN END OF BLOCK blk1.

*--------------------------------------------------------------------*
* start of selection event
*--------------------------------------------------------------------*
START-OF-SELECTION.

"open sql
SELECT  kunnr
        land1
        name1
        regio
        telf1
        FROM kna1
        INTO TABLE ti_kna1
        "WHERE kunnr = p_kunnr.
        WHERE kunnr IN s_kunnr.

LOOP AT ti_kna1 INTO wa_kna1.
  WRITE: /  wa_kna1-kunnr,
            wa_kna1-land1,
            wa_kna1-name1,
            wa_kna1-regio,
            wa_kna1-telf1.
  "ULINE.
ENDLOOP.
