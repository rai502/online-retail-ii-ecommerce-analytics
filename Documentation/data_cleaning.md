# Data Cleaning & Preparation

## Overview

The Online Retail II dataset was cleaned and validated using Power Query before being imported into PostgreSQL for business analysis.

The objective of the cleaning process was to improve data consistency while preserving unusual transactions and operational records for investigation rather than deleting them without validation.

## Original Dataset

- Original row count: 1,067,371
- Final cleaned row count: 1,033,036
- Exact duplicate rows removed: 34,335

## Data Type Preparation

The main columns were assigned appropriate data types:

| Column | Data Type |
|---|---|
| Invoice | Text |
| StockCode | Text |
| Description | Text |
| Quantity | Whole Number |
| InvoiceDate | Date/Time |
| Price | Decimal Number |
| Customer ID | Whole Number |
| Country | Text |

`Invoice` was retained as text because cancellation invoices contain a `C` prefix.

## Missing Customer IDs

There were 243,007 rows with a missing Customer ID.

These rows were retained rather than automatically removed because Customer ID is not required for every transaction-level analysis.

Customer-level analyses explicitly exclude records where Customer ID is unavailable.

## Description Values

Missing descriptions were replaced with:

`UNKNOWN`

A total of 2,689 rows had an `UNKNOWN` description.

These records were retained because some correspond to operational or data-quality transactions that can be useful during investigation.

## Transaction Flags

Three analytical flags were created.

### IsCancellation

Identifies invoices whose invoice number starts with `C`.

```powerquery
if Text.StartsWith(Text.From([Invoice]), "C") then 1 else 0
```

### IsZeroPrice

Identifies transactions where Price equals zero.

```powerquery
if [Price] = 0 then 1 else 0
```

### IsNegativeQuantity

Identifies transactions where Quantity is below zero.

```powerquery
if Number.From([Quantity]) < 0 then 1 else 0
```

Negative quantity was not automatically classified as a customer return because negative quantities can also represent operational or adjustment records.

## Zero-Price Transactions

After duplicate removal:

- Zero-price rows: 6,014
- No negative prices were identified.

Zero-price transactions were retained and flagged.

They were excluded from relevant revenue and price analyses where a zero transaction price could distort the metric.

## Negative Quantities

Negative quantities were retained because they can represent cancellations, returns, or other operational adjustments.

The project therefore keeps `IsCancellation` and `IsNegativeQuantity` as separate flags.

This distinction was important for the cancellation and negative-quantity business case.

## Exact Duplicate Removal

Exact duplicates were identified using the original transaction fields:

- Invoice
- StockCode
- Description
- Quantity
- InvoiceDate
- Price
- Customer ID
- Country

A total of 34,335 duplicate rows were removed.

The analytical flags and Revenue field were retained after duplicate removal.

## Revenue Calculation

A Revenue column was created using:

```text
Revenue = Quantity × Price
```

The resulting revenue values were validated for errors and inspected for unusually large positive and negative values.

Extreme values were retained when they represented plausible transaction values rather than being removed solely because of their magnitude.

## Operational Transaction Codes

The dataset contains codes that do not represent normal merchandise products, including examples such as:

- POST
- DOT
- M
- D
- C2
- GIFT
- ADJUST
- AMAZONFEE
- BANK CHARGES
- CRUK
- S

These codes were retained in the dataset but excluded from relevant merchandise-level product analysis.

## Cancellation Validation

After cleaning:

- Non-cancellation rows: 1,013,932
- Cancellation rows: 19,104

A cross-check identified one cancellation record with a positive quantity. This record was retained because it is an operational/manual transaction rather than an error that should be deleted automatically.

## Invoice Date Preparation

The original invoice date values were converted into a consistent date-time representation for PostgreSQL import.

The final format used for database loading was:

```text
YYYY-MM-DD HH:MM:SS
```

## Final Validation

Before loading the cleaned data into PostgreSQL, the following checks were performed:

- Country values checked for null/blank values
- Quantity checked for zero values
- Analytical flags checked for errors
- Revenue checked for errors
- Final row count verified as 1,033,036

## Cleaning Philosophy

The cleaning process followed a principle of:

**Investigate → Flag → Validate → Exclude only when justified**

Unusual transactions were not automatically deleted simply because they looked abnormal. Instead, they were investigated and retained when they could contain meaningful business or operational information.
