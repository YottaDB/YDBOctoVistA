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
