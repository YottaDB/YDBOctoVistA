#################################################################
#								#
# Copyright (c) 2019 Chris Combs
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
DROP FUNCTION IF EXISTS CURRTIMESTAMP(varchar);
CREATE FUNCTION CURRTIMESTAMP(varchar) RETURNS timestamp(fileman) as $$TIMESTAMP^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS DATEFORMAT(numeric);
DROP FUNCTION IF EXISTS DATEFORMAT(numeric,varchar);
DROP FUNCTION IF EXISTS DATEFORMAT(date(fileman),varchar);
DROP FUNCTION IF EXISTS DATEFORMAT(timestamp(fileman),varchar);
CREATE FUNCTION DATEFORMAT(numeric) RETURNS varchar as $$DATETIME^%YDBOCTOVISTAF;
CREATE FUNCTION DATEFORMAT(numeric,varchar) RETURNS varchar as $$DATETIME^%YDBOCTOVISTAF;
CREATE FUNCTION DATEFORMAT(date(fileman),varchar) RETURNS varchar as $$DATETIME^%YDBOCTOVISTAF;
CREATE FUNCTION DATEFORMAT(timestamp(fileman),varchar) RETURNS varchar as $$DATETIME^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS FMGET(varchar); -- old definition that is not invalid
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric);
DROP FUNCTION IF EXISTS FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric);
CREATE FUNCTION FMGET(numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;
CREATE FUNCTION FMGET(numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) RETURNS varchar as $$FMGET^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS IFNULL(varchar); -- old defintion
DROP FUNCTION IF EXISTS IFNULL(varchar, varchar);
CREATE FUNCTION IFNULL(varchar, varchar) RETURNS varchar as $$IFNULL^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS LEFTY(varchar,int);
CREATE FUNCTION LEFTY(varchar,int) RETURNS varchar as $$LEFT^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS MPIECE(varchar); -- old definition
DROP FUNCTION IF EXISTS MPIECE(varchar,varchar,int);
CREATE FUNCTION MPIECE(varchar,varchar,int) RETURNS varchar as $$PIECE^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS NUMBER(varchar);
CREATE FUNCTION NUMBER(varchar) RETURNS numeric as $$NUMBER^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS PATINDEX(varchar,varchar);
CREATE FUNCTION PATINDEX(varchar,varchar) RETURNS int as $$PATINDEX^%YDBOCTOVISTAF;
DROP FUNCTION IF EXISTS RIGHTY(varchar,int);
CREATE FUNCTION RIGHTY(varchar,int) RETURNS varchar as $$RIGHT^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS TOKEN(varchar,varchar,integer);
CREATE FUNCTION TOKEN(varchar,varchar,integer) RETURNS varchar as $$PIECE^%YDBOCTOVISTAF;

-- Note that FMDIFF can return an interval using parameter "3", but we don't handle that right now
DROP FUNCTION IF EXISTS FMDIFF(int,int,int); -- old definition
DROP FUNCTION IF EXISTS FMDIFF(numeric,numeric,int);
DROP FUNCTION IF EXISTS FMDIFF(date(fileman),date(fileman),int);
DROP FUNCTION IF EXISTS FMDIFF(timestamp(fileman),timestamp(fileman),int);
DROP FUNCTION IF EXISTS FMDIFF(date(fileman),timestamp(fileman),int);
DROP FUNCTION IF EXISTS FMDIFF(timestamp(fileman),date(fileman),int);
CREATE FUNCTION FMDIFF(numeric,numeric,int) RETURNS integer as $$FMDIFF^%YDBOCTOVISTAF;
CREATE FUNCTION FMDIFF(date(fileman),date(fileman),int) RETURNS integer as $$FMDIFF^%YDBOCTOVISTAF;
CREATE FUNCTION FMDIFF(timestamp(fileman),timestamp(fileman),int) RETURNS integer as $$FMDIFF^%YDBOCTOVISTAF;
CREATE FUNCTION FMDIFF(date(fileman),timestamp(fileman),int) RETURNS integer as $$FMDIFF^%YDBOCTOVISTAF;
CREATE FUNCTION FMDIFF(timestamp(fileman),date(fileman),int) RETURNS integer as $$FMDIFF^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS FMNOW();
CREATE FUNCTION FMNOW() RETURNS timestamp(fileman) as $$NOW^XLFDT;

DROP FUNCTION IF EXISTS FMADD(int,int,int,int,int); --old defintion
DROP FUNCTION IF EXISTS FMADD(numeric,int,int,int,int);
DROP FUNCTION IF EXISTS FMADD(date(fileman),int,int,int,int);
DROP FUNCTION IF EXISTS FMADD(timestamp(fileman),int,int,int,int);
CREATE FUNCTION FMADD(numeric,int,int,int,int) RETURNS timestamp(fileman) as $$FMADD^%YDBOCTOVISTAF;
CREATE FUNCTION FMADD(date(fileman),int,int,int,int) RETURNS timestamp(fileman) as $$FMADD^%YDBOCTOVISTAF;
CREATE FUNCTION FMADD(timestamp(fileman),int,int,int,int) RETURNS timestamp(fileman) as $$FMADD^%YDBOCTOVISTAF;

DROP FUNCTION IF EXISTS GETDATE(varchar);
CREATE FUNCTION GETDATE(varchar) RETURNS INTEGER as $$TIMESTAMP^%YDBOCTOVISTAF;
