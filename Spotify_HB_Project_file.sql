-- SQL Project --> Spotify Dataset

--  Creating Table

DROP TABLE If EXISTS spotify;
CREATE TABLE spotify(
	artist VARCHAR(255),
	track VARCHAR(255),
	album VARCHAR(255),
	album_type VARCHAR(50),
	danceability FLOAT,
	energy FLOAT,
	loudness FLOAT,
	speechiness FLOAT,
	acousticness FLOAT,
	instrumentalness FLOAT,
	liveness FLOAT,
	valence FLOAT,
	tempo FLOAT,
	duration_min FLOAT,
	title VARCHAR(255),
	channel VARCHAR(255),
	views FLOAT, 
	likes BIGINT,
	comments BIGINT,
	lincensed BOOLEAN,
	official_video BOOLEAN,
	stream BIGINT,
	energy_liveness FLOAT,
	most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis (EDA)

-- total count of all the rows
SELECT COUNT(*) FROM spotify;
-- 20594

-- total number of unique artists
SELECT COUNT(DISTINCT artist) FROM spotify;
-- 2074

-- total number of unique albums
SELECT COUNT(DISTINCT album) FROM spotify;
-- 11854

-- types of albums
SELECT DISTINCT album_type FROM spotify;
-- album, compilation, single

-- maximum and minimum duration
SELECT MAX(duration_min) FROM spotify;
-- 77.9343
SELECT MIN(duration_min) FROM spotify;
-- 0


-- how can a song have 0 duration? lets see
SELECT * FROM spotify
WHERE duration_min = 0;
-- 1. Natasha Bedingfield
-- 2. White Noise for Babies
--  these two songs are found that have duration of 0 minutes so, will simply drop them

DELETE FROM spotify
WHERE duration_min = 0;
-- Messages : DELETE 2

SELECT * FROM spotify
WHERE duration_min = 0;
--  returns 0 rows as now there are no songs left in our database with the duration of zero minutes

SELECT COUNT(*) FROM spotify;
-- 20592

-- how many different types of channel are there
SELECT COUNT(DISTINCT channel) FROM spotify;
-- 6673

-- unique most played on platforms
SELECT DISTINCT most_played_on FROM spotify;
-- Youtube
-- Spotify

-- ---------------------------------------------
-- Data Analysis - Business Problems
-- ---------------------------------------------

-- Q.1 Which tracks have amassed over one billion streams? List their names.
SELECT * FROM spotify
WHERE stream > 1000000000;
-- 385 total tracks which have over one billion streams

--Q.2 For each album, show the album title along with its artist.
SELECT 
	DISTINCT album, artist
FROM spotify
ORDER BY 1;

SELECT 
	DISTINCT album
FROM spotify
ORDER BY 1;


-- Q.3What is the total number of comments on tracks where licensed = TRUE?
-- first checking the case sensitivity of the values in lincensed column
SELECT DISTINCT lincensed FROM spotify;


SELECT 
	SUM(comments) as total_comments
FROM spotify
WHERE lincensed = 'true';

-- Q.4 List all tracks that are included in albums of type “single.”

SELECT * FROM spotify
WHERE album_type = 'single';

-- Q.5 How many tracks does each artist have in total?

SELECT 
	artist,
	COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist;

-- in descending order 
SELECT 
	artist,
	COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist
ORDER BY 2 DESC;

--  in ascending order
SELECT 
	artist,
	COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist
ORDER BY 2; 

-- Q.6 For each album, compute the average danceability of its tracks.
SELECT 
	album,
	avg(danceability) as avg_danceability
FROM spotify
GROUP BY 1;

-- sorting the value of second column in descending order
SELECT 
	album,
	avg(danceability) as avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;


-- Q.7 Identify the top five tracks with the highest energy values.
SELECT 
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.8 List all tracks where official_video = TRUE, including their view and like counts.
SELECT 
	track, 
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1;

-- Q.9 For each album, compute the total number of views across all its tracks.
SELECT 
	album,
	track,
	SUM(views) AS total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;


-- Q.10 Which tracks have been streamed more on Spotify than on YouTube? Provide their names.
SELECT * FROM 
(SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_Youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_Spotify
FROM spotify
GROUP BY 1
) AS t1
WHERE
	streamed_on_Spotify > streamed_on_Youtube
	AND
	streamed_on_Youtube <> 0;

-- Q.11 Using window functions, identify each artist’s three most-viewed tracks.
--  1. each artists and total view for each track 
--  2. track with highest view for each artist (we need top 3)
-- 3. dense rank
--  cte and filter rank <=3

WITH ranking_artist
AS
(SELECT
	artist, 
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <=3;

-- Q.12 Select tracks whose liveness score exceeds the overall average.

SELECT 
	track,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)


-- Q.13 With a CTE, compute for each album the difference between its highest and lowest track energy values.


WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
Group BY 1
)
SELECT 
	album,
	highest_energy - lowest_energy as energy_difference 
FROM cte
ORDER BY 2 DESC