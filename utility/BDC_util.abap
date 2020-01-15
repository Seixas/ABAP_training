class YCL_UTIL_BDC definition
  public
  final
  create public .

public section.

  methods BDC_DYNPRO
    importing
      !IV_PROGRAM type BDC_PROG
      !IV_DYNPRO type BDC_DYNR
      !IV_DYNBEGIN type BDC_START optional .
  methods BDC_FIELDVALUE
    importing
      !IV_FNAM type FNAM_____4
      !IV_FVAL type BDC_FVAL .
  methods BDC_FREE .
  methods CALL_TRANSACTION
    importing
      !IV_TCODE type TCODE
      !IV_MODE type CHAR1 default 'N'
      !IV_UPDATE type CHAR1 default 'S' .
  methods GET_MESSAGES
    returning
      value(RT_MSG) type TAB_BDCMSGCOLL .
protected section.
private section.

  data T_BDC type TAB_BDCDATA .
  data W_BDC type BDCDATA .
  data T_MSG type TAB_BDCMSGCOLL .
ENDCLASS.



CLASS YCL_UTIL_BDC IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method YCL_UTIL_BDC->BDC_DYNPRO
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PROGRAM                     TYPE        BDC_PROG
* | [--->] IV_DYNPRO                      TYPE        BDC_DYNR
* | [--->] IV_DYNBEGIN                    TYPE        BDC_START(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD bdc_dynpro.

    w_bdc-program  = iv_program.
    w_bdc-dynpro   = iv_dynpro.
    w_bdc-dynbegin = iv_dynbegin.

    APPEND w_bdc TO t_bdc.
    CLEAR w_bdc.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method YCL_UTIL_BDC->BDC_FIELDVALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FNAM                        TYPE        FNAM_____4
* | [--->] IV_FVAL                        TYPE        BDC_FVAL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD bdc_fieldvalue.

    w_bdc-fnam = iv_fnam.
    w_bdc-fval = iv_fval.

    APPEND w_bdc TO t_bdc.
    CLEAR w_bdc.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method YCL_UTIL_BDC->BDC_FREE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD bdc_free.

    FREE: me->t_bdc,
          me->t_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method YCL_UTIL_BDC->CALL_TRANSACTION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TCODE                       TYPE        TCODE
* | [--->] IV_MODE                        TYPE        CHAR1 (default ='N')
* | [--->] IV_UPDATE                      TYPE        CHAR1 (default ='S')
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD call_transaction.

    CALL TRANSACTION iv_tcode
    USING me->t_bdc
    MODE iv_mode
    UPDATE iv_update
    MESSAGES INTO me->t_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method YCL_UTIL_BDC->GET_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_MSG                         TYPE        TAB_BDCMSGCOLL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_messages.

    rt_msg = me->t_msg.

  ENDMETHOD.
ENDCLASS.


DATA(o_bdc) = NEW zcl_util_bdc( ).
  o_bdc->bdc_free( ).
  o_bdc->bdc_dynpro( iv_program = 'SAPMV45A' iv_dynpro = '0102' iv_dynbegin = 'X' ).
  o_bdc->bdc_fieldvalue( iv_fnam = 'BDC_OKCODE' iv_fval = '/00' ).
  o_bdc->bdc_fieldvalue( iv_fnam = 'VBAK-VBELN' iv_fval = 'VALOR' ).
  o_bdc->bdc_dynpro( iv_program = 'SAPMV45A' iv_dynpro = '4001' iv_dynbegin = 'X' ).
  o_bdc->bdc_fieldvalue( iv_fnam = 'BDC_OKCODE' iv_fval = '=BVFP' ).
  o_bdc->bdc_dynpro( iv_program = 'SAPMV45A' iv_dynpro = '4001' iv_dynbegin = 'X' ).
  o_bdc->bdc_fieldvalue( iv_fnam = 'BDC_OKCODE' iv_fval = '=SICH' ).
  o_bdc->call_transaction( iv_tcode = 'VA02' ). 
