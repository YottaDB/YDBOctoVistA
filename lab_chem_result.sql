#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.					#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
-- ----------------------------------------------------------------------------------------------------
-- Table for VistA Lab "CH" chemistry results.
-- 
-- LAB_DATA (vista.sql) is keyed only by lab_data_id and maps the ^LR(lab_data_id,<subscript>) sub-nodes
-- (autopsy/blood-bank/etc.); it does NOT handle the per-test "CH" results.
-- 
-- ^LR(LRDFN,"CH",INVDT,test) = "<1>^<2>^<3>^<4>^<5>^...^<9>^<10>^<11>"   (top level "^"-delimited)
-- 
-- where LRDFN = lab_data_id, INVDT = inverse FileMan date/time, test = the test data name (file 60 IEN).
-- 
-- Example:
--   ^LR(314452,"CH",6879595.9,41)="66^82550.0000!82550.0000!2157!4151!!!197^111346^73!28!181!!!!IU/L^^^^648^1"
-- ----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS `LAB_CHEM_RESULT`;
CREATE TABLE `LAB_CHEM_RESULT`(
 -- Key columns: ^LR( LRDFN , "CH" , INVDT , TEST )
 `LRDFN`  INTEGER PRIMARY KEY START 0 ENDPOINT '$CHAR(0)',       -- LRDFN
 `INVDT`  NUMERIC KEY NUM 1 START 0 ENDPOINT '$CHAR(0)',         -- Inverse Date
 `TEST`   INTEGER KEY NUM 2 START 0 ENDPOINT '$CHAR(0)',         -- Pointer to File 60

 -- Top-level "^" pieces of ^LR(lrdfn,"CH",invdt,test):
 `RESULT_VALUE`           VARCHAR PIECE 1,                       -- 1   test value (e.g. 66)
 `RESULT_FLAG`            VARCHAR PIECE 2,                       -- 2   H/L/HH/LL flag

 -- Piece 3 (workload) -- "!"-sub-delimited:
 `NATIONAL_LAB_CODE`      VARCHAR DELIMS ("^","!") PIECES (3,1), -- 3.1 National Lab Code
 `RESULT_NLT_CODE`        VARCHAR DELIMS ("^","!") PIECES (3,2), -- 3.2 Result National Lab Code (+suffix)
 `LOINC_CODE`             VARCHAR DELIMS ("^","!") PIECES (3,3), -- 3.3 LOINC (no checksum char)
 `WORKLOAD_SUFFIX`        VARCHAR DELIMS ("^","!") PIECES (3,4), -- 3.4 Workload Suffix
 `TEST_IEN_FILE_60`       INTEGER DELIMS ("^","!") PIECES (3,7), -- 3.7 IEN pointer to file 60 ^LAB(60,

 `VERIFYING_TECH`         INTEGER PIECE 4,                       -- 4   verifying technologist (file 200)

 -- Piece 5 (reference ranges / units) -- "!"-sub-delimited:
 `SITE_SPECIMEN`          INTEGER DELIMS ("^","!") PIECES (5,1), -- 5.1 Site/Specimen IEN, file 61 ^LAB(61,
 `REFERENCE_LOW`          VARCHAR DELIMS ("^","!") PIECES (5,2), -- 5.2 Reference Low
 `REFERENCE_HIGH`         VARCHAR DELIMS ("^","!") PIECES (5,3), -- 5.3 Reference High
 `CRITICAL_LOW`           VARCHAR DELIMS ("^","!") PIECES (5,4), -- 5.4 Critical Low
 `CRITICAL_HIGH`          VARCHAR DELIMS ("^","!") PIECES (5,5), -- 5.5 Critical High
 `UNITS`                  VARCHAR DELIMS ("^","!") PIECES (5,7), -- 5.7 Units (e.g. IU/L)
 `DELTA_CHECK_TYPE`       VARCHAR DELIMS ("^","!") PIECES (5,8), -- 5.8 Type of Delta Check
 `DELTA_VALUE`            VARCHAR DELIMS ("^","!") PIECES (5,9), -- 5.9 Delta Value
 `DEFAULT_VALUE`          VARCHAR DELIMS ("^","!") PIECES (5,10),-- 5.10 Default Value
 `THERAPEUTIC_LOW`        VARCHAR DELIMS ("^","!") PIECES (5,11),-- 5.11 Therapeutic Low
 `THERAPEUTIC_HIGH`       VARCHAR DELIMS ("^","!") PIECES (5,12),-- 5.12 Therapeutic High

 `INSTITUTION`            INTEGER PIECE 9,                       -- 9   institution performing test (file 4)
 `EQUIPMENT_ID`           VARCHAR PIECE 11                       -- 11  equipment identifier
)
GLOBAL "^LR(keys(""lrdfn""),""CH"",keys(""invdt""),keys(""test""))"
DELIM "^"
READONLY;
