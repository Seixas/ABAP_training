DATA: wa_dados_ent TYPE ty_lay_ent,
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
        vl_msgtext   TYPE string.

PERFORM zf_preencher_bdcdata TABLES tl_bdcdata
                                 USING:
              'ZTRN_CADASTRO_LCG'   '9000'    'X'   space                   space,
              ''                    ''        ''    'BDC_OKCODE'            '=BTN9100',
              'ZTRN_CADASTRO_LCG'   '9100'    'X'   ''                      space,
              ''                    ''        ''    'WA_PESSOA-CPF'         wa_dados_ent-cpf,
              ''                    ''        ''    'WA_PESSOA-NOME'        wa_dados_ent-nome,
              ''                    ''        ''    'WA_PESSOA-DTNASC'      wa_dados_ent-dtnasc,
              ''                    ''        ''    'WA_PESSOA-SEXONASC'    wa_dados_ent-sexonasc,
              ''                    ''        ''    'BDC_OKCODE'            '=BTN_SALVAR'.

    "Executar o batch input
    CALL TRANSACTION 'ZTRN_T_CADASTRO_LCG' "Transação executada
      USING tl_bdcdata          "As ações a serem executadas
      MESSAGES INTO tl_message  "Captura todas message da execução
      MODE vl_mode. " A - Exibir todas as telas
    " E - Somente vai exibir se houver message type E
    " N - Background
    

FORM zf_preencher_bdcdata  TABLES   pt_bdcdata STRUCTURE bdcdata
                           USING    p_programa
                                    p_tela
                                    p_inicio
                                    p_nome_campo
                                    p_valor_campo.
  DATA: wa_bdcdata TYPE bdcdata.

  wa_bdcdata-program  = p_programa.
  wa_bdcdata-dynpro   = p_tela.
  wa_bdcdata-dynbegin = p_inicio.
  wa_bdcdata-fnam     = p_nome_campo.
  wa_bdcdata-fval     = p_valor_campo.

  APPEND wa_bdcdata TO pt_bdcdata.
ENDFORM.
