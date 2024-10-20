-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type, count(*) as Count 
FROM 
	netflix_tb
GROUP BY 
	type;

-- 2. Find the most common rating for movies and TV shows

SELECT
	type, MODE() WITHIN GROUP ( ORDER BY rating ) as Most_Common_Rating
FROM 
	netflix_tb
GROUP BY 
	type;
	
-- 3. List all movies released in a specific year (e.g. 2020)

SELECT
	* 
FROM 
	netflix_tb
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*)
FROM netflix_tb
GROUP BY country;

SELECT STRING_TO_ARRAY(country, ',') as new_Country
FROM netflix_tb;

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) as new_Country
FROM netflix_tb;

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) as new_Country, COUNT(*) as total_content
FROM netflix_tb
GROUP BY 1;

-- 5. Indentify the longest movie or TV show duration

(
    SELECT 
		type, duration
	FROM 
		netflix_tb
	WHERE 
		duration IS NOT NULL
		AND 
		duration LIKE '% min'
	ORDER BY 
		CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
	LIMIT 1
)
UNION ALL
(
	SELECT 
		type, duration
	FROM 
		netflix_tb
	WHERE 
		duration IS NOT NULL
		AND 
		duration LIKE '% Seasons'
	ORDER BY 
		CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
	LIMIT 1
);


-- 6. Find content added in the last 5 years

SELECT 
	*
FROM 
	netflix_tb
WHERE 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) >= EXTRACT(YEAR FROM CURRENT_DATE)-5;

-- 7. Final all the movies/TV shows by director 'Rajiv Chilaka'

SELECT
	*
FROM
	netflix_tb
WHERE
	director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT 
	*
FROM 
	netflix_tb
WHERE 
	duration IS NOT NULL
	AND 
	duration LIKE '% Seasons'
	AND
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as Genre, COUNT(*) as total_content
FROM 
	netflix_tb
GROUP BY 1; 

-- 10. Find the average release year for content produced in a specific country

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as Country, ROUND(AVG(release_year),0) as Avg_release_year
FROM 
	netflix_tb
GROUP BY 1;

-- 11. List all movies that are documentaries

SELECT 
	*
FROM 
	netflix_tb
WHERE 
	type = 'Movie'
	AND
	listed_in LIKE 'Documentaries';
	

-- 12. Find all content without a director

SELECT 
	*
FROM 
	netflix_tb
WHERE 
	director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT 
	*
FROM 
	netflix_tb
WHERE 
	casts LIKE '%Salman Khan%'
	AND
	release_year >=  EXTRACT(YEAR FROM CURRENT_DATE)-10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as Actors, COUNT(show_id) as total_movies
FROM 
	netflix_tb
WHERE 
	country LIKE '%India%'
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 
	10;

15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
-- Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.


SELECT label, COUNT(*)
FROM
	(
	SELECT 
	    *,
	    CASE
	        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
	        ELSE 'Good'
	    END AS Label
	FROM 
	    netflix_tb
	)
GROUP BY label;

WITH classified AS (
    SELECT 
        CASE
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS Label
    FROM 
        netflix_tb
)
SELECT 
    Label, 
    COUNT(*) AS count
FROM 
    classified
GROUP BY 
    Label;

