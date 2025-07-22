-- Netflix Data Analysis using SQL
-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT  type, rating,COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT  type,rating, rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type, rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(
SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE director_name = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE TYPE = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


select * from(
SELECT 
 EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as YEAR,
 COUNT(*),
 RANK() OVER(ORDER BY COUNT(*) DESC)
FROM NETFLIX
where country = 'India'
group by 1
)t1
where rank < 5


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'


-- 12. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM NETFLIX
WHERE CASTS LIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM current_date) - 10


-- 13. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT * FROM(
SELECT unnest(STRING_TO_ARRAY(casts,',')) as actors, count(*) as total_count, RANK() OVER(ORDER BY COUNT(*) DESC) AS RANKS FROM NETFLIX
WHERE country = 'India'
group by 1
)
WHERE RANKS <= 10

/*
Question 14:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




-- End of reports

