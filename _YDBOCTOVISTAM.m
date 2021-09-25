%YDBOCTOVISTAM ; YDB/CJE/SMH - Octo-VistA SQL Mapper ;2021-09-22
 ;;1.1;YOTTADB OCTO VISTA UTILITIES;;Sep 22, 2012
 ;
 ; Copyright (c) 2019-2021 YottaDB LLC
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
MAPALL(PATH,VERIFY,DEBUG)
 S DEBUG=$G(DEBUG)
 S VERIFY=$G(VERIFY)
 I '$L($G(PATH)) W "Error: Path argument is invalid" QUIT
 S U="^"
 ; Clean up SQLI mapping information
 ; Insert Keywords, Purge & Perform SQLI Mapping
 D KW,ALLF^DMSQF(1)
 N FILE,TABLEIEN,LINE,ERRORCOUNT
 S ERRORCOUNT=0
 ; Use SQLI_TABLE file (#1.5215) to get table mappings
 S FILE="" F  S FILE=$O(^DMSQ("T","C",FILE))  Q:FILE']""  D
 . S TABLEIEN=$O(^DMSQ("T","C",FILE,""))
 . S LINE=1
 . ;
 . D MAPTABLE(TABLEIEN,,LINE)
 . I VERIFY D
 . . D VERIFY^KBBOSQLT(FILE,1)
 W "Error count: ",ERRORCOUNT
 ;
 ; TODO: change this to use VistA IO utils
 open PATH:(newversion)
 use PATH
 D OUTPUT
 close PATH
 QUIT
 ;
MAPONE(PATH,FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 I '$L($G(FILE)) W "Error: File argument is invalid" QUIT
 I '$L($G(PATH)) W "Error: Path argument is invalid" QUIT
 N TABLEIEN,LINE
 S TABLEIEN=$O(^DMSQ("T","C",FILE,""))
 ; Clean up SQLI mapping information
 ; Insert Keywords, Purge & Perform SQLI Mapping
 D KW,RUNONE^DMSQ(FILE)
 S LINE=1
 D MAPTABLE(TABLEIEN,,LINE)
 W "Error count: ",ERRORCOUNT
 ;
 ; TODO: change this to use VistA IO utils
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
 ; Map a Table
MAPTABLE(TABLEIEN,SCHEMA,LINE)
 N ELEMENTIEN,COLUMNIEN,COLUMNTYPE,TABLENAME,COLUMNNAME,COLUMNSQLTYPE,KEY,DONE,PRIMARYKEYS,TABLEGLOBALLOCATION,QUOTE,DBLQUOTE
 N START,END,LOCATION,NOTNULL,PRIMARYKEYIEN,PIECE,EXTRACTSTART,EXTRACTEND,COLUMNGLOBAL,TABLEOPENGLOBAL,INDEX,KEYCOLUMNS
 N SQLCOLUMNNAME,SQLCOLUMNELEMENTIEN,SQLCOLUMNIEN,ORDER,ERROR,FMTYPE,FMFILE,FMFIELD,KEYCOLUMNNAME,KEYCOLUMNSO
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
 . . ; TODO: figure out if END is anything else but '{K}
 . . S:END="'{K}" DDL(FILE,LINE)=DDL(FILE,LINE)_" START "_START_" END ""'(keys("""_QUOTE_SQLCOLUMNNAME_QUOTE_"""))!(keys("""_QUOTE_SQLCOLUMNNAME_QUOTE_""")="""""""")"","
 . . S LINE=LINE+1
 ;
 ; Create an open global root for concatenation of column location later
 S TABLEOPENGLOBAL=$E(TABLEGLOBALLOCATION,1,$L(TABLEGLOBALLOCATION)-1)
 ;
 ; Loop through the table elements for Foreign Keys (F) and Columns (C)
 S ELEMENTIEN="" F COLUMNTYPE="F","C" D
 . S ELEMENTIEN="" F  S ELEMENTIEN=$O(^DMSQ("E","F",TABLEIEN,COLUMNTYPE,ELEMENTIEN))  Q:ELEMENTIEN=""  D
 . . S ERROR=0
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
 . . ; Add the first part to the output "PATIENT_NAME CHARACTER"
 . . S DDL(FILE,LINE)=" `"_COLUMNNAME_"` "_COLUMNSQLTYPE
 . . ;
 . . ; TODO: Need to figure out how to pull in primary key information and ensure the columns are in the create table statement
 . . ;
 . . ; No support for Foreign keys right now
 . . E  I COLUMNTYPE="F" Q
 . . ;
 . . ; Determine if the column can be null
 . . S NOTNULL=$P(^DMSQ("C",COLUMNIEN,0),U,7)
 . . I NOTNULL S DDL(FILE,LINE)=DDL(FILE,LINE)_" NOT NULL"
 . . ;
 . . ; Global
 . . I COLUMNTYPE'="P" D
 . . . S COLUMNGLOBAL=$$ESCAPEQUOTES($E($G(^DMSQ("C",COLUMNIEN,1)),1,$G(^DD("STRING_LIMIT"),245)))
 . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" GLOBAL "_QUOTE_TABLEOPENGLOBAL_COLUMNGLOBAL_QUOTE
 . . . ;
 . . . ; Piece/$EXTRACT
 . . . S PIECE=""
 . . . S PIECE=$P(^DMSQ("C",COLUMNIEN,0),U,11)
 . . . S EXTRACTSTART=$P(^DMSQ("C",COLUMNIEN,0),U,12)
 . . . S EXTRACTEND=$P(^DMSQ("C",COLUMNIEN,0),U,13)
 . . . I $G(PIECE) D
 . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" PIECE "_PIECE
 . . . I $G(EXTRACTSTART) D
 . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$E($G("_TABLEOPENGLOBAL_COLUMNGLOBAL_"),"_EXTRACTSTART_","_EXTRACTEND_")"""
 . . . I '$L(PIECE)&('$L(EXTRACTSTART)) D
 . . . . ; Fallback and get FileMan data type
 . . . . S FMFILE=$P(^DMSQ("C",COLUMNIEN,0),U,5)
 . . . . S FMFIELD=$P(^DMSQ("C",COLUMNIEN,0),U,6)
 . . . . S FMTYPE=$P(^DD(FMFILE,FMFIELD,0),U,2)
 . . . . ; For whatever reason Word Processing fields aren't processed correctly
 . . . . ; Project this as a $EXTRACT for the whole global node
 . . . . I FMTYPE["W" D  Q
 . . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$E($G("_TABLEOPENGLOBAL_COLUMNGLOBAL_"),1,"_$G(^DD("STRING_LIMIT"),245)_")"""
 . . . . ; SubFiles are already mapped, skip this column
 . . . . ; TODO: use a different variable than ERROR here, ERROR does what I need, but this isn't really an error
 . . . . I +FMTYPE S ERROR=1 Q
 . . . . ; Computed fields need more logic to get the actual data
 . . . . I FMTYPE["C" D  Q
 . . . . . ; TODO: support computed multiples
 . . . . . I FMTYPE["Cm" W "Computed Multiple Found!",! Q
 . . . . . ; Add the first half of the EXTRACT command
 . . . . . S DDL(FILE,LINE)=DDL(FILE,LINE)_" EXTRACT ""$$COMPEXP^%YDBOCTOVISTAM("_FMFILE_","_FMFIELD
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
 . . ; Add ending comma and increment the line for the next column
 . . S:'ERROR DDL(FILE,LINE)=DDL(FILE,LINE)_","
 . . S:'ERROR LINE=LINE+1
 . . K:ERROR DDL(FILE,LINE)
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
 S DDL(FILE,LINE)="DELIM ""^"";"
 S LINE=LINE+1
 QUIT
 ;
GETTYPE(ELEMENTIEN,COLUMNIEN)
 N COLUMNSQLTYPE,LENGTH
 ; Get the SQL Data type (CHARACTER, INTEGER, ETC)
 S COLUMNSQLTYPE=$P(^DMSQ("DT",$P(^DMSQ("DM",$P(^DMSQ("E",ELEMENTIEN,0),U,2),0),U,2),0),U,1)
 ; Moment and memo aren't Standard SQL types
 S COLUMNSQLTYPE=$S(COLUMNSQLTYPE="MOMENT":"DATE",COLUMNSQLTYPE="MEMO":"TEXT",1:COLUMNSQLTYPE)
 ; TODO: PRIMARY_KEY and DATE aren't valid either
 S COLUMNSQLTYPE=$S(COLUMNSQLTYPE="DATE":"NUMERIC",COLUMNSQLTYPE="PRIMARY_KEY":"NUMERIC",1:COLUMNSQLTYPE)
 ; TODO: TIMESTAMP and TEXT aren't valid either
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
 ; TODO: don't use $P here, use something else to get the rest of the line
 X $P(^DD(FILE,FIELD,0),U,5,9999999)
 QUIT X
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
