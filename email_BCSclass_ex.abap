*&---------------------------------------------------------------------*
*& Report ZBCS
*&---------------------------------------------------------------------*
*& using BCS, check tcode SOST after
*&---------------------------------------------------------------------*
REPORT ZBCS.

*&---------------------------------------------------------------------*
*& Data Declaration
*&---------------------------------------------------------------------*
DATA : lo_mime_helper TYPE REF TO cl_gbt_multirelated_service,
       lo_bcs         TYPE REF TO cl_bcs,
       lo_doc_bcs     TYPE REF TO cl_document_bcs,
       lo_recipient   TYPE REF TO if_recipient_bcs,
       lt_soli        TYPE TABLE OF soli,
       ls_soli        TYPE soli,
       lv_status      TYPE bcs_rqst.

*&---------------------------------------------------------------------*
*& Creation of the mail
*&---------------------------------------------------------------------*

" Create the main object of the mail.
CREATE OBJECT lo_mime_helper.

" Create the mail content.
ls_soli-line = '<!DOCTYPE html PUBLIC “-//IETF//DTD HTML 5.0//EN">'.
APPEND ls_soli TO lt_soli.

ls_soli-line = '<HTML>'.
APPEND ls_soli TO lt_soli.

ls_soli-line = '<BODY>'.
APPEND ls_soli TO lt_soli.

ls_soli-line = 'Hi,<P>Content Section!</P>'.
APPEND ls_soli TO lt_soli.

ls_soli-line = '</BODY>'.
APPEND ls_soli TO lt_soli.

ls_soli-line = '</HTML>'.
APPEND ls_soli TO lt_soli.

" Set the HTML body of the mail
CALL METHOD lo_mime_helper->set_main_html
  EXPORTING
    content     = lt_soli
    description = 'Test Email'.

* Set the subject of the mail.
lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                i_subject          = 'Subject of our email'
                i_importance       = '9'                " 1~High Priority  5~Average priority 9~Low priority
                i_multirel_service = lo_mime_helper ).

lo_bcs = cl_bcs=>create_persistent( ).

lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address
lo_recipient = cl_cam_address_bcs=>create_internet_address(
                  i_address_string =  'seixas.dev@gmail.com' ).

lo_bcs->add_recipient( i_recipient = lo_recipient ).

* Change the status.
lv_status = 'N'.
CALL METHOD lo_bcs->set_status_attributes
  EXPORTING
    i_requested_status = lv_status.

*&---------------------------------------------------------------------*
*& Send the email
*&---------------------------------------------------------------------*
lo_bcs->send( ).

* Commit Work.
IF sy-subrc IS INITIAL.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ENDIF.
