*&---------------------------------------------------------------------*
*& Report ZADDPI
*&---------------------------------------------------------------------*
*& Interface Proxy2SOAP
*& Proxy(Sender=ECC/S4H) -> PI -> SOAP(Receiver=WS)
*& a calculator adition operation example, 2 int values out, 1 result in
*&---------------------------------------------------------------------*
REPORT ZADDPI.

DATA:
"Reference variables for proxy and exception class
      lo_clientProxy   TYPE REF TO zcl_co_si_adicionar_out_sync, "[Generated sproxy class],
      lo_sys_exception TYPE REF TO cx_ai_system_fault,

"Structures to set and get message content
      ls_REQuest           TYPE zcl_mt_adicionar_request , "[Output message type]
      ls_REQsubElementData TYPE zcl_dt_adicionar_request , "[Output message DataType]
      ls_RESponse          TYPE zcl_mt_adicionar_response. "[Input message type]    

"2. Complete the structure ls_REQuest for the request message.

ls_REQsubElementData = VALUE #( VALOR1 = 3
                                VALOR2 = 4 ).

ls_request = VALUE #( MT_ADICIONAR_REQUEST = ls_REQsubElementData ).

"3. Instantiate your client proxy.

TRY.
 "create proxy client
  CREATE OBJECT lo_clientProxy. "( LOGICAL_PORT_NAME ).

*    LOGICAL_PORT_NAME is the name of the logical port that you want to use,
*  which is used to define the receiver.
*    You can omit this parameter if you are using a default port
*  or the XI runtime (see runtime configuration).

*  4. To send a message, call the corresponding client proxy method.
*  WSDL allows several such methods (specified by the element <operation>).
*  In XI, there is only one method, with the default name
*  EXECUTE_SYNCHRONOUS or EXECUTE_ASYNCHRONOUS.
*  Catch at least the exception cx_ai_system_fault:

  "do synchronous client proxy call
  CALL METHOD lo_clientProxy->si_adicionar_out_sync "[method of generated sproxy class]
    EXPORTING output = ls_REQuest
    IMPORTING input  = ls_RESponse.

CATCH cx_ai_system_fault INTO lo_sys_exception.
  "Error handling
ENDTRY.
