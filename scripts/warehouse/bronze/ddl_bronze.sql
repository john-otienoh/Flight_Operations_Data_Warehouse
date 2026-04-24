-- ===============================================================================
-- DDL Script: Create Bronze Tables
-- ===============================================================================
-- Script Purpose:
--     This script creates tables in the 'bronze' schema, dropping existing tables 
--     if they already exist.
-- 	  Run this script to re-define the DDL structure of 'bronze' Tables
-- ===============================================================================

DROP TABLE IF EXISTS bronze.csv_fact_flights;

CREATE TABLE bronze.csv_fact_flights (
    dep_airport_key TEXT,
    arr_airport_key TEXT,
    airline_key TEXT,
    date_key TEXT,
    aircraft_key TEXT,
    scheduled_duration_mins TEXT,
    passengers TEXT,
    actual_duration_mins TEXT,
    delay_mins TEXT,
    status TEXT,
    delay_category TEXT,
    responsible_party TEXT,

    _ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS bronze.csv_dim_airports;

CREATE TABLE bronze.csv_dim_airports (
    airport_key TEXT,
    iata_code TEXT,
    airport_name TEXT,
    city TEXT,
    country TEXT,
    continent TEXT,
    timezone TEXT,
    airport_type TEXT,
    hub_flag TEXT,

    _ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DROP TABLE IF EXISTS bronze.csv_dim_airlines;

CREATE TABLE bronze.csv_dim_airlines (
    airline_key TEXT,
    iata_code TEXT,
    airline_name TEXT,
    country_of_origin TEXT,
    alliance TEXT,
    airline_type TEXT,

    _ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS bronze.csv_flight_raw;

CREATE TABLE bronze.csv_flight_raw (

    -- Raw data (keep close to CSV)
    flightdate TEXT,
    reporting_airline TEXT,
    iata_code_reporting_airline TEXT,
    tail_number TEXT,
    flight_number_reporting_airline TEXT,

    originairportid TEXT,
    origin TEXT,
    origincityname TEXT,
    originstate TEXT,

    destairportid TEXT,
    dest TEXT,
    destcityname TEXT,
    deststate TEXT,

    crselapsedtime TEXT,
    actualelapsedtime TEXT,

    depdelay TEXT,
    arrdelay TEXT,
    depdelayminutes TEXT,
    arrdelayminutes TEXT,

    cancelled TEXT,
    diverted TEXT,

    distance TEXT,

    carrierdelay TEXT,
    weatherdelay TEXT,
    nasdelay TEXT,
    securitydelay TEXT,
    lateaircraftdelay TEXT,

    -- Metadata (CRITICAL)
    _ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file TEXT
);