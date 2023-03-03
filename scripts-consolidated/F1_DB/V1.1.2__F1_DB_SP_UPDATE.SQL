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