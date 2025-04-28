create database dev;
use dev;
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);



show databases;
desc netflix;
SELECT * FROM netflix LIMIT 10;

-- Select title and director for all Movies:
SELECT title, director 
FROM netflix
WHERE type = 'Movie';

-- Find distinct types available in the netflix_titles table:
SELECT DISTINCT(type) 
FROM netflix;

 -- Find all Movies released after 2015:
 SELECT title, release_year, type
FROM netflix
WHERE release_year > 2015
  AND type = 'Movie';

-- Count how many TV Shows there are country-wise:
SELECT country, COUNT(*)
FROM netflix
WHERE type = 'TV Show'
GROUP BY country;

-- Top 5 countries with the most number of TV Shows:
SELECT country, COUNT(*)
FROM netflix
WHERE type = 'TV Show'
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 8. Titles of all TV Shows added in 2020
SELECT title, date_added
FROM netflix
WHERE type = 'TV Show'
  AND YEAR(STR_TO_DATE(date_added, '%M %e, %Y')) = 2015;
  
-- 9. Average duration of Movies per country
WITH movies AS (
  SELECT
    country,
    CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED) AS duration_mins
  FROM netflix
  WHERE type = 'Movie'
)
SELECT
  country,
  AVG(duration_mins) AS avg_duration_mins
FROM movies
GROUP BY country;

-- Top 3 longest Movies in each country 
WITH ranked_movies AS (
  SELECT
    title,
    country,
    CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED) AS duration_mins,
    RANK() OVER (
      PARTITION BY country 
      ORDER BY CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED) DESC
    ) AS rn
  FROM netflix
  WHERE type = 'Movie'
)
SELECT title, country, duration_mins
FROM ranked_movies
WHERE rn <= 3;

-- 11. Average release year of Movies per country (window function version)
SELECT
  title,
  country,
  release_year,
  AVG(release_year) OVER (PARTITION BY country) AS avg_release_year_per_country
FROM netflix
WHERE type = 'Movie';

-- 12. Average release year of Movies per country (GROUP BY version)
WITH movie_avg AS (
  SELECT
    country,
    AVG(release_year) AS avg_release_year
  FROM netflix
  WHERE type = 'Movie'
  GROUP BY country
)
SELECT * 
FROM movie_avg;

-- Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranked
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE ranked = 1;

-- Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

 -- Find Content Added in the Last 5 Years
 SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

 -- Find All Movies/TV Shows by Director 'Funke Akindele'
SELECT title, director
FROM netflix
WHERE FIND_IN_SET('Funke Akindele', REPLACE(director, ', ', ',')) > 0;


-- List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
-- Count the Number of Content Items in Each Genre
SELECT 'Dramas' AS genre, COUNT(*) AS total_content
FROM netflix
WHERE listed_in LIKE '%Dramas%'

UNION ALL

SELECT 'International Movies', COUNT(*)
FROM netflix
WHERE listed_in LIKE '%International Movies%'

UNION ALL

SELECT 'Comedies', COUNT(*)
FROM netflix
WHERE listed_in LIKE '%Comedies%'

;

 -- List All Movies that are Documentaries
 SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > (YEAR(CURDATE()) - 10);
  

-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

 

 