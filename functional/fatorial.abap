REPORT zfatorial_funcional.

CLASS cl_fatorial DEFINITION.
  PUBLIC SECTION.
  METHODS doFatorial
    IMPORTING
      !n TYPE i
    RETURNING
      VALUE(resultado) TYPE i.
ENDCLASS.

CLASS cl_fatorial IMPLEMENTATION.
  METHOD doFatorial.
    resultado = COND i( WHEN n = 0
                          THEN 1
                        ELSE
                          REDUCE i( INIT r= 1
                                      FOR i = 1 THEN i + 1 WHILE i <= n
                                      NEXT r = r * i ) ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  cl_demo_output=>display( NEW cl_fatorial( )->doFatorial( 20 ) ).
