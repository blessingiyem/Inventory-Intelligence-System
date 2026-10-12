# Inventory Intelligence & Automated Reorder System

## Business Background

Meridian Retail Distribution Ltd. is a growing retail and wholesale company managing multiple products across different categories.

Currently, inventory monitoring is mostly manual. Staff record stock movements, but managers lack real-time visibility into inventory health.

The company experiences:

- Frequent stockouts of popular products
- Overstocking of slow-moving items
- Delayed reorder decisions
- Difficulty monitoring supplier performance

The company requires an automated inventory monitoring system that transforms inventory transactions into actionable insights.

---

# Project Objective

Build an inventory intelligence application that:

- Tracks inventory movements
- Calculates current stock levels automatically
- Identifies low-stock and out-of-stock products
- Generates reorder recommendations
- Provides management dashboards

---

# System Users

## Inventory Manager

Responsibilities:

- Record stock received
- Record stock issued/sold
- Monitor inventory status
- Review reorder recommendations


## Operations Manager

Responsibilities:

- Monitor inventory performance
- Review supplier activity
- Identify operational issues


## Business Manager

Responsibilities:

- View business KPIs
- Understand inventory value
- Support purchasing decisions

---

# Core Features

## Product Management

The system should allow users to:

- Add products
- Assign categories
- Assign suppliers
- Set reorder levels
- Set maximum stock levels


## Inventory Transactions

The system should record:

- Stock received
- Stock issued
- Transaction dates
- Transaction notes


## Automated Inventory Classification

Products should automatically be classified as:

- Healthy Stock
- Low Stock
- Out of Stock


## Reorder Recommendations

The system should calculate:

Recommended Order Quantity =
Maximum Stock Level - Current Stock


## Dashboard

The dashboard should display:

- Total products
- Inventory value
- Low-stock items
- Out-of-stock items
- Inventory trends
- Supplier performance

---

# Technology Stack

Database:
- PostgreSQL

Backend:
- Python

Application:
- Streamlit

Analytics:
- SQL
- Plotly

Version Control:
- GitHub

---

# Success Criteria

The project is successful if:

- Users can record inventory movements
- Stock levels update automatically
- Low-stock products are identified
- Reorder recommendations are generated
- Managers can view inventory insights
- Reports can be exported