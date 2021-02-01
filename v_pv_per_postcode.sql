/*
This script is slightly different from “pv_per_postcode”.
This script allows us to answer the business questions with the same results but also looks at the time period between each postcode changes,
allowing us to map a users movement by current and previous codes.
*/

--- INSERT YESTERDAYS AGGREGATED DATE INTO FINAL TABLE
CREATE MATERIALIZED VIEW  PV_PC.V_PV_PER_POSTCODE
AS       SELECT
         A.PV_DATETIME
        ,B.POST_CODE
        ,B.PREVIOUS_POST_CODE
        ,SUM(A.PVS) PVS
        ,SUM(CASE WHEN B.PREVIOUS_POST_CODE IS NULL THEN  A.PVS ELSE 0 END)  LAST_POSTCODE_PVS
        FROM
        (SELECT  DATE_TRUNC('hour',A.PAGEVIEW_DATETIME) PV_DATETIME, A.USER_ID, COUNT(A.EVENT_ID) PVS
        FROM PV_PC.PAGEVIEWS A WHERE A.USER_ID = 0 AND A.PAGEVIEW_DATETIME::DATE = '2021-01-21'  GROUP BY 1,2) --AGGREGATE THE PV DATA AT A USER/DAILY/HOUR LEVEL
        A JOIN
          (SELECT USER_ID, DATE_TRUNC('hour',EVENT_DATETIME) EFFECTIVE_FROM, POST_CODE
          ,LEAD(POST_CODE,1) OVER (PARTITION BY USER_ID ORDER BY DATE_TRUNC('HOUR',EVENT_DATETIME)) PREVIOUS_POST_CODE -- MAP THE NEXT POSTCODE THE USER WENT TO
          ,LEAD(DATE_TRUNC('hour',EVENT_DATETIME)) OVER (PARTITION BY USER_ID ORDER BY DATE_TRUNC('HOUR',EVENT_DATETIME)) EFFECTIVE_TO
          FROM PV_PC.USERS_LOCATION WHERE USER_ID = 0  AND EVENT_DATETIME::DATE = '2021-01-21')
          B ON B.USER_ID = A.USER_ID
          AND B.EFFECTIVE_FROM <= PV_DATETIME     -- joining on effective to and from dates
          AND COALESCE(B.EFFECTIVE_TO, '9999-01-01'::DATE) > PV_DATETIME 		-- joining on effective to and from dates
        GROUP BY 1,2,3
