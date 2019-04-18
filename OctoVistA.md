# Octo & VistA installation instructions

Octo is a SQL implementation for the YottaDB database that you can use to map existing data into a SQL projection. This document describes how to use Octo and VistA together to map VistA data into the SQL projection provided by Octo.

This document is written using CentOS 7 which should apply to RHEL 7. Debian based distributions can adapt the `yum install` lines as appropriate for their distribution.

## YottaDB installation

Currently Octo requires YottaDB r1.25 (which will become r1.26 when all testing and development is complete). Specifically there is an issue with triggers and decimal numbers (.11 for example) that is fixed in r1.25/r1.26.

### Install build tools

These instructions are the same as documented in the YottaDB readme:

```
yum install -y git gcc cmake tcsh {libconfig,gpgme,libicu,libgpg-error,libgcrypt,ncurses,openssl,zlib,elfutils-libelf}-devel binutils
```

### Retrieve and unpack the YottaDB source code

Make sure that you are in a directory in which you can write to:

```
curl -s -L https://gitlab.com/YottaDB/DB/YDB/-/archive/Octo_alpha1/YDB-Octo_alpha1.tar.gz -o YDB-Octo_alpha1.tar.gz
tar xzf YDB-Octo_alpha1.tar.gz
cd YDB-Octo_alpha1
```

### Build YottaDB from source

You may want to modify the ydbinstall command to fit your environment:

```
mkdir build
cd build
cmake -D CMAKE_INSTALL_PREFIX:PATH=$PWD ../
make -j `grep -c ^processor /proc/cpuinfo`
make install
cd yottadb_r*
./ydbinstall --force-install --ucaseonly-utils --utf8 default --installdir /opt/yottadb/r1.25_x86_64
```

Modify your environment to use the new YottaDB version. This is controlled by the environment variables `ydb_dist` and `ydb_routines`.

## Octo installation

### Install build tools

You'll need to install the epel-release repository to get cmake3. The cmake3 build tool is required as Octo uses features that aren't available in cmake2 which is the cmake version distributed by default.

```
yum install -y epel-release
```

Now we can install the rest of the build tools:

```
yum install -y cmake3 bison yacc flex readline-devel vim-common
```

### Retrieve and unpack the Octo source code

Make sure that you are in a directory in which you can write to:

```
curl -s -L https://gitlab.com/YottaDB/DBMS/YDBOcto/-/archive/v0.0.1-alpha1/YDBOcto-v0.0.1-alpha1.tar.gz -o YDBOcto-v0.0.1-alpha1.tar.gz
tar xzf YDBOcto-v0.0.1-alpha1.tar.gz
cd YDBOcto-v0.0.1-alpha1
```

### Build Octo from source

```
mkdir build
cd build
cmake3 -DSTRING_BUFFER_LENGTH=300000 ../
make
```

### Add directory for generated Octo routines

You'll need to place this directory where it makes sense in your environment:

```
cd ..
mkdir octoroutines
```

### Get the Octo VistA Mapping routine

Move to a directory that is part of your `ydb_routines` search path where you'd like to place the Octo VistA mapping routine:

```
curl -s -L https://gitlab.com/YottaDB/DBMS/ydbvistaocto/raw/master/_YDBOCTOVISTAM.m?inline=false -o _YDBOCTOVISTAM.m
```

### Create the Octo database

#### Create the global directory command file
Make sure that the `-FILE` argument points to where you want the Octo database to be stored.

```
echo "c -s DEFAULT -alloc=4000 -exten=5000 -glob=2000 -FILE=g/octo.dat" > octo.gde
echo "c -r DEFAULT -RECORD_SIZE=300000 -KEY_SIZE=1019 -NULL_SUBSCRIPTS=ALWAYS" >> octo.gde
echo "sh -a" >> octo.gde
```

#### Create the global directory
In the command below make sure that `ydb_gbldir` points to where you want to store the global directory and that the `mumps` command is going to run the recently installed version of YottaDB:

```
ydb_gbldir=g/octo.gld $ydb_dist/mumps -run GDE < octo.gde
```

#### Create the Octo database file

Replace paths below as appropriate for your environment:

```
ydb_gbldir=g/octo.gld $ydb_dist/mupip create
```

### Create Octo configuration file

You need to modify the path for `routine_cache` and `octo_global_directory` point to the items created above:

Note: you can also just edit the file instead of running the perl commands below. You need to modify "routine_cache" and "octo_global_directory".

```
cp YDBOcto-v0.0.1-alpha1/src/aux/octo.conf ~/.octo.conf
perl -pi -e 's/routine_cache = "\.\/"/routine_cache = "octoroutines"/' ~/.octo.conf
perl -pi -e 's/octo_global_directory = "mumps.gld"/octo_global_directory = "g\/octo.gld"/' ~/.octo.conf
```

### Adding Custom Functions to Octo

Some custom functions have been created to make transitioning from other SQL mapping tools to Octo easier. This isn't an automated process yet.

Be sure to change the `ydb_gbldir` path to the correct path of the Octo global directory.

```
ydb_gbldir=g/octo.gld $ydb_dist/mumps -dir
s ^%ydboctoocto("functions","MPIECE")="$PIECE"
s ^%ydboctoocto("functions","SQL_FN_REPLACE")="$$REPLACE^%YDBOCTOVISTAM"
s ^%ydboctoocto("variables","application_name")=""
s ^%ydboctoocto("variables","client_encoding")="UTF8"
s ^%ydboctoocto("variables","DateStyle")="ISO, MDY"
s ^%ydboctoocto("variables","integer_datetimes")="on"
s ^%ydboctoocto("variables","IntervalStyle")="postgres"
s ^%ydboctoocto("variables","is_superuser")="on"
s ^%ydboctoocto("variables","server_encoding")="UTF8"
s ^%ydboctoocto("variables","server_version")="0.1"
s ^%ydboctoocto("variables","session_authorization")="postgres"
s ^%ydboctoocto("variables","standard_conforming_strings")="on"
s ^%ydboctoocto("variables","TimeZone")="UTC"
```

### Add call-in to allow Octo to call into YottaDB

Octo uses the YottaDB call-in interface to use YottaDB databases. You'll need to make sure that the path referenced below is correct for your environment:

```
export GTMCI=octo-build/calltab.ci
```

## Running the Octo VistA mapping tool

The mapping routine requires certian FileMan variables to be setup and ran in programmer mode. This utility uses SQLI to perform the mappings and will clear any existing SQLI mappings, keywords, etc. before running. If the existing SQLI information is important, please back it up before running the utility.

This utility will create a file named vista-new.sql in the current directory. Make sure that you have write permissions in the current directory before running.

An example run is below, you'll need to modify it for your environment:

```
mumps -dir
VEHU>S DUZ=1 D Q^DI,MAPALL^%YDBOCTOVISTAM("vista-new.sql")
VEHU>H
```

It will take a few minutes to run. You may see some errors after it is done:

```
ERROR: No piece or extract defined for:
 FILE 791812.0101
 FIELD 791810.2
 COLUMNNAME ORDER11
 COLUMNIEN 74453
 ELEMENTIEN 82300
 FileMan 0 Node for field: ORDER
Error count: 1
```

These can be ignored for now, and those columns will not be available in the mapping.

## Running Octo

Octo can be ran in one of two ways:

1. Using the command line tool `octo`
2. Using the PostgreSQL wire protocol for JDBC access using `rocto`

When first testing the `octo` tool gives faster feedback to make sure the configuration is all done correctly and allows for efficient loading of the initial SQL DDL.

The `rocto` tool is better to use when issuing test queries as JDBC tools give better graphical output than a command line tool can.

### Loading the VistA schema

The VistA SQL DDL needs to be loaded into Octo to provide instructions to Octo on how to parse the VistA data structures.

Note: you can alias or add to the `PATH` environment variable so that the Octo programs are easier to access instead of typing full paths everytime.

```
YDBOcto-v0.0.1-alpha1/build/src/octo -f vista-new.sql
```

This should load with no errors reported.

### Issuing a simple query

To make sure everything is setup correctly a sample query can be ran from the `octo` tool:

```
YDBOcto-v0.0.1-alpha1/build/src/octo
OCTO> SELECT * FROM NEW_PERSON LIMIT 10;
```
You should see results from the above query and no errors. If you see errors contact your YottaDB support channel.

### Starting Rocto

`rocto` is a daemon that provides compatibility with the PostreSQL wire protocol and is currently tested with the JDBC connector.

To start Rocto:

```
YDBOcto-v0.0.1-alpha1/build/src/rocto
```

This will then run Octo in the foreground and all log messages will be written to your terminal. These log messages can provide important information as to why queries may have failed. You of course have the option to run Rocto in the background and look at the log files later.

Information on setting up SquirrelSQL for Rocto can be found at https://charles.hathaway.gitlab.io/YDBDBMS/rocto.html.
