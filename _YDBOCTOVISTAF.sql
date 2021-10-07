#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# Copyright (c) 2019 Chris Combs
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
DROP FUNCTION IF EXISTS CURRTIMESTAMP(varchar);
CREATE FUNCTION CURRTIMESTAMP(varchar) RETURNS INTEGER as $$TIMESTAMP^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS DATEFORMAT(numeric,varchar);
CREATE FUNCTION DATEFORMAT(numeric,varchar) RETURNS varchar as $$DATETIME^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS FMGET(varchar);
CREATE FUNCTION FMGET(varchar) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS IFNULL(varchar);
CREATE FUNCTION IFNULL(varchar) RETURNS boolean as $$IFNULL^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS LEFTY(varchar,int);
CREATE FUNCTION LEFTY(varchar,int) RETURNS varchar as $$LEFT^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS MPIECE(varchar);
CREATE FUNCTION MPIECE(varchar) RETURNS varchar as $PIECE;
DROP FUNCTION IF EXISTS NUMBER(varchar);
CREATE FUNCTION NUMBER(varchar) RETURNS numeric as $$NUMBER^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS PATINDEX(varchar,varchar);
CREATE FUNCTION PATINDEX(varchar,varchar) RETURNS int as $$PATINDEX^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS REPLACE(varchar,varchar);
CREATE FUNCTION REPLACE(varchar,varchar) RETURNS varchar as $$REPLACE^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS RIGHTY(varchar,int);
CREATE FUNCTION RIGHTY(varchar,int) RETURNS varchar as $$RIGHT^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS SUBSTRING();
CREATE FUNCTION SUBSTRING() RETURNS varchar as $$SUBSTRING^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS TOKEN(varchar,varchar,integer);
CREATE FUNCTION TOKEN(varchar,varchar,integer) RETURNS varchar as $PIECE;
DROP FUNCTION IF EXISTS FMDIFF(int,int,int);
CREATE FUNCTION FMDIFF(int,int,int) RETURNS integer as $$FMDIFF^XLFDT;
DROP FUNCTION IF EXISTS FMNOW();
CREATE FUNCTION FMNOW() RETURNS integer as $$NOW^XLFDT;
DROP FUNCTION IF EXISTS FMADD(int,int,int,int,int);
CREATE FUNCTION FMADD(int,int,int,int,int) RETURNS integer as $$FMADD^XLFDT;
DROP FUNCTION IF EXISTS GETDATE(varchar);
CREATE FUNCTION GETDATE(varchar) RETURNS INTEGER as $$TIMESTAMP^%YDBOCTOVISTAF;
