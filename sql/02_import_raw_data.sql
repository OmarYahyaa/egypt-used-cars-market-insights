/*
===============================================================================
Project: Egypt Used Cars Market Analysis
Script: 02_import_raw_data.sql
Purpose: Import the original CSV into a staging table, then load it into the
         final raw table with metadata.
Database: egypt_used_cars_db
Schema: raw
===============================================================================

Workflow:
1. Create a staging table that matches the CSV structure exactly.
2. Import the CSV into the staging table using pgAdmin Import/Export.
3. Insert staging data into the final raw table.
4. Add source_file_name during the insert.
5. Let PostgreSQL generate raw_listing_id and loaded_at automatically.
6. Validate row counts and metadata completeness.

Source file:
hatla2ee_cars_august_2025.csv
===============================================================================
*/


/*
===============================================================================
Step 1: Create staging table
This table matches the CSV file exactly.
It contains only the 12 source columns from the file.
===============================================================================
*/

DROP TABLE IF EXISTS raw.stg_used_car_listings_aug_2025;

CREATE TABLE raw.stg_used_car_listings_aug_2025 (
    title TEXT,
    company TEXT,
    model TEXT,
    year TEXT,
    price TEXT,
    mileage TEXT,
    color TEXT,
    transmission TEXT,
    location TEXT,
    date_posted TEXT,
    features TEXT,
    detail_link TEXT
);


/*
===============================================================================
Step 2: Import CSV into staging table

Use pgAdmin Import/Export to import the CSV into:
raw.stg_used_car_listings_aug_2025

Recommended import settings:
- Header: ON
- Delimiter: comma
- Encoding: UTF-8
- Quote: "
- Escape: "

Important:
Do not import the CSV directly into raw.raw_used_car_listings_aug_2025.
The final raw table contains metadata columns that do not exist in the CSV.
===============================================================================
*/


/*
===============================================================================
Step 3: Validate staging import row count
Expected result:
24,688 rows
===============================================================================
*/

SELECT COUNT(*) AS staging_row_count
FROM raw.stg_used_car_listings_aug_2025;


/*
===============================================================================
Step 4: Insert staging data into the final raw table

Notes:
- raw_listing_id is GENERATED ALWAYS AS IDENTITY, so it is not included.
- loaded_at has DEFAULT NOW(), so it is not included.
- source_file_name is added manually because it does not exist in the CSV.
-- Important:
-- Run this insert only once after creating the raw table.
-- If re-running the full import process, recreate or truncate the final raw table first.
===============================================================================
*/

INSERT INTO raw.raw_used_car_listings_aug_2025 (
    title,
    company,
    model,
    year,
    price,
    mileage,
    color,
    transmission,
    location,
    date_posted,
    features,
    detail_link,
    source_file_name
)
SELECT
    title,
    company,
    model,
    year,
    price,
    mileage,
    color,
    transmission,
    location,
    date_posted,
    features,
    detail_link,
    'hatla2ee_cars_august_2025.csv' AS source_file_name
FROM raw.stg_used_car_listings_aug_2025;


/*
===============================================================================
Step 5: Validate final raw table row count
Expected result:
24,688 rows
===============================================================================
*/

SELECT COUNT(*) AS raw_row_count
FROM raw.raw_used_car_listings_aug_2025;


/*
===============================================================================
Step 6: Validate metadata completeness
Expected result for each column:
24,688
===============================================================================
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(raw_listing_id) AS generated_ids,
    COUNT(source_file_name) AS source_file_names,
    COUNT(loaded_at) AS loaded_timestamps
FROM raw.raw_used_car_listings_aug_2025;


/*
===============================================================================
Step 7: Validate source file name
Expected result:
hatla2ee_cars_august_2025.csv
===============================================================================
*/

SELECT DISTINCT source_file_name
FROM raw.raw_used_car_listings_aug_2025;
