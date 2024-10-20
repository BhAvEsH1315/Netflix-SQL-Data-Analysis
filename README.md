# Netflix Movies & Shows - SQL Analysis

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
-- Netflix Project
DROP TABLE IF EXISTS netflix_tb;
CREATE TABLE netflix_tb
(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),	
	duration VARCHAR(15),	
	listed_in VARCHAR(100),	
	description VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	type, count(*) as Count 
FROM 
	netflix_tb
GROUP BY 
	type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```
*OR*

```sql
SELECT
	type, MODE() WITHIN GROUP ( ORDER BY rating ) as Most_Common_Rating
FROM 
	netflix_tb
GROUP BY 
	type;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT
	* 
FROM 
	netflix_tb
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

*OR*

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) as new_Country, COUNT(*) as total_content
FROM netflix_tb
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie/TV show with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	*
FROM 
	netflix_tb
WHERE 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) >= EXTRACT(YEAR FROM CURRENT_DATE)-5;

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT
	*
FROM
	netflix_tb
WHERE
	director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as Genre, COUNT(*) as total_content
FROM 
	netflix_tb
GROUP BY 1; 
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as Country, ROUND(AVG(release_year),0) as Avg_release_year
FROM 
	netflix_tb
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	*
FROM 
	netflix_tb
WHERE 
	type = 'Movie'
	AND
	listed_in LIKE 'Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT 
	*
FROM 
	netflix_tb
WHERE 
	director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
	*
FROM 
	netflix_tb
WHERE 
	casts LIKE '%Salman Khan%'
	AND
	release_year >=  EXTRACT(YEAR FROM CURRENT_DATE)-10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```
*OR*

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Bhavesh Borse

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Thank you for your support, and I look forward to connecting with you!
