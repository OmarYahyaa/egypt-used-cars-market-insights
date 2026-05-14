/*
===============================================================================
Project: Egypt Used Cars Market Analysis
Script: 00_database_setup.sql
Purpose: Create the project database and schemas
Database: egypt_used_cars_db
===============================================================================

Important PostgreSQL note:
- CREATE DATABASE should be executed while connected to the default postgres database.
- After creating egypt_used_cars_db, connect to egypt_used_cars_db.
- Then run the schema creation section.

===============================================================================
*/


/*
===============================================================================
Step 1: Create the project database
Run this while connected to the default postgres database.
===============================================================================
*/

CREATE DATABASE egypt_used_cars_db;


/*
===============================================================================
Step 2: Create project schemas
After creating the database, connect to egypt_used_cars_db, then run this section.
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS clean;
CREATE SCHEMA IF NOT EXISTS analysis;


/*
===============================================================================
Optional: Set the default schema search path
===============================================================================

For this project, SQL scripts should still use explicit schema names, such as:
raw.raw_used_car_listings_aug_2025
clean.clean_used_car_listings_aug_2025

The search_path setting is only a convenience for interactive querying.

Current session change:
- Applies only to the current query window/session.
- Resets when the session is closed.

Permanent change:
- Applies automatically whenever a new connection is opened to egypt_used_cars_db.
- Requires reconnecting to the database before the change is visible.
===============================================================================
*/

/* The search_path defines the default order PostgreSQL uses when resolving unqualified table names */

-- Current session change
SET search_path TO raw, clean, analysis;

-- Permanent change
ALTER DATABASE egypt_used_cars_db SET search_path TO raw, clean, analysis;

/*
===============================================================================
Verification queries
Run these after setup to confirm the database and schemas exist.
===============================================================================
*/

-- Show current database
SELECT CURRENT_DATABASE();

-- Show the first active schema in the current search path
SELECT CURRENT_SCHEMA();

-- Show schemas in the current database
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'clean', 'analysis')
ORDER BY schema_name;
