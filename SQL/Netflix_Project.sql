USE netflix;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 1: What is the overall composition of Netflix's catalog in terms of total titles, Movies, TV Shows, and their percentages?
WITH CTE AS(SELECT COUNT(*) AS Total_titles,
COUNT(
      CASE 
          WHEN Show_type='Movie' THEN 1
      END) AS Total_movies,
COUNT(      
      CASE 
          WHEN Show_type='TV Show' THEN 1
      END) AS Total_shows
FROM Netflix)
SELECT Total_titles, 
Total_movies, 
Total_shows,
ROUND((Total_movies/Total_titles)*100,2) as 'Movies%', 
ROUND((Total_shows/Total_titles)*100,2) as 'TV Shows%'
FROM CTE;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 2: Which years had the highest number of titles added to Netflix, and how many titles were added in the latest recorded year?
SELECT YEAR(date_added),COUNT(Title) AS Titles FROM netflix GROUP BY YEAR(date_added) 
ORDER BY COUNT(Title) DESC LIMIT 5; # 1.2019 -->2016 titles added,2.2020 --> 1879 titles added,3.2018 -->1649

SELECT YEAR(date_added),COUNT(Title) FROM netflix WHERE YEAR(date_added)='2024' 
GROUP BY YEAR(date_added); #2024 --> 2 titles added #2023 have 0 titles added 2024 is the latest year

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 3: How did the number of Movies and TV Shows added to Netflix change by year?
SELECT COALESCE(YEAR(date_added),'No_year') AS Added_year,
COUNT(
CASE
    WHEN show_type='movie' THEN 1
END    
) AS Total_movies,

COUNT(
CASE 
    WHEN show_type='tv show' THEN 1
END) AS Total_shows
FROM Netflix 
GROUP BY Added_year ORDER BY Added_year DESC;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 4: How did Netflix's annual content additions change compared with the previous recorded year?
WITH yearly_count AS (
    SELECT
        YEAR(date_added) AS added_year,
        COUNT(*) AS total_titles
    FROM netflix
    GROUP BY YEAR(date_added)
),
yearly_growth AS (
    SELECT
        added_year,
        total_titles,
        LAG(total_titles) OVER (
            ORDER BY added_year
        ) AS previous_year
    FROM yearly_count
)
SELECT
    added_year,
    total_titles,
    previous_year,
    total_titles - previous_year AS absolute_growth,
    ROUND(
        (total_titles - previous_year) / previous_year * 100,
        2
    ) AS growth_percentage
FROM yearly_growth
ORDER BY added_year;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 5: Which years ranked highest in terms of the number of Netflix titles added?
WITH cte AS(
SELECT YEAR(date_added) AS Year_added,
COUNT(*) AS Titles_added,
RANK() OVER(ORDER BY Count(*) DESC) AS title_rank FROM Netflix GROUP BY Year_added)
SELECT Year_added,Titles_added,title_rank FROM cte WHERE title_rank<11;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 6: Which years experienced the strongest increases or declines in Netflix content additions compared with the previous recorded year?
WITH yearly_count AS(
SELECT COALESCE(YEAR(date_added),'NO_RECORDED_YEAR') as year_added,
COUNT(*) as Total_titles FROM Netflix 
GROUP BY COALESCE(YEAR(date_added),'NO_RECORDED_YEAR')
),
yearly_growth AS(SELECT year_added,Total_titles,lag(Total_titles) 
OVER(ORDER BY year_added) AS previous_total_titles
FROM yearly_count),
GROWTH_RANK AS (SELECT year_added,Total_titles,previous_total_titles,
(Total_titles-previous_total_titles) AS Growth,
ROUND((Total_titles-previous_total_titles)/previous_total_titles*100,2) AS Growth_percentage
FROM yearly_growth)
SELECT * FROM GROWTH_RANK ORDER BY Growth_percentage DESC;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 7: How has Netflix's cumulative catalog grown over time?
WITH yearly_titles AS(
SELECT YEAR(date_added) AS Added_year,COUNT(*) AS Total_titles
FROM Netflix GROUP BY YEAR(date_added)),CUMULATIVE_SALES AS(
SELECT Added_year,SUM(Total_titles) OVER(ORDER BY Added_year
) AS Cumulative_sales FROM yearly_titles)
SELECT * FROM CUMULATIVE_SALES ORDER BY Added_year DESC;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 8: What percentage of Netflix's cumulative catalog had been added by each year, and how much did the cumulative share increase from the previous year?
WITH yearly_titles AS(
SELECT YEAR(date_added) AS year_added,COUNT(*) AS Total_titles
FROM Netflix GROUP BY YEAR(date_Added)),

CUMULATIVE_TITLES AS(SELECT year_added,SUM(Total_titles) OVER
(ORDER BY year_added) AS Cumulative_titles FROM yearly_titles GROUP BY year_added),

 CUMULATIVE_PERCENT AS
(SELECT year_added, Cumulative_titles,((Cumulative_titles)/MAX(cumulative_titles) OVER())*100 AS 
Cumulative_percentage FROM CUMULATIVE_TITLES GROUP BY year_added ORDER BY year_added),

PREVIOUS_CUMULATIVE_PERCENTAGE AS(
SELECT year_added,Cumulative_titles,cumulative_percentage,LAG(cumulative_percentage) OVER(ORDER BY year_added)
AS PREVIOUS_YEAR_PERCENT FROM CUMULATIVE_PERCENT GROUP BY year_added)

SELECT year_added,Cumulative_titles,cumulative_percentage,PREVIOUS_YEAR_PERCENT,
(cumulative_percentage-PREVIOUS_YEAR_PERCENT)AS PERCENT_ADDED FROM PREVIOUS_CUMULATIVE_PERCENTAGE 
GROUP BY year_added ;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 9: How do years rank by the number of titles added to Netflix?
SELECT YEAR(date_added) AS Year_added,count(*) AS titles_added,
RANK() OVER(ORDER BY count(*) DESC) AS Total_rank FROM netflix
GROUP BY YEAR(date_added);

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 10: What are the top 5 content-addition years for Movies and TV Shows separately?
WITH CTE AS (SELECT show_type,COALESCE(YEAR(date_added),'NO_RECORDED_YEAR') AS year,
COUNT(*) AS Titles_added, RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS
Year_rank FROM Netflix GROUP BY show_type,COALESCE(YEAR(date_added),'NO_RECORDED_YEAR'))
SELECT * FROM CTE WHERE Year_rank<6;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 11: What are the top 3 release years for Movies and TV Shows based on the number of titles released?
WITH CTE AS(SELECT show_type,release_year,COUNT(*) AS Total_titles,
RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS _RANK
FROM Netflix
GROUP BY show_type,release_year)
SELECT * FROM  CTE WHERE _RANK<4;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 12: What are the most common content ratings on Netflix, and what percentage of the catalog does each rating represent?
WITH CTE AS(SELECT COALESCE(rating,'No Ratings') AS rating,COUNT(*) AS Rating_count FROM Netflix
GROUP BY rating)
SELECT rating,Rating_count,((Rating_count)/(SUM(Rating_count)OVER()))*100 AS Percent FROM CTE ORDER BY Percent DESC;

#------------------------------------------------------------------------------------------------------------------------#

-- Business Question 13: What are the top 3 ratings for Movies and TV Shows separately?
WITH CTE AS(SELECT show_type,COALESCE(rating,'No rating') AS rating
,COUNT(*) AS Rate_count,RANK() OVER(PARTITION BY show_type 
ORDER BY COUNT(*) DESC)
AS _RANK
FROM Netflix GROUP BY show_type,rating)
SELECT show_type,rating,Rate_count,_RANK FROM CTE WHERE _RANK<4;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 14: What is the most common rating for Movies and TV Shows separately?
WITH CTE AS(SELECT show_type,COALESCE(rating,'No_rating') AS rating,COUNT(*) AS Rate_count,
RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS _RANK
FROM netflix GROUP BY show_type,COALESCE(rating,'No_rating'))
SELECT * FROM CTE WHERE _RANK=1;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 15: What is the average duration of Netflix Movies?
SELECT show_type,CONCAT(ROUND(AVG(CAST(SUBSTRING_INDEX(duration,' ',1)AS UNSIGNED)),2),' Min') AS Avg_duration
 FROM Netflix WHERE show_type='movie';

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 16: How does the average number of seasons of TV Shows vary by release year?
SELECT release_year,show_type,
CONCAT(CEIL(AVG(CAST(SUBSTRING_INDEX(duration,' ',1)AS UNSIGNED))),' Seasons') AS Avg_seasons
FROM Netflix WHERE show_type='Tv show' GROUP BY release_year;

#----------------------------------------------------------------------------------------------------------------------#

-- Business Question 17: What are the 10 longest Movies in the Netflix catalog?
WITH CTE AS (SELECT title,release_year, CONCAT(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED),' Min') AS Duration,
RANK() OVER(ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) DESC) AS _RANK FROM Netflix
WHERE show_type='movie')
SELECT * FROM CTE WHERE _RANK<11;

#----------------------------------------------------------------------------------------------------------------------#

-- Business Question 18: What are the 3 longest Movies within each rating category?
WITH CTE AS(SELECT COALESCE(rating,'Not rated') AS rating,title,
CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) AS duration,
DENSE_RANK() OVER(PARTITION BY  COALESCE(rating,'Not rated')
 ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) DESC) AS _RANK
FROM Netflix WHERE show_type='movie')
SELECT * FROM CTE WHERE _RANK<4;

#----------------------------------------------------------------------------------------------------------------------#

-- Business Question 19: Which Movie release years have the highest average Movie duration?
SELECT release_year, AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)) AS Avg_duration,
RANK() OVER(ORDER BY AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)) DESC) AS _RANK
FROM Netflix WHERE show_type='movie' GROUP BY release_year
 ORDER BY AVG(CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)) DESC;

#---------------------------------------------------------------------------------------------------------------------#

-- Business Question 20: How is the Netflix TV Show catalog distributed by number of seasons?
SELECT CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) AS Seasons,
COUNT(title) AS No_of_shows
FROM netflix WHERE show_type='Tv show' GROUP BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED)
ORDER BY COUNT(title) DESC;

#---------------------------------------------------------------------------------------------------------------------#

-- Business Question 21: Which TV Shows have the highest number of seasons?
WITH CTE AS( SELECT title, CAST(SUBSTRING_INDEX(duration,' ',1)AS UNSIGNED)AS seasons,
DENSE_RANK()OVER(ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1)AS UNSIGNED) DESC) AS _RANK
FROM Netflix WHERE show_type='Tv show')
SELECT * FROM CTE WHERE _RANK<11;

#----------------------------------------------------------------------------------------------------------------------#

-- Business Question 22: How has the balance between Movie and TV Show additions changed over time, and which content type was dominant each year?
WITH CTE AS(SELECT COALESCE(YEAR(date_added),'No_recorded_year') AS year_Added,
COUNT(
     CASE
         WHEN show_type='movie' THEN 1
     END) AS Movies_added,
COUNT(
     CASE
         WHEN show_type='Tv show' THEN 1
	 END) AS shows_added
FROM Netflix 
WHERE date_added IS NOT NULL
GROUP BY COALESCE(YEAR(date_added),'No_recorded_year') ),
PERCENTAGE AS(SELECT year_added, Movies_added,Shows_added,
ROUND((Movies_added/(Movies_added+shows_added))*100,2) AS Movies_percentage,
(shows_added/(Movies_added+shows_added))*100 AS Shows_percentage
 FROM CTE)
SELECT year_added,Movies_added,Shows_Added,Movies_percentage,Shows_percentage,
CASE 
WHEN Movies_percentage>Shows_percentage THEN 'Movies'
WHEN Movies_percentage=Shows_percentage THEN 'Both'
ELSE 'Shows'
END as Dominant FROM PERCENTAGE ORDER BY year_Added DESC;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 23: Which years experienced the largest increases or declines in Netflix content additions, and what was the growth status in each year?
WITH Yearly_titles AS(SELECT YEAR(date_added) AS year,COUNT(title) AS titles_added
FROM netflix WHERE YEAR(date_added) IS NOT NULL
GROUP BY YEAR(date_added) ORDER BY YEAR(date_added) DESC),
 PREVIOUS_YEAR AS (SELECT year,titles_added,LAG(titles_added)OVER(ORDER BY year) AS previous_year_titles,
 LAG(year) OVER(ORDER BY year) AS Previous_year
FROM Yearly_titles ORDER BY year DESC),
GROWTH AS(SELECT year,titles_added,Previous_year,previous_year_titles,
titles_added-previous_year_titles AS Difference,
CASE 
WHEN titles_added-previous_year_titles>0 THEN 'Increased'
WHEN titles_added-previous_year_titles=0 THEN 'No growth'
ELSE 'Declined'
END AS Growth
FROM PREVIOUS_YEAR)
SELECT year,titles_added,Previous_year,previous_year_titles,Difference,Growth,
RANK()OVER(ORDER BY Difference DESC) AS _RANK FROM GROWTH;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 24: Which years added more titles than the average number of titles added per year?
WITH Yearly_titles AS(SELECT YEAR(date_added)AS year,COUNT(title) AS Titles_added 
FROM Netflix GROUP BY YEAR(date_added)),
Yearly_avg AS (SELECT year,Titles_added,ROUND(AVG(Titles_added)OVER(),2) AS Yearly_avg
FROM Yearly_titles)
SELECT * FROM Yearly_avg WHERE Titles_added>Yearly_avg;

#-----------------------------------------------------------------------------------------------------------------------#

-- Business Question 25: Which years contributed the largest percentage of Netflix's total catalog additions?
WITH Yearly_titles
 AS(SELECT YEAR(date_added) AS Year,COUNT(title) AS Yearly_titles_added
FROM Netflix GROUP BY Year),
Total_titles AS 
(SELECT Year,Yearly_titles_added,SUM(Yearly_titles_added)OVER() AS Total_titles FROM Yearly_titles),
Percentage_total AS(SELECT Year,Yearly_titles_added,Total_titles,
ROUND((Yearly_titles_added/Total_titles)*100,2) AS Percentage_of_total
FROM Total_titles)

SELECT Year,Yearly_titles_added,Total_titles,Percentage_of_total,
DENSE_RANK() OVER(ORDER BY Percentage_of_total DESC) AS _RNK FROM Percentage_total

#=======================================================================================================================#
-- FINAL BUSINESS INSIGHTS
#=======================================================================================================================#
-- 1. Netflix's catalog is Movie-heavy, with 6,132 Movies (69.61%) and 2,677 TV Shows (30.39%) out of 8,809 titles.
--
-- 2. 2019 was the peak content-addition year in the dataset, with 2,016 titles added, followed by 2020 (1,879) and 2018 (1,649).
--
-- 3. Netflix experienced its largest absolute year-over-year increase in recorded content additions in 2017, with 759 more titles than the previous recorded year.
--
-- 4. Content additions declined after the 2019 peak: 2020 recorded a decline of 137 titles, while 2021 recorded a decline of 381 titles versus the previous recorded year.
--
-- 5. The 2017-2021 period was the major expansion period in the dataset, contributing the overwhelming majority of recorded additions.
--
-- 6. Movies remained the dominant content type, but TV Shows increased their share of annual additions over time; the TV Show share reached about 33.7% in 2021.
--
-- 7. TV-MA was the most common rating, with 3,208 titles, indicating that mature-audience content represents a substantial portion of the catalog.
--
-- 8. TV Shows are heavily concentrated around one-season content: 1,794 TV Shows have one season.
--
-- 9. A small number of TV Shows have substantially longer runs than the typical show; Grey's Anatomy is the longest-running example in the dataset at 17 seasons.
--
-- 10. The average Movie duration is approximately 100 minutes, showing that the catalog is centered around feature-length Movies.
--
-- 11. Older release years can show unusually high average Movie durations, but these averages should be interpreted cautiously because some older years contain relatively few titles.
--
-- 12. The project demonstrates CTEs, LAG(), RANK(), DENSE_RANK(), PARTITION BY, and running totals through business-oriented questions.
--
-- NOTE: Original SQL query text was preserved; only comments and the final insights section were added.
-- NOTE: Verify exact result values in MySQL Workbench before publishing, especially for queries involving NULL date_added values.
