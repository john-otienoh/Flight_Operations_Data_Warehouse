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

    -- Date & Time Identifiers
    year                    TEXT,
    quarter                 TEXT,
    month                   TEXT,
    day_of_month            TEXT,
    day_of_week             TEXT,
    fl_date                 TEXT,

    -- Carrier Info
    op_unique_carrier       TEXT,
    op_carrier              TEXT,
    tail_num                TEXT,

    -- Origin
    origin_airport_id       TEXT,
    origin_airport_seq_id   TEXT,
    origin_city_market_id   TEXT,
    origin                  TEXT,
    origin_city_name        TEXT,
    origin_state_abr        TEXT,
    origin_state_nm         TEXT,
    origin_wac              TEXT,

    -- Destination
    dest_airport_id         TEXT,
    dest_airport_seq_id     TEXT,
    dest_city_market_id     TEXT,
    dest                    TEXT,
    dest_city_name          TEXT,
    dest_state_abr          TEXT,
    dest_state_nm           TEXT,
    dest_wac                TEXT,

    -- Departure
    crs_dep_time            TEXT,
    dep_time                TEXT,
    taxi_out                TEXT,
    wheels_off              TEXT,

    -- Arrival
    wheels_on               TEXT,
    taxi_in                 TEXT,
    arr_time                TEXT,

    -- Flight Status
    cancelled               TEXT,
    cancellation_code       TEXT,
    diverted                TEXT,

    -- Flight Metrics
    air_time                TEXT,
    flights                 TEXT,
    distance                TEXT,

    -- Delay Breakdown
    carrier_delay           TEXT,
    weather_delay           TEXT,
    nas_delay               TEXT,
    security_delay          TEXT,
    late_aircraft_delay     TEXT,

    -- Metadata
    _ingested_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);