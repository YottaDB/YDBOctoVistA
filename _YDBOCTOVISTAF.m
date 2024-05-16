%ydboctoFunction ;JCC/CRH
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;                                                               ;
 ; Copyright (c) 2019 Chris Combs                                ;
 ; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	 ;
 ; All rights reserved.                                          ;
 ;                                                               ;
 ;   This source code contains the intellectual property         ;
 ;   of its copyright holder(s), and is made available           ;
 ;   under a license.  If you do not know the terms of           ;
 ;   the license, please stop and do not read further.           ;
 ;                                                               ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Formats datetime based on datetime type returns MM/DD/YYYY HH:MM:SS as default. 
 ; Function Uses "5ZSP" for fileman dates unless formatcode is otherwise specified. 
 ; If fileman date is detected function calls VA routine $$FMTE^XLFDT(value,format) to format
DATETIME(VALUE,FORMATSTRING)
 Q:$ZYISSQLNULL(VALUE) $ZYSQLNULL
 I $ZYISSQLNULL(FORMATSTRING) S FORMATSTRING=""
 N FROM,TO,FORMAT
 S FROM=VALUE
 S FORMAT=$S($G(FORMATSTRING)="":"5ZSP",$G(FORMATSTRING)>"":$G(FORMATSTRING),1:"5ZSP")
 I VALUE="" Q VALUE
 I FORMAT="" Q VALUE
 I ($$LEFT(VALUE,1)="2")!($$LEFT(VALUE,1)="3") S TO=$$FMTE^XLFDT(VALUE,FORMAT)
 E  S TO=$ZD(VALUE,"MM/DD/YYYY 24:MM:SS") 
 QUIT TO
 ; VistA Fileman specific, uses VA Routine $$GET1^DIQ to take foreign keys (up to 7) 
 ; and fetch a field from the specified foreign key source
FMGET(FILE,FIELD,D0,D1,D2,D3,D4,D5,D6)
 Q:$ZYISSQLNULL(FILE) $ZYSQLNULL
 Q:$ZYISSQLNULL(FIELD) $ZYSQLNULL
 Q:$ZYISSQLNULL(D0) $ZYSQLNULL
 Q:$ZYISSQLNULL(D1) $ZYSQLNULL
 Q:$ZYISSQLNULL(D2) $ZYSQLNULL
 Q:$ZYISSQLNULL(D3) $ZYSQLNULL
 Q:$ZYISSQLNULL(D4) $ZYSQLNULL
 Q:$ZYISSQLNULL(D5) $ZYSQLNULL
 Q:$ZYISSQLNULL(D6) $ZYSQLNULL
 N VALUE,IENS,ERROR
 S IENS=""
 S VALUE=""
 F D=0:1:6 I $D(@("D"_D))=1,@("D"_D) S $P(IENS,",",D+1)=@("D"_D)
 S IENS=IENS_","
 S VALUE=$$GET1^DIQ(FILE,IENS,FIELD)
 QUIT VALUE
 ; if the passed value is null, replaced with parameter 2, a way to replace nulls with 0 for example
IFNULL(VALUE,REPLACER)
 QUIT:$ZYISSQLNULL(VALUE) REPLACER
 QUIT:VALUE="" REPLACER
 QUIT VALUE
 ; returns left x(NUMCHARS) characters from VALUE 
LEFT(VALUE,NUMCHARS)
 Q:$ZYISSQLNULL(VALUE) $ZYSQLNULL
 QUIT $E(VALUE,1,NUMCHARS)
 ; returns right x(NUMCHARS) characters from VALUE  
RIGHT(VALUE,NUMCHARS)
 Q:$ZYISSQLNULL(VALUE) $ZYSQLNULL
 QUIT $E(VALUE,$L(VALUE)-NUMCHARS+1,$L(VALUE))
 ; returns numeric portion of EXPRESSION
NUMBER(EXPRESSION)
 Q:$ZYISSQLNULL(EXPRESSION) $ZYSQLNULL
 QUIT +$G(EXPRESSION)
 ; returns starting position of SEARCHSTRING in VALUE
PATINDEX(VALUE,SEARCHSTRING)
 Q:$ZYISSQLNULL(VALUE) $ZYSQLNULL
 N POSITION
 I SEARCHSTRING="" QUIT 0
 S POSITION=$F(VALUE,SEARCHSTRING)-$L(SEARCHSTRING)
 I POSITION<0 S POSITION=0
 QUIT POSITION
 ;
 ; returns current date time in three different formats specified by TYPE
 ; TYPE("V") = VA Fileman formatted current datetime
 ; TYPE("S") = Current datetime in SQL Server format
 ; TYPE("M") = Current datetime in $HOROLOG format
TIMESTAMP(TYPE)
 Q:$ZYISSQLNULL(TYPE) $ZYSQLNULL
 I TYPE="V"!(TYPE="v") QUIT $$NOW^XLFDT()
 I TYPE="S"!(TYPE="s") QUIT $ZD($H,"MM/DD/YYYY 24:60:60")
 I TYPE="M"!(TYPE="m") QUIT $H
 QUIT $H
 ;
 ; Interlude to FMDIFF^XLFDT, that handles SQL NULL
FMDIFF(%1,%2,%3)
 Q:$ZYISSQLNULL(%1) $ZYSQLNULL
 Q:$ZYISSQLNULL(%2) $ZYSQLNULL
 Q:$ZYISSQLNULL(%3) $ZYSQLNULL
 Q $$FMDIFF^XLFDT(%1,%2,%3)
 ;
 ; Interlude to FMADD^XLFDT, that handles SQL NULL
FMADD(%1,%2,%3,%4,%5)
 Q:$ZYISSQLNULL(%1) $ZYSQLNULL
 Q:$ZYISSQLNULL(%2) $ZYSQLNULL
 Q:$ZYISSQLNULL(%3) $ZYSQLNULL
 Q:$ZYISSQLNULL(%4) $ZYSQLNULL
 Q:$ZYISSQLNULL(%5) $ZYSQLNULL
 Q $$FMADD^XLFDT(%1,%2,%3,%4,%5)
 ;
 ; Interlude to $PIECE that handles SQL NULL
PIECE(%1,%2,%3)
 Q:$ZYISSQLNULL(%1) $ZYSQLNULL
 Q:$ZYISSQLNULL(%2) $ZYSQLNULL
 Q:$ZYISSQLNULL(%3) $ZYSQLNULL
 Q $P(%1,%2,%3)
