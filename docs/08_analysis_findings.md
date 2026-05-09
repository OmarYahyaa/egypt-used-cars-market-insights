# 08 Analysis Findings

## Purpose

This document summarizes the main analysis findings from the Egypt Used Cars Market Analysis project.

The goal is to translate SQL results into business meaning for buyers and sellers.

## Default Analysis Filter

Unless stated otherwise, analysis uses only rows marked as analysis-ready:

```sql
WHERE is_analysis_ready = TRUE
```

The analysis-ready dataset contains **22,423 rows**.

## Important Limitation

This project analyzes **listed asking prices**, not confirmed sold prices.

Therefore, the findings should be interpreted as marketplace listing benchmarks, not guaranteed fair market values or confirmed transaction prices.

---

# Q1. How does listed price vary by manufacturing year?

## Key Finding

Listed prices generally increase as manufacturing year becomes newer. However, the relationship is not perfectly linear.

The dataset includes manufacturing years from 1972 to 2026. The year 2021 has the highest number of listings, with 1,668 cars. The year 2015 has the widest listed-price gap, with a spread of 16,340,000 EGP between the minimum and maximum listed prices.

Very old manufacturing years show more irregular pricing patterns. This may be due to low listing counts, model differences, condition differences, rarity, or unusual listings. Therefore, manufacturing year alone is not enough to explain listed price.

### Data Quality / Scope Note

The wide price gap was treated as an analysis signal, not as an automatic cleaning rule.

During the project, I investigated whether some unusual results were caused by source data limitations such as extreme listed prices, inconsistent company/model naming, and multi-word brand parsing.

A deeper clean-layer v2 idea was explored to handle field-specific readiness and company/model normalization. However, this was scoped as future work because fully solving it would require a separate normalization layer and title-parsing rules.

For the current release, the analysis keeps source-listed company/model values for transparency and focuses on documented, analysis-ready records.


## Evidence From Result

The manufacturing years in the analysis range from 1972 to 2026.

Example boundary years:

| Manufacturing year | Listings | Minimum price | Average price | Median price | Maximum price | Price gap |
|---:|---:|---:|---:|---:|---:|---:|
| 1972 | 1 | 60,000 | 60,000 | 60,000 | 60,000 | 0 |
| 2026 | 5 | 725,000 | 1,098,000 | 790,000 | 2,200,000 | 1,475,000 |

The most listed manufacturing year is 2021:

| Manufacturing year | Listings | Minimum price | Average price | Median price | Maximum price | Price gap |
|---:|---:|---:|---:|---:|---:|---:|
| 2021 | 1,668 | 79,000 | 1,214,235 | 940,000 | 9,250,000 | 9,171,000 |

The widest price gap appears in 2015:

| Manufacturing year | Listings | Minimum price | Average price | Median price | Maximum price | Price gap |
|---:|---:|---:|---:|---:|---:|---:|
| 2015 | 1,298 | 160,000 | 706,264 | 600,000 | 16,500,000 | 16,340,000 |

Older years such as 1972, 1973, 1976, and 1978 have very small listing counts, so they should be interpreted carefully.

## Buyer Interpretation

Buyers should expect newer manufacturing years to generally have higher listed prices. If a buyer has a lower budget, older manufacturing years may offer more affordable options.

However, buyers should not judge price by manufacturing year alone. A large price gap within the same year means that company, model, mileage, condition, trim, and other factors can strongly affect price.

For years with many listings, such as 2021, buyers may have more comparable options when evaluating whether a listing is priced reasonably.

## Seller Interpretation

Sellers should benchmark their car against listings from the same manufacturing year, but they should not rely on year alone.

If a manufacturing year has many listings, the seller may face more competition and should compare against similar company, model, mileage, and condition. If the seller is in a hurry, a more competitive price may help attract buyers.

If a year has a very wide price gap, sellers should be careful not to compare their car against extreme listings that may belong to luxury models, unusual conditions, or outlier prices.

## Caution / Limitation

This analysis is based on listed asking prices, not confirmed sold prices.

Years with very low listing counts are weak evidence and should not be treated as reliable market patterns.

Price gap is useful as a spread indicator, but it is sensitive to extreme listings. A large price gap does not mean all cars from that year vary naturally by that amount; it may reflect mixed car types, luxury listings, condition differences, or outliers.

---

# Q2. How does listed price vary by mileage?

## Key Finding

Listed price decreases as mileage increases. Low-mileage cars have the highest median listed price, while high-mileage cars have the lowest median listed price.

The result also shows that low-mileage cars tend to be newer, while high-mileage cars tend to be older.

## Evidence From Result

| Mileage category | Listings | Average listed price | Median listed price | Median mileage | Median manufacturing year |
|---|---:|---:|---:|---:|---:|
| Low mileage | 2,883 | 1,732,090 EGP | 1,280,000 EGP | 22,147 km | 2023 |
| Moderate mileage | 8,345 | 900,870 EGP | 735,000 EGP | 100,000 km | 2018 |
| High mileage | 11,195 | 533,905 EGP | 450,000 EGP | 205,000 km | 2011 |

## Buyer Interpretation

Buyers should verify mileage carefully because mileage has a strong relationship with listed price.

A low price may be attractive, but if mileage is high, the buyer should inspect condition, service history, documents, and the dashboard reading carefully.

## Seller Interpretation

Sellers should benchmark their car against listings with a similar mileage category. A low-mileage car may support a stronger asking price, while a high-mileage car usually needs more competitive pricing.

## Caution / Limitation

Mileage is seller-listed and not independently verified. The dataset cannot detect odometer manipulation, condition issues, or service-history quality.

The maximum price inside a mileage category may be affected by luxury models or unusual listings, so median listed price is more useful than maximum price for typical benchmark interpretation.

---

# Q3. What used-car options are available within different buyer budget segments?

## Key Finding

Budget segments show a clear relationship with car age and mileage. As budget increases, cars generally become newer and lower mileage.

The very low budget segment has a median manufacturing year of 2003 and median mileage of 200,000 km, while the premium budget segment has a median manufacturing year of 2022 and median mileage of 35,000 km.

The low budget segment has the highest number of listings, with 7,164 cars, making it the most available budget range in the analysis-ready dataset.

## Evidence From Result

| Budget segment | Listings | Median listed price | Median mileage | Median manufacturing year |
|---|---:|---:|---:|---:|
| Very low budget | 3,666 | 220,000 EGP | 200,000 km | 2003 |
| Low budget | 7,164 | 440,000 EGP | 182,000 km | 2012 |
| Mid budget | 6,657 | 750,000 EGP | 130,000 km | 2018 |
| High budget | 3,568 | 1,300,000 EGP | 90,000 km | 2020 |
| Premium budget | 1,368 | 2,850,000 EGP | 35,000 km | 2022 |

## Buyer Interpretation

Buyers with lower budgets should expect older and higher-mileage cars. Buyers with higher budgets are more likely to find newer and lower-mileage cars.

The low budget segment has the most listings, so buyers in this range may have more available options to compare.

## Seller Interpretation

Sellers should compare their car against listings in the same budget segment. A seller in the low-budget range may face more competition because this segment has the highest number of listings.

Sellers should not use the full price spread as a negotiation rule. The upside and downside percentages describe observed listing spread from the median, not guaranteed negotiation limits.

## Caution / Limitation

Budget segments are analyst-defined ranges.

The upside and downside percentages are spread indicators, not negotiation rules. They can be affected by extreme listings, car condition, brand, model, mileage, and missing details not captured in the dataset.

---

# Q3B. Which company/model combinations appear most often within each budget segment?

## Key Finding

Each buyer budget segment has a different set of common company/model combinations. This makes the budget analysis more practical because buyers can see not only the price range, but also the types of cars commonly available inside that range.

## Evidence From Result

Top listed company/model combinations by budget segment included:

| Budget segment | Common listed options |
|---|---|
| Very low budget | Daewoo Lanos, Daewoo Nubira, Chevrolet Lanos, Speranza A516, Speranza A113 |
| Low budget | Nissan Sunny, Chevrolet Optra, Renault Logan, Mitsubishi Lancer, Chevrolet Aveo |
| Mid budget | Hyundai Elantra, Mitsubishi Lancer, Chery Tiggo, Fiat Tipo, Toyota Corolla |
| High budget | Kia Sportage, Hyundai Tucson, Toyota Corolla, Mercedes C, Hyundai Elantra |
| Premium budget | Mercedes C, Mercedes E, Skoda Kodiaq, Mercedes GLC, Land Rover |

## Buyer Interpretation

Buyers can use this table to understand realistic options inside each budget segment.

Instead of only asking, "What can I afford?", buyers can ask, "Which models commonly appear in my budget range?"

## Seller Interpretation

Sellers should compare their car against listings in the same budget segment and similar company/model group.

A seller should not compare a low-budget economy car against unrelated premium or SUV listings.

## Caution / Limitation

This result uses company and model names exactly as they appear in the source data.

Some real-world equivalent or closely related models may be split across different company names. For example, Daewoo Lanos and Chevrolet Lanos appear separately, even though they are closely related market options in Egypt.

For the current public release, the analysis keeps source-listed company/model names for transparency. A future improvement would be to create a model normalization reference table.

---

# Q4. How can sellers benchmark their asking price against similar listed cars?

## Key Finding

Sellers can use similar listings to create a practical asking-price benchmark. In this project, similar cars are defined by company, model, manufacturing year, and mileage category.

Using quartiles provides a more useful benchmark than relying only on minimum and maximum prices. Q1 to Q3 shows the normal middle range of comparable listings, while the median gives the typical listed-price benchmark.

## Evidence From Result

For a Toyota Corolla 2020 with moderate mileage, the analysis found 31 similar listings.

| Metric | Value |
|---|---:|
| Company | Toyota |
| Model | Corolla |
| Manufacturing year | 2020 |
| Mileage category | Moderate mileage |
| Number of similar listings | 31 |
| Minimum listed price | 900,000 EGP |
| Q1 listed price | 1,020,000 EGP |
| Median listed price | 1,060,000 EGP |
| Q3 listed price | 1,100,000 EGP |
| Maximum listed price | 1,300,000 EGP |
| Lower outlier boundary | 900,000 EGP |
| Upper outlier boundary | 1,220,000 EGP |
| Median mileage | 97,000 km |

The middle benchmark range is between Q1 of 1,020,000 EGP and Q3 of 1,100,000 EGP. The median listed price is 1,060,000 EGP.

The maximum listed price of 1,300,000 EGP is above the upper outlier boundary of 1,220,000 EGP. This makes it statistically unusual compared with similar listings.

## Seller Interpretation

A seller with a Toyota Corolla 2020 and moderate mileage can use 1,060,000 EGP as a typical listed-price benchmark.

If the seller wants to price aggressively, a price closer to Q1 may help position the car more competitively. If the seller is not in a hurry, pricing around the median is a reasonable benchmark. If the seller is patient or believes the car has stronger condition, lower mileage within the category, better trim, or extra features, pricing closer to Q3 may be reasonable.

Pricing above Q3 should require justification. Pricing above the upper outlier boundary is statistically unusual compared with similar listings and should require strong justification.

## Buyer Interpretation

Buyers can use this benchmark to judge whether a listing is within the normal comparable range.

A listing near the median is close to the typical benchmark. A listing below Q1 may be competitively priced or may require closer inspection. A listing above Q3 should be checked carefully to see whether the higher price is justified by condition, mileage, trim, features, or service history.

## Caution / Limitation

This benchmark is based on listed asking prices, not confirmed sold prices.

The similarity group uses company, model, manufacturing year, and mileage category. It does not include verified condition, trim level, accident history, service history, feature quality, or independent mileage verification.

The benchmark only includes groups with at least 5 similar listings. Groups with more listings are more reliable than groups close to the minimum threshold.

---

# Q5. How can sellers choose a pricing position depending on urgency?

## Key Finding

Q5 converts the seller benchmark from Q4 into practical pricing zones. Instead of showing only benchmark statistics, this output helps sellers choose a pricing position based on urgency, competitiveness, and how much justification the asking price may need.

For the Nissan Sunny 2013 high-mileage example, the result shows five pricing zones and does not show an unusually low or unusually high pricing zone. This means the observed listed prices for this group fall within the IQR-based outlier boundaries.

## Evidence From Result

The benchmark is based on 25 similar listings for Nissan Sunny 2013 with high mileage.

| Pricing position | Price range | Seller meaning | Buyer meaning |
|---|---:|---|---|
| Aggressive / urgent pricing | 320,000-390,000 EGP | Faster-sale range | Attractive, but inspect carefully |
| Competitive-normal pricing | 390,000-440,000 EGP | Normal competitive range | Within normal benchmark |
| Typical benchmark pricing | 440,000 EGP | Typical market reference | Around the median |
| Upper-normal pricing | 440,000-450,000 EGP | Good for seller not in a hurry | Still normal but higher |
| Premium / patient pricing | 450,000-475,000 EGP | Needs justification | Buyer should check why the price is high |

The output does not include an "Unusually low pricing" row or an "Unusually high pricing" row. This means the observed minimum and maximum prices are not outside the calculated outlier boundaries.

## Seller Interpretation

A seller can use this guide to choose a price based on their situation.

If the seller wants faster buyer interest, the aggressive / urgent range may be more suitable. If the seller wants a normal market position, the competitive-normal or median benchmark can be used. If the seller is patient or believes the car has better condition, stronger features, or lower mileage within the category, the premium / patient range may be considered.

## Buyer Interpretation

Buyers can use the pricing zones to judge whether a listing is low, normal, high, or premium compared with similar cars.

A low price may look attractive, but buyers should still inspect the car carefully. A higher price may still be reasonable if condition, mileage, trim, documents, or service history justify it.

## Caution / Limitation

This analysis is based on listed asking prices, not confirmed sold prices.

The pricing guide does not include verified condition, trim level, accident history, service history, negotiation outcome, or independent mileage verification. Therefore, the guide should be used as a benchmark, not as proof of true fair market value.

---

# Final Summary

This project shows how SQL can be used to move from raw scraped listings into business-ready analysis.

The strongest project outputs are:

- raw-to-clean data workflow,
- quality flags and analysis-ready filtering,
- buyer-focused price analysis by year, mileage, and budget,
- seller benchmark analysis using quartiles,
- seller pricing guide using benchmark zones and outlier boundaries.

The main limitation is that the dataset contains listed asking prices, not confirmed sold prices. Therefore, findings should be used as listing-market benchmarks, not proof of actual transaction value.

## Analysis Table Used

The findings in this document are based on the official clean table:

```sql
clean.clean_used_car_listings_aug_2025_v1
```

A future clean-layer enhancement may add more granular field readiness and model normalization, but the current public release keeps the analysis scope stable and focused on the official clean table.
