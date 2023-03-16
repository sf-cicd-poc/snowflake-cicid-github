
----------------------------------------
--CITIBIKE_MART
----------------------------------------
CREATE SCHEMA IF NOT EXISTS CITIBIKE_MART;

----------------------------------------
--TABLES
----------------------------------------
CREATE TABLE IF NOT EXISTS T_TRIPS
(tripduration integer,
 starttime timestamp,
 stoptime timestamp,
 start_station_id integer,
 start_station_name string,
 start_station_latitude float,
 start_station_longitude float,
 end_station_id integer,
 end_station_name string,
 end_station_latitude float,
 end_station_longitude float,
 bikeid integer,
 membership_type string,
 usertype string,
 birth_year integer,
 gender integer);

CREATE TABLE IF NOT EXISTS T_RIDE_DATA
(ride_id VARCHAR,
 rideable_type VARCHAR,
 started_at timestamp,
 ended_at timestamp,
 start_station_name VARCHAR,
 start_station_id VARCHAR,
 end_station_name VARCHAR,
 end_station_id VARCHAR,
 start_lat VARCHAR,
 start_lng VARCHAR,
 end_lat VARCHAR,
 end_lng VARCHAR,
 membership_type VARCHAR);

-----------------------------------------
--VIEWS
-----------------------------------------

----------------------------------------
--CITIBIKE_WAREHOUSE
----------------------------------------
CREATE SCHEMA IF NOT EXISTS CITIBIKE_WAREHOUSE;

----------------------------------------
--TABLES
----------------------------------------
CREATE TABLE IF NOT EXISTS T_WAREHOUSE_DATA
(ride_id VARCHAR,
 rideable_type VARCHAR,
 started_at timestamp,
 ended_at timestamp,
 start_station_name VARCHAR,
 start_station_id VARCHAR,
 end_station_name VARCHAR,
 end_station_id VARCHAR,
 start_lat VARCHAR,
 start_lng VARCHAR,
 end_lat VARCHAR,
 end_lng VARCHAR,
 membership_type VARCHAR);

CREATE TABLE IF NOT EXISTS T_SPACE_DATA_JSON (
  people variant
  );

-----------------------------------------
--VIEWS
-----------------------------------------
CREATE OR REPLACE VIEW V_SPACE_DATA
AS  
  select *
from 
CITIBIKE_DEV.CITIBIKE_WAREHOUSE.T_SPACE_DATA_JSON,
LATERAL FLATTEN(INPUT => people:people) as a;


----------------------------------------
--DB_METASTORE
----------------------------------------
CREATE SCHEMA IF NOT EXISTS DB_METASTORE;

CREATE TABLE IF NOT EXISTS T_CITIBIKE_METASTORE
(ride_id VARCHAR,
 rideable_type VARCHAR,
 started_at timestamp,
 ended_at timestamp,
 start_station_name VARCHAR,
 start_station_id VARCHAR,
 end_station_name VARCHAR,
 end_station_id VARCHAR,
 start_lat VARCHAR,
 start_lng VARCHAR,
 end_lat VARCHAR,
 end_lng VARCHAR,
 membership_type VARCHAR);




 