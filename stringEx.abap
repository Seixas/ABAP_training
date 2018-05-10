*&---------------------------------------------------------------------*
*& Report  ZABAP22_SEIXAS
*&---------------------------------------------------------------------*

REPORT ZABAP22_SEIXAS NO STANDARD PAGE HEADING.

WRITE: 'Meu programa para calcular uma media estatica em ABAP'.

DATA:
      v_VALOR1 TYPE I,
      v_VALOR2 TYPE I,
      v_VALOR3 TYPE I,
      v_MEDIA  TYPE P DECIMALS 3 LENGTH 3.

v_VALOR1 = 75.
v_VALOR2 = 43.
v_VALOR3 = 24.

v_MEDIA = ( v_VALOR1 + v_VALOR2 + v_VALOR3 ) / 3.

WRITE:/ 'A media dos 3 valores é: ' , V_MEDIA LEFT-JUSTIFIED COLOR 3.

WRITE:/.

WRITE:/ 'Convertendo dolar estatico em real em ABAP'.

DATA:
  V_DOLAR   TYPE P DECIMALS 2 LENGTH 3,
  V_REAL    TYPE P DECIMALS 2 LENGTH 3,
  V_COTACAO TYPE P DECIMALS 2 LENGTH 4.

V_DOLAR   =  '125'.
V_COTACAO = '3.23'.

V_REAL = V_DOLAR * V_COTACAO.

WRITE:/ V_DOLAR LEFT-JUSTIFIED COLOR 6, 'dolares são', V_REAL COLOR 5, 'reais'.


------------------------------------------------------------------------------------------------

STRINGS EXEMPLOS

REPORT  Z_CHAR_STRINGS.

TABLES zemployees.

DATA mychar(10) TYPE c.

DATA zemployeesl(40) type c.

DATA zemployees2 like zemployees-surname.
********************************************

DATA znumberl TYPE n.
********************************************

* Concatenating string fields
* difinition: CONCATENATE f1 f2 INTO d1 [separated by sep].
DATA: title(15)         TYPE c VALUE 'Mr',
      surname(40)       TYPE c VALUE 'Doe',
      forename(40)      TYPE c VALUE 'John',
      sep,
      destination(200)  TYPE c,
      spaced_name(20)   TYPE c VALUE 'Mr    John    Doe',
      len               TYPE i,
      surname2(40),
      empl_num(10).
DATA: mystring(30)  TYPE c,
      a1(10)        TYPE c,
      a2(10)        TYPE c,
      a3(10)        TYPE c,
      sep2(2)       TYPE c VALUE '**'.
*---

CONCATENATE title surname forename INTO destination SEPARATED BY sep.
WRITE destination.
ULINE.

* Condensing char fields
*definition: CONDENSE c [NO-GAPS].

CONDENSE spaced_name.
WRITE spaced_name.
ULINE.

CONDENSE spaced_name NO-GAPS.
WRITE spaced_name.
ULINE.

* find the length of a string

len = strlen( surname ).
WRITE: 'O tamanho do surname field é ', len.
ULINE.

*replace char strings

surname2 = 'Mr, John Doe'.
WHILE sy-subrc = 0.
  REPLACE ',' with '.' INTO surname2.
ENDWHILE.
WRITE: surname2.
ULINE.

*******************************
* Searching for specific chars
surname2 = 'Mr John Doe'.
WRITE: / 'Procurando: "Mr John Doe"'.
SKIP.

* blank spaces ignored
SEARCH surname2 for 'John   '.
WRITE: / 'Procurando: "John   "'.
WRITE: / 'sy-subrc: ', sy-subrc, / 'sy-fdpos: ', sy-fdpos.
ULINE.

*blank spaces are taken into account
SEARCH surname2 for '.John   .'.
WRITE: / 'Procurando: ".John   ."'.
WRITE: / 'sy-subrc: ', sy-subrc, / 'sy-fdpos: ', sy-fdpos.
ULINE.

* wild card search - word ending with 'oe'
SEARCH surname2 for '*oe'.
WRITE: / 'Procurando: "*oe"'.
WRITE: / 'sy-subrc: ', sy-subrc, / 'sy-fdpos: ', sy-fdpos.
ULINE.

* wild card search - word starting with 'Joh'
SEARCH surname2 for 'Joh*'.
WRITE: / 'Procurando: "Joh*"'.
WRITE: / 'sy-subrc: ', sy-subrc, / 'sy-fdpos: ', sy-fdpos.
ULINE.


**********
*SHIFT statement
empl_num = '0005468971'.

SHIFT empl_num LEFT DELETING LEADING '0'.
WRITE empl_num.

empl_num = '0005468971'.
SHIFT empl_num CIRCULAR.
WRITE empl_num.

**********
* splitting chars strings


mystring = ' 1234** ABCD **6789'.
*mystring = ' 1234** ABCD **6789**WXYZ'.
WRITE mystring.
SKIP.

SPLIT mystring AT sep2 INTO a1 a2 a3.

WRITE / a1.
WRITE / a2.
WRITE / a3.


* subfields

DATA: int_telephone_num(17) TYPE c,
      country_code(3) TYPE c,
      telephone_num(14) TYPE c.

int_telephone_num = '+55 (22)999991111'.
WRITE int_telephone_num.
SKIP.

country_code = int_telephone_num(3).
telephone_num = int_telephone_num+4(13).
WRITE / country_code.
WRITE / telephone_num.

country_code+1(2) = '01'.
WRITE / country_code.
