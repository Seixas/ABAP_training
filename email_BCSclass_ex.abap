*&---------------------------------------------------------------------*
*& Report ZBCS
*&---------------------------------------------------------------------*
*& using BCS, check tcode SOST after
*& check sap example programs BCS_EXAMPLE_8, BCS_EXAMPLE_7
*&---------------------------------------------------------------------*
REPORT ZBCS.

"email configs at tcode SCOT, basis team helps

*&---------------------------------------------------------------------*
*& Data Declaration
*&---------------------------------------------------------------------*
DATA : lo_mime_helper   TYPE REF TO cl_gbt_multirelated_service,
       lo_bcs           TYPE REF TO cl_bcs, " Send request
       lo_doc_bcs       TYPE REF TO cl_document_bcs, " Mail body, document
       lx_document_bcs  TYPE REF TO cx_document_bcs, "document exception
       lo_recipient     TYPE REF TO if_recipient_bcs, " Recipient
       lo_sender        TYPE REF TO if_sender_bcs, " Sender address
       lt_soli          TYPE TABLE OF soli, " Mail body html
       ls_soli          TYPE soli, " Mail body line
       lv_status        TYPE bcs_rqst,

       lv_attach        TYPE bcsy_text, " Attachment
       "wa_text          TYPE soli, " Work area for attach
       lv_size          TYPE sood-objlen, " Size of Attachment

       lv_sent_to_all TYPE os_boolean.

*data for a list of emails, created at SO15/SO23
DATA: ob_distributionlist_bcs TYPE REF TO cl_distributionlist_bcs.
PARAMETERS: p_dlist TYPE so_dli_nam MATCHCODE OBJECT sxmsalert_dl_search_hlp . " Name of document, folder or distribution list
*&---------------------------------------------------------------------*
*& Creation of the mail
*&---------------------------------------------------------------------*

***********************************************************************
**RAW email content example
**Create document for mail body
*DATA: l_body TYPE bcsy_text, " Mail body
*      wa_text TYPE soli. " Work area for attach
*wa_text = 'Contents'.
*APPEND wa_text TO l_body.
*CLEAR wa_text.
*
*lo_document = cl_document_bcs=>create_document(
*                i_type = 'RAW'
*                i_text = l_body
*                i_subject = 'Log' ).
*
***********************************************************************


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

* Add attachment
*TRY.
*  lo_doc_bcs->add_attachment(
*    EXPORTING
*      i_attachment_type     = 'PDF' "CSV etc
*      i_attachment_size     = lv_size
*      i_attachment_subject  = 'Form Details'
*      i_att_content_text    = lv_attach.
*      i_att_content_hex     = it_content ).
*
*  CATCH cx_document_bcs INTO lx_document_bcs.
*ENDTRY.

"create send request
lo_bcs = cl_bcs=>create_persistent( ).

* Pass the document to send request
lo_bcs->set_document( i_document = lo_doc_bcs ).

* Sender addess
lo_sender = cl_sapuser_bcs=>create( sy-uname ).
CALL METHOD lo_bcs->set_sender
  EXPORTING
    i_sender = lo_sender.

*"Recipient address another way
*DATA l_email type ad_smtpadr, " Email ID
*l_email =<ur_emailid>.
*l_recipient = cl_cam_address_bcs=>create_internet_address( l_email ).

* Set the email address
lo_recipient = cl_cam_address_bcs=>create_internet_address(
                  i_address_string =  'seixas.dev@gmail.com' ).

lo_bcs->add_recipient( i_recipient = lo_recipient ).
*            i_express    = 'X'
*            i_copy       = 'X'
*            i_blind_copy = ' '
*            i_no_forward = ' ' ).

*--------------------------------------------------------------------*
*In case of multiple emails, list, etc, use distribution list, tcode SO15/SO23
TRY.
  ob_distributionlist_bcs = cl_distributionlist_bcs=>getu_persistent(
                                i_dliname = p_dlist
                                i_private = abap_false ). "abap_true ) .

  CATCH cx_address_bcs .
    MESSAGE s882(so) WITH p_dlist DISPLAY LIKE 'E'. " Distribution list <&> does not exist
  RETURN .
ENDTRY.

CALL METHOD lo_bcs->add_recipient
  EXPORTING
    i_recipient = ob_distributionlist_bcs
    i_copy      = abap_true.
*--------------------------------------------------------------------*

* Change the status.
lv_status = 'N'.
CALL METHOD lo_bcs->set_status_attributes
  EXPORTING
    i_requested_status = lv_status.

*&---------------------------------------------------------------------*
*& Send the email
*&---------------------------------------------------------------------*

"Trigger E-Mail immediately
lo_bcs->set_send_immediately( 'X' ).

lo_bcs->send( EXPORTING i_with_error_screen = 'X'
              RECEIVING result              = lv_sent_to_all ).

* Commit Work.
IF sy-subrc IS INITIAL.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ENDIF.


**--------------------------------------------------------------------*
** example to compress file in attach, like excel exceeding 255 column
**--------------------------------------------------------------------*
*
*"IT_ATTACH contain the data to transfer.
*"Field separator "TAB" and record separator is "RETURN".
*
*DATA: it_attach TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE.
*
*"it_attach has been filled up with the ALV data. Fields are separated by "TAB" and record by "Return".
*"Than pass it_attach into the compress_table form.
*
*"FORM COMPRESS_TABLE reorganize the IT_ATTACH to have maximum 250 characters per line.
*"That will allow Excel to read the entire table.
*
*FORM compress_table.
*  DATA: it_comp  TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE,
*        size     TYPE i,
*        line     TYPE string,
*        compress(256).
*
*  REFRESH it_comp.
*  CLEAR compress.
*  CLEAR line.
*  LOOP AT it_attach.
*    compress = it_attach.
*    WHILE compress <> ''.
*      CONCATENATE line compress(1) INTO line RESPECTING BLANKS.
*      size = STRLEN( line ).
*      IF size = 255.
*        it_comp = line.
*        APPEND it_comp.
*        CLEAR it_comp.
*        CLEAR line.
*      ENDIF.
*      SHIFT compress LEFT.
*    ENDWHILE.
*  ENDLOOP.
*  size = STRLEN( line ).
*  IF size > 0.
*    it_comp = line.
*    APPEND it_comp.
*  ENDIF.
*  REFRESH it_attach.
*  it_attach[] = it_comp[].
*ENDFORM. " COMPRESS_TABLE
*
*"Then you can use "IT_ATTACH" as attachment into your email.
*"Excel should be able to upload the file.
