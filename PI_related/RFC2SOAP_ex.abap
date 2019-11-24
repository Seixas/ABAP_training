*&---------------------------------------------------------------------*
*& Report ZPIRFC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPIRFC.

DATA: val1 TYPE string,
      val2 TYPE string,
      res  TYPE string.

val1 = '40'.
val2 = '6'.

* 1- RFC created in SM59->TCP/IP, e.g.: RFC2PI
* 2- PROGRAM_ID needs to match same one at PI, check radiobutton "Server Regristrated Program"
* 3- Test connection after done the Channel creation at Integration Builder->ECC/S4H client as RFC Sender adapter
* 4- Create a Function Group->Function Module, checking "Access Remote Module radio", settup parameters with "Value Transfer" checkBox
* 5- Import FM/RFC Object at ESR Designer
CALL FUNCTION 'ZPI_ALUNO40_EX005_ADICIONA' DESTINATION 'RFC2PI' "destination from SM59(actual RFC)
  EXPORTING
    I_VALOR1          = val1
    I_VALOR2          = val2
  IMPORTING
    I_RESULTADO       = res
          .
WRITE res.
