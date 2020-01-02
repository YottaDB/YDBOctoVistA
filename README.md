# YDBVistAOcto

This allows for mapping of VistA FileMan files to Octo SQL tables. Mapping is supported by FileMan's SQLI utilities.

This is currently pre-release software, so there may be issues and incompleteness in the code.

# Installation

## Pre-requisites

 * YottaDB r1.26 is required for the Octo Field Test release
 * Octo must be installed

## Routine Installation

Copy the `_YDBOCTOVISTAM.m` routine into your routines directory.

# Running

The software has two modes of operation:

 1. Map all VistA files
 2. Map a selected VistA file

Both utilities require that you have a `DUZ` set to allow modification of the SQLI Files for keywords and the SQLI mapping.

## Mapping All VistA Files

To map all VistA FileMan Files run the following command:

```
YDB>D MAPALL^%YDBOCTOVISTAM("vista.sql")
```

This will create a file in the current directory named `vista.sql` that can be used with Octo to generate a mapping between Octo/SQL and FileMan files. You can change the `vista.sql` argument to another filename or complete file path if required.

### Mapping a Single VistA File

To map a single VistA FileMan File run the following command:

```
YDB>MAPONE^%YDBOCTOVISTAM("vista.sql",FileNumber)
```

This will create a file in the current directory named `vista.sql` that can be used with Octo to generate a mapping between Octo/SQL and FileMan files. You can change the `vista.sql` argument to another filename or complete file path if required.


# OCTO FUNCTIONS 

Contained in _YDBOCTOVISTAF.m file. Copy to $ydbdist/plugin/r to use.  Simply embed in SQL code.

Contains a number of functions written in mumps that serve as helpers to extend the SQL dialect for specific use cases as follows.

`CURR_TIMESTAMP()` 

Returns horolog datetime  or `CURR_TIMESTAMP("v")` returns Fileman Datetime -- VistA Specific

`DATEFORMAT(value, formatcode)` 

Formats datetime based on datetime type returns MM/DD/YYYY HH:MM:SS as default. Function Uses "5ZSP" for fileman dates unless formatcode is otherwise specified. If fileman date is detected function calls VA routine `$$FMTE^XLFDT(value,format)` to format

`IFNULL(value, replacer)`	    

Takes a passed field and replaces a null value with whatever is passes as the second argument

`TOKEN(value, seperator, token#)`    

Remapper for Mumps `$Piece` function 

`Replace(value, finder, replacement)` 

Takes any string and searches for the finder string to replace it with the replacement string, modified string is returned

`SUBSTRING(value, start, range)`   

Function returns a part of passed value staring at the position specified by start (2nd parameter), continuing for range (3rd parameter) or end of string whichever comes first

`FMGET(file#, [field# or name] ,keys(1-6))` 

VistA Fileman specific, uses VA Routine `$$GET1^DIQ` to take foreign keys (up to 6) and fetch a field from the specified file

`LEFT(value, characters)`		

Return left x characters from value

`RIGHT(value, characters)`	

Function returns right x characters from value

`PATINDEX(value, searchstring)`	

Function returns the position of the first occruence of search string in value

`NUMBER(value)`

Function returns the mumps equivalent of +value, numeric portion returned only

