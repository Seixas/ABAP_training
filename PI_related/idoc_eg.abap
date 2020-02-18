report z_idoc_creat_tr .

tables : ekpo,
         edidd,  " Data record (IDoc)
         tbdlst, " Text for logical system
         edmsg . "Logical message types

parameters: p_ebeln like ekpo-ebeln.
*            p_logsys LIKE tbdlst-logsys .
*            p_mestyp LIKE edmsg-msgtyp DEFAULT 'Z_EKPO'.

data : c_seg1 like edidd-segnam value 'ZSEG1_TR',
       c_seg2 like edidd-segnam value 'ZSEG2_TR',
       itab_comm_idocs  like edidc occurs 0 with header line ,
       control_record like edidc.

*Internal Tables

data :
     itab_edidd like edidd occurs 0 with header line, "Data record(IDoc)

*       itab_seg1 LIKE zseg1_tr  OCCURS 0 WITH HEADER LINE ,
* zseg1_tr structure generated when you define the Segments in WE31

       itab_seg2 like zseg2_tr  occurs 0 with header line .
* zseg2_tr structure generated when you define the Segments in WE31

* Work Area

data : seg1 like zseg1_tr, " Header Data
       seg2 like zseg2_tr.

select single * from ekpo  where ebeln = p_ebeln.

*Build Control Data

control_record-mestyp = 'Z_EKPO' .  "p_mestyp .
control_record-idoctp = 'ZIDOC_TR' .

control_record-sndprt = 'LS'.
control_record-sndprn = 'LOGSYS0100' .
control_record-sndpor = 'SAPLT1'.

control_record-rcvprt = 'LS'.
control_record-rcvprn = 'SEND' .
control_record-rcvpor = 'A000000171'.

*Filling the Segment 1 ie.,Purchasing Document Number .

move-corresponding ekpo to seg1.

itab_edidd-segnam = 'ZSEG1_TR'.
itab_edidd-sdata = seg1.  " Value for the Segment1.

append itab_edidd .
clear itab_edidd.

*Filling the Segment 2 ie.,Item Number of Purchasing Document.

select * from ekpo into corresponding fields of table itab_seg2  where
         ebeln = p_ebeln .

loop at itab_seg2 .

  move-corresponding  itab_seg2 to seg2.

  itab_edidd-segnam = 'ZSEG2_TR'.
  itab_edidd-sdata = seg2.

  append itab_edidd.
  clear itab_edidd.

endloop.

call function MASTER_IDOC_DISTRIBUTE
  exporting
    master_idoc_control                  = control_record
*   OBJ_TYPE                             = ''
*   CHNUM                                = ''
  tables
    communication_idoc_control           = itab_comm_idocs
    master_idoc_data                     = itab_edidd
 exceptions
   error_in_idoc_control                = 1
   error_writing_idoc_status            = 2
   error_in_idoc_data                   = 3
   sending_logical_system_unknown       = 4
   others                               = 5
          .
if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
endif.

loop at itab_comm_idocs.

  write:/2 'Docs generated', itab_comm_idocs-docnum.

endloop.
