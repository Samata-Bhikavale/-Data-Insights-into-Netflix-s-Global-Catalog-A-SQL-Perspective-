# Netflix Data Analysis Using MySQL

## Overview
This project involves analyzing Netflix's content data using **MySQL** for SQL queries. The goal is to explore and extract useful insights from Netflix's content dataset, such as:
- Popular movies and TV shows
- Top actors and directors
- Average movie durations by country
- Rating analysis
- Date-based content filtering

The dataset contains information about Netflix's movies and TV shows, including titles, directors, release years, duration, ratings, and more.


## Data

The dataset used in this project includes information about Netflix content such as:
- `show_id`: Unique identifier for each show
- `type`: Type of content (Movie/TV Show)
- `title`: Title of the content
- `director`: Director(s) of the content
- `casts`: Cast(s) of the content
- `country`: Country where the content was produced
- `date_added`: Date when the content was added to Netflix
- `release_year`: Year of release
- `rating`: Content rating
- `duration`: Duration (in minutes for movies, number of seasons for TV shows)
- `listed_in`: Genre/categories the content belongs to
- `description`: Brief description of the content

# Business Problems and Solutions
1. Select Title and Director for All Movies

```sql
SELECT title, director 
FROM netflix
WHERE type = 'Movie';

 2. Find Distinct Types Available in the Netflix Titles Table
SELECT DISTINCT(type) 
FROM netflix;

## 3. Find All Movies Released After 2015

SELECT title, release_year, type
FROM netflix
WHERE release_year > 2015
  AND type = 'Movie';

## 4. Count How Many TV Shows There Are Country-Wise
SELECT country, COUNT(*)
FROM netflix
WHERE type = 'TV Show'
GROUP BY country;

## 5. Top 5 Countries with the Most Number of TV Shows
SELECT country, COUNT(*)
FROM netflix
WHERE type = 'TV Show'
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 5;

## 6.Titles of All TV Shows Added in 2020
SELECT title, date_added
FROM netflix
WHERE type = 'TV Show'
  AND YEAR(STR_TO_DATE(date_added, '%M %e, %Y')) = 2020;

## 7. Average Duration of Movies Per Country
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
##  8.Top 3 Longest Movies in Each Country
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

## 9.Average Release Year of Movies Per Country (Window Function Version)
SELECT
  title,
  country,
  release_year,
  AVG(release_year) OVER (PARTITION BY country) AS avg_release_year_per_country
FROM netflix
WHERE type = 'Movie';

## 10.Average Release Year of Movies Per Country (GROUP BY Version)
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

## 11. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

## 12. Find the Most Common Rating for Movies and TV Shows
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

## 13. Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

## 14. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

## 15. Find All Movies/TV Shows by Director 'Funke Akindele'
SELECT title, director
FROM netflix
WHERE FIND_IN_SET('Funke Akindele', REPLACE(director, ', ', ',')) > 0;

## 16. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

## 17.List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

## 18.Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

## 19.Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > (YEAR(CURDATE()) - 10);

## 20.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
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


## Findings and Conclusion


**Content Distribution**: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.

**Common Ratings**: Insights into the most common ratings provide an understanding of the content's target audience.

**Geographical Insights**: The top countries and the average content releases by India highlight regional content distribution.

**Content Categorization**: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
