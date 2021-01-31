/*
  The queries below is used to update PV_PC.USERS_LOCATION from the source table a daily interval: execution time 00:15
*/

  --- EXECUTE THIS DAILY AT 00:15 -- DEPENDING ON HOW LONG IT TAKES FOR THE SOURCE TABLE TO LOAD OR SET A DEPENDECY ON THE ETL JOB FOR USERS_EXTRACT
  DELETE FROM PV_PC.USERS_LOCATION WHERE EVENT_DATETIME::DATE >= CURRENT_DATE-1 AND EVENT_DATETIME::DATE <= CURRENT_DATE-1 -- DELETE PREVIOUS DAYS DATA, THERE SHOULDN'T BE ANY DATA TO DELETE BUT JUST IN CASE THERE WAS A MANUAL LOAD
    INSERT INTO PV_PC.USERS_LOCATION
    SELECT PV_PC.UUID() AS ROW_ID, EVENT_DATETIME, USER_ID,  POST_CODE, GETDATE() AS LOAD_DATE FROM USERS_EXTRACT;
  --- EXECUTE THIS DAILY AT 00:15 -- DEPENDING ON HOW LONG IT TAKES FOR THE SOURCE TABLE TO LOAD

  -- DELETE DUPLICATE IF AVAILABLE
  DELETE FROM PV_PC.USERS_LOCATION WHERE ROW_ID IN
    (SELECT ROW_ID FROM
    (SELECT ROW_ID, ROW_NUMBER() OVER (PARTITION BY A.USER_ID,A.EVENT_DATETIME,A.POST_CODE ORDER BY A.LOAD_DATE ASC) RNK FROM PV_PC.USERS_LOCATION  A ) WHERE RNK != 1);
  -- DELETE DUPLICATE IF AVAILABLE
