/*
The queries below is used to update PV_PC.PAGEVIEWS from the source table PAGEVIEWS_EXTRACT at an hourly interval: execution time 5mins past the hour
*/

  --- EXECUTE THIS DAILY AT 5 MINS PAST THE HOUR -- DEPENDING ON HOW LONG IT TAKES FOR THE SOURCE TABLE TO LOAD
  DELETE FROM PV_PC.PAGEVIEWS WHERE DATE_TRUNC('hour',PAGEVIEW_DATETIME) >= DATEADD(HOUR, -1,  DATE_TRUNC('hour',GETDATE()) 
                              AND DATE_TRUNC('hour',PAGEVIEW_DATETIME)   <= DATEADD(HOUR, 1,  DATE_TRUNC('hour',GETDATE()); -- DELETE PREVIOUS HOURS DATA, THERE SHOULDN'T BE ANY DATA TO DELETE BUT JUST IN CASE THERE WAS A MANUAL LOAD
    INSERT INTO PV_PC.PAGEVIEWS
    SELECT PV_PC.UUID() AS EVENT_ID, USER_ID, PAGEVIEW_DATETIME, PAGE_URL, GETDATE() AS LOAD_DATE FROM PAGEVIEWS_EXTRACT;
  --- EXECUTE THIS DAILY AT 5 MINS PAST THE HOUR -- DEPENDING ON HOW LONG IT TAKES FOR THE SOURCE TABLE TO LOAD

  -- DELETE DUPLICATE IF AVAILABLE, THIS TABLE SHOULD ONLY HOLD 1 ROW PER USER PER HOUR
  DELETE FROM PV_PC.PAGEVIEWS WHERE EVENT_ID IN
    (SELECT ROW_ID FROM
    (SELECT ROW_ID, ROW_NUMBER() OVER (PARTITION BY A.USER_ID,DATE_TRUNC('hour',PAGEVIEW_DATETIME) ORDER BY A.LOAD_DATE ASC) RNK FROM PV_PC.USERS_LOCATION  A ) WHERE RNK != 1);
  -- DELETE DUPLICATE IF AVAILABLE
