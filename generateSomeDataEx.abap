*&---------------------------------------------------------------------*
*& Report ZTREINA06
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTREINA06.

TABLES: ztreina_car,
        ztreina_carloc.

**********************************************************************
* TYPES
**********************************************************************
TYPES: BEGIN OF ty_carros,
         mandt    TYPE ztreina_car-mandt    ,
         id_carro TYPE ztreina_car-id_carro ,
         placa    TYPE ztreina_car-placa    ,
         ano      TYPE ztreina_car-ano      ,
         marca    TYPE ztreina_car-marca    ,
         cor      TYPE ztreina_car-cor      ,
         preco    TYPE ztreina_car-preco    ,
       END OF ty_carros,

       BEGIN OF ty_locacao,
         mandt           TYPE ztreina_carloc-mandt          ,
         id_locacao      TYPE ztreina_carloc-id_locacao     ,
         placa           TYPE ztreina_carloc-placa          ,
         dtini           TYPE ztreina_carloc-dtini          ,
         dtfim           TYPE ztreina_carloc-dtfim          ,
         valor_locacao   TYPE ztreina_carloc-valor_locacao  ,
         locatario       TYPE ztreina_carloc-locatario      ,
       END OF ty_locacao,

       BEGIN OF ty_marcas,
         marca TYPE string,
       END OF ty_marcas,

       BEGIN OF ty_cores,
         cor TYPE string,
       END OF ty_cores,

       t_cores   TYPE TABLE OF ty_cores  WITH EMPTY KEY,
       t_marcas  TYPE TABLE OF ty_marcas WITH EMPTY KEY.

**********************************************************************
*       VARS
**********************************************************************
DATA: it_carros  TYPE STANDARD TABLE OF ty_carros,
      it_locacao TYPE STANDARD TABLE OF ty_locacao,
      wa_carros  TYPE ty_carros,
      wa_locacao TYPE ty_locacao,

      it_marcas  TYPE t_marcas,
      it_cores   TYPE t_cores,
      id_gen     TYPE char128,
      idxmarca_random     TYPE i,
      idxcor_random       TYPE i,
      idxplaca_random     TYPE i,
      idxlocatario_random TYPE i,
      placa_gen  TYPE char128,
      placaconv  TYPE ztreina_car-placa,
      ano_gen    TYPE i,
      marca_gen  TYPE i,
      cor_gen    TYPE i,
      precoconv  LIKE ztreina_car-preco,
      preco_gen  LIKE bbseg-wrbtr.


SELECTION-SCREEN BEGIN OF BLOCK block
                            WITH FRAME TITLE title.

PARAMETERS: radio1 RADIOBUTTON GROUP rad1,
            radio2 RADIOBUTTON GROUP rad1.

SELECTION-SCREEN END OF BLOCK block.

SELECTION-SCREEN BEGIN OF BLOCK block2
                            WITH FRAME TITLE title2.

PARAMETERS: radio3 RADIOBUTTON GROUP rad2,
            radio4 RADIOBUTTON GROUP rad2.

SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3
                            WITH FRAME TITLE title3.

PARAMETERS:     p_quant TYPE i OBLIGATORY.

SELECTION-SCREEN END OF BLOCK block3.

INITIALIZATION.
  title  = 'Tabela' .
  title2 = 'Opção'.
  title3 = 'Parametro' .

************************************************************************
**   Processing block                                                 **
************************************************************************
START-OF-SELECTION.

IF radio1 = 'X' AND radio3 = 'X'.
  PERFORM car_generator.
ELSEIF radio1 = 'X' AND radio4 = 'X'.
  PERFORM car_deletion.
ELSEIF radio2 = 'X' AND radio3 = 'X'.
  PERFORM carloc_generator.
ELSEIF radio2 = 'X' AND radio4 = 'X'.
  PERFORM carloc_deletion.
ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CAR_GENERATOR
*&---------------------------------------------------------------------*
FORM car_generator .

  it_marcas = VALUE #( ( marca = 'Toyota'     )
                       ( marca = 'Volkswagen' )
                       ( marca = 'Ford'       )
                       ( marca = 'Nissan'     )
                       ( marca = 'Honda'      )
                       ( marca = 'Hyundai'    )
                       ( marca = 'Chevrolet'  )
                       ( marca = 'Volkswagen' ) ).

  it_cores = VALUE #( ( cor = 'Branco'   )
                      ( cor = 'Preto'    )
                      ( cor = 'Vermelho' )
                      ( cor = 'Verde'    )
                      ( cor = 'Azul'     )
                      ( cor = 'Amarelo'  )
                      ( cor = 'Cinza'    )
                      ( cor = 'Prateado' ) ).

  DO p_quant TIMES.

    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = 8
      IMPORTING
        RND_VALUE       = idxmarca_random .

    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = 8
      IMPORTING
        RND_VALUE       = idxcor_random .

*  Escolhendo marca e cores
    READ TABLE it_marcas INDEX idxmarca_random INTO data(wa_marca).
    READ TABLE it_cores  INDEX idxcor_random   INTO data(wa_cor).

*  Gerando id do carro
    CALL FUNCTION 'RANDOM_C_BY_SET'
      EXPORTING
        LEN_MIN         = 7
        LEN_MAX         = 7
        CHAR_MIN        = 1
        CHAR_MAX        = 10
        charset         = '1234567890'
      IMPORTING
        RND_VALUE       = id_gen.

*  Gerando numero da placa
    CALL FUNCTION 'RANDOM_C_BY_SET'
      EXPORTING
        LEN_MIN         = 7
        LEN_MAX         = 7
        CHAR_MIN        = 1
        CHAR_MAX        = 36
        charset         = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      IMPORTING
        RND_VALUE       = placa_gen.

*  Gerando ano
    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1980
        RND_MAX         = 2019
      IMPORTING
        RND_VALUE       = ano_gen.

*  Gerando preço do carro
    CALL FUNCTION 'RANDOM_AMOUNT'
      EXPORTING
        RND_MIN          = '50000'
        RND_MAX          = '300000'
        VALCURR          = 'BRL'
      IMPORTING
        RND_AMOUNT       = preco_gen.

    CALL FUNCTION 'MOVE_CHAR_TO_NUM'
      EXPORTING
        CHR             = preco_gen
      IMPORTING
        NUM             = precoconv
      EXCEPTIONS
        CONVT_NO_NUMBER = 1
        CONVT_OVERFLOW  = 2
        OTHERS          = 3.

    APPEND VALUE #( mandt    = 'DEV'
                    id_carro = id_gen
                    placa    = placa_gen
                    ano      = ano_gen
                    marca    = wa_marca-marca
                    cor      = wa_cor-cor
                    preco    = precoconv      ) TO it_carros.

  ENDDO.

  SORT it_carros.
  DELETE ADJACENT DUPLICATES FROM it_carros COMPARING placa.

  INSERT ztreina_car FROM TABLE it_carros.

  COMMIT WORK.

  MESSAGE 'Dados dos carros gerados aleatoriamente' TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CARLOC_GENERATOR
*&---------------------------------------------------------------------*
FORM carloc_generator .

  SELECT placa
    FROM ztreina_car INTO TABLE @data(it_placas).

  SELECT pernr
    FROM pa0002 INTO TABLE @data(it_locatarios).

  DESCRIBE TABLE it_placas     LINES data(lv_placascnt).
  DESCRIBE TABLE it_locatarios LINES data(lv_locatarioscnt).

  DO p_quant TIMES.

    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = lv_placascnt
      IMPORTING
        RND_VALUE       = idxplaca_random .

    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = lv_locatarioscnt
      IMPORTING
        RND_VALUE       = idxlocatario_random .

*  Escolhendo uma placa e locatario aleatoriamente
    READ TABLE it_placas     INDEX idxplaca_random     INTO data(wa_placa).
    READ TABLE it_locatarios INDEX idxlocatario_random INTO data(wa_locatarios).

*  Gerando id da locação
    CALL FUNCTION 'RANDOM_C_BY_SET'
      EXPORTING
        LEN_MIN         = 7
        LEN_MAX         = 7
        CHAR_MIN        = 1
        CHAR_MAX        = 10
        charset         = '1234567890'
      IMPORTING
        RND_VALUE       = id_gen.

*  Gerando valor da locação
    CALL FUNCTION 'RANDOM_AMOUNT'
      EXPORTING
        RND_MIN          = '400'
        RND_MAX          = '3000'
        VALCURR          = 'BRL'
      IMPORTING
        RND_AMOUNT       = preco_gen.

    CALL FUNCTION 'MOVE_CHAR_TO_NUM'
      EXPORTING
        CHR             = preco_gen
      IMPORTING
        NUM             = precoconv
      EXCEPTIONS
        CONVT_NO_NUMBER = 1
        CONVT_OVERFLOW  = 2
        OTHERS          = 3.

*gerando datas
    data: d_ini  TYPE sy-datum,
          d_fim  TYPE sy-datum,
          dt_ini TYPE sy-datum,
          dt_fim TYPE sy-datum,
          i_date TYPE sy-datum,
          v_date TYPE sy-datum.

    dt_ini = sy-datum. "'20190707'.
    dt_fim = sy-datum. "'20190707'.
    data(decrement_random) = 0.
    data(increment_random) = 0.

    CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = 31
      IMPORTING
        RND_VALUE       = decrement_random .

     CALL FUNCTION 'RANDOM_I4'
      EXPORTING
        RND_MIN         = 1
        RND_MAX         = 31
      IMPORTING
        RND_VALUE       = increment_random .

    IF sy-index MOD 2 = 0.
      d_ini = dt_ini + increment_random.
      d_fim = dt_fim - decrement_random.
    ELSE.
      d_ini = dt_ini - decrement_random.
      d_fim = dt_fim + increment_random.
    ENDIF.

    APPEND VALUE #( mandt               = 'DEV'
                    id_locacao          = id_gen
                    placa               = wa_placa-placa
                    dtini               = d_ini
                    dtfim               = d_fim
                    valor_locacao       = precoconv
                    locatario           = wa_locatarios-pernr  ) TO it_locacao.

  ENDDO.

  SORT it_locacao.
  DELETE ADJACENT DUPLICATES FROM it_locacao COMPARING placa.

  INSERT ztreina_carloc FROM TABLE it_locacao.

  COMMIT WORK.

  MESSAGE 'Dados dos carros gerados aleatoriamente' TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CAR_DELETION
*&---------------------------------------------------------------------*
FORM car_deletion .
  DELETE FROM ztreina_car.
  COMMIT WORK.
  MESSAGE 'Dados da tabela ZTREINA_CAR eliminados' TYPE 'S'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CARLOC_DELETION
*&---------------------------------------------------------------------*
FORM carloc_deletion .
  DELETE FROM ztreina_carloc.
  COMMIT WORK.
  MESSAGE 'Dados da tabela ZTREINA_CARLOC eliminados' TYPE 'S'.
ENDFORM.
