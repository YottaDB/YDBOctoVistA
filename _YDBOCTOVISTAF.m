%ydboctoFunction ;JCC/CRH
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;                                                               ;
 ; Copyright (c) 2019 Chris Combs                                ;
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
 N VALUE,IENS,ERROR
 S IENS=""
 S VALUE=""
 F D=0:1:6 I $D(@("D"_D))=1,@("D"_D) S $P(IENS,",",D+1)=@("D"_D)
 S IENS=IENS_","
 S VALUE=$$GET1^DIQ(FILE,IENS,FIELD)
 QUIT VALUE
 ; if the passed value is null, replaced with parameter 2, a way to replace nulls with 0 for example
IFNULL(VALUE,REPLACER)
 QUIT $S($G(VALUE)="":$G(REPLACER),1:VALUE)
 ; returns left x(NUMCHARS) characters from VALUE 
LEFT(VALUE,NUMCHARS)
 N LEFTCHARS,LEN,START
 I NUMCHARS<=0 QUIT VALUE
 QUIT $E(VALUE,1,$S(NUMCHARS>0:NUMCHARS,1:$L(VALUE)))
 ; returns numeric portion of EXPRESSION
NUMBER(EXPRESSION)
 QUIT +$G(EXPRESSION)
 ; returns starting position of SEARCHSTRING in VALUE
PATINDEX(VALUE,SEARCHSTRING)
 N POSITION
 I SEARCHSTRING="" QUIT 0
 S POSITION=$F(VALUE,SEARCHSTRING)-$L(SEARCHSTRING)
 I POSITION<0 S POSITION=0
 QUIT POSITION
 ; search VALUE for REPLACED which is replaced by REPLACER
REPLACE(VALUE,REPLACED,REPLACER)
 N PIECES,NVALUE,PIECE
 S NVALUE=""
 S PIECES=$L(VALUE,REPLACED)
 I PIECES=0 Q VALUE
 F PIECE=1:1:PIECES D
 .I $L($P(VALUE,REPLACED,PIECE))>0,(PIECE>=1),(PIECE<PIECES) S NVALUE=NVALUE_$P(VALUE,REPLACED,PIECE)_REPLACER
 .I $L($P(VALUE,REPLACED,PIECE))>0,(PIECE=PIECES) S NVALUE=NVALUE_$P(VALUE,REPLACED,PIECE)
 .I $L($P(VALUE,REPLACED,PIECE))=0,(PIECE=1) S NVALUE=REPLACER
 .I $L($P(VALUE,REPLACED,PIECE))=0,(PIECE=PIECES) S NVALUE=NVALUE
 QUIT NVALUE
 ; returns right x(NUMCHARS) characters from VALUE  
RIGHT(VALUE,NUMCHARS)
 N RIGHTCHARS
 I NUMCHARS<=0 QUIT VALUE
 QUIT $E(VALUE,1,NUMCHARS)
 ;
SUBSTRING(VALUE,START,RANGE)
 S START=$S($G(START)="":1,1:START)
 S RANGE=$S($G(RANGE)="":$L(VALUE),1:RANGE)
 QUIT $E(VALUE,START,START+RANGE)
 ; returns current date time in three different formats specified by TYPE
 ; TYPE("V") = VA Fileman formatted current datetime
 ; TYPE("S") = Current datetime in SQL Server format
 ; TYPE("M") = Current datetime in $HOROLOG format
TIMESTAMP(TYPE)
 N FORMAT
 I $D(TYPE)=0 S TYPE=""
 I TYPE="V"!(TYPE="v") QUIT $$NOW^XLFDT()
 I TYPE="S"!(TYPE="s") QUIT $ZD($H,"MM/DD/YYYY 24:60:60")
 I TYPE="M"!(TYPE="m") QUIT $H
 QUIT $H
