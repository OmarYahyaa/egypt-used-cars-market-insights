/*
===============================================================================
Project: Egypt Used Cars Market Analysis
Script: 04_create_clean_table.sql
Purpose: Create the clean listing table based on the approved clean layer design
Database: egypt_used_cars_db
Schema: clean
===============================================================================

Notes:
- The clean table keeps one row per raw listing row.
- raw_listing_id is used as the primary key and traceability link to the raw table.
- Raw messy values are preserved for auditability.
- Clean analytical columns are created for analysis.
- Quality flags make data quality issues explicit instead of hiding them.
===============================================================================
*/


/*
===============================================================================
Create clean table
===============================================================================
*/

DROP TABLE IF EXISTS clean.clean_used_car_listings_aug_2025_v1;

CREATE TABLE clean.clean_used_car_listings_aug_2025_v1 (
    /*
    ---------------------------------------------------------------------------
    Traceability columns
    ---------------------------------------------------------------------------
    */
    raw_listing_id BIGINT PRIMARY KEY
        REFERENCES raw.raw_used_car_listings_aug_2025 (raw_listing_id),

    detail_link TEXT,
    source_file_name TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL,

    /*
    ---------------------------------------------------------------------------
    Descriptive / reference columns
    ---------------------------------------------------------------------------
    */
    title TEXT,
    company TEXT,
    model TEXT,
    color TEXT,

    /*
    ---------------------------------------------------------------------------
    Raw messy fields kept for audit
    ---------------------------------------------------------------------------
    */
    raw_year TEXT,
    raw_price TEXT,
    raw_mileage TEXT,
    raw_location TEXT,
    raw_features TEXT,
    raw_transmission TEXT,
    raw_date_posted TEXT,

    /*
    ---------------------------------------------------------------------------
    Clean analytical columns
    ---------------------------------------------------------------------------
    */
    manufacturing_year SMALLINT,
    price_egp NUMERIC,
    mileage_km NUMERIC,
    clean_location TEXT,
    date_posted DATE,

    /*
    ---------------------------------------------------------------------------
    Quality flag columns
    ---------------------------------------------------------------------------
    */
    year_quality_flag TEXT,
    price_quality_flag TEXT,
    mileage_quality_flag TEXT,
    location_quality_flag TEXT,
    date_quality_flag TEXT,
    duplicate_quality_flag TEXT,
    is_analysis_ready BOOLEAN,

    /*
    ---------------------------------------------------------------------------
    Clean layer metadata
    ---------------------------------------------------------------------------
    */
    cleaned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
===============================================================================
Verification query
Run this after creating the table to confirm the structure.
===============================================================================
*/

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'clean'
  AND table_name = 'clean_used_car_listings_aug_2025_v1'
ORDER BY ordinal_position;
