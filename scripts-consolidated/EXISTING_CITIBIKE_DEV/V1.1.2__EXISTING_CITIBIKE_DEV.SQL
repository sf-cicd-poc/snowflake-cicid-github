CREATE SCHEMA IF NOT EXISTS EXISTING_CITIBIKE_DEV.NEW_SCHEMA;

CREATE OR REPLACE TABLE CITIBIKE_DEV.CITIBIKE_MART.T_TRIPS
(trip_duration integer,
 start_timee timestamp,
 stop_time timestamp,
 start_station_id integer,
 start_station_name string,
 start_station_latitude float,
 start_station_longitude float,
 end_station_id integer,
 end_station_name string,
 end_station_latitude float,
 end_station_longitude float,
 bike_id integer,
 membership_type string,
 user_type string,
 birth_year integer,
 gender integer)
 ;