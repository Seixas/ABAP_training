*&---------------------------------------------------------------------*
*& Report ZTREINA07
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztreina07.

TABLES: usr02.

PARAMETERS: p_bname LIKE usr02-bname,
            p_class LIKE usr02-class.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bname.

  PERFORM f_valuerequest_vbeln.

*&---------------------------------------------------------------------*
*& Form f_valuerequest_vbeln
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM f_valuerequest_vbeln.

  DATA: BEGIN OF t_data OCCURS 1,
          data(20),
        END OF t_data.

  DATA: lwa_dfies TYPE dfies.

  DATA wa_h_field LIKE dfies.
  DATA t_h_field  LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA v_h_dselc  LIKE dselc OCCURS 0 WITH HEADER LINE.

  SELECT * FROM usr02.
    t_data = usr02-bname. APPEND t_data.
    t_data = usr02-class. APPEND t_data.
  ENDSELECT.

  PERFORM f_fieldinfo_get USING 'USR02'
                                'BNAME'
                          CHANGING wa_h_field.
  APPEND wa_h_field TO t_h_field.
  PERFORM f_fieldinfo_get USING 'USR02'
                                'CLASS'
                          CHANGING wa_h_field.
  APPEND wa_h_field TO t_h_field.

  v_h_dselc-fldname   = 'BNAME'.
  v_h_dselc-dyfldname = 'P_BNAME'.
  APPEND v_h_dselc.
  v_h_dselc-fldname   = 'CLASS'.
  v_h_dselc-dyfldname = 'P_CLASS'.
  APPEND v_h_dselc.

  DATA: ld_repid LIKE sy-repid.
  ld_repid = sy-repid.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'P_BNAME'
      dynpprog        = ld_repid
      dynpnr          = '1000'
      dynprofield     = 'P_BNAME'
*     multiple_choice = ''
*     value_org       = 'S'
    TABLES
      value_tab       = t_data
      field_tab       = t_h_field
*     return_tab      = return_tab
      dynpfld_mapping = v_h_dselc
    EXCEPTIONS
      OTHERS          = 0.

ENDFORM. " f_valuerequest_vbeln

*&---------------------------------------------------------------------*
*& Form f_fieldinfo_get
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* -->P_0079 text
* -->P_0080 text
* <--P_wa_h_field text
*----------------------------------------------------------------------*
FORM f_fieldinfo_get USING p_tabname
                           p_fieldname
                     CHANGING c_wa_field_tab.


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = p_tabname
      fieldname      = p_fieldname
      lfieldname     = p_fieldname
    IMPORTING
      dfies_wa       = c_wa_field_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM. " f_fieldinfo_get
