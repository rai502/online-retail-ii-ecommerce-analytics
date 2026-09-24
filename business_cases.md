# Business Cases & Analysis

This document summarizes the six business investigations completed using the cleaned Online Retail II dataset.

All year-over-year comparisons that involve 2011 use January-November periods where appropriate because December 2011 is incomplete.

---

## 1. Sales Decline Investigation

### Manager Question

Overall sales have declined. Investigate what happened, identify where the decline is concentrated, determine the likely drivers, and recommend what the business should investigate next.

### Investigation

The analysis initially identified a significant revenue decline between November and December 2011.

However, the dataset ends on December 9, 2011. December therefore contains only 8 active reporting days and is not a complete month.

Because the two periods are not comparable, the November-to-December change was not treated as a reliable full-month sales decline.

### Key Finding

The apparent month-over-month decline was affected by incomplete December data.

### Business Learning

Before interpreting a period-over-period change, validate whether the comparison periods contain complete and comparable data.

---

## 2. Underperforming Market — EIRE

### Manager Question

One of our markets is underperforming compared with the others. Identify the market, determine what is driving its weak performance, and recommend what the business should investigate.

### Market Selection

EIRE was investigated using comparable January-November periods.

| Metric | Jan-Nov 2010 | Jan-Nov 2011 |
|---|---:|---:|
| Revenue | £355,527.05 | £265,766.37 |
| Orders | 318 | 261 |
| Active Customers | 5 | 3 |

Revenue declined by 25.25%, while orders declined by 17.92%.

### Customer Analysis

| Customer Type | Jan-Nov 2010 | Jan-Nov 2011 |
|---|---:|---:|
| New Customers | 3 | 0 |
| Returning Customers | 2 | 3 |

The number of active customers declined from 5 to 3.

New customer acquisition declined from 3 customers to 0, while returning customers increased from 2 to 3.

### Product Investigation

Product-level analysis showed that the revenue decline was spread across multiple products rather than being dominated by a single normal merchandise product.

Several major declining products experienced substantial reductions in units sold while average selling prices remained stable or increased.

### Conclusion

EIRE revenue declined by 25.25% in the comparable January-November period. The decline was associated with lower order volume and fewer active customers, with new customer acquisition falling from 3 to 0.

The product analysis suggests that lower volume was a more important contributor than broad price reductions.

The customer sample is small, so these findings should be interpreted with caution.

---

## 3. Product Revenue Concentration

### Manager Question

The product portfolio is generating revenue, but management wants to understand whether revenue is too dependent on a small number of products.

### Investigation

Product revenue was aggregated after excluding operational transaction codes that do not represent normal merchandise.

The analysis focused on the contribution of the highest-revenue products to total valid merchandise revenue.

### Key Finding

The top 10 products contributed approximately **8.07%** of total valid merchandise revenue.

This indicates that total revenue is distributed across a broad product base rather than being dominated by a small group of products.

### Business Learning

Revenue concentration should be evaluated using both product contribution and the nature of the underlying transaction codes. Operational records should not be treated as normal merchandise products.

---

## 4. Cancellations & Negative-Quantity Transactions

### Manager Question

Cancellations and negative-quantity transactions may be reducing sales. Investigate their scale, financial impact, and where the issue occurs.

### Important Data Distinction

Negative quantity does not automatically mean a customer return.

The analysis therefore kept:

- `IsCancellation`
- `IsNegativeQuantity`

as separate indicators.

### Overall Comparison

| Metric | Jan-Nov 2010 | Jan-Nov 2011 |
|---|---:|---:|
| Total Transactions | 493,653 | 469,414 |
| Cancellations | 9,559 | 8,173 |
| Cancellation Rate | 1.94% | 1.74% |
| Negative-Quantity Transactions | 11,595 | 9,409 |
| Negative-Quantity Rate | 2.35% | 2.00% |

Cancellation rates and negative-quantity transaction rates both decreased.

However, the average financial impact per cancellation increased:

| Metric | 2010 | 2011 |
|---|---:|---:|
| Cancellation Revenue Impact | -£616,964.55 | -£614,161.34 |
| Average Impact per Cancellation | -£64.54 | -£75.15 |

### Product & Market Analysis

Cancellation behavior varied substantially across products and countries.

Some products showed high cancellation frequencies, while other products had relatively few cancellations but much larger financial impacts.

### Conclusion

Cancellations and negative-quantity transactions did not worsen overall on a transaction-rate basis. However, the financial impact remained significant because the average impact per cancellation increased.

Management should therefore investigate high-frequency cancellations and high-value cancellations separately.

---

## 5. Customer Purchasing Behavior

### Manager Question

Understand how customers purchase from the business, whether the customer base is driven mainly by new or returning customers, how frequently customers purchase, and whether a small group contributes a large share of revenue.

### New vs Returning Customers

| Year | New Customers | Returning Customers |
|---|---:|---:|
| 2010 | 3,387 | 844 |
| 2011 | 1,508 | 2,665 |

New customer acquisition declined from 3,387 to 1,508, a decrease of approximately 55.5%.

Returning customers increased from 844 to 2,665, an increase of approximately 215.8%.

This represents a substantial shift in the customer base from new-customer acquisition toward existing-customer activity.

### Customer AOV

| Year | Customer AOV |
|---|---:|
| 2010 | £1,979.32 |
| 2011 | £1,869.06 |

Customer AOV declined by approximately 5.56%.

### Customer Revenue Concentration

The top 10 customers contributed approximately **16.04% of total revenue**.

The analysis therefore identified meaningful revenue concentration among high-value customers.

### Conclusion

The customer base shifted toward existing customers while new customer acquisition declined. Customer AOV also decreased, and a relatively small group of high-value customers generated a meaningful share of revenue.

This makes both customer acquisition and high-value customer retention important areas to monitor.

---

## 6. High-Value Customers & Products

### Manager Question

Identify the highest-value customers and products, determine how dependent the business is on these groups, and identify what management should monitor.

### Key Findings

- Top 10 customers contributed approximately **16.04% of total revenue**.
- Top 10 products contributed approximately **8.07% of total valid merchandise revenue**.
- The top 10 products accounted for approximately **10.31% of the revenue generated by the top 10 customers**.

### Interpretation

The analysis shows meaningful customer-level revenue concentration while the high-value customer group remains relatively diversified across products.

This suggests that customer concentration and product concentration are different dimensions of business risk and should be monitored separately.

---

## Overall Analytical Takeaways

Across the six investigations, several recurring analytical principles emerged:

1. **Validate the time period before comparing performance.**
2. **Separate transaction volume from financial impact.**
3. **Distinguish customer acquisition from retention.**
4. **Separate operational records from normal merchandise when analyzing products.**
5. **Use both percentage rates and absolute financial impact when evaluating cancellations.**
6. **Investigate revenue concentration at both customer and product levels.**
7. **Treat unusual records as data-quality or business signals until their meaning is understood.**

The project therefore focuses on business investigation rather than simply producing descriptive metrics.
