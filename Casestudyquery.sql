/*Combine all the tables i-e; 12 months dataset (January 2023-December 2023) into Individual table using UNION ALL function and giving alias as Combined_12months_dataset*/

SELECT * FROM
`dataset_12months.January` UNION ALL
SELECT * FROM
`dataset_12months.February` UNION ALL
SELECT * FROM
`dataset_12months.March` UNION ALL
SELECT * FROM
`dataset_12months.April` UNION ALL
SELECT * FROM
`dataset_12months.May` UNION ALL
SELECT * FROM
`dataset_12months.June` UNION ALL
SELECT * FROM
`dataset_12months.July` UNION ALL
SELECT * FROM
`dataset_12months.August` UNION ALL
SELECT * FROM
`dataset_12months.September` UNION ALL
SELECT * FROM
`dataset_12months.October` UNION ALL
SELECT * FROM
`dataset_12months.November` UNION ALL
SELECT * FROM
`dataset_12months.December`
AS Combined_12months_dataset;

--Saving the result of the combined dataset into new table called "Combined_12months_dataset" 
--Using the newly created table for the analysis 
--Adding new Columns tripduration_mintues, day_of_ week, month, year and hour

SELECT
ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
start_station_id,
end_station_name,
end_station_id,
member_casual,
TIMESTAMP_DIFF(ended_at,started_at,MINUTE) AS tripduration_minutes,
format_date('%A',started_at) as day_of_week,
format_date('%B',started_at) as month,
format_date('%Y',started_at) as year,
extract(hour from started_at) as hour
FROM `dataset_12months.Combined_12months_dataset`;

--Saveing the new table with the additional columns as “Final_dataset”.
--Noticed that some cells in column tripduration_minutes = 0 and some longer than 24 hours (1440 minutes) which might not provide a correct average trip duration for all rides.so,ran a query to delete rows with tripduration_minutes greater than a day or equal to zero. The query deleted 156,032 from the table “Final_dataset”. Now, the total number of rows in the table are 5,563,845 

DELETE from
`dataset_12months.Final_dataset`
where tripduration_minutes <= 0 OR tripduration_minutes >=1441;

--Analyzing the dataset
--To find the ride total, average, maximum and minimum trip duration for different ride types by casual and member riders

SELECT 
    member_casual,
    rideable_type,
    COUNT(ride_id) AS rides_total,
    AVG(tripduration_minutes) AS avg_trip_duration,
    MAX(tripduration_minutes) AS max_trip_duration,
    MIN(tripduration_minutes) AS min_trip_duration
FROM 
    `dataset_12months.Final_dataset`
GROUP BY 
     member_casual,
     rideable_type
ORDER BY 
    rides_total DESC;

-- to find the ride total, average, maximum and minimum trip duration for each month by casual and member riders

SELECT 
    month,
    member_casual,
    COUNT(ride_id) AS rides_total,
    AVG(tripduration_minutes) AS avg_trip_duration,
    MAX(tripduration_minutes) AS max_trip_duration,
    MIN(tripduration_minutes) AS min_trip_duration
FROM 
    `dataset_12months.Final_dataset`
GROUP BY 
     member_casual,
     month
     ORDER BY 
    rides_total DESC;

--to find the ride total, average, maximum and minimum trip duration for each day of the week by casual and member riders

SELECT 
    day_of_week,
    member_casual,
    COUNT(ride_id) AS rides_total,
    AVG(tripduration_minutes) AS avg_trip_duration,
    MAX(tripduration_minutes) AS max_trip_duration,
    MIN(tripduration_minutes) AS min_trip_duration
FROM 
    `dataset_12months.Final_dataset`
GROUP BY 
     day_of_week,
     member_casual
ORDER BY 
    rides_total DESC;

--to find the ride total, average, maximum and minimum trip duration at each start station by casual and member riders
    SELECT 
    start_station_name,
    member_casual,
    COUNT(ride_id) AS rides_total,
    AVG(tripduration_minutes) AS avg_trip_duration,
    MAX(tripduration_minutes) AS max_trip_duration,
    MIN(tripduration_minutes) AS min_trip_duration
FROM 
    `dataset_12months.Final_dataset`
GROUP BY 
     start_station_name,
     member_casual
ORDER BY 
    rides_total DESC;

--to find the total number of rides and its percentage taken by each rider type, sorted in alphabetical order and the percentage rounded to two decimal places
SELECT 
    member_casual as membership_type,
    count(member_casual) as total_rides,
    ROUND(COUNT(member_casual)/SUM(COUNT(member_casual))OVER()*100,2) AS percentage
    
FROM 
    `dataset_12months.Final_dataset`
GROUP BY 
     member_casual
ORDER BY 
     member_casual;
    
--to list top 10 casual riders by station name
WITH casual_station_counts AS (
    SELECT 
        start_station_name,
        COUNT(*) AS ride_count
    FROM 
        `dataset_12months.Final_dataset`
    WHERE 
        member_casual = 'casual'
    GROUP BY 
        start_station_name
),
ranked_casual_stations AS (
    SELECT 
        start_station_name,
        ride_count,
        RANK() OVER (ORDER BY ride_count DESC) AS rank
    FROM 
        casual_station_counts
)
SELECT 
    start_station_name,
    ride_count,
    rank
FROM 
    ranked_casual_stations
WHERE 
    rank <= 10
ORDER BY 
    rank;
--to list top 10 member riders by start station name
WITH casual_station_counts AS (
    SELECT 
        start_station_name,
        COUNT(*) AS ride_count
    FROM 
        `dataset_12months.Final_dataset`
    WHERE 
        member_casual = 'member'
    GROUP BY 
        start_station_name
),
ranked_casual_stations AS (
    SELECT 
        start_station_name,
        ride_count,
        RANK() OVER (ORDER BY ride_count DESC) AS rank
    FROM 
        casual_station_counts
)
SELECT 
    start_station_name,
    ride_count,
    rank
FROM 
    ranked_casual_stations
WHERE 
    rank <= 10
ORDER BY 
    rank;

--to retrieve the total number of rides taken by each rider type for each hour of the day, sorting the results first by rider type and then by hour.
SELECT 
member_casual,
hour,
COUNT(hour) AS total_rides
FROM `dataset_12months.Final_dataset`
GROUP BY
member_casual,hour
ORDER BY
member_casual,hour


