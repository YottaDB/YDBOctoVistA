#!/bin/bash
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Set verbose mode so we see each command as it gets executed
set -v
set -x
set -u # Enable detection of uninitialized variables.
set -o pipefail # this way $? is set to zero only if ALL commands in a pipeline succeed. Else only last command determines $?
set -e # Below ensures any errors in this script cause it to exit with a non-zero status right away

# Copy DDL Generator file over to a directory in $ydb_routines
cp _YDBOCTOVISTAM.m ~vehu/r/

# Go to instance home
cd ~vehu

# Source environment
source ~vehu/etc/env

# Run DDL Generator
$gtm_dist/yottadb -r %XCMD 'S DUZ=.5,DIQUIET=1,DUZ(0)="@" D DT^DICRW,MAPALL^%YDBOCTOVISTAM("vista.sql")'

# View a little of it for a spot check
tail -100 vista.sql

# Install BATS
pushd /tmp/
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
popd

# Get Octo and run Octo VistA Tests
pushd /tmp/
git clone https://gitlab.com/YottaDB/DBMS/YDBOcto.git
mkdir YDBOcto/build
cd YDBOcto/build
cmake3 -D TEST_VISTA=ON -D TEST_VISTA_ENV_FILE="~vehu/etc/env" -D TEST_VISTA_INPUT_SQL="~vehu/vista.sql" ..
bats -T bats_tests/test_vista_database.bats
