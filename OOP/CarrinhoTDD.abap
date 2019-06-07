*&---------------------------------------------------------------------*
*& Report  ZALIW_CARRINHOO
*&---------------------------------------------------------------------*
*& Author:  Lucas Seixas
*& Ambient: PETROBRAS dev 7.40 07/06/2019
*&---------------------------------------------------------------------*
REPORT ZALIW_CARRINHOO.

*&---------------------------------------------------------------------*
**&&~~ Interface definition for unit test usage
*&---------------------------------------------------------------------*
INTERFACE lif_unit_test.
ENDINTERFACE.

*&---------------------------------------------------------------------*
**&&~~ Class Definitions
*&---------------------------------------------------------------------*
CLASS lcl_produto  DEFINITION FRIENDS lif_unit_test.
  PUBLIC SECTION.
**~~** Declaration of Static  Variable
    CLASS-DATA: lv_name TYPE string.
**~~** Declaration of Static  Method
    CLASS-METHODS : show_name.
**~~** Declaration of Instance constructor
    METHODS : constructor
                 IMPORTING im_nome  TYPE string
                           im_preco TYPE i,
              get_nome  RETURNING VALUE(rv_nome)  TYPE string,
              get_preco RETURNING VALUE(rv_preco) TYPE i.
**~~** Declaration of Static constructor
    CLASS-METHODS: class_constructor.
  PROTECTED SECTION.
    "No Declaratons
  PRIVATE SECTION.
    DATA: nome  TYPE string,
          preco TYPE i.
ENDCLASS.                    "lcl_produto DEFINITION

CLASS lcl_item  DEFINITION FRIENDS lif_unit_test.
  PUBLIC SECTION.
    METHODS : constructor
                 IMPORTING im_produto    TYPE REF TO lcl_produto
                           im_quantidade TYPE i,
              valor            RETURNING VALUE(rv_valor)       TYPE f,
              set_quantidade   IMPORTING im_quantidade         TYPE i,
              get_quantidade   RETURNING VALUE(rv_quantidade)  TYPE i,
              get_produto      RETURNING VALUE(rv_produto)     TYPE REF TO lcl_produto.
  PRIVATE SECTION.
    DATA: lco_produto  TYPE REF TO lcl_produto,
          quantidade   TYPE i.
ENDCLASS.                    "lcl_item DEFINITION

CLASS lcl_carrinho  DEFINITION FRIENDS lif_unit_test.
  PUBLIC SECTION.
    METHODS : constructor,
              incluir             IMPORTING im_lo_produto TYPE REF TO lcl_produto,
              remover             IMPORTING im_lo_produto TYPE REF TO lcl_produto,
              alterar_quantidade  IMPORTING im_lo_produto TYPE REF TO lcl_produto
                                            im_quantidade TYPE i,
              get_quantidade      IMPORTING im_lo_produto TYPE REF TO lcl_produto
                                  RETURNING VALUE(rv_quantidade_do_item)  TYPE i,
              get_produtos        RETURNING VALUE(rv_produtos)  TYPE REF TO cl_object_collection,
              get_total           RETURNING VALUE(rv_total) TYPE f,
              get_linefortest     RETURNING VALUE(rv_value) TYPE line. "for internal tests, ignore that
    
  PRIVATE SECTION.
    TYPES: BEGIN OF line, "nothing here in types was used or relevant, just lazy annotation for myself
            col1 TYPE i,
            col2 TYPE i,
            col3 TYPE i,
           END OF line,
           itab TYPE STANDARD TABLE OF line WITH EMPTY KEY.
    TYPES: BEGIN OF t_itens,
            lo_colitem TYPE REF TO lcl_item,
           END OF t_itens,
           it_itens TYPE STANDARD TABLE OF t_itens WITH EMPTY KEY.

    DATA:   itens        TYPE REF TO cl_object_collection,
            produtos     TYPE REF TO cl_object_collection,
            lo_item      TYPE REF TO lcl_item.

            "inst_tab TYPE TABLE of ref to lcl_item,
            "oref TYPE REF TO lcl_item.

    METHODS: item_conteudo IMPORTING     im_produto TYPE REF TO lcl_produto
                           RETURNING VALUE(rv_item) TYPE REF TO lcl_item.
ENDCLASS.                    "lcl_carrinho DEFINITION


*&---------------------------------------------------------------------*
**&&~~ Class Implementations
*&---------------------------------------------------------------------*
CLASS lcl_carrinho  IMPLEMENTATION.

  METHOD constructor.
    itens  = new cl_object_collection( ).
    produtos      = new cl_object_collection( ).
  ENDMETHOD.

  METHOD incluir.

    itens->add( new lcl_item( im_produto    = im_lo_produto
                              im_quantidade = 1  ) ).
  ENDMETHOD.

  METHOD remover.

    itens->remove( item_conteudo( im_lo_produto ) ).

  ENDMETHOD.

  METHOD get_quantidade.
    BREAK-POINT.
    rv_quantidade_do_item = item_conteudo( im_produto = im_lo_produto )->get_quantidade( ).

  ENDMETHOD.

  METHOD get_produtos.
    DATA(lo_iterator) = itens->get_iterator( ).

    while lo_iterator->has_next( ).
      lo_item = cast lcl_item( lo_iterator->get_next( ) ).
      produtos->add( lo_item->get_produto( ) ).
    ENDWHILE.

    rv_produtos = produtos.

  ENDMETHOD.

  METHOD alterar_quantidade.

    item_conteudo( im_lo_produto )->set_quantidade( im_quantidade ).

  ENDMETHOD.

  METHOD get_total.

    DATA(lo_iterator) = itens->get_iterator( ).

    WHILE lo_iterator->has_next( ).
      lo_item ?= lo_iterator->get_next( ).
      "lo_item = cast lcl_item( lo_iterator->get_next( ) ). exemplos nitido de CAST
      rv_total = rv_total + lo_item->valor( ).
    ENDWHILE.

  ENDMETHOD.

  METHOD item_conteudo.

    DATA(lo_iterator) = itens->get_iterator( ).

    WHILE lo_iterator->has_next( ).
      DATA(lo_item) = cast lcl_item( lo_iterator->get_next( ) ).
      IF lo_item->get_produto( ) eq im_produto.
        rv_item = lo_item.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD get_linefortest.
    cl_demo_output=>write(
        VALUE itab(
          FOR j = 11 THEN j + 10 WHILE j < 40
          ( col1 = j col2 = j + 1 col3 = j + 2 ) ) ).
    cl_demo_output=>write(
        VALUE itab(
          FOR j = 31 THEN j - 10 UNTIL j < 10
          ( col1 = j col2 = j + 1 col3 = j + 2  ) ) ).
    cl_demo_output=>display( ).
  ENDMETHOD.
ENDCLASS.                    "lcl_carrinho IMPLEMENTATION

CLASS lcl_produto  IMPLEMENTATION.

**~~** Implementation of method - CLASS_CONSTRUCTOR
  METHOD class_constructor.
    WRITE :/ 'This is the Method - CLASS_CONSTRUCTOR'.
  ENDMETHOD.

**~~** Implementation of method - CONSTRUCTOR
  METHOD constructor.
    nome  = im_nome.
    preco = im_preco.
  ENDMETHOD.
**~~** Implementation of method
  METHOD show_name.
    WRITE :/ 'This is the SHOW_NAME Method'.
    WRITE :/5 lv_name.
  ENDMETHOD.

  METHOD get_nome.
    rv_nome = me->nome.
  ENDMETHOD.

  METHOD get_preco.
    rv_preco = me->preco.
  ENDMETHOD.
ENDCLASS.                    "lcl_produto IMPLEMENTATION

CLASS lcl_item  IMPLEMENTATION.
**~~** Implementation of method - CONSTRUCTOR
  METHOD constructor.
    lco_produto = im_produto.
    quantidade  = 1.
  ENDMETHOD.

  METHOD valor.
    rv_valor = lco_produto->get_preco( ) * quantidade.
  ENDMETHOD.

  METHOD set_quantidade.
    quantidade = im_quantidade.
  ENDMETHOD.

  METHOD get_quantidade.
    rv_quantidade = me->quantidade.
  ENDMETHOD.

  METHOD get_produto.
    rv_produto = lco_produto.
  ENDMETHOD.
ENDCLASS.                    "lcl_item IMPLEMENTATION

*&---------------------------------------------------------------------*
**&&~~ Test classes
*&---------------------------------------------------------------------*
CLASS lcl_test_class DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
    PUBLIC SECTION.
      INTERFACES lif_unit_test.
    PRIVATE SECTION.
      DATA: m_carrinho      TYPE REF TO lcl_carrinho,
            m_outro_produto TYPE REF TO lcl_produto,
            m_produto       TYPE REF TO lcl_produto.
      METHODS: setup,
               teardown,
               test_adicao_de_produto           FOR TESTING,
               test_remocao_de_produto          FOR TESTING,
               test_se_produtos_sao_unicos      FOR TESTING,
               test_aumento_de_qnt_do_prod      FOR TESTING,
               test_qnt_de_um_mesmo_prod_add    FOR TESTING,
               test_diminu_de_qnt_de_prods      FOR TESTING,
               test_calculo_de_preco_total      FOR TESTING,
               "test_imp_do_rel_com_data_incld FOR TESTING RAISING cx_static_check,
               "test_nomes_no_rel_atualizam_de_acordo_com_nomes_nos_produtos FOR TESTING RAISING cx_static_check,
               adiciona_10_produtos_iguais      .

ENDCLASS.                    "lcl_test_class DEFINITION

CLASS lcl_test_class IMPLEMENTATION.

  METHOD setup.
    m_carrinho      = NEW lcl_carrinho( ).

    m_produto       = NEW lcl_produto( im_nome = 'ps5'
                              im_preco = 5000 ).
    m_outro_produto = NEW lcl_produto( im_nome = 'Metal Gear'
                              im_preco = 299 ).

    TYPES: BEGIN OF t_produtos,
            lo_colprod TYPE REF TO lcl_produto,
           END OF t_produtos,
           it_produtos TYPE STANDARD TABLE OF t_produtos WITH EMPTY KEY.
  ENDMETHOD.


**********************************************************************
*Special method TEARDOWN( ) should be used to clear down the test data
*which was used by the actual test. You should use this method to clear
*the test data and make sure they are ready to use by the next Test method.
**********************************************************************
  METHOD teardown.
    CLEAR m_carrinho.
    CLEAR m_produto .
    CLEAR m_outro_produto .
  ENDMETHOD.                    "teardown

  METHOD test_adicao_de_produto.
    m_carrinho->incluir( im_lo_produto = m_produto ).
    data(quantidade_da_lista) = m_carrinho->get_produtos( )->size( ).

    cl_abap_unit_assert=>assert_equals( act = 1
                                        EXP = quantidade_da_lista
                                        msg = 'Adicao errada' ).
  ENDMETHOD.

  METHOD test_remocao_de_produto.
    m_carrinho->incluir( im_lo_produto = m_produto ).
    m_carrinho->remover( im_lo_produto = m_produto ).
    data(quantidade_da_lista) = m_carrinho->get_produtos( )->size( ).

    cl_abap_unit_assert=>assert_equals( act = quantidade_da_lista
                                        EXP = 0
                                        msg = 'Remoção do produto sem sucesso' ).
  ENDMETHOD.

  METHOD test_se_produtos_sao_unicos.
    "me->adiciona_10_produtos_iguais( ).

  ENDMETHOD.

  METHOD test_aumento_de_qnt_do_prod.
    m_carrinho->incluir( im_lo_produto = m_outro_produto ).
    cl_abap_unit_assert=>assert_equals( act = m_carrinho->get_produtos( )->size( )
                                        EXP = 1
                                        msg = 'Inclusão sem sucesso' ).

    m_carrinho->alterar_quantidade( im_lo_produto = m_outro_produto
                                    im_quantidade = 2 ).
    cl_abap_unit_assert=>assert_equals( act = m_carrinho->get_quantidade( m_outro_produto )
                                        EXP = 2
                                        msg = 'E alteração de quantidade também' ).

  ENDMETHOD.

  METHOD test_qnt_de_um_mesmo_prod_add.
    adiciona_10_produtos_iguais( ).

    cl_abap_unit_assert=>assert_equals( act = m_carrinho->get_quantidade( m_produto )
                                        EXP = 10
                                        msg = 'Adição do mesmo produto não está sendo levado em consideração.' ).
  ENDMETHOD.

  METHOD test_diminu_de_qnt_de_prods.
    me->adiciona_10_produtos_iguais( ).
    m_carrinho->alterar_quantidade( im_lo_produto = m_produto
                                    im_quantidade = 5 ).

    cl_abap_unit_assert=>assert_equals( act = m_carrinho->get_quantidade( m_produto )
                                        EXP = 5
                                        msg = 'Diminuição de quantidade de produtos sem sucesso' ).
  ENDMETHOD.

  METHOD test_calculo_de_preco_total.
    m_carrinho->incluir( im_lo_produto = m_produto ).
    m_carrinho->incluir( im_lo_produto = m_outro_produto ).
    m_carrinho->alterar_quantidade( im_lo_produto = m_outro_produto
                                    im_quantidade = 2 ).

    cl_abap_unit_assert=>assert_equals( act = m_carrinho->get_total( )
                                        EXP = 5598
                                        TOL = '0.0000000001'
                                        msg = 'Calculo de preço total incorreto' ).
  ENDMETHOD.

  METHOD adiciona_10_produtos_iguais.

    DATA(contador) = 1.

    WHILE contador le 10.
      m_carrinho->incluir( im_lo_produto = m_produto ).
      contador = contador + 1.
    ENDWHILE.

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
**&&~~ Presentation
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  DATA: lo_ps5      TYPE REF TO lcl_produto,
        lo_jogo     TYPE REF TO lcl_produto,
        lo_carrinho TYPE REF TO lcl_carrinho.


  lcl_produto=>lv_name = 'Classe Produto'.

** Accessing Static Method
  CALL METHOD lcl_produto=>show_name.

**&&~~ Creation of the Object -** When you have import Parameters for the
**&&~~ Constructor you must pass those values

**&&~~when you are creating the Object
* OBSOLETO
*   CREATE OBJECT lo_ps5
*         EXPORTING im_nome  = 'Ps5'
*                   im_preco = 5000.
*   CREATE OBJECT lo_jogo
*         EXPORTING im_nome  = 'Metal Gear'
*                   im_preco = 299.
   DATA(carrinho) = NEW lcl_carrinho( ).

   lo_ps5  = NEW lcl_produto( im_nome = 'ps5'
                              im_preco = 5000 ).
   data(lo_ps4)  = NEW lcl_produto( im_nome = 'ps4'
                              im_preco = 4000 ).
   lo_jogo = NEW lcl_produto( im_nome = 'Metal Gear'
                              im_preco = 50 ).

   data(ps5_nome) = lo_ps5->get_nome( ).
   data(msg) = |Produto { ps5_nome } preco { lo_ps5->get_preco( ) }.|.
   WRITE:/5 msg.
   WRITE:/5 'FIM TESTE NA MÃO'.

   carrinho->incluir( im_lo_produto = lo_ps5 ).
   carrinho->incluir( im_lo_produto = lo_ps4 ).
   carrinho->incluir( im_lo_produto = lo_jogo ).
   DATA(msg_test_quantidade) = |Quantidade de itens no carrinho: { carrinho->get_produtos( )->size( ) }|.
   carrinho->remover( im_lo_produto = lo_ps4 ).
   DATA(msg_test_aposremocao) = |PS4 removido, Quantidade de itens no carrinho: { carrinho->get_produtos( )->size( ) }|.
   carrinho->alterar_quantidade( im_lo_produto = lo_jogo
                                 im_quantidade =  5 ).
   DATA(msg_test_aposalteraquanti) = |Quantidade alterada, Quantidade de produtos atual: { carrinho->get_produtos( )->size( ) }|.
   DATA(msg_test_valortotal) = |Valor total do carrinho: { carrinho->get_total( ) }|.
   DATA(msg_test_quantiprodespec) = |Quantidade do produto { lo_jogo->get_nome( ) } : { carrinho->GET_QUANTIDADE( im_lo_produto = lo_jogo ) }|.


   WRITE:/5 'FIM TESTE FULL OO na mão'.



    cl_demo_output=>new( )->write_data( msg_test_quantidade
    )->write_data( msg_test_aposremocao
    )->write_data( msg_test_aposalteraquanti
    )->write_data( msg_test_valortotal
    )->write_data( msg_test_quantiprodespec
    )->display( ).

    carrinho->get_linefortest( ).
