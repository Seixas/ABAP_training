*Prints the numbers from 1 to 100.
*Multiples of 3 print “Fizz” instead of the number and for the multiples of 5 print “Buzz”.
*For numbers which are multiples of both 3 and 5 print “FizzBuzz”.

"normal way
REPORT zfizz_buzz.

DATA: int_tab 	  TYPE STANDARD TABLE OF i,
      result_tab 	TYPE STANDARD TABLE OF string.

DO 100 TIMES.
  APPEND INITIAL LINE TO int_tab ASSIGNING FIELD-SYMBOL(<int_value>).
  <int_value> = sy-tabix.
ENDDO.

LOOP AT int_tab ASSIGNING <int_value>.
  APPEND INITIAL LINE TO result_tab ASSIGNING FIELD-SYMBOL(<result_value>).
  IF <int_value> MOD 3 = 0.
    <result_value> = |Fizz|.
  ENDIF.
  IF <int_value> MOD 5 = 0.
    <result_value> = |{ <result_value> }Buzz|.
  ENDIF.
  IF <result_value> IS INITIAL.
    <result_value> = <int_value>.
  ENDIF.
ENDLOOP.

cl_demo_output=>display( result_tab ).

"functional way
REPORT zfunctional_fizz_buzz.

cl_demo_output=>display(
  VALUE string_table(
    FOR index = 1 WHILE index <= 100 (
      COND string( LET result3 = index MOD 3 "let for local vars
                       result5 = index MOD 5 IN
                   WHEN result3 = 3 AND result5 = 0 THEN |FizzBuzz|
                   WHEN result3 = 0                 THEN |Fizz|
                   WHEN result5 = 0                 THEN |Buzz|
                   ELSE index ) ) ) ).
