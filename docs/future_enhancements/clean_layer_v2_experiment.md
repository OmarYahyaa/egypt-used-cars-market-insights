# Clean Layer v2 Experiment

## Purpose

The v2 clean-layer experiment was created to improve the original clean table design by separating field-level quality from analysis-specific readiness.

The main idea was:

A row may be valid for one type of analysis but invalid for another.

For example:
- A row with a valid company but unknown model can still be used for company-level analysis.
- The same row should not be used for model-level benchmark analysis.

## What v2 Added

The v2 table added:
- raw descriptive fields
- clean descriptive fields
- descriptive-field quality flags
- analysis-specific readiness flags

Examples:
- `company_quality_flag`
- `model_quality_flag`
- `color_quality_flag`
- `transmission_quality_flag`
- `features_quality_flag`
- `is_company_analysis_ready`
- `is_model_analysis_ready`

## Main Discovery

The v2 experiment revealed parsing issues in multi-word company names.

Examples:
- `Land` + `Rover` should represent `Land Rover`
- `Ssang` + `Yong` should represent `Ssang Yong`
- `Great` + `Wall` should represent `Great Wall`
- `Alfa` + `Romeo` should represent `Alfa Romeo`

The company name could be standardized safely, but the model name required deeper parsing from the title.

Example:

`Land Rover Range Rover Sport 2022`

The original parsed values were:
- company = Land
- model = Rover

The correct interpretation is closer to:
- company = Land Rover
- model = Range Rover Sport

## Why v2 Was Not Adopted as the Official Analysis Table

The v2 experiment improved data quality visibility, but fully solving model parsing would require additional normalization work.

This was considered outside the current project scope because the main portfolio goal is to demonstrate:
- SQL analysis
- data cleaning
- dimensional modeling
- Power BI dashboarding

Therefore, v1 remains the official clean table for analysis, while v2 is documented as a future enhancement.

## Future Improvements

Future versions could include:
- a brand normalization lookup table
- a model normalization lookup table
- title parsing rules
- standardized model families and trims
- better handling of multi-word car names
