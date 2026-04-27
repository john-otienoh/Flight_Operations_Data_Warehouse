CREATE OR REPLACE PROCEDURE bronze.load_bronze(p_base_path TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
DECLARE
    start_time      TIMESTAMP;
    end_time        TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time  TIMESTAMP;
BEGIN

    batch_start_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE 'Base Path: %', p_base_path;
    RAISE NOTICE '================================================';

    -----------------------------------------------------------------------
    -- 1. LOAD csv_flight_raw
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_flight_raw;

        EXECUTE format($f$
            COPY bronze.csv_flight_raw (
                year, quarter, month, day_of_month, day_of_week, fl_date,
                op_unique_carrier, op_carrier, tail_num,
                origin_airport_id, origin_airport_seq_id, origin_city_market_id,
                origin, origin_city_name, origin_state_abr, origin_state_nm, origin_wac,
                dest_airport_id, dest_airport_seq_id, dest_city_market_id,
                dest, dest_city_name, dest_state_abr, dest_state_nm, dest_wac,
                crs_dep_time, dep_time, taxi_out, wheels_off,
                wheels_on, taxi_in, arr_time,
                cancelled, cancellation_code, diverted,
                air_time, flights, distance,
                carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay
            )
            FROM '%s/flight_raw.csv'
            DELIMITER ',' CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_flight_raw loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_flight_raw → %', SQLERRM;
    END;
    -----------------------------------------------------------------------
    -- 2. LOAD csv_fact_flights
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();
        TRUNCATE TABLE bronze.csv_fact_flights;

        EXECUTE format($f$
            COPY bronze.csv_fact_flights (
                dep_airport_key, arr_airport_key, airline_key, date_key,
                aircraft_key, scheduled_duration_mins, passengers,
                actual_duration_mins, delay_mins, status,
                delay_category, responsible_party
            )
            FROM '%s/fact_flights.csv'
            DELIMITER ',' CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_fact_flights loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_fact_flights → %', SQLERRM;
    END;

    -----------------------------------------------------------------------
    -- 3. LOAD csv_dim_airports
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_dim_airports;

        EXECUTE format($f$
            COPY bronze.csv_dim_airports (
                airport_key, iata_code, airport_name, city, 
                country, continent, timezone, airport_type, hub_flag 
            )
            FROM '%s/dim_airports.csv'
            DELIMITER ','
            CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_dim_airports loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_dim_airports → %', SQLERRM;
    END;

    -----------------------------------------------------------------------
    -- 4. LOAD csv_dim_airlines
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_dim_airlines;

        EXECUTE format($f$
            COPY bronze.csv_dim_airlines(
                airline_key, iata_code, airline_name,
                country_of_origin, alliance, airline_type
            )
            FROM '%s/dim_airlines.csv'
            DELIMITER ','
            CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_dim_airlines loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_dim_airlines → %', SQLERRM;
    END;

    -----------------------------------------------------------------------
    -- BATCH SUMMARY
    -----------------------------------------------------------------------
    batch_end_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Bronze Load Completed';
    RAISE NOTICE 'Total Duration: % sec',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::INT;
    RAISE NOTICE 'Tables Loaded: 4';
    RAISE NOTICE '================================================';

END;
$$;