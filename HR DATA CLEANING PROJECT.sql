CREATE DATABASE hr;
USE hr;
-- DATA CLEANING
-- 1. REMOVING DUPLICATES
-- 2. STANDARDIZING EVERY COLUMN
-- 3. UPDATING NULL AND BLANK VALUES
-- 4. REMOVING UNNECESSARY COLUMN

SELECT * 
FROM `human resources`
;

CREATE TABLE human_resource_staging
LIKE `human resources`
;

INSERT INTO human_resource_staging
SELECT *
FROM `human resources`
;
SELECT *
FROM human_resource_staging
;

SELECT *, ROW_NUMBER() 
OVER
(
PARTITION BY ï»¿id, birthdate, race, department, jobtitle, location, location_city, location_state
) AS row_num
FROM human_resource_staging
;

WITH duplicate_cte AS 
(
SELECT *, ROW_NUMBER() 
OVER
(
PARTITION BY ï»¿id, birthdate, race, department, jobtitle, location, location_city, location_state
) AS row_num
FROM human_resource_staging
)
SELECT *
FROM human_resource_staging
;

CREATE TABLE `human_resource_staging2` (
  `ï»¿id` text,
  `first_name` text,
  `last_name` text,
  `birthdate` text,
  `gender` text,
  `race` text,
  `department` text,
  `jobtitle` text,
  `location` text,
  `hire_date` text,
  `termdate` text,
  `location_city` text,
  `location_state` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM human_resource_staging2
;

INSERT INTO human_resource_staging2
SELECT *,
ROW_NUMBER() 
OVER
(
PARTITION BY ï»¿id, birthdate, race, department, jobtitle, location, location_city, location_state
) AS row_num
FROM human_resource_staging
;

SELECT * 
FROM human_resource_staging2
WHERE row_num > 1
;

-- SINCE THERE IS NO DUPPLICATE,  WE CAN PROCEED TO STANDARDIZED THE TABLE
DESCRIBE human_resource_staging2;
-- RENAMING ID COLUMN AND FIXING ITS FORMAT 
ALTER TABLE human_resource_staging2
RENAME COLUMN ï»¿id TO employee_id 
;
ALTER TABLE human_resource_staging2
MODIFY COLUMN employee_id VARCHAR(50) PRIMARY KEY
;

-- FIXING THE FORMAT OF BIRTHDATE
SELECT `birthdate`, CASE 
WHEN `birthdate` LIKE "%/%" THEN date_format(STR_TO_DATE(`birthdate`, "%m/%d/%Y"),"%Y-%m-%d")
WHEN `birthdate`LIKE "%-%" THEN date_format(STR_TO_DATE(`birthdate`, "%m-%d-%Y"),"%Y-%m-%d")
ELSE NULL
END AS formatted_date
FROM human_resource_staging2
;

UPDATE human_resource_staging2
SET `birthdate` = CASE
    WHEN `birthdate` LIKE "%/%" THEN DATE_FORMAT(STR_TO_DATE(`birthdate`, '%m/%d/%Y'), "%Y-%m-%d") 
	WHEN `birthdate` LIKE "%-%" THEN DATE_FORMAT(STR_TO_DATE(`birthdate`, '%m-%d-%Y'), "%Y-%m-%d") 
ELSE NULL 
END
;

ALTER TABLE human_resource_staging2
MODIFY COLUMN birthdate date
;

SELECT *
FROM human_resource_staging2
;

-- FIXING THE FORMAT OF HIREDATE
SELECT `hire_date`, CASE
	WHEN `hire_date`LIKE "%/%" THEN DATE_FORMAT(STR_TO_DATE(`hire_date`, "%m/%d/%Y"), "%Y-%m-%d")
	WHEN `hire_date`LIKE "%-%" THEN DATE_FORMAT(STR_TO_DATE(`hire_date`, "%m-%d-%Y"), "%Y-%m-%d")
ELSE NULL
END AS formatted_hire_date
FROM human_resource_staging2
;


UPDATE human_resource_staging2
SET `hire_date` = CASE 
	WHEN `hire_date` LIKE "%/%" THEN DATE_FORMAT(STR_TO_DATE(`hire_date`, "%m/%d/%Y"), "%Y-%m-%d")
    WHEN `hire_date` LIKE "%-%" THEN DATE_FORMAT(STR_TO_DATE(`hire_date`, "%m-%d-%Y"), "%Y-%m-%d")
ELSE NULL
END
;

ALTER TABLE human_resource_staging2
MODIFY COLUMN hire_date date;

SELECT *
FROM human_resource_staging2
;
-- START OF UPDATING NULL AND BLANK VALUES
SELECT termdate
FROM human_resource_staging2
;
SELECT *
FROM human_resource_staging2
WHERE termdate = '' OR termdate IS NULL
;

UPDATE human_resource_staging2
SET `termdate` = IF(`termdate` IS NOT NULL AND termdate != '', DATE(STR_TO_DATE(`termdate`, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true
;
-- TO 
SET sql_mode = 'ALLOW_INVALID_DATES'
;
ALTER TABLE human_resource_staging2
MODIFY COLUMN termdate date
;

ALTER TABLE human_resource_staging2
ADD COLUMN age INT AFTER birthdate
;

SELECT birthdate, age
FROM human_resource_staging2
;

UPDATE human_resource_staging2
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURRENT_TIME)
;

-- REMOVING UNNECESSARY COLUMN
DESCRIBE human_resource_staging2
;
-- REMOVING ROW_NUM
ALTER TABLE human_resource_staging2
DROP row_num
;

SELECT *
FROM human_resource_staging2
;