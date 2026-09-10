# 🛒 OLIST E-Commerce SQL Analysis

![E-Commerce Analytics](./assets/olist-banner.png)

> **A MySQL-based SQL analytics project using the Brazilian Olist e-commerce dataset to answer real-world business questions across customers, orders, products, sellers, payments, reviews, and revenue.**

### Dataset Source

**Brazilian E-Commerce Public Dataset by Olist — Kaggle**
🔗 https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
---

## 📌 Project Overview

This project is a hands-on **SQL data analysis project** built using the **Brazilian Olist E-Commerce dataset**.

The main objective was not simply to practice individual SQL commands, but to work with a **relational, multi-table e-commerce database** and solve business-oriented analytical problems using SQL.

Unlike simple datasets where most analysis can be performed within a single table, the Olist database contains multiple interconnected tables representing different parts of an e-commerce business.

This required me to:

- Understand the database structure and relationships between tables
- Build the database from the raw datasets using MySQL
- Work with primary and foreign-key relationships
- Combine information from multiple tables using JOINs
- Aggregate and transform transactional data
- Use subqueries and Common Table Expressions (CTEs)
- Apply conditional logic using `CASE`
- Use window functions for advanced business analysis
- Translate business requirements into SQL queries
- Analyze revenue, customers, products, sellers, orders, payments, delivery performance, and customer reviews

The project contains **20 progressively difficult business questions**, ranging from basic SQL queries to advanced analytical problems.

---

## 🎯 Why I Chose This Project

I chose the Olist dataset because it provides a much more realistic environment for practicing SQL than a simple single-table dataset.

The database represents an e-commerce business where different entities are stored separately:

- Customers
- Orders
- Products
- Sellers
- Order Items
- Payments
- Reviews
- Product Categories

These tables are connected through relationships, meaning that answering a business question often requires information from several tables.

For example, answering a question about **which product category generates the most revenue in each state** requires connecting seller information, order items, products, and product categories.

This made the project particularly useful for developing the kind of SQL skills required in real-world data analyst roles.

---

# 🏢 Business Context

Olist is a Brazilian e-commerce marketplace that connects customers with sellers.

The dataset contains information about approximately **100,000 orders made between 2016 and 2018**, including order status, pricing, payment information, freight, customer location, product attributes, and customer reviews.

The dataset is particularly useful for analytical work because a single business transaction can be examined from multiple perspectives:

**Customer → Order → Product → Seller → Payment → Delivery → Review**

This relational structure makes it possible to investigate both operational and business-performance questions.

---

# 🗄️ Database Structure

The project uses a relational database containing the following core tables:

| Table | Purpose |
|---|---|
| `customers` | Customer information and geographic location |
| `orders` | Order status and order timestamps |
| `order_items` | Products, sellers, prices, and freight associated with orders |
| `products` | Product attributes and categories |
| `sellers` | Seller information and location |
| `order_payments` | Payment methods, installments, and payment values |
| `order_reviews` | Customer review scores and comments |
| `category_translation` | Portuguese product categories translated into English |

### Simplified Relationship Structure

```text
                         ┌──────────────┐
                         │  Customers   │
                         └──────┬───────┘
                                │
                                │ customer_id
                                ▼
                         ┌──────────────┐
                         │    Orders    │
                         └──────┬───────┘
                                │
                    ┌───────────┼────────────┐
                    │           │            │
                    ▼           ▼            ▼
             Order Items    Payments      Reviews
                    │
             ┌──────┴──────┐
             │             │
             ▼             ▼
         Products       Sellers
             │
             ▼
    Category Translation
