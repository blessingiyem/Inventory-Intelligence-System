-- ==========================================
-- Inventory Intelligence System
-- Database Schema
-- Meridian Retail Distribution Ltd.
-- ==========================================


-- Categories Table

CREATE TABLE categories (

    category_id SERIAL PRIMARY KEY,

    category_name VARCHAR(100) NOT NULL

);



-- Suppliers Table

CREATE TABLE suppliers (

    supplier_id SERIAL PRIMARY KEY,

    supplier_name VARCHAR(150) NOT NULL,

    contact_person VARCHAR(100),

    phone VARCHAR(20),

    email VARCHAR(100),

    location VARCHAR(100)

);



-- Products Table

CREATE TABLE products (

    product_id SERIAL PRIMARY KEY,

    product_name VARCHAR(150) NOT NULL,

    category_id INT,

    supplier_id INT,

    cost_price DECIMAL(10,2),

    selling_price DECIMAL(10,2),

    reorder_level INT,

    maximum_stock INT,


    FOREIGN KEY (category_id)

    REFERENCES categories(category_id),


    FOREIGN KEY (supplier_id)

    REFERENCES suppliers(supplier_id)

);



-- Inventory Transactions Table

CREATE TABLE inventory_transactions (

    transaction_id SERIAL PRIMARY KEY,

    product_id INT,

    transaction_type VARCHAR(10),

    quantity INT,

    transaction_date DATE,

    reference_note VARCHAR(255),


    FOREIGN KEY (product_id)

    REFERENCES products(product_id)

);



-- Purchase Orders Table

CREATE TABLE purchase_orders (

    order_id SERIAL PRIMARY KEY,

    product_id INT,

    quantity_ordered INT,

    order_date DATE,

    status VARCHAR(50),


    FOREIGN KEY (product_id)

    REFERENCES products(product_id)

);



-- Users Table

CREATE TABLE users (

    user_id SERIAL PRIMARY KEY,

    full_name VARCHAR(100),

    email VARCHAR(150),

    role VARCHAR(50)

);