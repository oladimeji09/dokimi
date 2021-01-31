----THIS FUNCTION CREATES A UUID EVERY TIME IT’S CALLED, WE WON’T BE ABLE TO USE THIS JOIN/REFERENCE ONTO OTHER TABLES BUT IT WILL HELPS IN REGARDS TO TABLE/QUERY PERFORMANCE
CREATE OR REPLACE FUNCTION public.fn_uuid()
  RETURNS character varying AS
  ' import uuid
  return uuid.uuid4().__str__()
  '
  LANGUAGE PLPYTHONU VOLATILE;
----THIS FUNCTION CREATES A UUID EVERY TIME IT’S CALLED, WE WON’T BE ABLE TO USE THIS JOIN/REFERENCE ONTO OTHER TABLES BUT IT WILL HELPS IN REGARDS TO TABLE/QUERY PERFORMANCE

---- CREATE A TABLE TO STORE THE USER DATA, THEREFORE WE CAN PRESERVE USER LOCATION HISTORY
CREATE TABLE IF NOT EXISTS USERS_LOCATION
  (
      ROW_ID VARCHAR(36)
     ,EVENT_DATETIME DATETIME -- ASSUMING THERE IS AN EVENT TIMESTAMP INCLUDED USERS_EXTRACT SOURCE TABLE, IF NOT THEN THIS DATE WILL CORRESPOND WITH THE LOAD DATE
     ,USER_ID BIGINT
     ,POST_CODE VARCHAR(40)
     ,LOAD_DATE DATETIME -- THE DATE THE SPECIFIC ROW WAS LOADED INTO THE SCHEMA
  )
  DISTSTYLE KEY
  DISTKEY (ROW_ID) --- DISTRIBUTION KEY TO HELP QUERY PERFORMANCE
  SORTKEY (EVENT_DATETIME);  --SORT KEY TO HELP QUERY PERFORMANCE

---- CREATE A TABLE TO STORE THE PAGEVIEW DATA
CREATE TABLE IF NOT EXISTS PAGEVIEWS
  (
     EVENT_ID VARCHAR(36)
    ,USER_ID BIGINT
    ,PAGEVIEW_DATETIME DATETIME
    ,PAGE_URL VARCHAR(MAX)
    ,LOAD_DATE DATETIME
  )
  DISTSTYLE KEY
  DISTKEY (EVENT_ID) --- DISTRIBUTION KEY TO HELP QUERY PERFORMANCE
  SORTKEY (PAGEVIEW_DATETIME);  --SORT KEY TO HELP QUERY PERFORMANCE

---- CREATE A AGGREGATED TABLE TO CONNECT TO LOOKER
  CREATE TABLE IF NOT EXISTS PV_PER_POSTCODE
    (
       PV_DATETIME DATETIME
      ,POST_CODE VARCHAR(10)
      ,LAST_POSTCODE_PVS BIGINT
      ,PVS BIGINT
      ,LOAD_DATE DATETIME
    )
    DISTSTYLE KEY
    DISTKEY (POST_CODE) --- DISTRIBUTION KEY TO HELP QUERY PERFORMANCE
    SORTKEY (PV_DATETIME);  --SORT KEY TO HELP QUERY PERFORMANCE
---- CREATE A AGGREGATED TABLE TO CONNECT TO LOOKER

---- THIS FUNCTION IS USED TO GENERATE RANDOM STRINGS AS POST_CODE OR WEBSITE URL
CREATE  OR REPLACE FUNCTION randomtext() RETURNS  character varying as $$
    def randomword():
      import random, string
      letters = string.ascii_lowercase
      return ''.join(random.choice(letters) for i in range(4))

    return randomword()
  $$ LANGUAGE PLPYTHONU VOLATILE;
---- THIS FUNCTION IS USED TO GENERATE RANDOM STRINGS AS POST_CODE OR WEBSITE URL