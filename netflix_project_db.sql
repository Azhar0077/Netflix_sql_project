--Netflix project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
show_id VARCHAR(6) PRIMARY KEY,
type VARCHAR(10),
title VARCHAR (150),
director VARCHAR(210),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT * FROM netflix;

--SQL problem and solution

--count the number of movies vs tv shows
SELECT type, COUNT(type) AS total_content
FROM netflix 
GROUP BY 1;


--find the most common rating for movies and tv shows:using rank and subquery
SELECT type,rating
FROM
(
SELECT type, rating,COUNT(rating), 
RANK () OVER(PARTITION BY type ORDER BY COUNT(*)DESC) AS ranking
FROM netflix 
GROUP BY 1,2
)
AS ti
WHERE ranking='1';


--list all movies released in a specific year(e.g 2020)
SELECT * FROM netflix 
WHERE release_year='2020'AND type='Movie';


--find the top 5 countries with the most content on netflix
--using unnest function
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS new_country
FROM netflix;

SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
COUNT(show_id)AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;


--identifies the longest movies
SELECT *
FROM netflix
WHERE type='Movie'
AND 
duration = (SELECT MAX(duration)FROM netflix);


--find content added in the last 5 years
SELECT *
FROM netflix
WHERE
TO_DATE(date_added,'Month DD yyyy') >= CURRENT_DATE - INTERVAL '5 Years';


--find all the movies/tv shows by director 'rajiv chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


--list all tv shows with more than 5 seasons
SELECT * FROM netflix
WHERE type='TV Show'
AND 
SPLIT_PART (duration,' ',1)::numeric >5 ;


--count the number of content item in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;


--find each year and the average numbers of content release by india on netflix
--return top 5 year with highest avg content release
SELECT
EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD,yyyy')) AS year,
COUNT(*) AS yearly_content,
ROUND(
COUNT(*)::numeric/(SELECT COUNT(*)FROM netflix
WHERE country='India')::numeric * 100 ,2) AS avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1;


--list all movies that are documantries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%';


--find the all content without a director 
SELECT * FROM netflix
WHERE  director IS NULL;


--find the many movies actor 'salman khan' appeard in last 10 years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND 
release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10;



--find the top 10 actors who have appeard in the highest number of movies produced in india
SELECT
UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
COUNT(*) AS number_of_movies
 FROM netflix
WHERE country ILIKE '%india%'
AND 
type ILIKE '%movie%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;


--categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--label content containing these keywords as 'bad' and all other content as 'good' .
--count how many items fall into each category
WITH new_table
AS
(SELECT *,
CASE
WHEN description ILIKE '%kill%' OR
      description ILIKE '%violence%' THEN 'Bad_content'
ELSE 'Good_content'
END category 
FROM netflix)
SELECT category,
COUNT(*) AS total_content
FROM new_table
GROUP BY 1;






