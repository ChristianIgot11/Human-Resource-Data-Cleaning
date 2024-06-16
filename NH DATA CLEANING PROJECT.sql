USE housingdata_db;

-- DATA CLEANING
-- STANDARDIZING EVERY COLUMN
-- UPDATING NULL AND BLANK VALUES
-- REMOVING DUPLICATES
-- REMOVING UNNNECESSARY ROW


SELECT *
FROM nashville_housing_data_2013_2016
;

CREATE TABLE housing_data
LIKE nashville_housing_data_2013_2016;

SELECT *
FROM housing_data;

INSERT INTO housing_data
SELECT *
FROM nashville_housing_data_2013_2016;

-- STANDARDIZING THE DATA
SELECT DISTINCT(`Land Use`)
FROM housing_data;

-- VACANT RESIENTIAL LAND
-- VACANT RES LAND

UPDATE housing_data
SET `Land Use` = 'VACANT RESIDENTIAL LAND'
WHERE `Land Use`= 'VACANT RESIENTIAL LAND' 
;
UPDATE housing_data
SET `Land Use` = 'VACANT RESIDENTIAL LAND'
WHERE `Land Use`= 'VACANT RES LAND' 
;

ALTER TABLE housing_data
MODIFY COLUMN `Sale Date` DATE;

SELECT *
FROM housing_data;

ALTER TABLE housing_data
RENAME COLUMN `Unnamed: 0` TO unique_id;

-- UPDATING NULL AND BLANK VALUES
SELECT *
FROM housing_data
WHERE `Property Address` = '';

UPDATE housing_data
SET `Property Address` = NULL
WHERE `Property Address` = ''
;
SELECT a.`Property Address`, a.`Parcel ID`, b.`Property Address`, b.`Parcel ID` 
FROM housing_data AS a
INNER JOIN housing_data AS b
	ON a.`Parcel ID` = b.`Parcel ID`
    AND a.`unique_id` != b.`unique_id`
WHERE a.`Property Address` IS NULL; 
;
UPDATE housing_data AS a
INNER JOIN housing_data AS b
	ON a.`Parcel ID` = b.`Parcel ID`
    AND a.`unique_id` != b.`unique_id`
    SET a.`Property Address` = b.`Property Address`
WHERE a.`Property Address` IS NULL; 
;
-- SPLITTING COLUMN
SELECT owner_address,
TRIM(SUBSTRING_INDEX(`owner_address`, ',', 1)) AS address,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`owner_address`, ' ,', 2),',', '-1')) AS city,
TRIM(SUBSTRING_INDEX(`owner_address`, ',', '-1')) AS state
FROM housing_data;

ALTER TABLE housing_data
ADD COLUMN address VARCHAR (50) AFTER owner_address,
ADD COLUMN city VARCHAR (50) AFTER address,
ADD COLUMN state VARCHAR (50) AFTER city;

UPDATE housing_data
SET `address` = TRIM(SUBSTRING_INDEX(`owner_address`, ',', 1)),
	`city` = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`owner_address`, ',', 2), ',', -1)),
	`state` = TRIM(SUBSTRING_INDEX(`owner_address`, ',', '-1'));
    
SELECt `Sold As Vacant`
FROM housing_data 
WHERE `Sold As Vacant` = 'N'
;

SELECT `Sold As Vacant`, CASE 
	WHEN `Sold As Vacant` = 'Y' THEN 'YES'
	WHEN `Sold As Vacant` = 'N' THEN 'NO'
ELSE `Sold As Vacant`
END
FROM housing_data;

UPDATE housing_data
SET `Sold As Vacant` = CASE 
	WHEN `Sold As Vacant` = 'Y' THEN 'YES'
	WHEN `Sold As Vacant` = 'N' THEN 'NO'
ELSE `Sold As Vacant`
END
;

-- REMOVING DUPLICATES
SELECT *, ROW_NUMBER() OVER
(
PARTITION BY `Parcel ID`, `Property Address`, `Sale Date`, `Sale Price`, `Legal Reference`
) AS row_num
FROM housing_data;

WITH CTE_duplicate AS (
SELECT *, ROW_NUMBER() OVER
(
PARTITION BY `Parcel ID`, `Property Address`, `Sale Date`, `Sale Price`, `Legal Reference`
) AS row_num
FROM housing_data
)
SELECT *
FROM CTE_duplicate
WHERE row_num > 1
;

CREATE TABLE `housing_data2` (
  `MyUnknownColumn` int DEFAULT NULL,
  `unique_id` int DEFAULT NULL,
  `Parcel ID` text,
  `Land Use` text,
  `Property Address` text,
  `Suite/ Condo   #` text,
  `Property City` text,
  `Sale Date` date DEFAULT NULL,
  `Sale Price` int DEFAULT NULL,
  `Legal Reference` text,
  `Sold As Vacant` text,
  `Multiple Parcels Involved in Sale` text,
  `Owner Name` text,
  `owner_address` varchar(250) DEFAULT NULL,
  `address` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `Acreage` text,
  `Tax District` text,
  `Neighborhood` text,
  `image` text,
  `Land Value` text,
  `Building Value` text,
  `Total Value` text,
  `Finished Area` text,
  `Foundation Type` text,
  `Year Built` text,
  `Exterior Wall` text,
  `Grade` text,
  `Bedrooms` text,
  `Full Bath` text,
  `Half Bath` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM housing_data2;

INSERT INTO housing_data2
SELECT *, ROW_NUMBER() OVER
(
PARTITION BY `Parcel ID`, `Property Address`, `Sale Date`, `Sale Price`, `Legal Reference`
) AS row_num
FROM housing_data;

SELECT *
FROM housing_data2
WHERE row_num > 1
;
DELETE FROM housing_data2
WHERE row_num > 1;

-- REMOVING UNNECESSARY COLUMNS
SELECT *
FROM housing_data2;

ALTER TABLE housing_data2
DROP COLUMN MyUnknownColumn,
DROP COLUMN `Property Address`,
DROP COLUMN `Owner Name`,
DROP COLUMN `owner_address`;

-- END





