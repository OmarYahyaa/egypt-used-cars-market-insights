# Raw Data Quality Checks Plan

**Project:** Egypt Used Cars Market Analysis  
**Planned SQL file:** `sql/03_raw_data_quality_checks.sql`  
**Current phase:** Raw data quality profiling  
**Status:** Planning document before writing SQL

---

## 1. Purpose

This document defines the planned raw data quality checks for the imported used-cars dataset.

The goal of this phase is **not to clean the data yet**.  
The goal is to measure and understand data quality problems in the raw layer before deciding cleaning rules.

The checks will be performed on:

```sql
raw.raw_used_car_listings_aug_2025
```

---

## 2. Important Principle

Raw data quality profiling answers this question:

> What problems exist in the raw data?

It does not answer:

> How should we clean the data?

Cleaning decisions will happen later in the clean layer after the raw problems are measured and documented.

---

## 3. Row Count Checks

### Checks to run

- Compare the expected CSV row count with the staging table row count.
- Compare the staging table row count with the final raw table row count.
- Confirm that the final raw table contains `24,688` rows.

### Expected values

```text
CSV rows      = 24,688
Staging rows  = 24,688
Raw rows      = 24,688
```

### Why this matters

This confirms that no rows were lost or accidentally added during the import process.

---

## 4. Missing-Value Checks

### Checks to run

For each important column, count:

- SQL `NULL` values
- Empty strings
- Text placeholders such as:
  - `N/A`
  - `NA`
  - `n/a`
  - `Unknown`

### Columns to check

- `title`
- `company`
- `model`
- `year`
- `price`
- `mileage`
- `color`
- `transmission`
- `location`
- `date_posted`
- `features`
- `detail_link`

### Why this matters

Because the raw table stores source columns as `TEXT`, missing values may not appear only as SQL `NULL`. They may also appear as text placeholders such as `N/A`.

---

## 5. Duplicate Checks

### Checks to run

- Count duplicate `detail_link` values.
- Find which `detail_link` values appear more than once.
- Check exact duplicate rows by grouping all source columns together.
- Compare duplicate source links with exact duplicate rows.

### Why this matters

A duplicated `detail_link` may indicate:

- exact duplicate rows
- repeated listings
- scraping duplication
- same listing captured more than once with changed attributes

Duplicate checks should identify the type of duplication before removing or excluding anything.

---

## 6. Year Quality Checks

### Checks to run

- Find minimum and maximum `year` values.
- Count non-numeric year values.
- Count suspicious or invalid years.
- Review years below a realistic minimum, such as `1950`.
- Review years above a realistic maximum, such as `2026`.

### Known issue from raw audit

The raw audit found unrealistic years such as:

```text
1100
5008
```

### Why this matters

The `year` column looks numeric, but the raw values are not always valid manufacturing years. This must be measured before converting the column to a numeric type in the clean layer.

---

## 7. Price Quality Checks

### Checks to run

- Count missing, empty, and `N/A` price values.
- Check whether prices contain the currency word `EGP`.
- Check whether prices contain commas.
- Check whether prices can be converted to numeric values after removing commas and `EGP`.
- Find minimum and maximum cleaned price values.
- Identify suspicious extreme prices.

### Known issue from raw audit

Example raw price value:

```text
1,640,000 EGP
```

Suspicious value noticed:

```text
1,000,000,000 EGP
```

### Why this matters

Price is one of the most important analysis fields. It must be validated carefully before being used in business questions.

---

## 8. Mileage Quality Checks

### Checks to run

- Count missing, empty, and `N/A` mileage values.
- Check whether mileage contains the unit `Km`.
- Check whether mileage contains commas.
- Check whether mileage can be converted to numeric values after removing commas and `Km`.
- Find minimum and maximum cleaned mileage values.
- Identify suspicious mileage values such as:
  - `0 Km`
  - `1 Km`
  - extremely high mileage values

### Known issue from raw audit

Example raw mileage value:

```text
58,000 Km
```

Suspicious values noticed:

```text
0 Km
1 Km
```

### Why this matters

Mileage is a key factor in used-car pricing, but it must be converted and validated before analysis.

---

## 9. Transmission Quality Checks

### Checks to run

- Count all distinct `transmission` values.
- Count how many rows contain `N/A`.
- Calculate the percentage of rows where transmission is unavailable.
- Decide later whether the column should be excluded from analysis.

### Known issue from raw audit

The `transmission` column appears to contain mostly `N/A` values and should be profiled before being used in analysis.

### Why this matters

A column should not be dropped emotionally. First, we measure how complete or incomplete it is, then decide whether it is useful for analysis.

---

## 10. Location Quality Checks

### Checks to run

- Count missing, empty, and `N/A` location values.
- Count distinct location values.
- Review the most frequent location values.
- Check whether location values are mixed between:
  - governorates
  - cities
  - areas
  - neighborhoods
- Look for suspicious values that may be car models or wrong scraped values instead of real locations.

### Known issue from raw audit

Some location values appear to contain car model names instead of locations.

### Why this matters

Location may help answer whether geographic location affects listed price, but it must be validated because the field may contain mixed or incorrect values.

---

## 11. Feature Quality Checks

### Checks to run

- Count missing, empty, and `N/A` feature values.
- Count how many rows contain the pipe separator `|`.
- Review common raw feature strings.
- Estimate whether the column can later be split into a separate feature table.

### Known feature structure

Example raw feature value:

```text
Automatic | Air Conditioner | Power Steering | Remote Control
```

### Why this matters

The `features` column is not clean as one analytical field, but it may contain useful one-to-many information.

A future clean model may represent it like this:

```text
listing_id | feature_name
1          | Automatic
1          | Air Conditioner
1          | Power Steering
1          | Remote Control
```

This will be decided later after profiling.

---

## 12. Source Metadata Checks

### Checks to run

- Count total rows.
- Count non-null `raw_listing_id` values.
- Count non-null `source_file_name` values.
- Count non-null `loaded_at` values.
- Check distinct `source_file_name` values.
- Confirm that all rows came from:

```text
hatla2ee_cars_august_2025.csv
```

### Expected values

```text
total_rows          = 24,688
generated_ids       = 24,688
source_file_names   = 24,688
loaded_timestamps   = 24,688
```

### Why this matters

Metadata confirms that the raw load was traceable and complete.

---

## 13. Source Website Context

The dataset was collected from Hatla2ee.

Exploring the source website can help understand how fields may have been structured, such as:

- brands
- models
- prices
- mileage
- year
- location
- filters
- listing details

However, source-system understanding does **not** replace data validation.

Even if the website appears to use structured filters or dropdowns, the downloaded dataset can still contain:

- missing values
- duplicated listings
- parsing errors
- misplaced fields
- invalid years
- inconsistent locations
- text-formatted numeric values

### Decision

Source website understanding will be treated as a small context note inside the data quality phase, not as a separate large phase.

The actual PostgreSQL data remains the source of truth for validation.

---

## 14. Planned Output of Raw Data Quality SQL File

The raw data quality SQL file should produce checks for:

1. Row counts
2. Missing values
3. Duplicate `detail_link` values
4. Exact duplicate rows
5. Year quality
6. Price quality
7. Mileage quality
8. Transmission availability
9. Location quality
10. Feature structure
11. Source metadata completeness

---

## 15. Related Rulebook Principle

### Principle

Source-system understanding can guide data quality expectations, but it cannot replace validation on the actual dataset.

### Why this matters

A website may use dropdowns, filters, or structured fields, but the exported or scraped dataset can still contain missing values, duplicates, parsing errors, or misplaced fields.

### How it appeared in the project

Hatla2ee appears to use structured car listing fields and filters, but the downloaded dataset still contains invalid years, duplicated `detail_link` values, text-formatted prices, text-formatted mileage, and possible location issues. So the website is used only as context, while validation is performed on the actual PostgreSQL data.

---

## 16. Related SQL File

After this plan was approved, the raw data quality checks were implemented in:

```text
sql/03_raw_data_quality_checks.sql
```

The file contains both:
- high-level portfolio-ready summary checks,
- detailed drill-down investigation queries for suspicious values, duplicate records, and manual review candidates.
