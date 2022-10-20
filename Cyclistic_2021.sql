
WITH union_all_monthy_table AS(
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
SELECT COUNT(*) FROM union_all_monthy_table;

WITH union_monthy_table AS(
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
yearly_not_null AS(
SELECT * FROM union_monthy_table
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
remove_space_station_name AS(
SELECT ride_id,
			TRIM(start_station_name) AS new_start_station_name, 
			TRIM(end_station_name) AS new_end_station_name  
FROM yearly_not_null
)
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
ON yearly_not_null.ride_id = remove_space_station_name.ride_id;

CREATE TEMPORARY TABLE cyclistic_2021(
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
);

SELECT MONTHNAME(started_at) AS month_name, 
	COUNT(*) AS count_of_rideID FROM cyclistic_2021
GROUP BY month_name
ORDER BY MONTH(started_at);

SELECT DISTINCT member_casual FROM cyclistic_2021;

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

SELECT DISTINCT rideable_type FROM cyclistic_2021;

SELECT COUNT(CASE WHEN rideable_type = 'electric_bike' THEN ride_id ELSE NULL END) AS electric_bike,
	COUNT(CASE WHEN rideable_type = 'docked_bike' THEN ride_id ELSE NULL END) AS docked_bike,
	COUNT(CASE WHEN rideable_type = 'classic_bike' THEN ride_id ELSE NULL END) AS classic_bike
FROM cyclistic_2021
GROUP BY MONTH(started_at);

