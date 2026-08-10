USE netflix;

-- Check total records
SELECT COUNT(*) AS total_rows
FROM stg_netflix;

-- Check NULL values
SELECT
    COUNT(*) AS total_rows,
    COUNT(show_id) AS show_id_count,
    COUNT(show_type) AS show_type_count,
    COUNT(title) AS title_count,
    COUNT(director) AS director_count,
    COUNT(cast) AS cast_count,
    COUNT(country) AS country_count,
    COUNT(date_added) AS date_added_count,
    COUNT(release_year) AS release_year_count,
    COUNT(rating) AS rating_count,
    COUNT(duration) AS duration_count,
    COUNT(listed_in) AS listed_in_count,
    COUNT(show_description) AS description_count
FROM stg_netflix;