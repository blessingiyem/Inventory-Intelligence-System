# Inventory Intelligence System

An automated inventory analytics system designed to transform raw inventory and purchase-order data into actionable business insights.

## Project Overview

The Inventory Intelligence System combines Python, SQL, PostgreSQL, and Tableau to create a repeatable analytics workflow for inventory management.

The system generates structured inventory and purchase-order data, stores it in a relational database, calculates business metrics through SQL, and presents the resulting insights through an interactive Tableau dashboard.

The project focuses on answering practical business questions such as:

- How much capital is currently tied up in inventory?
- What is the potential sales value of the current inventory?
- How much potential profit could the inventory generate?
- Which product categories represent the greatest inventory value?
- Which categories have the highest potential sales and profit?
- How many products are currently represented in the inventory?

## Key Features

### Automated Data Generation

Python is used to generate realistic inventory and purchase-order records for the analytics workflow.

### Relational Database

PostgreSQL stores the structured inventory and purchase-order data using a relational schema.

### SQL Analytics

SQL queries transform the raw database records into business-focused metrics and category-level summaries.

### Interactive Dashboard

Tableau is used to visualize the resulting metrics through an interactive inventory intelligence dashboard.

The dashboard includes:

- Total Inventory Value
- Potential Sales Value
- Potential Profit
- Total Products
- Inventory Value by Category
- Potential Sales by Category
- Potential Profit by Category
- Total Products by Category

Dashboard filtering allows users to select a product category and see the related metrics update across the dashboard.

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data generation and automation |
| PostgreSQL | Data storage and relational database |
| SQL | Data transformation and analysis |
| Tableau Public | Interactive visualization |
| VS Code | Development environment |
| GitHub | Version control and project documentation |

## Project Structure

```text
Inventory-Intelligence-System/
│
├── analysis/
│   └── SQL analysis and analytical queries
│
├── app/
│   └── Application components
│
├── data/
│   └── generate_data.py
│
├── database/
│   └── schema.sql
│
├── docs/
│   └── Project documentation
│
├── planning/
│   └── requirements.md
│
├── screenshots/
│   └── Dashboard screenshots
│
└── README.md
Analytics Workflow
Python
   ↓
Generate Inventory Data
   ↓
PostgreSQL Database
   ↓
SQL Analysis
   ↓
Business Metrics
   ↓
Tableau Dashboard
   ↓
Interactive Inventory Insights

Business Impact
The project demonstrates how an automated analytics workflow can reduce manual reporting effort and make inventory information easier to interpret.
Instead of manually calculating inventory metrics and preparing reports, the workflow provides a structured process for generating data, storing it, analyzing it, and presenting the results.
This makes the system suitable as a foundation for automated inventory reporting and decision support.
Dashboard
The final dashboard provides a high-level view of inventory performance and allows users to investigate individual product categories.
The Tableau Public version of the dashboard is available here:
Tableau Public:
https://public.tableau.com/
Project Goals
This project was built to demonstrate practical experience with:
- Data automation
- Relational database design
- SQL analytics
- Business intelligence
- Dashboard development
- Data-driven decision support
- End-to-end analytics workflows
Future Improvements
Potential extensions include:
- Automated database refreshes
- Scheduled dashboard updates
- Inventory stock-level alerts
- Low-stock monitoring
- Supplier performance analysis
- Purchase-order trend analysis
- Additional profitability metrics
- Automated reporting
Author: Blessing Iyem
Role: Data Analyst