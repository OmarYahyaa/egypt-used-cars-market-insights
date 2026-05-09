# Raw Data Quality Findings

| Field | Value |
|---|---|
| Project | Egypt Used Cars Market Analysis |
| Document | `docs/05_raw_data_quality_findings.md` |
| Related SQL file | `sql/03_raw_data_quality_checks.sql` |
| Phase | Raw Data Quality Profiling |
| Status | Completed |

---

## 1. Purpose

This document summarizes the raw data quality findings from the imported Egypt used-cars dataset.

The goal of this phase was not to clean the data yet.  
The goal was to profile the raw data, understand its quality issues, and define what must be handled later in the clean layer.

The checks were performed on:

```sql
raw.raw_used_car_listings_aug_2025
```

---

## 2. Row Count Validation

The row count validation passed for both the staging table and the final raw table.

| Check | Row Count | Expected Row Count | Status |
|---|---:|---:|---|
| staging_table | 24,688 | 24,688 | PASS |
| final_raw_table | 24,688 | 24,688 | PASS |

### Interpretation

The imported data row count matches the expected dataset size. This confirms that no rows were lost between the CSV import into the staging table and the insert into the final raw table.

---

## 3. Missing-Value Findings

Missing-like values were checked using SQL `NULL`, empty strings, and text placeholders such as `N/A`, `NA`, `UNKNOWN`, and `-`.

| Column | Missing Count | Missing Percent |
|---|---:|---:|
| transmission | 24,381 | 98.76% |
| features | 7,818 | 31.67% |
| mileage | 1,410 | 5.71% |
| price | 109 | 0.44% |
| year | 6 | 0.02% |
| color | 0 | 0.00% |
| company | 0 | 0.00% |
| date_posted | 0 | 0.00% |
| detail_link | 0 | 0.00% |
| location | 0 | 0.00% |
| model | 0 | 0.00% |
| title | 0 | 0.00% |

### Interpretation

- `transmission` has very low coverage and should not be used for Version 1 business analysis.
- `features` is partially missing, but still potentially useful.
- `mileage` has moderate missingness and must be handled carefully in mileage-related analysis.
- `price` has a small number of missing-like values represented by `-`.
- Most core descriptive fields are fully populated.

---

## 4. Duplicate Findings

Two duplicate checks were performed:

| Duplicate Check Type | Duplicate Groups | Extra Duplicate Rows |
|---|---:|---:|
| duplicate_detail_link | 61 | 131 |
| exact_duplicate_record | 61 | 125 |

### Interpretation

`detail_link` is the strongest source identifier available in the dataset, but it is not fully unique.

There are:

- 61 duplicated `detail_link` groups.
- 131 extra rows based on repeated `detail_link` values.
- 61 exact duplicate record groups.
- 125 extra rows that are exact duplicate records.

This means not all repeated `detail_link` rows are exact duplicates. Some repeated links may have differences in one or more fields.

### Cleaning implication

Duplicate rows should not be removed blindly. A duplicate-handling rule should be defined later in the clean layer.

---

## 5. Year Quality Findings

The `year` column is stored as text in the raw table, so year quality was checked before conversion.

| Check | Result |
|---|---:|
| Missing year count | 6 |
| Non-numeric year count | 0 |
| Years before 1950 | 11 |
| Years after 2026 | 349 |
| Invalid year count | 360 |
| Minimum numeric year | 1100 |
| Maximum numeric year | 5008 |

### Interpretation

The `year` column is mostly numeric, but it contains unrealistic manufacturing years.

Examples of invalid year issues include:

- Very old years such as `1100`.
- Future years such as `5008`.

### Cleaning implication

In the clean layer, valid manufacturing years should be converted to numeric values, while missing or invalid years should be flagged or set to `NULL`.

---

## 6. Price Quality Findings

The raw `price` column contains text values such as:

```text
1,640,000 EGP
```

The price quality checks found:

| Check | Result |
|---|---:|
| Total rows | 24,688 |
| Missing-like price count | 109 |
| Values containing EGP | 24,579 |
| Values containing comma | 24,579 |
| Non-numeric after cleaning | 0 |
| Minimum numeric price | 1,111 |
| Maximum numeric price | 1,000,000,000 |
| Suspicious low price count `< 50,000 EGP` | 108 |
| Suspicious high price count `> 20,000,000 EGP` | 9 |

### Interpretation

Most price values follow the expected pattern of number + comma formatting + `EGP`.

However:

- 109 rows use `-` as a missing-like price value.
- The minimum price is suspiciously low.
- The maximum price is suspiciously high.
- Price is technically convertible after removing `EGP`, commas, and spaces, but it still requires business validation.

### Cleaning implication

In the clean layer:

- Convert valid price values to numeric.
- Treat `-` as missing-like.
- Flag suspicious low and high prices instead of deleting them immediately.

---

## 7. Mileage Quality Findings

The raw `mileage` column contains text values such as:

```text
58,000 Km
```

The mileage quality checks found:

| Check | Result |
|---|---:|
| Total rows | 24,688 |
| Missing-like mileage count | 1,410 |
| Values containing Km | 23,278 |
| Values containing comma | 23,047 |
| Non-numeric after cleaning | 0 |
| Minimum numeric mileage | 0 |
| Maximum numeric mileage | 10,000,000 |
| Zero mileage count | 131 |
| One km mileage count | 10 |
| Suspicious high mileage count `> 500,000 km` | 127 |

### Interpretation

Mileage is technically convertible after removing `Km`, commas, and spaces, but it still contains suspicious values.

Examples:

- `0 Km`
- `1 Km`
- Very high values such as `10,000,000 Km`

### Cleaning implication

In the clean layer:

- Convert valid mileage values to numeric.
- Treat `N/A` as missing-like.
- Flag suspicious mileage values for review.
- Avoid deleting suspicious mileage rows during profiling.

---

## 8. Transmission Findings

Transmission value distribution:

| Transmission | Row Count | Percent |
|---|---:|---:|
| N/A | 24,381 | 98.76% |
| Automatic | 195 | 0.79% |
| Manual | 111 | 0.45% |
| manual | 1 | 0.00% |

### Interpretation

The `transmission` column has very low coverage. Since 98.76% of rows are `N/A`, it is not reliable for Version 1 business analysis.

There is also a minor standardization issue:

```text
Manual
manual
```

### Cleaning implication

Keep `transmission` in the raw data for traceability, but exclude it from Version 1 analysis because coverage is too low.

---

## 9. Location Findings

Location checks found:

| Check | Result |
|---|---:|
| Missing-like location count | 0 |
| Distinct location count | 177 |
| Suspicious location rows where location appears inside title | 106 |

### Interpretation

The `location` column has no missing-like values, but it still has quality issues.

The top frequent locations looked mostly valid, such as:

- Cairo
- Tagamo3 - New Cairo
- 6 October
- Alexandria
- Nasr City
- Giza

However, rare location values revealed suspicious entries that appear to be car models or titles instead of real locations, such as:

- Volkswagen Tiguan
- Avatr 11
- Mercedes G63
- Mercedes Maybach
- BMW X6
- Hyundai Tucson

### Cleaning implication

In the clean layer:

- Preserve the original raw location.
- Create a cleaned location field.
- Flag values that appear to contain car model/title information.
- Do not assume that every rare location value is invalid.

---

## 10. Feature Findings

Feature quality checks found:

| Check | Result |
|---|---:|
| Total records | 24,688 |
| Missing features | 7,818 |
| Non-missing features | 16,870 |
| Rows with pipe separator `|` | 13,952 |
| Rows with only one feature | 2,918 |

### Interpretation

The `features` column is list-like. It may contain one feature or multiple features separated by a pipe symbol.

Example:

```text
Automatic | Air Conditioner | Power Steering | Remote Control
```

This means the column should not be treated as a simple single-value category if feature-level analysis is needed.

### Cleaning implication

In a future clean model, features may be split into a separate table, such as:

```text
raw_listing_id | feature_name
```

For Version 1, feature modeling should be considered carefully to avoid over-engineering.

---

## 11. Source Metadata Validation

Metadata validation passed.

| Check | Result |
|---|---:|
| total_rows | 24,688 |
| generated_ids | 24,688 |
| source_file_names | 24,688 |
| loaded_timestamps | 24,688 |

Distinct source file name:

```text
hatla2ee_cars_august_2025.csv
```

### Interpretation

Metadata validation proves that the raw load is complete, traceable, and auditable.

---

## 12. Overall Decision Before Cleaning

### Transmission

Exclude from Version 1 business analysis because 98.76% of rows are `N/A`. Keep it in the raw data for traceability.

### Price

Convert valid non-missing values to numeric in the clean layer. Treat `-` as missing-like and flag suspicious low/high prices instead of deleting them immediately.

### Mileage

Convert valid non-missing values to numeric in the clean layer. Treat `N/A` as missing-like and flag `0 Km`, `1 Km`, and very high mileage values for review.

### Year

Convert valid numeric years in the clean layer. Flag missing years and invalid manufacturing years outside the accepted range.

### Location

Preserve the raw location value, create a cleaned location field later, and flag suspicious values that appear to contain car model/title information.

### Features

Treat features as a list-like field. It may later be modeled as a separate listing-features table.

### Duplicates

Do not blindly remove duplicates. Define a duplicate-handling rule in the clean layer using `detail_link` and exact duplicate checks.

### Metadata

Metadata validation proves the raw load is complete, traceable, and auditable.

---

## 13. Main Data Quality Conclusion

The raw dataset is usable for a SQL portfolio project, but it requires a careful clean layer before analysis.

The most important cleaning needs are:

1. Convert price and mileage from text to numeric values.
2. Validate manufacturing years.
3. Handle missing-like values.
4. Flag suspicious price and mileage values.
5. Handle duplicate records carefully.
6. Exclude transmission from Version 1 business analysis.
7. Clean and validate location values.
8. Consider whether features should be modeled separately.

---

## 14. Related Rulebook Principle

### Principle

Profiling findings should not become deletion rules too early.

### Why this matters

Data quality profiling identifies problems, but cleaning rules require careful decisions. Deleting or excluding records too early can remove useful evidence and bias the analysis.

### How it appeared in the project

Price, mileage, year, and location had suspicious values. Instead of immediately excluding them, we will flag them in the clean layer and decide how each analysis should handle them.
