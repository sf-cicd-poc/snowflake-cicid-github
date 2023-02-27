DROP TABLE T_RIDE_DATA;

create or replace table T_RIDE_DATA
(id VARCHAR,
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