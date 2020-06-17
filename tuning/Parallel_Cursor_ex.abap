*&---------------------------------------------------------------------*
*& Report ZPC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPC.

DATA t0 TYPE i.

PERFORM f_fetch_data.

*&---------------------------------------------------------------------*
*& Form F_FETCH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_FETCH_DATA .

  DATA: it_vbak TYPE TABLE OF vbak,
        wa_vbak TYPE vbak,

        it_vbap TYPE TABLE OF vbap,
        wa_vbap TYPE vbap.

  TYPES: BEGIN OF ty_final,
            vbeln TYPE vbeln,
            matnr TYPE matnr,
         END OF ty_final.

  DATA: it_final TYPE TABLE OF ty_final,
        wa_final TYPE ty_final.

  SELECT  mandt
          vbeln
          erdat
          erzet
          ernam
          angdt
          bnddt
          audat
          vbtyp
    FROM vbak
    INTO CORRESPONDING FIELDS OF TABLE it_vbak
    UP TO 1000 rows.

  IF sy-subrc = 0 AND it_vbak IS NOT INITIAL.

    SELECT  mandt
            vbeln
            posnr
            matnr
            matwa
            pmatn
            charg
      FROM vbap
      INTO CORRESPONDING FIELDS OF TABLE it_vbap
      FOR ALL ENTRIES IN it_vbak
      WHERE vbeln = it_vbak-vbeln.

    IF sy-subrc = 0 AND it_vbap IS NOT INITIAL.
      SORT it_vbap BY vbeln posnr.
    ENDIF.

  ENDIF.
**********************************************************************
* REALLY BAD PERFORMANCE, create a lot of noise
**********************************************************************
*  GET RUN TIME FIELD DATA(t1).
*  LOOP AT it_vbak INTO wa_vbak.
*    LOOP AT it_vbap INTO wa_vbap WHERE vbeln = wa_vbak-vbeln.
*      wa_final-vbeln = wa_vbak-vbeln.
*      wa_final-matnr = wa_vbap-matnr.
*      APPEND wa_final TO it_final.
*      CLEAR wa_final.
*    ENDLOOP.
*  ENDLOOP.
*  GET RUN TIME FIELD DATA(t2).
*  t0 = t2 - t1.
**********************************************************************

**********************************************************************
* Some tcodes for performance tunning and AMS related field
*SLG1 - apps logs
*ST12/ST05 - complete trace detailed / simple one for day2day and more focused
*SM12 - locks
*SM13 - update requests going on
**********************************************************************

**********************************************************************
* Parallel Cursor Concept
*Step 01: Sort both the tables
*Step 02: Write the first loop, like the previous way itself.
*Step 03: Read the second table with the key that was required to search the data.
*         This would give the first value regarding the key and also its position in the table [SY-TABIX].
*Step 04: If the above step executed successfully, it means data is there in the second table associated
*         with the key. Hence the SY-SUBRC will be set to zero. In this step we will check the value of SY-SUBRC.
*         If it is zero, than we will proceed.
*Step 05: Assign the SY-TABIX value into a local variable.
*         We do this step to preserve the SY-TABIX value as it changes with the loop.’
*Step 06: Now it’s the time to write the second loop. This time we don’t write the WHERE condition.
*         This time we will write FROM condition with the local variable we initialized above.
*Step 07: In this step we check if the key of first table is equal to the key of second table or not.
*         If not, then exit the loop. This stops the loop from reading non required data.
*Step 08: In this step we write our actual logic or print statements. And then close both the loops.
*
* So, in resume, we are NOT scanning the complete table through loops
* BETTER PERFORMANCE, a lot less noise
**********************************************************************

  DATA lv_index TYPE sy-index.
  SORT: it_vbak, it_vbap. "[Step 01]
  GET RUN TIME FIELD DATA(t3).
  LOOP AT it_vbak INTO wa_vbak. "[Step 02]
    READ TABLE it_vbap INTO wa_vbap WITH KEY vbeln = wa_vbak-vbeln BINARY SEARCH. "[Step 03]
    IF sy-subrc = 0. "[Step 04]
      lv_index = sy-tabix. "(you need to declare this variable earlier only) [Step 05]
      LOOP AT it_vbap INTO wa_vbap FROM lv_index. "[Step 06]
        IF wa_vbap-vbeln = wa_vbak-vbeln. "[Step 07]
          wa_final-vbeln = wa_vbak-vbeln.
          wa_final-matnr = wa_vbap-matnr.
          APPEND wa_final TO it_final.
          CLEAR wa_final.
        ELSE.
          CLEAR lv_index.
          EXIT.
        ENDIF.
        WRITE : / wa_final-vbeln, wa_final-matnr. "[Step 08] here or loop after done for easier debug
      ENDLOOP.
    ENDIF.
  ENDLOOP.
  GET RUN TIME FIELD DATA(t4).
  t0 = t4 - t3.
**********************************************************************
  WRITE: t0.
  LOOP AT it_final INTO wa_final. "[Step 08]
    WRITE : / wa_final-vbeln, wa_final-matnr.
  ENDLOOP.

ENDFORM.
