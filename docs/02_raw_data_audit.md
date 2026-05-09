# Raw Data Audit v1

**Project:** Egypt Used Cars Market Analysis  
**Dataset file:** `hatla2ee_cars_august_2025.csv`

## 1. File Overview

- Exact file name: `hatla2ee_cars_august_2025.csv`
- Number of rows: `24,688`
- Number of columns: `12`
- File opened in Excel: Not cleanly. Excel asked to convert the file and remove leading zeros.
- Action taken: Chose not to convert, to avoid silent changes to the raw data.

## 2. Column Names

The dataset contains the following columns:

1. `title`
2. `company`
3. `model`
4. `year`
5. `price`
6. `mileage`
7. `color`
8. `transmission`
9. `location`
10. `date_posted`
11. `features`
12. `detail_link`

## 3. Price Column Findings

- Example value: `1,640,000 EGP`
- Data type issue: Stored as text, not numeric.
- Formatting issues:
  - Contains commas.
  - Contains the currency word `EGP`.
- Missing values: Yes.
- Strange values noticed:
  - `1,000,000,000 EGP`

### Initial Interpretation

- Price needs SQL cleaning before analysis.
- Extremely high prices should be flagged as potential outliers, not deleted immediately.

## 4. Mileage Column Findings

- Example value: `58,000 Km`
- Data type issue: Stored as text, not numeric.
- Formatting issues:
  - Contains commas.
  - Contains the word `Km`.
- Missing / unavailable values:
  - Some rows contain `N/A`.
- Strange values noticed:
  - `0 Km`
  - `1 Km`

### Initial Interpretation

- Mileage needs SQL cleaning before analysis.
- Very low mileage values should be reviewed before deciding whether they are valid or suspicious.

## 5. Year Column Findings

- Minimum year noticed: `1100`
- Maximum year noticed: `5008`
- Strange values: Yes, many years are not realistic manufacturing years.

### Initial Interpretation

- Manufacturing year needs validation rules.
- Invalid years should be flagged and handled during the cleaning stage.

## 6. Date Posted Column Findings

- Example value from Excel display: `7/31/2025`
- Example value from raw CSV in Notepad++: `2025-08-01`
- Excel type: Treated/displayed as a converted date format.
- Raw CSV source format: Appears to be `YYYY-MM-DD`.
- Missing values: No missing values noticed.

### Validation Performed

- Excel displayed dates in a different format.
- The raw CSV was opened in Notepad++ to check the real stored value.
- The raw CSV showed values like `2025-08-01`.

### Initial Interpretation

- Excel should not be trusted as the only source for date format validation.
- The raw file is the source evidence.
- `date_posted` should be stored as `TEXT` in the raw PostgreSQL table to preserve the original value.
- `date_posted` can later be converted to `DATE` in the cleaned layer using the confirmed `YYYY-MM-DD` format.

## 7. Features Column Findings

- Example value: `Automatic | Air Conditioner | Power Steering | Remote Control`
- Structure: Text list separated by pipes.
- Usability:
  - Not directly usable as one clean analytical column.
  - Potentially useful if modeled as a separate feature table later.

### Initial Interpretation

- This column may represent a one-to-many relationship between listings and features.

## 8. Location Column Findings

- Example values:
  - `Nasr City`
  - `6-Oct`
- Structure: Mixed text.
- Problems noticed:
  - Some values appear to contain car model names instead of locations.

### Initial Interpretation

- Location needs cleaning and validation before being used in analysis.
- Raw location should be preserved.
- A cleaned location column may be created later.

## 9. Transmission Column Findings

- Problem noticed:
  - Transmission appears to contain mostly `N/A` values.
  - A small number of rows may still contain usable values such as `Automatic` or `Manual`.

### Initial Interpretation

- The column may have very low coverage and should be profiled before being used in analysis.
- It should still be kept in the raw table for traceability.

## 10. Detail Link Column Findings

### Initial Thought

- The column may not be useful for direct business analysis.

### Updated Finding

- Total rows: `24,688`
- Unique `detail_link` values: `24,557`
- Difference: `131` repeated `detail_link` values

### Initial Interpretation

- `detail_link` is useful for source traceability and duplicate detection.
- The repeated links may represent exact duplicate rows, repeated listings, changed records, or scraping issues.
- Further duplicate investigation is required before removing any rows.

## 11. Possible Duplicate Key

- No clean natural primary key was found in the raw dataset.
- `detail_link` is the strongest available source identifier, but it is not fully unique.

### Recommended Approach

- Create a generated internal `raw_listing_id` in PostgreSQL.
- Keep `detail_link` as a source reference field.
- Use `detail_link` later for duplicate checks.

## 12. Updated Data Quality Problems Noticed

- `price` is stored as text and contains commas and currency words.
- `mileage` is stored as text and contains commas and unit words.
- `year` contains invalid manufacturing years.
- `transmission` appears to be fully unavailable.
- `location` contains mixed values and possible wrong entries.
- `features` is a pipe-separated list that needs modeling if used.
- `detail_link` has duplicate values and should be investigated.
- `company` and `model` may need standardization because of repeated or inconsistent naming.
- Excel may display dates differently from the raw CSV source format.

## 13. Initial Cleaning Direction

The raw dataset should not be edited manually. The recommended workflow is:

1. Import the raw file into a PostgreSQL raw table with mostly text columns.
2. Preserve the original raw values.
3. Create cleaned/transformed tables using SQL.
4. Add validation flags for suspicious values.
5. Document every major cleaning decision.

## 14. Important Project Principles From This Audit

- Never let tools silently change raw data.
- Validate raw data in the raw file, not only through Excel display.
- When Excel and the raw file disagree, trust the raw file.
- Do not call a column useless too early.
- Strange values are not always wrong values.
- A messy list inside one column may represent a hidden one-to-many relationship.
- A surrogate key and a source key serve different purposes.
