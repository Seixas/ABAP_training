DATA: line(100) TYPE c,
      itab TYPE TABLE OF line,
      wa_tab LIKE LINE OF itab.

PARAMETER program TYPE sy-repid.

CALL FUNCTION 'GET_TABLES'
  EXPORTING
    progname = program
  TABLES
    tables_tab = itab.

SORT itab BY line.

DELETE ADJACENT DUPLICATES FROM itab COMPARING line.

LOOP AT itab INTO wa_tab.
  WRITE wa_tab-line.
ENDLOOP.

---x--- or

PARAMETERS rep TYPE sy-repid.

DATA: BEGIN OF itab1 OCCURS 0,
      line(255),
      END OF itab1.

DATA itab2 LIKE stoken OCCURS 0 WITH HEADER LINE.
DATA itab3 LIKE sstmnt  OCCURS 0 WITH HEADER LINE.
DATA itab4 LIKE itab1 OCCURS 0 WITH HEADER LINE.


read report rep into itab1.

APPEND: 'SELECT' TO itab4,
        'TABLES' TO itab4.

SCAN ABAP-SOURCE itab1    KEYWORDS FROM itab4
                          TOKENS INTO itab2
                          STATEMENTS INTO itab3.
                          
 
*************
use the FM GET_TABLES , pass the program name it will give the tables used in that program

OR

IN the transaction ST05 ..Switch on the SQL TRACE ..
Execute your program..
Switch off the SQL trace..
THen Press "List trace" button in ST05 to see the SQLs used

OR

RPR_ABAP_SOURCE_SCAN or
SCAN ABAP-SOURCE command
