# Clean Data Validation Findings

| Field | Value |
|---|---|
| Project | Egypt Used Cars Market Analysis |
| Document | `docs/07_clean_data_validation_findings.md` |
| Related SQL file | `sql/05_insert_clean_data.sql` |
| Phase | Clean Data Validation |
| Status | Passed |

---

## 1. Purpose

This document summarizes the validation results after inserting transformed data into the clean layer.

The clean insert process transformed raw source values into analysis-ready fields, preserved selected raw values for auditability, and created quality flags to identify valid, missing, suspicious, invalid, and duplicated records.

The validation was performed on:

```sql
clean.clean_used_car_listings_aug_2025_v1
```

---

## 2. Row Count Validation

| Table | Row Count |
|---|---:|
| raw.raw_used_car_listings_aug_2025 | 24,688 |
| clean.clean_used_car_listings_aug_2025_v1 | 24,688 |

### Interpretation

The clean table row count matches the raw table row count.

This confirms that no rows were lost during the clean insert process. The clean layer preserves one row per raw listing.

---

## 3. Analysis Readiness

| Status | Row Count |
|---|---:|
| analysis_ready | 22,423 |
| not_ready | 2,265 |

### Interpretation

22,423 rows are broadly ready for official analysis.

2,265 rows are preserved in the clean table but should be excluded from broad analysis unless a specific analysis requires them.

A row is marked as analysis-ready only when the key quality checks pass:

- valid price,
- valid mileage,
- valid year,
- valid location,
- valid date,
- not an extra duplicate row.

This keeps the data flexible while protecting the main analysis from known quality issues.

---

## 4. Duplicate Quality Validation

| Duplicate Quality Flag | Row Count |
|---|---:|
| unique_detail_link | 24,496 |
| duplicate_detail_link_extra_row | 131 |
| duplicate_detail_link_keep_first | 61 |

### Interpretation

The duplicate flag logic successfully identified rows with unique source listing links, the first row in each duplicated `detail_link` group, and extra rows inside duplicated `detail_link` groups.

The clean table does not delete duplicate rows. It flags them so analysis queries can exclude extra duplicate rows when needed.

---

## 5. Price Quality Validation

| Price Quality Flag | Row Count |
|---|---:|
| valid_price | 24,462 |
| missing_price | 109 |
| suspicious_low_price | 108 |
| suspicious_high_price | 9 |

### Interpretation

Most rows have valid cleaned prices.

The clean layer handled price values by preserving the original value as `raw_price`, removing `EGP`, commas, and spaces, converting valid values into `price_egp`, converting missing-like values such as `-` to `NULL`, and flagging suspicious low and high prices.

Suspicious prices are not deleted. They are kept and flagged for controlled analysis decisions.

---

## 6. Mileage Quality Validation

| Mileage Quality Flag | Row Count |
|---|---:|
| valid_mileage | 23,010 |
| missing_mileage | 1,410 |
| zero_mileage | 131 |
| suspicious_high_mileage | 127 |
| one_km_mileage | 10 |

### Interpretation

Most rows have valid cleaned mileage values.

The clean layer handled mileage values by preserving the original value as `raw_mileage`, removing `Km`, commas, and spaces, converting valid values into `mileage_km`, converting missing-like values such as `N/A` to `NULL`, and flagging zero, one-kilometer, and very high mileage values.

Suspicious mileage values are kept in the clean table but can be excluded from specific analysis queries.

---

## 7. Year Quality Validation

| Year Quality Flag | Row Count |
|---|---:|
| valid_year | 24,322 |
| invalid_future_year | 349 |
| invalid_old_year | 11 |
| missing_year | 6 |

### Interpretation

Most rows have valid manufacturing years.

The clean layer handled year values by preserving the original value as `raw_year`, converting valid years into `manufacturing_year`, setting missing or invalid years to `NULL`, and flagging future years and unrealistically old years.

Invalid years are not stored in the analytical `manufacturing_year` column. The quality flag preserves the reason the cleaned value became `NULL`.

---

## 8. Date Quality Validation

| Date Quality Flag | Row Count |
|---|---:|
| valid_date | 24,688 |

### Interpretation

All rows have valid `date_posted` values.

The raw date values followed the `YYYY-MM-DD` format and were successfully converted into a clean `DATE` column.

---

## 9. Location Quality Validation

| Location Quality Flag | Row Count |
|---|---:|
| valid_location | 24,582 |
| likely_model_in_location | 106 |

### Interpretation

Most rows have valid cleaned location values.

The clean layer preserved the original location as `raw_location` and created `clean_location`.

Rows were flagged as `likely_model_in_location` when the location value appeared inside the listing title, suggesting that the location field may contain car model or title information instead of a geographic location.

Those rows were not deleted. Their `clean_location` value was set to `NULL`, and the reason was preserved in the location quality flag.

---

## 10. Metadata Validation

| Metadata Check | Result |
|---|---|
| source_file_name | hatla2ee_cars_august_2025.csv |
| loaded_at | 2026-04-28 19:57:26.030945+03 |
| cleaned_at | populated automatically by PostgreSQL |

### Interpretation

Metadata validation confirms that the clean table remains traceable.

- `source_file_name` identifies the original CSV file.
- `loaded_at` preserves the raw load timestamp.
- `cleaned_at` records when the row entered the clean layer.

This supports auditability across the raw and clean layers.

---

## 11. Final Decision Before Analysis

The clean table is ready for official analysis.

Recommended default analysis filter:

```sql
WHERE is_analysis_ready = TRUE
```

This filter should be used for broad market analysis because it excludes rows with major quality issues, such as invalid or suspicious price, invalid or suspicious mileage, invalid year, likely bad location, and extra duplicate rows.

However, the excluded rows are still preserved in the clean table. They can be used later for data quality reporting or special investigation.

---

## 12. Main Clean Data Conclusion

The clean insert process passed validation.

The project now has:

- a raw table that preserves source evidence,
- a clean table with analytical fields,
- quality flags explaining data issues,
- an `is_analysis_ready` flag for safe official analysis,
- full traceability back to the source data.

This completes the clean data transformation and validation phase.

---

## 13. Related Rulebook Principle

### Principle

A clean table should make data quality decisions explicit, not invisible.

### Why this matters

If suspicious, invalid, missing, or duplicated rows are silently deleted or overwritten, the analysis becomes harder to audit and trust.

### How it appeared in the project

The clean used-cars table preserved all 24,688 raw rows, created clean analytical columns, and added flags for price, mileage, year, date, location, duplicates, and analysis readiness.

---

## 14. Future Enhancement Note

The official validation findings in this document are based on:

```sql
clean.clean_used_car_listings_aug_2025_v1
```

A future clean-layer enhancement may add more granular field-level quality flags and analysis-specific readiness flags. That work is documented separately in:

```text
docs/future_enhancements/clean_layer_v2_experiment.md
```

The current public release keeps this document focused on the official clean table used for the main SQL analysis.
