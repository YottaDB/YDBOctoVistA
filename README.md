# YDBVistAOcto
This allows for mapping of VistA FileMan files to Octo SQL tables. Mapping is
supported by FileMan's SQLI utilities.

# Installation
## Pre-requisites

 * YottaDB and Octo must be installed

## Routine Installation

Copy the `_YDBOCTOVISTAM.m` routine into your routines directory.

## Running

The software has two modes of operation:

 1. Map all VistA files
 2. Map a selected VistA file

Both utilities require that you have a `DUZ` set to allow modification of the SQLI Files for keywords and the SQLI mapping. The following examples can be copied and pasted; but you can adapt them if you already have a VistA symbol table properly set-up (e.g. by using `^XUP`).

## Mapping All VistA Files

To map all VistA FileMan Files run the following command:

```
YDB>S DUZ=.5,DIQUIET=1,DUZ(0)="@" D DT^DICRW,MAPALL^%YDBOCTOVISTAM("vista.sql")
```

This will create a file in the current directory named `vista.sql` that can be used with Octo to generate a mapping between Octo/SQL and FileMan files. You can change the `vista.sql` argument to another filename or complete file path if required.

`MAPALL` takes an optional 2nd parameter by reference for options. A currently
supported option of `ExternalDates` is to add an extra field after each Fileman
formatted date for that date presented in a ISO 8601 format, as in the
following example:

```
YDB>S DUZ=.5,DIQUIET=1,DUZ(0)="@",O("ExternalDates")=1 D DT^DICRW,MAPALL^%YDBOCTOVISTAM("vista_ext_dates.sql",.O)
```

## Mapping a Single VistA File
To map a single VistA FileMan File run the following command (shown with File 200)

```
YDB>S DUZ=.5,DIQUIET=1,DUZ(0)="@",FileNumber=200 D DT^DICRW,MAPONE^%YDBOCTOVISTAM("vista"_FileNumber_".sql",FileNumber)
File or Subfile Number:  (.11-9999999.9201): 200// <enter>
     Done.  See SQLI files for changes.
     Error count: 0
```

This will create a file in the current directory named `vista200.sql` that can
be used with Octo to generate a mapping between Octo/SQL and FileMan files. You
can change the `vista200.sql` argument to another filename or complete file
path if required.

## Troubleshooting
If you get a crash at `SETOF+3^DMSQD`, this is caused by bad Fileman Data
Dictionaries sent in patch `ECX*3.0*178`. See
https://gitlab.com/YottaDB/DBMS/YDBOctoVistA/-/issues/26 for how to fix this.

# OCTO Functions
Contained in `_YDBOCTOVISTAF.m` file. Copy to your routines directory to use
and then load `_YDBOCTOVISTAF.sql` to define the functions in Octo. After that,
you should be able to embed the code in SQL.

Contains a number of functions written in M that serve as helpers to extend
the SQL dialect for specific use cases as follows.

## Date Functions
### `CURRTIMESTAMP/GETDATE(V/S/M)`
Returns today's date/time. Without any arguments, returns today's date in the
$HOROLOG format. V: Fileman Format. S: US Format. M: $HOROLOG format.

### `DATEFORMAT(value, formatcode)`
Formats datetime based on datetime type returns MM/DD/YYYY HH:MM:SS as default. Function Uses "5ZSP" for fileman dates unless formatcode is otherwise specified. If fileman date is detected function calls VA routine `$$FMTE^XLFDT(value,format)` to format

### `FMADD(Fileman Date 1, days, hours, minutes, seconds)`
Call $$FMADD^XLFDT to add/subtract date/time to produce another Fileman date. See https://hardhats.org/kernel/html/x-fmadd-xlfdt.html for more information.

### `FMDIFF(Fileman Date 1, Fileman Date 2, [1-3])`
Call $$FMDIFF^XLFDT to return the difference between two Fileman dates. See https://hardhats.org/kernel/html/x-fmdiff-xlfdt.html for more information.

### `FMNOW()`
Call $$NOW^XLFDT to return the current date/time in Fileman Format. Can be combined with other FM\* date functions to calculate date differences.

## String Functions
### `IFNULL(value, replacer)`
Takes a passed field and replaces a null value with whatever is passes as the second argument

### `LEFTY(value, characters)`
Return left x characters from value

### `NUMBER(value)`
Function returns the mumps equivalent of +value, numeric portion returned only

### `PATINDEX(value, searchstring)`
Function returns the position of the first occruence of search string in value

### `RIGHTY(value, characters)`
Function returns right x characters from value

### `SUBSTRING(value, start, range)`
THIS FUNCTION IS NOW REMOVED AS IT IS AVAILABLE IN OCTO.

### `TOKEN/MPIECE(value, seperator, token#)`
Remapper for Mumps `$Piece` function

## Fileman Related
### `FMGET(file#, [field# or name] ,keys(1-6))`
VistA Fileman specific, uses VA Routine `$$GET1^DIQ` to take foreign keys (up to 6) and fetch a field from the specified file
