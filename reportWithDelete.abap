*&--------------------------------------------------------------------------*
*& Report ZXXXX_LIMPA
* Cliente    : xxxx
* Módulo     : FI
* Transação  : xxxx
* Descrição  : Transação para que duas tabelas sejam limpas diretamente
*              pelo usuário, sem necessidade de acionar a equipe Funcional.
* Responsável: xxxx
* Autor      : Lucas Seixas                                 Data: xx/xx/2019
*---------------------------------------------------------------------------*
* Histórico de Alterações:
*---------------------------------------------------------------------------*
* Data       |Change #    |Autor                  |Alteração
*---------------------------------------------------------------------------*
* xx/xx/2019 |xxxxxxxxxxx |Lucas Seixas           |Desenvolvimento Inicial
* dd/mm/aaaa |            |Codificador02          |Descrição da Alteração
*---------------------------------------------------------------------------*
REPORT zxxxx_limpa.

TABLES: zxxxxx011,
        zxxxxx012.

DATA: lv_cnt    TYPE i,
      lv_cnts   TYPE string,
      l_text1   TYPE string,
      l_text2   TYPE string,
      lv_answer.

SELECTION-SCREEN BEGIN OF BLOCK block1
                            WITH FRAME TITLE title.

*  PARAMETERS: p_empr   type zxxxxx011-bukrs,
*              p_exer   type zxxxxx011-gjahr,
*              p_peri   type zxxxxx011-perio.
SELECT-OPTIONS  s_empr   FOR   zxxxxx011-bukrs.
SELECT-OPTIONS  s_exer   FOR   zxxxxx011-gjahr.
SELECT-OPTIONS  s_peri   FOR   zxxxxx011-perio.

SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2
                            WITH FRAME TITLE title2.

PARAMETERS: radio1 RADIOBUTTON GROUP rad1,
            radio2 RADIOBUTTON GROUP rad1.

SELECTION-SCREEN END OF BLOCK block2.

INITIALIZATION.
  title  = 'Seleção'.
  title2 = 'Tabela' .

************************************************************************
**   Processing block                                                 **
************************************************************************
START-OF-SELECTION.

  IF  radio1 = 'X' AND
      s_empr IS NOT INITIAL AND
      s_exer IS NOT INITIAL AND
      s_peri IS NOT INITIAL.

    PERFORM z_processar_zxxxxx011.
  ENDIF.

  IF  radio2 = 'X' AND
      s_empr IS NOT INITIAL AND
      s_exer IS NOT INITIAL AND
      s_peri IS NOT INITIAL.

    PERFORM z_processar_zxxxxx012.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  Z_PROCESSAR_zxxxxx011
*&---------------------------------------------------------------------*
FORM z_processar_zxxxxx011 .
  SELECT *
       FROM zxxxxx011
       INTO TABLE @DATA(ti_zxxxxx011)
       WHERE bukrs IN @s_empr AND
             gjahr IN @s_exer AND
             perio IN @s_peri.

  DESCRIBE TABLE ti_zxxxxx011 LINES lv_cnt.
  lv_cnts = lv_cnt.

  IF sy-subrc = 0.

    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        textline1 = |{ lv_cnt } linhas da tabela zxxxxx011 serão deletadas |
        textline2 = 'Deseja continuar?'
        titel     = 'Confirmação'
      IMPORTING
        answer    = lv_answer.

    IF lv_answer = 'J'.
      DELETE zxxxxx011 FROM TABLE zxxxxx011.
      IF sy-subrc = 0.
        COMMIT WORK.
        l_text1 = TEXT-001.
        REPLACE '&1' WITH lv_cnts INTO l_text1 .
        CONDENSE l_text1.
        MESSAGE l_text1 TYPE 'S'. " records deleted
      ELSE.
        ROLLBACK WORK.
        MESSAGE 'Erro ao salvar a remoção, processamento desfeito' TYPE 'E'.
        RETURN.
      ENDIF.
    ELSE.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = 'Cancelamento'
          txt1  = 'Nenhum dado foi ou será removido.'
          txt2  = ''
          txt3  = 'Transação cancelada'.

      LEAVE PROGRAM.
    ENDIF.

  ELSE.
    MESSAGE TEXT-003 TYPE 'E'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  Z_PROCESSAR_zxxxxx012
*&---------------------------------------------------------------------*
FORM z_processar_zxxxxx012 .
  SELECT *
      FROM zxxxxx012
      INTO TABLE @DATA(ti_zxxxxx012)
      WHERE bukrs IN @s_empr AND
            gjahr IN @s_exer AND
            perio IN @s_peri.

  DESCRIBE TABLE ti_zxxxxx012 LINES lv_cnt.
  lv_cnts = lv_cnt.

  IF sy-subrc = 0.

    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        textline1 = |{ lv_cnt } linhas da tabela zxxxxx012 serão deletadas |
        textline2 = 'Deseja continuar?'
        titel     = 'Confirmação'
      IMPORTING
        answer    = lv_answer.

    IF lv_answer = 'J'.
      DELETE zxxxxx012 FROM TABLE ti_zxxxxx012.
      IF sy-subrc = 0.
        COMMIT WORK.
        l_text2 = TEXT-002.
        REPLACE '&1' WITH lv_cnts INTO l_text2 .
        CONDENSE l_text2.
        MESSAGE l_text2 TYPE 'S'. " records deleted
      ELSE.
        ROLLBACK WORK.
        MESSAGE 'Erro ao salvar a remoção, processamento desfeito' TYPE 'E'.
        RETURN.
      ENDIF.
    ELSE.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = 'Cancelamento'
          txt1  = 'Nenhum dado foi ou será removido.'
          txt2  = ''
          txt3  = 'Transação cancelada'.

      LEAVE PROGRAM.
    ENDIF.

  ELSE.
    MESSAGE TEXT-003 TYPE 'E'.
  ENDIF.

ENDFORM.
