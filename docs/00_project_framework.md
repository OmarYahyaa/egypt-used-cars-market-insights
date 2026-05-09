# Project Framework

Project: Egypt Used Cars Market Analysis

## 1. Framework Summary

This project follows a SQL-first analytical workflow inspired by:

1. CRISP-DM thinking
2. Layered data architecture / medallion-style thinking
3. Portfolio-ready SQL project delivery

The goal is not to copy a framework name for decoration. The goal is to use a clear professional process that connects the business problem, raw data, data cleaning, modeling, analysis, and final communication.

## 2. Why This Framework Fits This Project

This project is designed as a first professional SQL-based data analysis portfolio project.

The main goals are to show that I can:

- Understand a business problem before writing SQL.
- Inspect raw data before importing it into a database.
- Preserve raw data safely.
- Design a raw table with traceability metadata.
- Clean and validate messy real-world data using SQL.
- Build analysis-ready tables or views.
- Answer business questions with SQL.
- Document decisions clearly.
- Present the project professionally on GitHub and LinkedIn.

## 3. CRISP-DM-Inspired Flow

CRISP-DM is used here as a project-thinking framework. In this project, it is adapted to a SQL-first analysis project.

### 3.1 Business Understanding

Purpose:
Define the project problem, audience, scope, and business questions.

Project implementation:
- Created `01_project_brief.md`
- Defined the primary audience as used-car buyers in Egypt with a limited budget.
- Defined the secondary audience as sellers who want to understand listed market prices.
- Defined the main business questions.

Project output:
- Clear project objective.
- Clear target audience.
- Clear Version 1 scope.

### 3.2 Data Understanding

Purpose:
Inspect the dataset before importing or cleaning it.

Project implementation:
- Created `02_raw_data_audit.md`
- Inspected rows, columns, data types, missing values, strange values, and duplicate indicators.
- Identified problems in price, mileage, year, location, features, transmission, and detail_link.

Project output:
- Raw data audit.
- List of data quality issues.
- Early cleaning direction.

### 3.3 Data Preparation

Purpose:
Prepare the database structure and cleaning strategy.

Project implementation:
- Created `03_raw_table_design.md`
- Designed the raw PostgreSQL table.
- Decided that source columns should be stored as TEXT in the raw layer.
- Added metadata columns for traceability.

Project output:
- Raw table design.
- Import strategy.
- Future cleaning direction.

### 3.4 Modeling / Structuring

Purpose:
Create clean and analysis-ready structures for the SQL analysis phase.

Project implementation:
- Created a clean table for validated analytical fields.
- Converted price, mileage, year, and date fields.
- Added data quality flags.
- Added an `is_analysis_ready` flag for broad analysis filtering.
- Documented feature modeling and deeper normalization as future improvements.

Project output:
- Official clean analysis table.
- Quality flags for important fields.
- Analysis-ready filtering logic.
- Future modeling ideas documented for the next phase.

### 3.5 Evaluation

Purpose:
Check whether the cleaned data and SQL analysis answer the original business questions.

Project implementation:
- Validate row counts before and after cleaning.
- Check missing values and invalid values.
- Compare business questions against final SQL outputs.
- Make sure no unsupported claims are made.

Project output:
- Data quality checks.
- Query validation.
- Clear limitations.

### 3.6 Communication / Deployment

Purpose:
Package and communicate the project professionally.

Project implementation:
- Final README case study.
- SQL files.
- Documentation files.
- LinkedIn post in Egyptian Arabic.
- Resume bullet points.
- Interview talking points.

Project output:
- GitHub portfolio project.
- LinkedIn post.
- Resume-ready project summary.

## 4. Layered Data Architecture Thinking

This project also uses a simple layered data structure inspired by medallion architecture.

### 4.1 Raw Layer

Purpose:
Preserve the original source data.

Project implementation:
- Table: `raw.raw_used_car_listings_aug_2025`
- Source columns stored as TEXT.
- Metadata columns added:
  - `raw_listing_id`
  - `source_file_name`
  - `loaded_at`

Key rule:
The raw layer should preserve evidence, not create perfect data.

### 4.2 Clean Layer

Purpose:
Create validated and analysis-ready fields.

Implemented examples:
- `price_egp`
- `mileage_km`
- `manufacturing_year`
- `date_posted`
- quality flags for invalid or suspicious values
- `is_analysis_ready` for safe broad analysis filtering

Key rule:
Cleaning should happen in documented SQL logic, not through manual Excel edits.

### 4.3 Analysis Layer

Purpose:
Answer business questions.

Implemented examples:
- Price patterns by manufacturing year.
- Price patterns by mileage category.
- Options available within buyer budget segments.
- Common company/model options by budget segment.
- Seller benchmark ranges using similar listings.
- Seller pricing zones based on urgency.

Key rule:
Analysis should answer the project questions, not become random SQL practice.

## 5. Project Workflow

The project workflow is:

1. Business Brief
   - Define problem, audience, scope, and business questions.

2. Raw Data Audit
   - Inspect the source file before importing.

3. Raw Table Design
   - Preserve original values and add metadata.

4. SQL Import
   - Load the CSV safely into PostgreSQL.

5. Data Quality Profiling
   - Measure missing values, duplicates, invalid years, outliers, and messy categories.

6. Cleaning Layer
   - Convert types, standardize values, and create quality flags.

7. Business Analysis
   - Write SQL queries that answer the approved business questions.

8. Documentation
   - Explain assumptions, decisions, limitations, and insights.

9. Portfolio Packaging
   - Prepare GitHub README, LinkedIn post, resume bullets, and interview talking points.

10. Future Data Modeling
   - Build dimensional modeling and Power BI structures in a later phase.

## 6. What This Framework Is Not

This workflow is not a strict official standard.

It is a practical project framework inspired by widely used industry practices.

The project should not claim:
"This project follows an official international standard."

Better wording:
"This project follows a SQL-first analytical workflow inspired by CRISP-DM and layered data architecture principles."

## 7. Recommended README Wording

This project follows a SQL-first analytical workflow inspired by CRISP-DM and layered data architecture principles. The workflow starts with business understanding, then raw data inspection, raw table design, SQL-based cleaning, analysis-ready structuring, business analysis, and final communication through GitHub documentation and LinkedIn.

## 8. Related Rulebook Principle

Principle:
Use industry frameworks as guidance, not decoration. A portfolio project should clearly show how business understanding, raw data, cleaning, modeling, analysis, and communication connect together.

Why this matters:
Framework names alone do not make a project professional. The value comes from applying the logic correctly and documenting each decision.

How it appeared in the project:
We used CRISP-DM-style thinking for the project flow and medallion-style layering for raw, cleaned, and analytical data, but adapted both to a SQL-first portfolio project.
