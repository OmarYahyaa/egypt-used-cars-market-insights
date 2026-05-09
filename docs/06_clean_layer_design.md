# Clean Layer Design

| Field | Value |
|---|---|
| Project | Egypt Used Cars Market Analysis |
| Document | `docs/06_clean_layer_design.md` |
| Related SQL files | `sql/04_create_clean_table.sql`, `sql/05_insert_clean_data.sql` |
| Phase | Clean Layer Design |
| Status | Approved clean table design |

---

## 1. Purpose

This document defines the planned design for the clean layer of the Egypt Used Cars Market Analysis project.

The clean layer will transform the profiled raw data into a more reliable structure for analysis while preserving traceability back to the raw layer.

The goal of the clean layer is to:

- convert raw text values into analytical data types,
- preserve enough source evidence for auditability,
- make data quality issues explicit using flags,
- avoid deleting or hiding questionable records too early,
- prepare the dataset for business analysis queries.

---

## 2. Clean Table Name

The official clean table used for the main analysis is:

```sql
clean.clean_used_car_listings_aug_2025_v1
```

This table is created by:

```text
sql/04_create_clean_table.sql
```

and populated by:

```text
sql/05_insert_clean_data.sql
```

The clean table is derived from:

```sql
raw.raw_used_car_listings_aug_2025
```

---

## 3. Clean Layer Design Principle

The clean layer should not hide data quality problems.

Instead, it should create:

```text
raw/source value
+ cleaned analytical value
+ quality flag
```

Example:

```text
raw_price          = "1,640,000 EGP"
price_egp          = 1640000
price_quality_flag = valid_price
```

Another example:

```text
raw_price          = "-"
price_egp          = NULL
price_quality_flag = missing_price
```

This approach keeps the row available while clearly documenting whether the cleaned value is usable.

---

## 4. Traceability Columns

The clean table should keep traceability columns that connect cleaned records back to the original raw data.

| Column | Purpose |
|---|---|
| `raw_listing_id` | Links each clean row back to the raw table row. |
| `detail_link` | Original source listing reference; useful for duplicate checks and traceability. |
| `source_file_name` | Shows which source file the row came from. |
| `loaded_at` | Shows when the row was loaded into the database. |

The clean table keeps one clean row per raw row. Therefore, `raw_listing_id` can be used as the key link between the clean table and the raw table.

---

## 5. Source and Reference Fields to Keep

The clean table should not blindly duplicate every raw column, but it should keep important reference fields and selected raw messy fields for auditability.

### 5.1 Descriptive / Reference Fields

These fields are useful for analysis and identification:

```text
title
company
model
color
```

These values are not heavily transformed in the official clean table, so they can remain as descriptive fields.

### 5.2 Raw Messy Fields Kept for Audit

These fields are transformed or inspected in the clean layer, so the original raw values should be preserved beside the cleaned values:

```text
raw_year
raw_price
raw_mileage
raw_location
raw_features
raw_transmission
raw_date_posted
```

Example:

```text
raw_mileage          = "10,000,000 Km"
mileage_km           = 10000000
mileage_quality_flag = suspicious_high_mileage
```

This allows future reviewers to understand exactly how the cleaned value and flag were created.

---

## 6. New Cleaned Analytical Columns

| Clean Column | Source Column | Planned Data Type | Purpose |
|---|---|---|---|
| `manufacturing_year` | `year` | `SMALLINT` | Clean numeric manufacturing year. |
| `price_egp` | `price` | `NUMERIC` | Clean listed price in Egyptian pounds. |
| `mileage_km` | `mileage` | `NUMERIC` | Clean mileage in kilometers. |
| `clean_location` | `location` | `TEXT` | Cleaned location value for analysis. |
| `date_posted` | `date_posted` | `DATE` | Clean posting date. |

---

## 7. Quality Flags

Quality flags describe the status of cleaned values. They help analysis queries decide which rows are safe to include without deleting data too early.

Planned quality flags:

```text
year_quality_flag
price_quality_flag
mileage_quality_flag
location_quality_flag
date_quality_flag
duplicate_quality_flag
is_analysis_ready
```

---

## 8. Planned Flag Values

### 8.1 Year Quality Flag

| Flag Value | Meaning |
|---|---|
| `valid_year` | Year is numeric and within the accepted range. |
| `missing_year` | Year is missing-like. |
| `invalid_old_year` | Year is before the accepted minimum range. |
| `invalid_future_year` | Year is after the accepted maximum range. |
| `invalid_year_format` | Year is present but not numeric. |

Accepted profiling range:

```text
1950 to 2026
```

### 8.2 Price Quality Flag

| Flag Value | Meaning |
|---|---|
| `valid_price` | Price is present, numeric after cleaning, and not suspicious. |
| `missing_price` | Price is missing-like, such as `-`. |
| `invalid_price_format` | Price cannot be converted after cleaning. |
| `suspicious_low_price` | Price is below the profiling threshold. |
| `suspicious_high_price` | Price is above the profiling threshold. |

Profiling thresholds:

```text
suspicious low price  = price < 50,000 EGP
suspicious high price = price > 20,000,000 EGP
```

### 8.3 Mileage Quality Flag

| Flag Value | Meaning |
|---|---|
| `valid_mileage` | Mileage is present, numeric after cleaning, and not suspicious. |
| `missing_mileage` | Mileage is missing-like, such as `N/A`. |
| `invalid_mileage_format` | Mileage cannot be converted after cleaning. |
| `zero_mileage` | Mileage is exactly 0 km. |
| `one_km_mileage` | Mileage is exactly 1 km. |
| `suspicious_high_mileage` | Mileage is above the profiling threshold. |

Profiling threshold:

```text
suspicious high mileage = mileage > 500,000 km
```

### 8.4 Location Quality Flag

| Flag Value | Meaning |
|---|---|
| `valid_location` | Location appears usable. |
| `missing_location` | Location is missing-like. |
| `likely_model_in_location` | Location appears inside the title and may contain car model/title information. |

A rare location value is not automatically invalid. Rare locations should be reviewed, not blindly removed.

### 8.5 Date Quality Flag

| Flag Value | Meaning |
|---|---|
| `valid_date` | Date was successfully converted to a real date. |
| `missing_date` | Date is missing-like. |
| `invalid_date_format` | Date cannot be converted safely. |

### 8.6 Duplicate Quality Flag

| Flag Value | Meaning |
|---|---|
| `unique_detail_link` | The listing has a unique `detail_link`. |
| `duplicate_detail_link_keep_first` | First row within a duplicated `detail_link` group. |
| `duplicate_detail_link_extra_row` | Additional row in a duplicated `detail_link` group. |

### 8.7 Analysis Readiness Flag

`is_analysis_ready` should show whether a row is generally safe for core the official analysis.

Possible values:

```text
TRUE
FALSE
```

This flag should not replace column-level quality flags. It is only a convenience flag for broad analysis filtering.

---

## 9. Columns Excluded from Version 1 Analysis but Still Kept

### Transmission

The `transmission` column should be kept as:

```text
raw_transmission
```

But it should be excluded from Version 1 business analysis because 98.76% of rows are `N/A`.

This means:

```text
Keep in clean table for traceability.
Do not use as a main analytical dimension in Version 1.
```

---

## 10. Duplicate Handling Strategy

Duplicates should not be deleted blindly.

The clean layer should:

1. Keep all rows.
2. Use `detail_link` to identify duplicate groups.
3. Mark the first row per `detail_link` as the preferred row.
4. Mark extra rows as duplicate extras.
5. Let analysis queries exclude duplicate extra rows when needed.

The raw quality checks found:

| Duplicate Check Type | Duplicate Groups | Extra Duplicate Rows |
|---|---:|---:|
| duplicate_detail_link | 61 | 131 |
| exact_duplicate_record | 61 | 125 |

This means some repeated `detail_link` rows are not exact duplicates. Deleting them blindly could remove changed or useful information.

---

## 11. Invalid and Suspicious Value Handling

### 11.1 Price

Planned handling:

- Convert valid prices to `price_egp`.
- Convert `-` to `NULL`.
- Flag price below `50,000 EGP` as `suspicious_low_price`.
- Flag price above `20,000,000 EGP` as `suspicious_high_price`.
- Do not delete suspicious prices during clean table creation.

### 11.2 Mileage

Planned handling:

- Convert valid mileage values to `mileage_km`.
- Convert `N/A` to `NULL`.
- Flag `0 Km` as `zero_mileage`.
- Flag `1 Km` as `one_km_mileage`.
- Flag mileage above `500,000 km` as `suspicious_high_mileage`.
- Do not delete suspicious mileage values during clean table creation.

### 11.3 Year

Planned handling:

- Convert valid numeric years between `1950` and `2026` to `manufacturing_year`.
- Convert missing years to `NULL`.
- Convert invalid years outside the accepted range to `NULL`.
- Flag years before `1950` as `invalid_old_year`.
- Flag years after `2026` as `invalid_future_year`.

### 11.4 Location

Planned handling:

- Preserve the original value as `raw_location`.
- Create `clean_location`.
- If `location` appears inside `title`, flag it as `likely_model_in_location`.
- Do not assume that every rare location is invalid.
- Do not delete rows because of suspicious location values during clean table creation.

---

## 12. Future Upgrade Ideas Not Included in the Current Release

### 12.1 Manufacturer Country Enrichment

Add manufacturer country using a documented reference mapping table.

Example:

```text
Toyota -> Japan
BMW -> Germany
Chery -> China
BYD -> China
```

This could support a future analysis about Chinese car brands in the Egyptian used-car market.

### 12.2 Chinese Car Brand Analysis

A future analysis could focus on Chinese car brands in Egypt, especially because of the user's background as a Xiaomi test engineer.

This should be added only after the core SQL portfolio project is complete.

### 12.3 Advanced Feature Modeling

The `features` column contains list-like values separated by a pipe symbol.

Future modeling could split features into a separate table:

```text
raw_listing_id | feature_name
```

This should be considered later if feature-level analysis becomes important.

---

## 13. Approved Clean Layer Direction

The approved clean layer direction is:

```text
Do not delete first.
Preserve traceability.
Create cleaned analytical fields.
Create quality flags.
Let analysis queries decide what to include.
```

This keeps the project professional, auditable, and flexible.

---

## 14. Related Rulebook Principle

### Principle

The clean layer should not hide data quality problems; it should make them explicit with cleaned values and quality flags.

### Why this matters

Deleting or excluding rows too early can remove evidence and bias the analysis. Quality flags allow analysts to decide which rows are safe for each business question.

### How it appeared in the project

Price, mileage, year, location, and duplicates all had issues. Instead of deleting those rows immediately, the clean layer should preserve raw values, create cleaned columns, and add flags for missing, invalid, suspicious, or duplicated records.

---

---

## 15. Future Enhancement Note

A future clean-layer improvement could add more granular field-level quality flags and analysis-specific readiness flags.

During exploration, this idea revealed deeper parsing challenges, especially with multi-word brands such as Land Rover, Ssang Yong, Great Wall, and Alfa Romeo.

Because fully fixing these issues requires model-name normalization and title parsing, this work is documented separately as a future enhancement:

```text
docs/future_enhancements/clean_layer_v2_experiment.md
```

The current public release keeps the official clean table focused on the SQL analysis workflow.
