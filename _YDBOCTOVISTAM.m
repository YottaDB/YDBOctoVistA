%YDBOCTOVISTAM ; YDB/CJE/SMH - Octo-VistA SQL Mapper ;7/26/2022
 ;;1.6;YOTTADB OCTO VISTA UTILITIES;;Sep 22, 2012
 ;
 ; Copyright (c) 2019-2022 YottaDB LLC
 ;
 ; This program is free software: you can redistribute it and/or modify
 ; it under the terms of the GNU Affero General Public License as
 ; published by the Free Software Foundation, either version 3 of the
 ; License, or (at your option) any later version.
 ;
 ; This program is distributed in the hope that it will be useful,
 ; but WITHOUT ANY WARRANTY; without even the implied warranty of
 ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ; GNU Affero General Public License for more details.
 ;
 ; You should have received a copy of the GNU Affero General Public License
 ; along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ;
MAPALL(PATH,OPTIONS)
 ; .OPTIONS:
 ; - Debug = Debug flag (does nothing right now)
 ; - ExternalDates = Create an extra field for each Fileman date in an external format
 ;
 I '$L($G(PATH)) W "Error: Path argument is invalid" QUIT
 ;
 N DEBUG S DEBUG=$G(OPTIONS("Debug"))
 N EXTDATE S EXTDATE=$G(OPTIONS("ExternalDates"))
 ;
 S U="^"
 ; Clean up SQLI mapping information
 ; Insert Keywords, Purge & Perform SQLI Mapping
 D KW,ALLF^DMSQF(1)
 N FILE,TABLEIEN,LINE,ERRORCOUNT,DDL
 S ERRORCOUNT=0
 ; Use SQLI_TABLE file (#1.5215) to get table mappings
 S FILE="" F  S FILE=$O(^DMSQ("T","C",FILE))  Q:FILE']""  D
 . S TABLEIEN=$O(^DMSQ("T","C",FILE,""))
 . S LINE=1
 . ;
 . D MAPTABLE(TABLEIEN,,LINE)
 W "Error count: ",ERRORCOUNT
 ;
 open PATH:(newversion)
 use PATH
 D OUTPUT
 close PATH
 QUIT
 ;
MAPONE(PATH,FILE,OPTIONS) ; [Debug] Project one file only; to be used by developers only
 ; .OPTIONS:
 ; See above for documentation
 I '$L($G(PATH)) W "Error: Path argument is invalid" QUIT
 N DEBUG S DEBUG=$G(OPTIONS("Debug"))
 N EXTDATE S EXTDATE=$G(OPTIONS("ExternalDates"))
 ;
 S U="^"
 N TABLEIEN,LINE,ERRORCOUNT,DDL
 S ERRORCOUNT=0
 ; Default to the question that will be asked in RUNONE^DMSQ
 N DIR S DIR("B")=FILE
 ; Clean up SQLI mapping information
 ; Insert Keywords, Purge & Perform SQLI Mapping
 D KW,RUNONE^DMSQ
 S TABLEIEN=$O(^DMSQ("T","C",FILE,""))
 S LINE=1
 D MAPTABLE(TABLEIEN,,LINE)
 W !,"Error count: ",ERRORCOUNT
 ;
 open PATH:(newversion)
 use PATH
 D OUTPUT
 close PATH
 QUIT
 ;
 ; Populate Keywords used by octo to SQLI
KW()
 N NUM,KW,DONE,ERR,KBBOKW
 F NUM=1:1 S KW=$P($T(keywords+NUM),";;",2,99) Q:KW="zzzzz"  D
 . S KBBOKW(NUM)=KW
 D KW^DMSQD("KBBOKW",.ERR)
 I $D(ERR) W "Error adding keyword to FileMan: "_ERR,!
 QUIT
 ;
OUTPUT(FILE)
 N I
 S I=""
 S FILE=$G(FILE)
 I FILE=+FILE F  S I=$O(DDL(FILE,I)) Q:I=""  W DDL(FILE,I),!
 E  F  S FILE=$O(DDL(FILE)) Q:FILE=""  F  S I=$O(DDL(FILE,I)) Q:I=""  W DDL(FILE,I),!
 QUIT
 ;
EXPORTONLY ; [Debug] Entry point for testing changes to MAPTABLE
 ; Prior to calling this, you need to manually call D KW^%YDBOCTOVISTAM,ALLF^DMSQF(1)
 N FILE,TABLEIEN,LINE,ERRORCOUNT
 S ERRORCOUNT=0
 S FILE="" F  S FILE=$O(^DMSQ("T","C",FILE))  Q:FILE']""  D
 . S TABLEIEN=$O(^DMSQ("T","C",FILE,""))
 . S LINE=1
 . D MAPTABLE(TABLEIEN,,LINE)
 QUIT
 ;
 ; Map a Table
MAPTABLE(TABLEIEN,SCHEMA,LINE)
 N ELEMENTIEN,COLUMNIEN,COLUMNTYPE,TABLENAME,COLUMNNAME,COLUMNSQLTYPE,KEY,DONE,PRIMARYKEYS,TABLEGLOBALLOCATION,QUOTE,DBLQUOTE
 N START,END,LOCATION,NOTNULL,PRIMARYKEYIEN,PIECE,EXTRACTSTART,EXTRACTEND,COLUMNGLOBAL,TABLEOPENGLOBAL,INDEX,KEYCOLUMNS
 N SQLCOLUMNNAME,SQLCOLUMNELEMENTIEN,SQLCOLUMNIEN,ORDER,ERROR,FMTYPE,FMFILE,FMFIELD,KEYCOLUMNNAME,KEYCOLUMNSO,ISSUBFILE
 S SCHEMA=+$G(SCHEMA)
 ; Convience variables for escaped quotes
 S QUOTE=""""
 S DBLQUOTE=QUOTE_QUOTE
 ;
 ; Get the table name
 S TABLENAME=$P(^DMSQ("T",TABLEIEN,0),U,1)
 ;
 ; Get the global location
 S TABLEGLOBALLOCATION=$E(^DMSQ("T",TABLEIEN,1),1,$G(^DD("STRING_LIMIT"),245))
 ;
 ; Escape Quotes in the global location
 S TABLEGLOBALLOCATION=$$ESCAPEQUOTES(TABLEGLOBALLOCATION)
 ;
 ; DROP Table if it exists
 S DDL(FILE,LINE)="DROP TABLE IF EXISTS `"_$S(SCHEMA:"SQLI.",1:"")_TABLENAME_"`;",LINE=LINE+1
 ;
 ; Add the CREATE TABLE opening information
 S DDL(FILE,LINE)="CREATE TABLE `"_$S(SCHEMA:"SQLI.",1:"")_TABLENAME_"`(",LINE=LINE+1
 ;
 ; Process Primary Keys first and replace the {K} tokens with real references to keys
 ; We will only have one entry per table for the Primary Key entry
 S ELEMENTIEN=""
 S ELEMENTIEN=$O(^DMSQ("E","F",TABLEIEN,"P",ELEMENTIEN))
 ;W !,"PRIMARY KEY INFO: ",!
 ;W "ELEMENTIEN: ",ELEMENTIEN,!
 ;W "PRIMARY KEY Index: ",!
 ; Loop through the multiple columns that are primary keys in order in which they appear in the global reference
 S ORDER="" F  S ORDER=$O(^DMSQ("P","C",ELEMENTIEN,ORDER)) Q:ORDER=""  D
 . S PRIMARYKEYIEN="" F  S PRIMARYKEYIEN=$O(^DMSQ("P","C",ELEMENTIEN,ORDER,PRIMARYKEYIEN)) Q:PRIMARYKEYIEN=""  D
 . . ;W "PRIMARY KEY GLOBAL INFO",!
 . . ;W "PRIMARYKEYIEN: ",PRIMARYKEYIEN,!
 . . ; Get the ELEMENT IEN for the Primary Key
 . . S SQLCOLUMNIEN=$O(^DMSQ("P","D",PRIMARYKEYIEN,""))
 . . S SQLCOLUMNELEMENTIEN=$P(^DMSQ("C",SQLCOLUMNIEN,0),U,1)
 . . S SQLCOLUMNNAME=$P(^DMSQ("E",SQLCOLUMNELEMENTIEN,0),U,1)
 . . S COLUMNSQLTYPE=$$GETTYPE(ELEMENTIEN,SQLCOLUMNIEN)
 . . ;W "COLUMN: ",SQLCOLUMNNAME,!
 . . ;W "COLUMN TYPE: ",COLUMNSQLTYPE,!
 . . ;
 . . ; Setup an index of Key columns so we don't visit them again
 . . S KEYCOLUMNS(SQLCOLUMNELEMENTIEN)=""
 . . S KEYCOLUMNSO(ORDER,SQLCOLUMNNAME)=""
 . . ;
 . . ; Get the global location
 . . ; There will be multiple "{K}" placeholders but since this loop goes through all keys in order we'll replace them
 . . ; as we go through the keys
 . . S LOCATION=$F(TABLEGLOBALLOCATION,"{K}")
 . . I LOCATION=0 W "ERROR: More keys defined than placeholders" B
 . . ; subtract 4 as LOCATION is one past the length of the FIND string
 . . S TABLEGLOBALLOCATION=$E(TABLEGLOBALLOCATION,0,LOCATION-4)_"keys("_DBLQUOTE_SQLCOLUMNNAME_DBLQUOTE_")"_$E(TABLEGLOBALLOCATION,LOCATION,$G(^DD("STRING_LIMIT"),245))
 . . ;
 . . ; Get where we need to start our loop from:
 . . S START=$P(^DMSQ("P",PRIMARYKEYIEN,0),U,4)
 . . S END=$E(^DMSQ("P",PRIMARYKEYIEN,1),1,$G(^DD("STRING_LIMIT"),245))
 . . ;
 . . ; Create the statment for this column
 . . S DDL(FILE,LINE)=" `"_SQLCOLUMNNAME_"` "_COLUMNSQLTYPE
 . . ;
 . . ; Identify this column as a (PRIMARY) KEY
 . . I ORDER=1 S DDL(FILE,LINE)=DDL(FILE,LINE)_" PRIMARY KEY"
 . . E  S DDL(FILE,LINE)=DDL(FILE,LINE)_" KEY NUM "_(ORDER-1)
 . . ;
 . . ; Add how to iterate through the KEY
 . . S:END="'{K}" DDL(FILE,LINE)=DDL(FILE,LINE)_" START "_START_" ENDPOINT '$CHAR(0)',"
 . . S LINE=LINE+1
 ;
 ; Create an open global root for concatenation of column location later
 S TABLEOPENGLOBAL=$E(TABLEGLOBALLOCATION,1,$L(TABLEGLOBALLOCATION)-1)
 ;
 ; Loop through the table elements for Foreign Keys (F) and Columns (C)
 F COLUMNTYPE="F","C" D
 . S ELEMENTIEN="" F  S ELEMENTIEN=$O(^DMSQ("E","F",TABLEIEN,COLUMNTYPE,ELEMENTIEN))  Q:ELEMENTIEN=""  D
 . . S (ERROR,ISSUBFILE)=0
 . . ; Don't process elements that are part of the primary key
 . . I $D(KEYCOLUMNS(ELEMENTIEN)) Q
 . . ;
 . . ; Each element type has its own SQLI table to get the rest of the details in
 . . S COLUMNIEN=""
 . . S:COLUMNTYPE="F" COLUMNIEN=$O(^DMSQ("F","B",ELEMENTIEN,""))
 . . S:COLUMNTYPE="C" COLUMNIEN=$O(^DMSQ("C","B",ELEMENTIEN,""))
 . . ;
 . . ; Get 31 character Column Name
 . . S COLUMNNAME=$P(^DMSQ("E",ELEMENTIEN,0),U,1)
 . . ;
 . . S COLUMNSQLTYPE=$$GETTYPE(ELEMENTIEN,COLUMNIEN)
 . . ;
 . . ; Add the first part to the output e.g. PATIENT_NAME CHARACTER
 . . S DDL(FILE,LINE)=" `"_COLUMNNAME_"` "_COLUMNSQLTYPE
 . . ;
 . . ; No support for Foreign keys right now
 . . ; TODO: Add support for Foreign Keys when implemented in YDBOcto#773
 . . I COLUMNTYPE="F" Q
 . . ;
 . . ; Determine if the column can be null
 . . S NOTNULL=$P(^DMSQ("C",COLUMNIEN,0),U,7)
 . . I NOTNULL S DDL(FILE,LINE)=DDL(FILE,LINE)_" NOT NULL"
 . . ;
 . . ; Global
 . . I COLUMNTYPE'="P" D
 . . . S COLUMNGLOBAL=$$ESCAPEQUOTES($E($G(^DMSQ("C",COLUMNIEN,1)),1,$G(^DD("STRING_LIMIT"),245)))
 . . . ;
 . . . ; Piece/$EXTRACT
 . . . S PIECE=""
 . . . S PIECE=$P(^DMSQ("C",COLUMNIEN,0),U,11)
 . . . S EXTRACTSTART=$P(^DMSQ("C",COLUMNIEN,0),U,12)
 . . . S EXTRACTEND=$P(^DMSQ("C",COLUMNIEN,0),U,13)
 . . . ;
 . . . ; Get FileMan data type for various uses below
 . . . S FMFILE=$P(^DMSQ("C",COLUMNIEN,0),U,5)
 . . . S FMFIELD=$P(^DMSQ("C",COLUMNIEN,0),U,6)
 . . . S FMTYPE=$P(^DD(FMFILE,FMFIELD,0),U,2)
 . . . ;
 . . . I PIECE D
 . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" GLOBAL "_QUOTE_TABLEOPENGLOBAL_COLUMNGLOBAL_QUOTE_" PIECE "_PIECE
 . . . . I FMTYPE["D",EXTDATE D  ; Date, emit external dates if requested
 . . . . . ; Close previous DDL column, and add a new one
 . . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_",",LINE=LINE+1
 . . . . . ; Add External Date
 . . . . . ; 25 is the length of the maximum date "2015-02-07T13:28:17+02:00"
 . . . . . S DDL(FILE,LINE)=" `"_COLUMNNAME_"_E` CHARACTER(25) EXTRACT ""$$FHIRDATE^%YDBOCTOVISTAM($P($G("_TABLEOPENGLOBAL_COLUMNGLOBAL_"),""""^"""","_PIECE_"))"""
 . . . ;
 . . . I EXTRACTSTART D
 . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$E($G("_TABLEOPENGLOBAL_COLUMNGLOBAL_"),"_EXTRACTSTART_","_EXTRACTEND_")"""
 . . . I '$L(PIECE),'$L(EXTRACTSTART) D
 . . . . ; For whatever reason Word Processing fields aren't processed correctly
 . . . . ; Get the whole global node using DELIM ""
 . . . . ; More info on Word Processing fields at:
 . . . . ; https://www.hardhats.org/fileman/u1/he_intro.htm#word (introduction)
 . . . . ; https://www.hardhats.org/fileman/pm/gfs_4.htm (storage as a multiple; not mentioned explicitly on the link)
 . . . . I FMTYPE["W" S DDL(FILE,LINE)=DDL(FILE,LINE)_" GLOBAL "_QUOTE_TABLEOPENGLOBAL_COLUMNGLOBAL_QUOTE_" DELIM """"" Q
 . . . . ; SubFiles are already mapped, skip this column
 . . . . I +FMTYPE S ISSUBFILE=1 Q
 . . . . ; Computed fields need more logic to get the actual data
 . . . . I FMTYPE["C" D  Q
 . . . . . I FMTYPE["Cm" S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$$COMPMUL^%YDBOCTOVISTAM("_FMFILE_","_FMFIELD
 . . . . . ; Add the first half of the EXTRACT command
 . . . . . E  S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$$COMPEXP^%YDBOCTOVISTAM("_FMFILE_","_FMFIELD
 . . . . . ; Loop through the Keys for this table and add them as arguments to COMPEXP
 . . . . . S ORDER="" 
 . . . . . F  S ORDER=$O(KEYCOLUMNSO(ORDER)) Q:ORDER=""  Q:ORDER'=+ORDER  D
 . . . . . . S KEYCOLUMNNAME=$O(KEYCOLUMNSO(ORDER,""))
 . . . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_","_"keys("_DBLQUOTE_KEYCOLUMNNAME_DBLQUOTE_")"
 . . . . . ; Now close up the EXTRACT command
 . . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_")"""
 . . . . W "ERROR: No piece or extract defined for:",!
 . . . . W " FILE ",FMFILE,!
 . . . . W " FIELD ",FMFIELD,!
 . . . . W " COLUMNNAME ",COLUMNNAME,!
 . . . . W " COLUMNIEN ",COLUMNIEN,!
 . . . . W " ELEMENTIEN ",ELEMENTIEN,!
 . . . . W " FileMan 0 Node for field: ",^DD(FMFILE,FMFIELD,0),!
 . . . . S ERRORCOUNT=ERRORCOUNT+1
 . . . . S ERROR=1
 . . ;
 . . ; kill line if there's an error or it's a subfile, otherwise, add ending comma and increment the line for the next column
 . . I ERROR!ISSUBFILE K DDL(FILE,LINE)
 . . E  S DDL(FILE,LINE)=DDL(FILE,LINE)_",",LINE=LINE+1
 ;
 ; Remove comma from last column line
 S:$E(DDL(FILE,LINE-1),$L(DDL(FILE,LINE-1)))="," DDL(FILE,LINE-1)=$E(DDL(FILE,LINE-1),0,$L(DDL(FILE,LINE-1))-1)
 ;
 ; Add closing CREATE TABLE information
 S DDL(FILE,LINE)=")"
 S LINE=LINE+1
 ;
 S DDL(FILE,LINE)="GLOBAL "_QUOTE_TABLEGLOBALLOCATION_QUOTE_" READONLY"
 S LINE=LINE+1
 ; DELIM will always be "^" as that is what FileMan uses by default
 ; Yes, some tables break FileMan conventions and store more data per column that FileMan has no idea about
 ; at the moment those parts are not important.
 S DDL(FILE,LINE)="DELIM ""^"""
 S LINE=LINE+1
 ;
 ; v1.4: Add AIM Metadata Type 1
 S DDL(FILE,LINE)="AIMTYPE 1;"
 S LINE=LINE+1
 ;
 ; Add empty line so that we can see where one table ends and another starts
 S DDL(FILE,LINE)=""
 S LINE=LINE+1
 QUIT
 ;
GETTYPE(ELEMENTIEN,COLUMNIEN)
 N COLUMNSQLTYPE,LENGTH
 N FMFILE,FMFIELD,FMTYPE
 ;
 ; SQLI does not know about computed multiples; these don't have a limit, so just call them VARCHAR
 S FMFILE=$P(^DMSQ("C",COLUMNIEN,0),U,5)
 S FMFIELD=$P(^DMSQ("C",COLUMNIEN,0),U,6)
 ; Primary Keys are virtual and don't have a field location; that's why we have this IF statement to check that we have a real field.
 I FMFILE,FMFIELD,$P(^DD(FMFILE,FMFIELD,0),U,2)["Cm" Q "VARCHAR"
 ;
 ; Get the SQL Data type (CHARACTER, INTEGER, ETC)
 N DOMAINIEN  S DOMAINIEN=$P(^DMSQ("E",ELEMENTIEN,0),U,2)
 N DOMAINNAME S DOMAINNAME=$P(^DMSQ("DM",DOMAINIEN,0),U,1)
 N TYPEIEN    S TYPEIEN=$P(^DMSQ("DM",DOMAINIEN,0),U,2)
 S COLUMNSQLTYPE=$P(^DMSQ("DT",TYPEIEN,0),U,1)
 ;
 ; SQLI has a bug where it says that all Pointers are Integers, which is not
 ; correct. NEW PERSON has .5 and .6 IENs, and about 10 files have a .001 of a
 ; Date, which may have a decimal point.
 ; See 3^DMSQD and 13^DMSQD for the incorrect SQLI code.
 ;
 ; Right now, we don't plan on trying to maintain the SQLI package, so we will
 ; work around it by hardcoding the type NUMERIC for Pointers.
 ; 
 ; 2022-06-27
 ; However, now due to https://gitlab.com/YottaDB/DBMS/YDBOcto/-/issues/846,
 ; it is thought best to keep Pointers as integers, so now the next line is commented out
 ; I DOMAINNAME="POINTER" Q "NUMERIC"
 ;
 ; Moment and memo aren't Standard SQL types
 S COLUMNSQLTYPE=$S(COLUMNSQLTYPE="MOMENT":"DATE",COLUMNSQLTYPE="MEMO":"TEXT",1:COLUMNSQLTYPE)
 ; PRIMARY_KEY and DATE aren't valid either
 S COLUMNSQLTYPE=$S(COLUMNSQLTYPE="DATE":"NUMERIC",COLUMNSQLTYPE="PRIMARY_KEY":"INTEGER",1:COLUMNSQLTYPE)
 ; TIMESTAMP and TEXT aren't valid either
 S COLUMNSQLTYPE=$S(COLUMNSQLTYPE="TIMESTAMP":"NUMERIC",COLUMNSQLTYPE="TEXT":"VARCHAR("_$G(^DD("STRING_LIMIT"),245)_")",1:COLUMNSQLTYPE)
 ; Get the default width of the Column for CHARACTER data types
 I COLUMNSQLTYPE="CHARACTER" D
 . S LENGTH=$P(^DMSQ("C",COLUMNIEN,0),U,2)
 . I LENGTH="" W "WARNING: No length found for CHARACTER datatype defaulting to max",! S LENGTH=$G(^DD("STRING_LIMIT"),245)
 . S COLUMNSQLTYPE=COLUMNSQLTYPE_"("_LENGTH_")"
 QUIT COLUMNSQLTYPE
 ;
 ; Convert computed expressions to be an extrinsic function
COMPEXP(FILE,FIELD,D0,D1,D2,D3,D4)
 N U,DUZ,DT,X,Y,KEY,I,IO,TABLENAME,FIELDNAME
 S Y=""
 ; Setup min variables for FileMan
 S DIQUIET=1 D DT^DICRW
 X $P(^DD(FILE,FIELD,0),U,5,99)
 QUIT X
 ;
 ; Convert Computed Multiples to be an extrinsic function
COMPMUL(FILE,FIELD,D0,D1,D2,D3,D4)
 N U,DUZ,DT,X,Y,KEY,I,IO,TABLENAME,FIELDNAME,DICMX
 ; Output variable that Fileman won't step on
 N %YDBOUT S %YDBOUT=""
 ; Setup min variables for FileMan
 S DIQUIET=1 D DT^DICRW
 ; Output variable for Computed Multiple
 S DICMX="S %YDBOUT=%YDBOUT_X_$C(10)"
 X $P(^DD(FILE,FIELD,0),U,5,99)
 ; Remove last new line; no-op if nothing there
 S $E(%YDBOUT,$L(%YDBOUT))=""
 QUIT %YDBOUT
 ;
FHIRDATE(FMDATE) ; Get FHIR date from Fileman date
 ; FHIR date is approx ISO 8601 date (aka Zulu), with allowances for inexact dates
 ; Example Input:  3150207.132817
 ; Example Output: 2015-02-07T13:28:17-05:00
 Q:$G(FMDATE)="" ""
 ;
 I $L(FMDATE)<7 QUIT ""
 ;
 N FHIRDATE
 ;
 ; Date only
 I $L(FMDATE)=7 DO  QUIT FHIRDATE
 . S FHIRDATE=$E(FMDATE,1,3)+1700 ; year
 . I $E(FMDATE,4,5)="00" QUIT  ; no month. quit.
 . S FHIRDATE=FHIRDATE_"-"_$E(FMDATE,4,5) ; month
 . I $E(FMDATE,6,7)="00" QUIT  ; no day. quit.
 . S FHIRDATE=FHIRDATE_"-"_$E(FMDATE,6,7) ; day
 ;
 ; Handle date/time and timezone
 N HL7DATE,DATE,TZ
 S HL7DATE=$$FMTHL7^XLFDT(FMDATE) ; Sample output: 20220712175306-0500
 I (HL7DATE="")!(HL7DATE=-1) QUIT ""
 N TZDELIM S TZDELIM=$S(HL7DATE["+":"+",1:"-")
 S DATE=$P(HL7DATE,TZDELIM,1)
 S TZ=$P(HL7DATE,TZDELIM,2)
 I $E(DATE,13,14)="" S $E(DATE,13,14)="00" ; HL7 API in VistA can omit seconds
 S FHIRDATE=""
 S FHIRDATE=FHIRDATE_$E(DATE,1,4)_"-"_$E(DATE,5,6)_"-"_$E(DATE,7,8) ; Date
 S FHIRDATE=FHIRDATE_"T" ; T
 S FHIRDATE=FHIRDATE_$E(DATE,9,10)_":"_$E(DATE,11,12)_":"_$E(DATE,13,14) ; Time
 S FHIRDATE=FHIRDATE_TZDELIM_$E(TZ,1,2)_":"_$E(TZ,3,4) ; Timezone
 QUIT FHIRDATE
 ;
 ; Escape quotes for SQL DDL
ESCAPEQUOTES(INPUT)
 N INDEX,DONE,QUOTE
 S (INDEX,DONE)=0
 S QUOTE=""""
 F  Q:DONE  D
 . S INDEX=$F(INPUT,QUOTE,INDEX)
 . I INDEX=0 S DONE=1 Q
 . I $E(INPUT,INDEX-2)'=QUOTE D
 . . S INPUT=$E(INPUT,0,INDEX-1)_QUOTE_$E(INPUT,INDEX,$G(^DD("STRING_LIMIT"),245))
 QUIT INPUT
 ;
 ; SQL Functions for VistA
 ; Replace a substring with another string
REPLACE(STRING,TOKEN,WITH)
 N LOCATION,RETURN,BEGIN
 S (LOCATION,BEGIN)=0
 S RETURN=""
 F  Q:LOCATION=""  D
 . S LOCATION=$F(STRING,TOKEN,BEGIN)
 . I LOCATION=0 S LOCATION="" S RETURN=RETURN_$E(STRING,BEGIN,$L(STRING)) Q
 . S RETURN=RETURN_$E(STRING,BEGIN,(LOCATION-$L(TOKEN)-1))_WITH
 . S BEGIN=LOCATION
 QUIT RETURN
keywords
 ;;ALL
 ;;AND
 ;;AS
 ;;ASC
 ;;AVG
 ;;BY
 ;;BEGIN
 ;;CASE
 ;;CASCADE
 ;;CHAR
 ;;CHARACTER
 ;;COLLATE
 ;;COMMAND
 ;;COMMIT
 ;;CORRESPONDING
 ;;COUNT
 ;;CREATE
 ;;CROSS
 ;;CURSOR
 ;;DEC
 ;;DECIMAL
 ;;DEFAULT
 ;;DELETE
 ;;DELIM
 ;;DESC
 ;;DISTINCT
 ;;DROP
 ;;END
 ;;ELSE
 ;;EXCEPT
 ;;EXTRACT
 ;;FALSE
 ;;FROM
 ;;FULL
 ;;GLOBAL
 ;;GROUP
 ;;HAVING
 ;;IN
 ;;INNER
 ;;INSERT
 ;;INT
 ;;INTEGER
 ;;INTERSECT
 ;;INTO
 ;;IS
 ;;JOIN
 ;;KEY
 ;;LEFT
 ;;MAX
 ;;MATCH
 ;;MIN
 ;;NATURAL
 ;;NOT
 ;;NUMERIC
 ;;ON
 ;;OR
 ;;ORDER
 ;;OUTER
 ;;PACK
 ;;PIECE
 ;;PRIMARY
 ;;RESTRICT
 ;;RIGHT
 ;;SELECT
 ;;SET
 ;;SMALLINT
 ;;SUM
 ;;TABLE
 ;;TRUE
 ;;THEN
 ;;UNION
 ;;UNIQUE
 ;;UNKNOWN
 ;;UNPACK
 ;;UPDATE
 ;;USING
 ;;VALUES
 ;;VARCHAR
 ;;VARYING
 ;;WHERE
 ;;NUM
 ;;ADVANCE
 ;;START
 ;;LIMIT
 ;;NULL
 ;;zzzzz
