USE netflix;

CREATE TABLE netflix (
    show_id VARCHAR(20) PRIMARY KEY,
    show_type VARCHAR(20),
    title VARCHAR(255),
    director TEXT,
    cast VARCHAR(1000),
    country VARCHAR(255),
    date_added DATE,
    release_year YEAR,
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    show_description TEXT
);

INSERT INTO netflix (
    show_id,
    show_type,
    title,
    director,
    cast,
    country,
    date_added,
    release_year,
    rating,
    duration,
    listed_in,
    show_description
)
SELECT
    show_id,
    show_type,
    title,
    director,
    cast,
    country,
    date_added,
    release_year,
    rating,
    duration,
    listed_in,
    show_description
FROM stg_netflix;