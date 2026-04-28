-- ===============================================================================
-- DDL Script: Create Silver Tables
-- ===============================================================================
-- Script Purpose:
--     Creates cleaned, typed, and enriched tables in the 'silver' schema.
--     Silver applies on top of Bronze:
--       • Proper type casting (no more TEXT for everything)
--       • Consistent snake_case column naming
--       • Derived / computed columns
--       • Data quality flags (_is_valid, _rejection_reason)
--       • Full metadata lineage (_ingested_at, _silver_loaded_at,
--         _source_table, _record_hash)
-- ===============================================================================


-- ===============================================================================
-- silver.fact_flights
-- ===============================================================================

DROP TABLE IF EXISTS silver.fact_flights;

CREATE TABLE silver.fact_flights (
    dep_airport_key    TEXT,
    arr_airport_key    TEXT,
    airline_key        TEXT,
    date_key           DATE,
    aircraft_key       TEXT,
    scheduled_duration_mins INTEGER,
    actual_duartion_mins    INTEGER,
    delay_mins              INTEGER,
    passenegers             INTEGER,
    status      TEXT,
    delay_category      TEXT,
    responsible_party   TEXT,

    is_delayed                  BOOLEAN
        GENERATED ALWAYS AS (delay_mins > 0) STORED,
    
    is_cancelled                BOOLEAN
        GENERATED ALWAYS AS (status = 'Cancelled') STORED,
    
    _is_valid                   BOOLEAN         DEFAULT TRUE,
    _rejection_reason           TEXT,

    delay_severity         TEXT,
    flight_duration_diff_mins   INTEGER,

    _source_table               TEXT            DEFAULT 'bronze.csv_fact_flights',
    _ingested_at                TIMESTAMP,      
    _silver_loaded_at           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    _record_hash                TEXT
);

DROP TABLE IF EXISTS silver.dim_airports;

CREATE TABLE silver.dim_airports (
    airport_key     TEXT PRIMARY KEY,
    iata_code       CHAR(3) NOT NULL,

    airport_name    TEXT,
    city            TEXT,
    country         TEXT,
    continent       TEXT,
    timezone        TEXT,
    airport_type    TEXT,
    hub_flag        BOOLEAN,
    is_african_hub              BOOLEAN
        GENERATED ALWAYS AS (continent = 'Africa' AND hub_flag = TRUE) STORED,

    _is_valid                   BOOLEAN         DEFAULT TRUE,
    _rejection_reason           TEXT,

    _source_table               TEXT            DEFAULT 'bronze.csv_dim_airports',
    _ingested_at                TIMESTAMP,
    _silver_loaded_at           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    _record_hash                TEXT

);

DROP TABLE IF EXISTS silver.dim_airlines;
CREATE TABLE silver.dim_airlines(
    airline_key         TEXT            PRIMARY KEY,
    iata_code           CHAR(2)         NOT NULL,
    airline_name        TEXT,
    country_of_origin   TEXT,
    alliance            TEXT,
    airline_type        TEXT,
    is_alliance_member  BOOLEAN
        GENERATED ALWAYS AS (alliance <> 'None') STORED,
    
    is_low_cost         BOOLEAN
        GENERATED ALWAYS AS (airline_type IN ('Low-Cost', 'Ultra Low-Cost')) STORED,
    
    _is_valid                   BOOLEAN         DEFAULT TRUE,
    _rejection_reason           TEXT,
    _source_table               TEXT            DEFAULT 'bronze.csv_dim_airlines',
    _ingested_at                TIMESTAMP,
    _silver_loaded_at           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    _record_hash                TEXT
);

DROP TABLE IF EXISTS silver.flight_raw;

CREATE TABLE silver.flight_raw(
    year            SMALLINT,
    quarter         SMALLINT,
    day_of_month    SMALLINT,
    day_of_week     SMALLINT,
    fl_date         DATE,
    op_unique_carrier   TEXT,
    tail_num            TEXT,

    origin_airport_id   INTEGER,
    origin_airport_seq_id   INTEGER,
    origin_city_market_id   INTEGER,
    origin  CHAR(3),
    origin_city_name            TEXT,
    origin_state_abr            CHAR(2),
    origin_state_nm             TEXT,
    origin_wac                  INTEGER,

    dest_airport_id   INTEGER,
    dest_airport_seq_id   INTEGER,
    dest_city_market_id   INTEGER,
    dest  CHAR(3),
    dest_city_name            TEXT,
    dest_state_abr            CHAR(2),
    dest_state_nm             TEXT,
    dest_wac                  INTEGER,

    crs_dep_time    SMALLINT,
    dep_time        SMALLINT,
    taxi_out        SMALLINT,
    wheels_off      SMALLINT,

    wheels_on   SMALLINT,
    taxi_in     SMALLINT,
    arr_time    SMALLINT,

    cancelled   BOOLEAN,
    cancellation_code   BOOLEAN,
    diverted    BOOLEAN,

    air_time    SMALLINT,
    flights     SMALLINT,
    distance    NUMERIC(7,2),

    carrier_delay   SMALLINT,
    weather_delay   SMALLINT,
    nas_delay       SMALLINT,
    security_delay  SMALLINT,
    late_aircraft_delay     SMALLINT,

    total_delay_mins    SMALLINT
        GENERATED ALWAYS AS (
            COALESCE(carrier_delay, 0)
            + COALESCE(weather_delay, 0)
            + COALESCE(nas_delay, 0)
            + COALESCE(security_delay, 0)
            + COALESCE(late_aircraft_delay, 0)
        ) STORED,
    
    is_cancelled        BOOLEAN
        GENERATED ALWAYS AS (cancelled=TRUE) STORED,
    
    is_diverted         BOOLEAN
        GENERATED ALWAYS AS (diverted=TRUE) STORED,

    primary_delay_cause    TEXT,
    dep_hour    SMALLINT,

    _is_valid                   BOOLEAN         DEFAULT TRUE,
    _rejection_reason           TEXT,
    _source_table               TEXT            DEFAULT 'bronze.csv_flight_raw',
    _ingested_at                TIMESTAMP,
    _silver_loaded_at           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    _record_hash                TEXT
);