*&---------------------------------------------------------------------*
*& Report  Z_OPENSQL_1                                                 *
*&---------------------------------------------------------------------*

REPORT  z_opensql_1                             .

DATA wa_employees LIKE zemployees.

********************
**** - INSERT
wa_employees-employee = '10000006'.
wa_employees-surname = 'WESTMORE'.
wa_employees-forename = 'BRUCE'.
wa_employees-title = 'MR'.
wa_employees-dob = '19921213'.

INSERT zemployees FROM wa_employees.

IF sy-subrc = 0.
  WRITE 'Record Inserted Correctly'.
ELSE.
  WRITE: 'We have a return code of ', sy-subrc.
ENDIF.

********************
**** - UPDATE
wa_employees-employee = '10000006'.
wa_employees-surname = 'EASTMORE'.
wa_employees-forename = 'ANDY'.
wa_employees-title = 'MR'.
wa_employees-dob = '19921213'.

UPDATE zemployees FROM wa_employees.

IF sy-subrc = 0.
  WRITE: / 'Record Updated Correctly'.
ELSE.
  WRITE: / 'We have a return code of ', sy-subrc.
ENDIF.

********************
**** - MODIFY
wa_employees-employee = '10000006'.
wa_employees-surname = 'NORTHMORE'.
wa_employees-forename = 'PETER'.
wa_employees-title = 'MR'.
wa_employees-dob = '19921213'.

MODIFY zemployees FROM wa_employees.

IF sy-subrc = 0.
  WRITE: / 'Record Modified Correctly'.
ELSE.
  WRITE: / 'We have a return code of ', sy-subrc.
ENDIF.
************
CLEAR wa_employees.

wa_employees-employee = '10000007'.
wa_employees-surname = 'SOUTHMORE'.
wa_employees-forename = 'SUSAN'.
wa_employees-title = 'MRS'.
wa_employees-dob = '19921113'.

MODIFY zemployees FROM wa_employees.

IF sy-subrc = 0.
  WRITE: / 'Record Modified Correctly'.
ELSE.
  WRITE: / 'We have a return code of ', sy-subrc.
ENDIF.

********************
**** - DELETE
CLEAR wa_employees.

wa_employees-employee = '10000007'.

DELETE zemployees FROM wa_employees.

IF sy-subrc = 0.
  WRITE: / 'Record Deleted Correctly'.
ELSE.
  WRITE: / 'We have a return code of ', sy-subrc.
ENDIF.
************

CLEAR wa_employees.

DELETE FROM zemployees WHERE surname = 'BROWN'.

IF sy-subrc = 0.
  WRITE: / '2 Records Deleted Correctly'.
ELSE.
  WRITE: / 'We have a return code of ', sy-subrc.
ENDIF.
************
CLEAR wa_employees.

DELETE FROM zemployees.

