Business Context:
The retail sector is currently facing stagnant growth and declining engagement. This project addresses these challenges by transforming raw transaction data into strategic insights. The goal is to move away from "one-size-fits-all" marketing and toward data-driven decision-making.

Project Objectives:
Product Performance Audit: Identify "Star" products and "Underperformers" to streamline inventory costs and focus marketing spend.

Behavioral Customer Segmentation: Categorize the customer base into actionable segments (No Orders, Low, Mid, and High-Value) based on purchase volume.

Loyalty & Retention Analysis: Uncover repeat purchase patterns to build a framework for long-term customer loyalty.

Data Architecture:
The analysis is built upon three core relational datasets:

Sales Transactions: Granular record of IDs, quantities, dates, and pricing.

Customer Profiles: Demographic data including age, gender, location, and tenure.

Product Inventory: Catalog details including categories and current stock levels.

Methodology & Technical Approach:
1. Data Engineering & SQL Cleaning
Utilized advanced SQL queries to handle missing values and ensure data consistency across transaction and inventory tables.

Performed Exploratory Data Analysis (EDA) to establish baseline metrics for monthly sales and active user counts.

2. Strategic Customer Segmentation
I implemented a volume-based segmentation logic to differentiate the customer base:

High Value (>30 units): Primary targets for loyalty programs and early access.

Mid (10-30 units): Potential "High Value" candidates through upselling.

Low (1-10 units): Targets for re-engagement and discount-driven conversions.

No Orders (0 units): Analysis of "churn at entry" or sign-up-only users.

3. Product & Inventory Optimization
Performance Variability: Ranked products by revenue vs. quantity to identify high-margin vs. high-volume items.

Stock Alignment: Cross-referenced sales velocity with inventory levels to prevent "Out of Stock" scenarios for top-performing products.

Impact & Recommendations:
Targeted Marketing: Enabled the marketing team to design specific campaigns for the "High Value" segment, increasing ROI on ad spend.

Inventory Efficiency: Provided a data-backed list of products for clearance to free up warehouse space for high-demand categories.

Retention Strategy: Identified the "loyalty threshold"—the number of purchases after which a customer is 80% likely to return.
