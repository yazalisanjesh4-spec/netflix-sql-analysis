# Netflix Content Analysis Using SQL

## 📌 Project Overview
# Netflix Content Analysis Using SQL

# Netflix Content Analysis Using SQL

This project analyzes Netflix's content catalog using MySQL to identify
content growth trends, Movie vs TV Show distribution, rating patterns,
movie duration trends, and TV Show season distribution.

The project demonstrates practical SQL skills including CTEs,
window functions, ranking, running totals, joins, aggregations,
date functions, and string manipulation.
Data Source:https://www.kaggle.com/datasets/shivamb/netflix-shows

## 🎯 Business Objectives

- Understand Netflix's content composition
- Analyze content additions over time
- Compare Movies and TV Shows
- Identify dominant content ratings
- Analyze Movie duration
- Analyze TV Show season distribution
- Identify major content growth periods



## 🧹 Data Cleaning

- Converted `date_added` from text to DATE
- Identified and corrected duration values incorrectly stored in `rating`
- Handled NULL values
- Validated Movie and TV Show records

## 📊 Business Questions

1. What is the overall composition of Netflix's catalog?
2. Which years had the highest number of titles added?
3. How has Movie vs TV Show content changed over time?
4. What was the year-over-year change in content additions?
5. Which years had the largest content expansion?
6. What is the cumulative growth of Netflix's catalog?
7. What are the most common content ratings?
8. What are the top-rated content categories by type?
9. What is the average Movie duration?
10. What are the longest Movies?
11. What is the distribution of TV Shows by number of seasons?
12. Which TV Shows have the most seasons?

## 🧠 SQL Skills Demonstrated

- SELECT / WHERE
- GROUP BY / HAVING
- CASE
- CTEs
- JOINs
- Subqueries
- RANK()
- DENSE_RANK()
- LAG()
- PARTITION BY
- Running totals
- Aggregate functions
- Date functions
- String functions
- Data cleaning

## 📈 Key Insights

- Movies represent approximately 70% of the Netflix catalog.
- 2019 was the peak year for content additions.
- 2017 recorded the largest absolute year-over-year increase.
- Content additions declined after the 2019 peak.
- TV Shows increased their share of annual additions over time.
- TV-MA is the most common rating.
- Most TV Shows have only one season.
- Average Movie duration is approximately 100 minutes.

## 🛠️ Tools

- MySQL
- MySQL Workbench
- GitHub

## 📁 Project Structure

netflix-sql-analysis/
│
├── README.md
├── sql/
├── screenshots/
└── dataset/