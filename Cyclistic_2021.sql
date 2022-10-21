-- Active: 1666274076413@@127.0.0.1@3306@cyclistic
-- Author : Elfrid Hasman

---------------------
--Prepare your data--
---------------------
-- Download source data every month 2021 (https://divvy-tripdata.s3.amazonaws.com/index.html)
-- Afer download it, unzip file and save in one folder call cyclistic dataset or whatever you want
-- Open file in excel to know what the field and data type 
-- The data is to large to combine all month in excel, that's why i choose MySQL to combine the data
-- Import data to MySQL
-- Query data

-- Choose/USE database cyclistic
USE cyclistic;

-- Combine all month data in one temporary table call union_all_month
-- UNION ALL means, combine all the data regardless of whetever the data is duplicated or not
WITH union_all_month_table AS(
	SELECT * FROM `202101-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202102-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202103-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202104-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202105-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202106-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202107-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202108-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202109-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202110-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202111-divvy-tripdata`
	UNION ALL
	SELECT * FROM `202112-divvy-tripdata`
)
SELECT COUNT(*) FROM union_all_month_table;

-- But in this case I prefer to choose UNION to remove all duplicate before the data combine to one table, 
-- CREATE TEMPORARY TABLE cyclistic_2021

CREATE TEMPORARY TABLE cyclistic_2021(
WITH union_month_table AS(
	SELECT * FROM `202101-divvy-tripdata`
	UNION
	SELECT * FROM `202102-divvy-tripdata`
	UNION
	SELECT * FROM `202103-divvy-tripdata`
	UNION
	SELECT * FROM `202104-divvy-tripdata`
	UNION
	SELECT * FROM `202105-divvy-tripdata`
	UNION
	SELECT * FROM `202106-divvy-tripdata`
	UNION
	SELECT * FROM `202107-divvy-tripdata`
	UNION
	SELECT * FROM `202108-divvy-tripdata`
	UNION
	SELECT * FROM `202109-divvy-tripdata`
	UNION
	SELECT * FROM `202110-divvy-tripdata`
	UNION
	SELECT * FROM `202111-divvy-tripdata`
	UNION
	SELECT * FROM `202112-divvy-tripdata`
),

--  After that, remove all NULL value from every field, so that the data clean from null value
yearly_not_null AS(
SELECT * FROM union_month_table
WHERE ride_id IS NOT NULL 
	AND rideable_type IS NOT NULL
	AND started_at IS NOT NULL 
	AND ended_at IS NOT NULL
	AND start_station_name IS NOT NULL
	AND start_station_id IS NOT NULL
	AND end_station_name IS NOT NULL
	AND end_station_id IS NOT NULL
	AND start_lat IS NOT NULL
	AND start_lng IS NOT NULL
	AND end_lat IS NOT NULL
	AND end_lng IS NOT NULL
	AND member_casual IS NOT NULL
),

-- Remove all space in start_station_name & end_station_name
remove_space_station_name AS(
SELECT ride_id,
			TRIM(start_station_name) AS new_start_station_name, 
			TRIM(end_station_name) AS new_end_station_name  
FROM yearly_not_null
)

-- After the data is clean, select and use it to 
SELECT yearly_not_null.ride_id,	
	yearly_not_null.rideable_type,
	yearly_not_null.started_at,
	yearly_not_null.ended_at,
	remove_space_station_name.new_start_station_name,
	yearly_not_null.start_station_id,
	remove_space_station_name.new_end_station_name,
	yearly_not_null.end_station_id,
	yearly_not_null.start_lat,
	yearly_not_null.start_lng,
	yearly_not_null.end_lat,
	yearly_not_null.end_lng,
	yearly_not_null.member_casual
FROM yearly_not_null LEFT JOIN remove_space_station_name 
ON yearly_not_null.ride_id = remove_space_station_name.ride_id);
-- End of TEMPORARY TABLE, you can export data to txt or connect to data visualization tools like tableau, powerbi or etc

-- count the number of ride_id
SELECT COUNT(*) FROM cyclistic_2021;

-- count the number of ride_id GROUP BY member_casual
SELECT member_casual, 
	COUNT(*) AS count_rideID FROM cyclistic_2021
GROUP BY member_casual;

-- count the number of ride_id GROUP BY rideable_bike
SELECT rideable_type,
	COUNT(*) AS count_of_rideID
FROM cyclistic_2021
GROUP BY rideable_type;

-- count of rideID group by month to know the trend cyclistics over month
SELECT MONTHNAME(started_at) AS month_name, 
	COUNT(*) AS count_of_rideID FROM cyclistic_2021
GROUP BY month_name
ORDER BY MONTH(started_at);

-- select DISTINCT to know what the member category in member_casual column
SELECT DISTINCT member_casual FROM cyclistic_2021;

-- count member category over month
SELECT MONTHNAME(started_at) AS month_name,
	COUNT(CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) AS member,
	COUNT(CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS casual,
	COUNT(CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) - COUNT(CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS diff_member_casual,
	CASE  
		WHEN COUNT(CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) > COUNT(CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) THEN 'member > casual member'
		WHEN COUNT(CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) < COUNT(CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) THEN 'member < casual member'
	ELSE '0'
	END AS Label
FROM cyclistic_2021
GROUP BY MONTH(started_at)
ORDER BY MONTH(started_at);

-- select DISTINCT trideable_type
SELECT DISTINCT rideable_type FROM cyclistic_2021;

-- select rideable_type group by month
SELECT COUNT(CASE WHEN rideable_type = 'electric_bike' THEN ride_id ELSE NULL END) AS electric_bike,
	COUNT(CASE WHEN rideable_type = 'docked_bike' THEN ride_id ELSE NULL END) AS docked_bike,
	COUNT(CASE WHEN rideable_type = 'classic_bike' THEN ride_id ELSE NULL END) AS classic_bike
FROM cyclistic_2021
GROUP BY MONTH(started_at);

-- what day with the most cyclists
SELECT DAYNAME(started_at) AS day_name,
	COUNT(*) AS count_of_rideID
FROM cyclistic_2021
GROUP BY WEEKDAY(started_at);

-- what day with the most cyclists order by count_of_rideID to sort the data on decending order
SELECT DAYNAME(started_at) AS day_name,
	COUNT(*) AS count_of_rideID
FROM cyclistic_2021
GROUP BY WEEKDAY(started_at)
ORDER BY count_of_rideID DESC;

-- Thank you

