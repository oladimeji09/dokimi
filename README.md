The scripts in this repo allows us to answer the business questions below using the data from the source tables *users_extract* and *pageviews_extract*.
The final results are stored in the table [pv_per_postcode](https://github.com/oladimeji09/dokimi/blob/main/pv_per_postcode.sql). I have also prepared another view [v_pv_per_postcode](https://github.com/oladimeji09/dokimi/blob/v_per_postcode/v_pv_per_postcode.sql), in a different branch, that could be used to gain additional insight on pageviews by user movement within postcodes.

●Number of pageviews, on a given time period (hour, day, month, etc), per postcode -based on the current/most recent postcode of a user.

●Number of pageviews, on a given time period (hour, day, month, etc), per postcode -based on the postcode a user was in at the time when that user made a pageview.

An assumption that the source table *users_extract* would store hold data at the granularity of one postcode per hour per user was concluded, I also assumed that there would be an event timestamp available that corresponds with when the user location data was capture, however if these assumptions are not true and the source table holds data at the granularity of one postcode per user per day the scripts in this repo will still return accurate data. The only change would be the field *pv_pc.users_location.event_datetime* would then use "current_date" function in the loading progressing.

* The [DDL](https://github.com/oladimeji09/dokimi/blob/main/ddl.sql) script is used to create the schema, tables and functions. The script can be executed on an ad-hoc basis.
* The [pageviews](https://github.com/oladimeji09/dokimi/blob/main/pageviews.sql) & [user_location](https://github.com/oladimeji09/dokimi/blob/main/user_location.sql) scripts are used to load data from source table, the script also delete duplicates if present. The *pageviews script will be schedule at an hourly interval: execution time 5mins past the hour depending on how long source tables take to update, the *user location* table will be scheduled at a daily interval: execution time 00:15. For both tables we could also create a dependency on the ETL task based on source table depending on systems used.
  * The [manual_load](https://github.com/oladimeji09/dokimi/blob/main/manual_load.sql) scripts is used to load sample data into the [pageviews](https://github.com/oladimeji09/dokimi/blob/main/pageviews.sql) & [user_location](https://github.com/oladimeji09/dokimi/blob/main/user_location.sql) tables for testing
* The [pv_per_postcode](https://github.com/oladimeji09/dokimi/blob/main/pv_per_postcode.sql) scripts is used to aggregate data from the [pageviews](https://github.com/oladimeji09/dokimi/blob/main/pageviews.sql) & [user_location](https://github.com/oladimeji09/dokimi/blob/main/user_location.sql) tables to answer the business questions. This table will schedule to refresh after the *user location* and *pageviews* last daily execution is completed. 
  * As explained above, stored in a different branch, [v_pv_per_postcode](https://github.com/oladimeji09/dokimi/blob/v_per_postcode/v_pv_per_postcode.sql) could also be used to gain additional insight on pageviews by user movement within postcodes
