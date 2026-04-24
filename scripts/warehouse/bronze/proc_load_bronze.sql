CREATE OR REPLACE PROCEDURE bronze.load_bronze(p_base_path TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
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

        TRUNCATE TABLE bronze.csv_fact_flight_raw;

        EXECUTE format($f$
            COPY bronze.csv_fact_flight_raw
            FROM '%s/csv_fact_flight_raw.csv'
            DELIMITER ','
            CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_fact_flight_raw loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_fact_flight_raw → %', SQLERRM;
    END;
    -----------------------------------------------------------------------
    -- 2. LOAD csv_fact_flights
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_fact_flights;

        EXECUTE format($f$
            COPY bronze.csv_fact_flights
            FROM '%s/fact_flights.csv'
            DELIMITER ','
            CSV HEADER
        $f$, p_base_path);

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'csv_fact_flights loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;

    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: csv_fact_flights → %', SQLERRM;
    END;

    -----------------------------------------------------------------------
    -- 2. LOAD csv_dim_airports
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_dim_airports;

        EXECUTE format($f$
            COPY bronze.csv_dim_airports
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
    -- 3. LOAD csv_dim_airlines
    -----------------------------------------------------------------------
    BEGIN
        start_time := CLOCK_TIMESTAMP();

        TRUNCATE TABLE bronze.csv_dim_airlines;

        EXECUTE format($f$
            COPY bronze.csv_dim_airlines
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
    RAISE NOTICE 'Tables Loaded: 3';
    RAISE NOTICE '================================================';

END;
$$;