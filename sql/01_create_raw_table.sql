/*
===============================================================================
Project: Egypt Used Cars Market Analysis
Script: 01_create_raw_table.sql
Purpose: Create the raw landing table for the original used cars CSV file
Database: egypt_used_cars_db
Schema: raw
===============================================================================

Notes:
- This table stores the original CSV values with minimal transformation.
- All source columns from the CSV are stored as TEXT to preserve raw values.
- Metadata columns are added for traceability and auditing.
===============================================================================
*/


/*
===============================================================================
Create raw table
===============================================================================
*/

DROP TABLE IF EXISTS raw.raw_used_car_listings_aug_2025;

CREATE TABLE raw.raw_used_car_listings_aug_2025 (
    raw_listing_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Source columns from CSV
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
    detail_link TEXT,

    -- Metadata columns
    source_file_name TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
===============================================================================
Verification queries
Run these after creating the table to confirm the structure.
===============================================================================
*/

-- Check table columns and data types
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'raw_used_car_listings_aug_2025'
ORDER BY ordinal_position;
