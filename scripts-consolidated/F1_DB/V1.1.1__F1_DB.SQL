----------------------------------------
--F1_DB
----------------------------------------
CREATE SCHEMA IF NOT EXISTS F1_DB;

----------------------------------------
--TABLES
----------------------------------------
CREATE TABLE IF NOT EXISTS T_CIRCUITS (
	CIRCUITID NUMBER(38,0) NOT NULL,
	CIRCUITREF VARCHAR(100),
	NAME VARCHAR(100),
	LOCATION VARCHAR(100),
	COUNTRY VARCHAR(100),
	LAT NUMBER(38,0),
	LNG NUMBER(38,0),
	ALT NUMBER(38,0),
	URL VARCHAR(120),
	IS_ACTIVE NUMBER(38,0),
	primary key (CIRCUITID)
);

CREATE TABLE IF NOT EXISTS T_CIRCUITS_ACTIVE (
	CIRCUITID NUMBER(38,0) NOT NULL,
	CIRCUITREF VARCHAR(100),
	NAME VARCHAR(100),
	LOCATION VARCHAR(100),
	COUNTRY VARCHAR(100),
	LAT NUMBER(38,0),
	LNG NUMBER(38,0),
	ALT NUMBER(38,0),
	URL VARCHAR(120),
	IS_ACTIVE NUMBER(38,0),
	primary key (CIRCUITID)
);

CREATE TABLE IF NOT EXISTS T_CONSTRUCTORS (
	CONSTRUCTORID NUMBER(38,0) NOT NULL,
	CONSTRUCTORREF VARCHAR(100),
	NAME VARCHAR(100),
	NATIONALITY VARCHAR(100),
	URL VARCHAR(120),
	primary key (CONSTRUCTORID)
);

CREATE TABLE IF NOT EXISTS T_CONSTRUCTOR_STANDINGS (
	CONSTRUCTORSTANDINGSID NUMBER(38,0) NOT NULL,
	RACEID NUMBER(38,0),
	CONSTRUCTORID NUMBER(38,0),
	POINTS NUMBER(38,0),
	POSITION NUMBER(38,0),
	POSITIONTEXT VARCHAR(100),
	WINS NUMBER(38,0),
	primary key (CONSTRUCTORSTANDINGSID)
);

CREATE TABLE IF NOT EXISTS T_DRIVERS (
	DRIVERID NUMBER(38,0) NOT NULL,
	DRIVERREF VARCHAR(100),
	NUMBER NUMBER(38,0),
	CODE VARCHAR(100),
	FORENAME VARCHAR(100),
	SURNAME VARCHAR(100),
	DOB DATE,
	NATIONALITY VARCHAR(100),
	URL VARCHAR(120),
	primary key (DRIVERID)
);

CREATE TABLE IF NOT EXISTS T_DRIVER_STANDINGS (
	DRIVERSTANDINGSID NUMBER(38,0) NOT NULL,
	RACEID NUMBER(38,0),
	DRIVERID NUMBER(38,0),
	POINTS NUMBER(38,0),
	POSITION NUMBER(38,0),
	POSITIONTEXT VARCHAR(100),
	WINS NUMBER(38,0),
	primary key (DRIVERSTANDINGSID)
);

CREATE TABLE IF NOT EXISTS T_LOG_TBL (
	PROC_NAME VARCHAR(16777216),
	EXPECTATION VARCHAR(16777216),
	USERNAME VARCHAR(16777216) DEFAULT CURRENT_USER(),
	CREATED_DATE TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS T_QUALIFYING (
	QUALIFYID NUMBER(38,0) NOT NULL,
	RACEID NUMBER(38,0),
	DRIVERID NUMBER(38,0),
	CONSTRUCTORID NUMBER(38,0),
	NUMBER NUMBER(38,0),
	POSITION NUMBER(38,0),
	Q1 VARCHAR(100),
	Q2 VARCHAR(100),
	Q3 VARCHAR(100),
	primary key (QUALIFYID)
);
CREATE TABLE IF NOT EXISTS T_RACES (
	RACEID NUMBER(38,0) NOT NULL,
	YEAR NUMBER(38,0),
	ROUND NUMBER(38,0),
	CIRCUITID NUMBER(38,0),
	NAME VARCHAR(100),
	DATE DATE,
	TIME VARCHAR(100),
	URL VARCHAR(120),
	primary key (RACEID)
);

CREATE TABLE IF NOT EXISTS T_TIME_TRAVEL_TBL (
	CODE VARCHAR(100),
	FORENAME VARCHAR(100),
	SURNAME VARCHAR(100),
	POINTS NUMBER(38,0),
	WINS NUMBER(38,0)
);

----------------------------------------
--VIEWS
----------------------------------------
CREATE OR REPLACE VIEW V_DRIVER_SEASON_WINS
AS
SELECT T_DRIVERS.CODE, T_DRIVERS.FORENAME, T_DRIVERS.SURNAME, T_DRIVER_STANDINGS.POINTS, T_DRIVER_STANDINGS.WINS
    FROM T_DRIVERS INNER JOIN T_DRIVER_STANDINGS 
    ON T_DRIVERS.DRIVERID = T_DRIVER_STANDINGS.DRIVERID
    WHERE WINS > 5
    ORDER BY T_DRIVER_STANDINGS.WINS DESC;

----------------------------------------
--FILE FORMATS
----------------------------------------
CREATE OR REPLACE FILE FORMAT FMT_CSV
	SKIP_HEADER = 1
;

CREATE OR REPLACE FILE FORMAT FMT_CSV1
	SKIP_HEADER = 1
	FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
;

CREATE OR REPLACE FILE FORMAT FMT_JSON1
	TYPE = JSON
	NULL_IF = ()
;

----------------------------------------
--PROCEDURES
----------------------------------------
CREATE OR REPLACE PROCEDURE "SP_CHK_ROW_DIFF_PROC"("PARAM_DB" VARCHAR(16777216), "PARAM_SCHEMA" VARCHAR(16777216), "PARAM_TBL1" VARCHAR(16777216), "PARAM_TBL2" VARCHAR(16777216))
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '  
	
	try {
	
		// row count for staged file
		var row_count = `SELECT COUNT(*) FROM ${PARAM_DB}.${PARAM_SCHEMA}.${PARAM_TBL1}`;
		var statement1 = snowflake.createStatement( {sqlText: row_count} );
		var result_set1 = statement1.execute();
		
		// Scan through the results, processing one row at a time...Note : this part is optional, based on requirements  
		
		var rows = 0
	
        while (result_set1.next())  {
        rows += result_set1.getColumnValue(1);
        }
			
		// row count TABLE
		var row_count2 = `SELECT COUNT(*) FROM ${PARAM_DB}.${PARAM_SCHEMA}.${PARAM_TBL2}`;
		var statement2 = snowflake.createStatement( {sqlText: row_count2} );
		var result_set2 = statement2.execute();
		
		// Scan through the results, processing one row at a time...Note : this part is optional, based on requirements  
		
		var rows2 = 0
	
        while (result_set2.next())  {
        rows2 += result_set2.getColumnValue(1);
        }
		  
		var diff = rows - rows2; // Replace with something more useful.
		
		var INSERT_STMNT = `INSERT INTO F1_DB.F1_ANALYTICS.LOG_TBL VALUES (''CHK_ROW_DIFF_PROC'', ''SUCCESS'', CURRENT_USER(), CURRENT_TIMESTAMP())`;
		var INSERT_STMNTEXE = snowflake.createStatement( {sqlText: INSERT_STMNT} );
		
		var INSERT_STMNT2 = `INSERT INTO F1_DB.F1_ANALYTICS.LOG_TBL VALUES (''CHK_ROW_DIFF_PROC'', ''FAILED'', CURRENT_USER(), CURRENT_TIMESTAMP())`;
		var INSERT_STMNTEXE2 = snowflake.createStatement( {sqlText: INSERT_STMNT2} );
		
		if (diff == 0) {
			INSERT_STMNTEXE.execute();
			} else {
			INSERT_STMNTEXE2.execute();
			}
		
		return diff + " ROWS DIFF"
		
	} catch(err) {
		return "Failed: " + err;   // Return a success/error indicator.
	}
	
  ';

----------------------------------------
--FUNCTIONS
----------------------------------------
CREATE OR REPLACE FUNCTION "FN_CIRCUITS_ON_CALENDAR"()
RETURNS TABLE ("CIRCUITID" NUMBER(38,0), "NAME" VARCHAR(16777216), "LOCATION" VARCHAR(16777216), "COUNTRY" VARCHAR(16777216), "ALT" NUMBER(38,0), "IS_ACTIVE" VARCHAR(16777216))
LANGUAGE SQL
AS 'SELECT CIRCUITID, 
                    NAME, 
                    LOCATION, 
                    COUNTRY,
                    ALT,
                    CASE WHEN IS_ACTIVE = 1 THEN ''TRUE'' ELSE ''FALSE'' END 
                        FROM T_CIRCUITS_ACTIVE 
                        ORDER BY 1';

----------------------------------------
--TASKS
----------------------------------------
create or replace task TSK_RUN_CHK_ROW_DIFF_PROC
	warehouse=COMPUTE_WH
	schedule='USING CRON 0 6 * * *  US/Central'
	COMMENT='Scheduled to run daily at 6 AM US/Central'
	as call CHK_ROW_DIFF_PROC ('F1_DB', 'F1_ANALYTICS', 'T_CIRCUITS', 'T_CIRCUITS_ACTIVE');

----------------------------------------
--STAGES
----------------------------------------
CREATE OR REPLACE STAGE STG_F1
  FILE_FORMAT = CSV1;
  
-- put file:///D:\Programming\Datasets\archive\lap_times.csv @STG_F1 auto_compress=true;
