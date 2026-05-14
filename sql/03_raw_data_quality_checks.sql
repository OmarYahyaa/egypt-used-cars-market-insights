/*
===============================================================================
Project: Egypt Used Cars Market Analysis
Script: 03_raw_data_quality_checks.sql
Purpose: Raw data quality checks before clean-layer design
Database: egypt_used_cars_db
Schema: raw
===============================================================================

This script profiles raw data quality before creating the clean layer.

It includes:
1. Summary checks for portfolio-ready quality findings.
2. Detailed investigation checks for suspicious values, duplicates, and manual review candidates.

No data is updated or cleaned in this script.
This file is used to understand raw data issues before defining clean-layer rules.
===============================================================================
*/


/*
===============================================================================
PART 1: RAW DATA QUALITY SUMMARY CHECKS
===============================================================================
*/

/*
===============================================================================
1. Row count checks
===============================================================================
*/

SELECT
    check_name,
    row_count,
    24688 AS expected_row_count,
    CASE
        WHEN row_count = 24688 THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM (
    SELECT
        'staging_table' AS check_name,
        COUNT(*) AS row_count
    FROM raw.stg_used_car_listings_aug_2025

    UNION ALL

    SELECT
        'final_raw_table' AS check_name,
        COUNT(*) AS row_count
    FROM raw.raw_used_car_listings_aug_2025
) AS row_counts;


/*
===============================================================================
2. Missing-value summary
Missing-like values checked: NULL, empty string, NA, N/A, UNKNOWN, -
===============================================================================
*/

WITH missing_counts AS (
    SELECT 
        'title' AS column_name,
         COUNT(*) AS total_number_of_missing
    FROM raw.raw_used_car_listings_aug_2025
    WHERE title IS NULL OR UPPER(TRIM(title)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'company',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE company IS NULL OR UPPER(TRIM(company)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'model',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE model IS NULL OR UPPER(TRIM(model)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'year',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE year IS NULL OR UPPER(TRIM(year)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'price',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE price IS NULL OR UPPER(TRIM(price)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'mileage',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE mileage IS NULL OR UPPER(TRIM(mileage)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'color',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE color IS NULL OR UPPER(TRIM(color)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'transmission',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE transmission IS NULL OR UPPER(TRIM(transmission)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'location',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE location IS NULL OR UPPER(TRIM(location)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'date_posted',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE date_posted IS NULL OR UPPER(TRIM(date_posted)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'features',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE features IS NULL OR UPPER(TRIM(features)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')

    UNION ALL
    SELECT 
        'detail_link',
         COUNT(*)
    FROM raw.raw_used_car_listings_aug_2025
    WHERE detail_link IS NULL OR UPPER(TRIM(detail_link)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
)
SELECT
    column_name,
    total_number_of_missing,
    ROUND(
        total_number_of_missing * 100.0
        / (SELECT COUNT(*) FROM raw.raw_used_car_listings_aug_2025),
        2
    ) AS missing_percent
FROM missing_counts
ORDER BY total_number_of_missing DESC, column_name;


/*
===============================================================================
3. Duplicate summary
===============================================================================
*/

SELECT
    'duplicate_detail_link' AS duplicate_check_type,
    COUNT(*) AS duplicate_groups,
    SUM(link_count - 1) AS extra_duplicate_rows
FROM (
    SELECT
        detail_link,
        COUNT(*) AS link_count
    FROM raw.raw_used_car_listings_aug_2025
    GROUP BY detail_link
    HAVING COUNT(*) > 1
) AS duplicate_links

UNION ALL

SELECT
    'exact_duplicate_record' AS duplicate_check_type,
    COUNT(*) AS duplicate_groups,
    SUM(duplicate_count - 1) AS extra_duplicate_rows
FROM (
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
        COUNT(*) AS duplicate_count
    FROM raw.raw_used_car_listings_aug_2025
    GROUP BY
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
        detail_link
    HAVING COUNT(*) > 1
) AS exact_duplicates;

/*
===============================================================================
4. Year quality summary
Valid manufacturing year profiling range: 1950 to 2026
===============================================================================
*/

WITH year_profile AS (
    SELECT
        year,
        CASE
            WHEN TRIM(year) ~ '^[0-9]+$'
            THEN CAST(TRIM(year) AS SMALLINT)
        END AS numeric_year
    FROM raw.raw_used_car_listings_aug_2025
)
SELECT
    COUNT(*) FILTER (
        WHERE year IS NULL
           OR TRIM(year) = ''
           OR UPPER(TRIM(year)) IN ('N/A', 'NA', 'UNKNOWN', '-')
    ) AS missing_year_count,

    COUNT(*) FILTER (
        WHERE year IS NOT NULL
          AND TRIM(year) <> ''
          AND UPPER(TRIM(year)) NOT IN ('N/A', 'NA', 'UNKNOWN', '-')
          AND TRIM(year) !~ '^[0-9]+$'
    ) AS non_numeric_year_count,

    COUNT(*) FILTER (WHERE numeric_year < 1950) AS years_before_1950,
    COUNT(*) FILTER (WHERE numeric_year > 2026) AS years_after_2026,
    COUNT(*) FILTER (
        WHERE numeric_year < 1950
           OR numeric_year > 2026
    ) AS invalid_year_count,
    MIN(numeric_year) AS minimum_numeric_year,
    MAX(numeric_year) AS maximum_numeric_year
FROM year_profile;

/*
===============================================================================
5. Price quality summary
Profiling thresholds:
- suspicious low price: price < 50,000 EGP
- suspicious high price: price > 20,000,000 EGP
===============================================================================
*/

WITH price_profile AS (
    SELECT
        raw_listing_id,
        title,
        company,
        model,
        year,
        price,
        CASE
            WHEN price IS NULL
              OR UPPER(TRIM(price)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
            THEN NULL
            ELSE TRIM(
                REPLACE(
                    REPLACE(UPPER(TRIM(price)), 'EGP', ''),
                    ',',
                    ''
                )
            )
        END AS cleaned_price_text
    FROM raw.raw_used_car_listings_aug_2025
),
numeric_price_profile AS (
    SELECT
        *,
        CASE
            WHEN cleaned_price_text ~ '^[0-9]+$'
            THEN cleaned_price_text::NUMERIC
        END AS price_egp
    FROM price_profile
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE price_egp IS NULL) AS missing_or_invalid_price_count,
    COUNT(*) FILTER (WHERE price ILIKE '%EGP%') AS contains_egp_count,
    COUNT(*) FILTER (WHERE price LIKE '%,%') AS contains_comma_count,
    COUNT(*) FILTER (
        WHERE cleaned_price_text IS NOT NULL
          AND cleaned_price_text !~ '^[0-9]+$'
    ) AS non_numeric_after_cleaning_count,
    COUNT(*) FILTER (WHERE price_egp < 50000) AS suspicious_low_price_count,
    COUNT(*) FILTER (WHERE price_egp > 20000000) AS suspicious_high_price_count,
    MIN(price_egp) AS minimum_price_egp,
    MAX(price_egp) AS maximum_price_egp
FROM numeric_price_profile;

/*
===============================================================================
6. Mileage quality summary
Profiling threshold:
- suspicious high mileage: mileage > 500,000 km
===============================================================================
*/

WITH mileage_profile AS (
    SELECT
        raw_listing_id,
        title,
        company,
        model,
        year,
        price,
        mileage,
        CASE
            WHEN mileage IS NULL
              OR UPPER(TRIM(mileage)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
            THEN NULL
            ELSE TRIM(
                REPLACE(
                    REPLACE(UPPER(TRIM(mileage)), 'KM', ''),
                    ',',
                    ''
                )
            )
        END AS cleaned_mileage_text
    FROM raw.raw_used_car_listings_aug_2025
),
numeric_mileage_profile AS (
    SELECT
        *,
        CASE
            WHEN cleaned_mileage_text ~ '^[0-9]+$'
            THEN cleaned_mileage_text::NUMERIC
        END AS mileage_km
    FROM mileage_profile
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE mileage_km IS NULL) AS missing_or_invalid_mileage_count,
    COUNT(*) FILTER (WHERE mileage ILIKE '%Km%') AS contains_km_count,
    COUNT(*) FILTER (WHERE mileage LIKE '%,%') AS contains_comma_count,
    COUNT(*) FILTER (
        WHERE cleaned_mileage_text IS NOT NULL
          AND cleaned_mileage_text !~ '^[0-9]+$'
    ) AS non_numeric_after_cleaning_count,
    COUNT(*) FILTER (WHERE mileage_km = 0) AS zero_mileage_count,
    COUNT(*) FILTER (WHERE mileage_km = 1) AS one_km_mileage_count,
    COUNT(*) FILTER (WHERE mileage_km > 500000) AS suspicious_high_mileage_count,
    MIN(mileage_km) AS minimum_mileage_km,
    MAX(mileage_km) AS maximum_mileage_km
FROM numeric_mileage_profile;

/*
===============================================================================
7. Transmission coverage
===============================================================================
*/

SELECT
    transmission,
    COUNT(*) AS total_number,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_used_car_listings_aug_2025), 2) AS percentage
FROM raw.raw_used_car_listings_aug_2025
GROUP BY transmission
ORDER BY total_number DESC;


/*
===============================================================================
8. Location quality summary
===============================================================================
*/

SELECT
    COUNT(*) FILTER (
        WHERE location IS NULL
           OR UPPER(TRIM(location)) IN ('', 'N/A', 'NA', 'UNKNOWN', '-')
    ) AS missing_like_location_count,
    COUNT(DISTINCT location) AS distinct_location_count
FROM raw.raw_used_car_listings_aug_2025;

/*
===============================================================================
9. Feature quality summary
===============================================================================
*/

WITH missing_features AS (
    SELECT
        COUNT(*) AS total_missing
    FROM raw.raw_used_car_listings_aug_2025
    WHERE features IS NULL
       OR UPPER(TRIM(features)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
)
SELECT
    COUNT(*) AS total_number_of_records,
    (SELECT total_missing FROM missing_features) AS total_missing,
    COUNT(*) - (SELECT total_missing FROM missing_features) AS total_non_missing,
    COUNT(*) FILTER (WHERE features LIKE '%|%') AS total_number_with_pipe_separator,
    (
        COUNT(*) - (SELECT total_missing FROM missing_features)
    ) - COUNT(*) FILTER (WHERE features LIKE '%|%') AS total_number_with_only_one_feature
FROM raw.raw_used_car_listings_aug_2025;

/*
===============================================================================
10. Source metadata checks
===============================================================================
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(raw_listing_id) AS generated_ids,
    COUNT(source_file_name) AS source_file_names,
    COUNT(loaded_at) AS loaded_timestamps
FROM raw.raw_used_car_listings_aug_2025;

SELECT DISTINCT
    source_file_name
FROM raw.raw_used_car_listings_aug_2025;


/*
===============================================================================
PART 2: DETAILED RAW DATA QUALITY INVESTIGATION CHECKS
===============================================================================

This section contains drill-down checks used to investigate the issues identified
in the summary checks.

These queries provide supporting evidence for:
- duplicated listing links
- exact duplicate records
- suspicious prices
- suspicious mileage values
- invalid manufacturing years
- suspicious location values
- feature-field structure

The purpose of this section is to support auditability and explain how data
quality decisions were made before designing the clean layer.
===============================================================================
*/

/*
A. Exact duplicate record details
*/

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
    COUNT(*) AS duplicate_count
FROM raw.raw_used_car_listings_aug_2025
GROUP BY
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
    detail_link
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


/*
B. Least 20 frequent locations
*/

SELECT
    location,
    COUNT(*) AS total_count
FROM raw.raw_used_car_listings_aug_2025
GROUP BY location
ORDER BY total_count ASC, location
LIMIT 20;

/*
C. Suspicious locations where location appears inside title
*/

SELECT
    raw_listing_id,
    title,
    location,
    COUNT(*) OVER () AS suspicious_location_rows
FROM raw.raw_used_car_listings_aug_2025
WHERE TRIM(location) <> ''
  AND title ILIKE '%' || location || '%'
ORDER BY location, raw_listing_id
LIMIT 100;


/*
D. Raw missing-like price values
*/

SELECT
    price,
    COUNT(*) AS row_count
FROM raw.raw_used_car_listings_aug_2025
WHERE price IS NULL
   OR UPPER(TRIM(price)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
GROUP BY price
ORDER BY row_count DESC;


/*
E. Raw missing-like mileage values
*/

SELECT
    mileage,
    COUNT(*) AS row_count
FROM raw.raw_used_car_listings_aug_2025
WHERE mileage IS NULL
   OR UPPER(TRIM(mileage)) IN ('', 'NA', 'N/A', 'UNKNOWN', '-')
GROUP BY mileage
ORDER BY row_count DESC;


/*
F. Full raw feature string distribution
*/

SELECT
    features,
    COUNT(*) AS total_count
FROM raw.raw_used_car_listings_aug_2025
GROUP BY features
ORDER BY total_count DESC;
