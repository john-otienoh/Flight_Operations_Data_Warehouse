-- ===============================================================================
-- Procedure: silver.load_silver()
-- ===============================================================================
-- Purpose:
--     Reads from all four Bronze tables, applies type casting, computes derived
--     columns, sets data quality flags, generates record hashes, and loads into
--     the Silver layer.
-- Usage:
--     CALL silver.load_silver();
-- ===============================================================================

CREATE OR REPLACE PROCEDURE silver.load_silver()
language plpgsql
AS $$
DECLARE
    batch_start_time    TIMESTAMP;
    batch_end_time      TIMESTAMP;
    start_time          TIMESTAMP;
    end_time            TIMESTAMP;

BEGIN
    batch_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE 'Started At: %', batch_start_time;
    RAISE NOTICE '================================================';

    BEGIN
        start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '================================================';
        RAISE NOTICE 'Loading Silver Layer';

        TRUNCATE TABLE silver.fact_flights;
        INSERT INTO silver.fact_flights(
            dep_airport_key,
            arr_airport_key,
            airline_key,
            date_key,
            aircraft_key,

            scheduled_duration_mins,
            actual_duartion_mins,
            delay_mins,
            passenegers,
            status,
            delay_category,
            responsible_party,
            delay_severity,
            flight_duration_diff_mins,

            _is_valid,
            _rejection_reason,
            _source_table,
            _ingested_at,
            _silver_loaded_at,
            _record_hash
        )
        SELECT
            dep_airport_key,
            arr_airport_key,
            airline_key,

            CASE
                WHEN date_key ~ '^\d{8}$'
                THEN TO_DATE(date_key, 'YYYYMMDD')
                ELSE NULL
            END     AS date_key,
            aircraft_key,

            NULLIF(scheduled_duration_mins, 'N/A')::INTEGER AS scheduled_duration_mins,
            NULLIF(actual_duartion_mins, 'N/A')::INTEGER AS actual_duartion_mins,
            NULLIF(delay_mins, 'N/A')::INTEGER AS delay_mins,
            NULLIF(passenegers, 'N/A')::INTEGER AS passenegers,

            TRIM(status) AS status,
            TRIM(delay_category) AS delay_category,
            TRIM(responsible_party) AS responsible_party,

            CASE
                WHEN NULLIF(delay_mins, 'N/A')::INTEGER IS NULL THEN 'N/A'
                WHEN NULLIF(delay_mins, 'N/A')::INTEGER = 0 THEN 'None'
                WHEN NULLIF(delay_mins, 'N/A')::INTEGER <= 30   THEN 'Minor'
                WHEN NULLIF(delay_mins, 'N/A')::INTEGER <= 120  THEN 'Moderate'
                ELSE    'Severe'
                
            END     AS delay_severity,

            NULLIF(actual_duartion_mins, 'N/A')::INTEGER - NULLIF(scheduled_duration_mins, 'N/A') AS flight_duration_diff_mins,

            NOT(
                dep_airport_key is NULL OR dep_airport_key = ''
                OR arr_airport_key IS NULL OR arr_airport_key = ''
                OR airline_key IS NULL OR airline_key = ''
                OR date_key IS NULL OR date_key !~ '^\d{8}$'
                OR NULLIF(scheduled_duration_mins, 'N/A')::INTEGER <= 0
                OR NULLIF(passenegers, 'N/A')::INTEGER < 0
            ) AS _is_valid,

            CASE
                WHEN dep_airport_key IS NULL OR dep_airport_key = ''
                    THEN 'Missing departure airport key'
                 WHEN arr_airport_key IS NULL OR arr_airport_key = ''
                    THEN 'Missing arrival airport key'
                WHEN airline_key IS NULL OR airline_key = ''
                    THEN 'Missing airline key'
                WHEN date_key IS NULL OR date_key !~ '^\d{8}$'
                    THEN 'Invalid or missing date_key — expected YYYYMMDD'
                WHEN NULLIF(scheduled_duration_mins, 'N/A')::INTEGER <= 0
                    THEN 'Scheduled duration must be greater than zero'
                WHEN NULLIF(passengers, 'N/A')::INTEGER < 0
                    THEN 'Passenger count cannot be negative'
                ELSE NULL
            END   AS _rejection_reason,
            'bronze.csv_fact_flights'                       AS _source_table,
            _ingested_at,
            MD5(CONCAT_WS('|',
                LOWER(dep_airport_key),
                LOWER(arr_airport_key),
                LOWER(airline_key),
                date_key,
                LOWER(aircraft_key),
                LOWER(status)
            )) AS _record_hash

        FROM bronze.csv_fact_flights;

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'silver.fact_flights loaded in % sec',
            EXTRACT(EPOCH  FROM (end_time - start_time))::INT;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: silver.fact_flights -> %', SQLERRM;
    END;
-- (CAST(NULLIF(scheduled_duration_mins, 'N/A') AS INTEGER)) AS scheduled_duration_mins

    BEGIN
        start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '------------------------------------------------';
        RAISE NOTICE 'Loading: silver.dim_airports';

        TRUNCATE TABLE silver.dim_airports;
        INSERT INTO silver.dim_airports(
            airport_key,
            iata_code,
            airport_name,
            city, 
            country,
            continent,
            timezone,
            airport_type,
            hub_flag,
            _is_valid,
            _rejection_reason,
            _source_table,
            _ingested_at,
            _record_hash
        )
        SELECT
            TRIM(airport_key) AS airport_key,
            UPPER(TRIM(iata_code)) AS airport_key,
            TRIM(airport_name),
            TRIM(city), 
            TRIM(country),
            TRIM(continent),
            TRIM(timezone),
            TRIM(airport_type),

            CASE UPPER(TRIM(hub_flag))
                WHEN 'Y' THEN TRUE
                ELSE FALSE
            END as hub_flag,
            NOT (
                airport_key IS NULL OR airport_key = ''
                OR iata_code IS NULL OR LENGTH(TRIM(iata_code)) <> 3
                OR city IS NULL OR city = ''
                OR country IS NULL OR country = ''
                OR continent NOT IN (
                    'Africe', 'Asia', 'Europe',
                    'North America', 'South America', 'Oceania'
                )
            ) AS _is_valid,

            CASE
                WHEN airport_key IS NULL OR airport_key = ''
                    THEN 'Missing airport key'
                WHEN iata_code is NULL OR LENGTH(TRIM(iata_code)) <> 3
                    THEN 'IATA code must be exactly # characters'
                WHEN city is NULL OR city = ''
                    THEN 'Missing city'
                WHEN country IS NULL OR country = ''
                    THEN 'Missing country'
                WHEN continent NOT IN (
                    'Africa','Asia','Europe',
                    'North America','South America','Oceania'
                )   
                    THEN 'Unknown continent: ' || COALESCE(continent, 'NULL')
                ELSE NULL
            END AS _rejection_reason,
            'bronze.csv_dim_airports'                       AS _source_table,
            _ingested_at,

            MD5(CONCAT_WS('|',
                LOWER(TRIM(airport_key)),
                UPPER(TRIM(iata_code)),
                TRIM(airport_name),
                TRIM(city),
                TRIM(country)  
            )) AS _record_hash
        FROM bronze.csv_dim_airports;

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'silver.dim_airports loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: silver.dim_airports';
    END;
BEGIN
    start_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading: silver.dim_airlines';

    TRUNCATE TABLE silver.dim_airlines;
    
    INSERT INTO silver.dim_airlines(
        airline_key,
        iata_code,
        airline_name,
        country_of_origin,
        alliance,
        airline_type,
        _is_valid,
        _rejection_reason,
        _source_table,
        _ingested_at,
        _record_hash
    )
    SELECT
        TRIM(airline_key) AS airline_key,
        UPPER(TRIM(iata_code)) AS iata_code,
        TRIM(airline_name),
        TRIM(country_of_origin),
        TRIM(alliance),
        TRIM(airline_type),

        NOT (
            airline_key IS NULL OR airline_key = ''
            OR iata_code IS NULL OR LENGTH(TRIM(iata_code)) <> 2
            OR airline_name IS NULL OR airline_name = ''
            OR alliance NOT IN (
                'Star Alliance', 'Oneworld', 'SkyTeam', 'None'
            )
            OR airline_type NOT IN (
                'Full-Service','Low-Cost','Ultra Low-Cost','Regional'
            )
            
        ) AS _is_valid,

        CASE
            WHEN airline_key is NULL OR airline_key = ''
            THEN 'Missing airline key'
                WHEN iata_code IS NULL OR LENGTH(TRIM(iata_code)) <> 2
                    THEN 'IATA code must be exactly 2 characters'
                WHEN airline_name IS NULL OR airline_name = ''
                    THEN 'Missing airline name'
                WHEN alliance NOT IN ('Star Alliance','Oneworld','SkyTeam','None')
                    THEN 'Unknown alliance: ' || COALESCE(alliance, 'NULL')
                WHEN airline_type NOT IN (
                    'Full-Service','Low-Cost','Ultra Low-Cost','Regional'
                )
                    THEN 'Unknown airline type: ' || COALESCE(airline_type, 'NULL')
                ELSE NULL
            END                                             AS _rejection_reason,

            'bronze.csv_dim_airlines'                       AS _source_table,
            _ingested_at,
            MD5(CONCAT_WS('|',
                LOWER(TRIM(airline_key)),
                UPPER(TRIM(iata_code)),
                TRIM(airline_name),
                TRIM(alliance),
                TRIM(airline_type)
            )) AS _record_hash
        FROM bronze.csv_dim_airlines;

        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'silver.dim_airlines loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: silver.dim_airports';
    END;

    BEGIN
        start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '------------------------------------------------';
        RAISE NOTICE 'Loading: silver.flight_raw';
        TRUNCATE TABLE silver.flight_raw;

        INSERT INTO silver.flight_raw(
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
            carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay,
            primary_delay_cause,
            dep_hour,
            _is_valid,
            _rejection_reason,
            _source_table,
            _ingested_at,
            _record_hash
        )
        SELECT
            NULLIF(year, '')::SMALLINT AS year,
            NULLIF(quarter, '')::SMALLINT AS quarter,
            NULLIF(month, '')::SMALLINT AS month,
            NULLIF(day_of_month, '')::SMALLINT AS day_of_month,
            NULLIF(day_of_week, '')::SMALLINT AS day_of_week,
            NULLIF(fl_date, '')::DATE AS fl_date,
            UPPER(TRIM(op_unique_carrier)) AS op_unique_carrier,
            UPPER(TRIM(op_carrier)) AS op_carrier,
            UPPER(TRIM(tail_num)) AS tail_num,
            NULLIF(origin_airport_id, '')::SMALLINT AS origin_airport_id,
            NULLIF(origin_airport_seq_id, '')::SMALLINT AS origin_airport_seq_id,
            NULLIF(origin_city_market_id, '')::SMALLINT AS origin_city_market_id,
            UPPER(TRIM(origin)) AS origin,
            TRIM(origin_city_name) AS origin_city_name,
            UPPER(TRIM(origin_state_abr))               AS origin_state_abr,
            TRIM(origin_state_nm)                       AS origin_state_nm,
            NULLIF(origin_wac,             '')::INTEGER AS origin_wac,

            NULLIF(dest_airport_id, '')::SMALLINT AS dest_airport_id,
            NULLIF(dest_airport_seq_id, '')::SMALLINT AS dest_airport_seq_id,
            NULLIF(dest_city_market_id, '')::SMALLINT AS dest_city_market_id,
            UPPER(TRIM(dest)) AS dest,
            TRIM(dest_city_name) AS dest_city_name,
            UPPER(TRIM(dest_state_abr))               AS dest_state_abr,
            TRIM(dest_state_nm)                       AS dest_state_nm,
            NULLIF(dest_wac,             '')::INTEGER AS dest_wac,

            NULLIF(crs_dep_time, '')::NUMERIC::SMALLINT AS crs_dep_time,
            NULLIF(dep_time, '')::NUMERIC::SMALLINT AS dep_time,
            NULLIF(taxi_out, '')::NUMERIC::SMALLINT AS taxi_out,
            NULLIF(wheels_off, '')::NUMERIC::SMALLINT AS wheels_off,
            NULLIF(wheels_on, '')::NUMERIC::SMALLINT AS wheels_on,
            NULLIF(taxi_in, '')::NUMERIC::SMALLINT AS taxi_in,
            NULLIF(arr_time, '')::NUMERIC::SMALLINT AS arr_time,

            NULLIF(cancelled, '')::NUMERIC = 1 AS cancelled,
            NULLIF(UPPER(TRIM(cancellation_code)), '')  AS cancellation_code,
            NULLIF(diverted, '')::NUMERIC = 1 AS diverted,

            NULLIF(air_time, '')::NUMERIC::SMALLINT AS carrier_delay,
            NULLIF(weather_delay, '')::NUMERIC::SMALLINT AS weather_delay,
            NULLIF(nas_delay, '')::NUMERIC::SMALLINT AS late_aircraft_delay,

            CASE
                WHEN GREATEST(
                    COALESCE(NULLIF(carrier_delay, '')::NUMERIC, 0),
                    COALESCE(NULLIF(weather_delay, '')::NUMERIC, 0),
                    COALESCE(NULLIF(nas_delay,           '')::NUMERIC, 0),
                    COALESCE(NULLIF(security_delay,      '')::NUMERIC, 0),
                    COALESCE(NULLIF(late_aircraft_delay, '')::NUMERIC, 0)
                ) = 0
                    THEN 'None'
                
                WHEN COALESCE(NULLIF(carrier_delay, '')::NUMERIC, 0)
                    = GREATEST(
                        COALESCE(NULLIF(carrier_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(weather_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(nas_delay,           '')::NUMERIC, 0),
                        COALESCE(NULLIF(security_delay,      '')::NUMERIC, 0),
                        COALESCE(NULLIF(late_aircraft_delay, '')::NUMERIC, 0)
                    ) THEN 'Carrier'
                
                WHEN COALESCE(NULLIF(weather_delay, '')::NUMERIC, 0)
                    = GREATEST(
                        COALESCE(NULLIF(carrier_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(weather_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(nas_delay,           '')::NUMERIC, 0),
                        COALESCE(NULLIF(security_delay,      '')::NUMERIC, 0),
                        COALESCE(NULLIF(late_aircraft_delay, '')::NUMERIC, 0)
                    ) THEN 'Weather'

                WHEN COALESCE(NULLIF(nas_delay, '')::NUMERIC, 0)
                    = GREATEST(
                        COALESCE(NULLIF(carrier_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(weather_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(nas_delay,           '')::NUMERIC, 0),
                        COALESCE(NULLIF(security_delay,      '')::NUMERIC, 0),
                        COALESCE(NULLIF(late_aircraft_delay, '')::NUMERIC, 0)
                    ) THEN 'NAS'
                
                WHEN COALESCE(NULLIF(security_delay, '')::NUMERIC, 0)
                    = GREATEST(
                        COALESCE(NULLIF(carrier_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(weather_delay,       '')::NUMERIC, 0),
                        COALESCE(NULLIF(nas_delay,           '')::NUMERIC, 0),
                        COALESCE(NULLIF(security_delay,      '')::NUMERIC, 0),
                        COALESCE(NULLIF(late_aircraft_delay, '')::NUMERIC, 0)
                    ) THEN 'Security'
                
                ELSE 'Late Aircraft'
            END AS primary_delay_cause,
            NULLIF(crs_dep_time, '')::NUMERIC::INTEGER / 100 AS dep_hour,

            NOT(
                origin IS NULL OR TRIM(origin) = ''
                OR dest IS NULL OR TRIM(dest) = ''
                OR fl_date IS NULL OR NULLIF(fl_date, '') IS NULL
                -- Flight date is required for all time-based analysis
                OR NULLIF(air_time, '')::NUMERIC <= 0
                -- A flight in the air must have positive airborne time
                OR NULLIF(distance, '')::NUMERIC <= 0
                -- A flight must have positive distance
                OR (
                    NULLIF(cancelled, '')::NUMERIC <> 1
                    AND NULLIF(cancellation_code, '') IS NOT NULL
                )
            ) as _is_valid,

            CASE
                WHEN origin IS NULL OR TRIM(origin) = ''
                    THEN 'Missing origin airport code'
                WHEN dest IS NULL OR TRIM(dest) = ''
                    THEN 'Missing destination airport code'
                WHEN fl_date IS NULL OR NULLIF(fl_date, '') IS NULL
                    THEN 'Missing or invalid flight date'
                WHEN NULLIF(air_time, '')::NUMERIC <= 0
                    THEN 'Air time must be greater than zero'
                WHEN NULLIF(distance, '')::NUMERIC <= 0
                    THEN 'Distance must be greater than zero'
                WHEN (
                    NULLIF(cancelled, '')::NUMERIC <> 1
                    AND NULLIF(cancellation_code, '') IS NOT NULL
                )
                    THEN 'Cancellation code present on non-cancelled flight'
                ELSE NULL
            END                                             AS _rejection_reason,

            'bronze.csv_flight_raw'                         AS _source_table,
            _ingested_at,
            MD5(CONCAT_WS('|',
                 NULLIF(fl_date, ''),
                UPPER(TRIM(op_unique_carrier)),
                UPPER(TRIM(tail_num)),
                UPPER(TRIM(origin)),
                UPPER(TRIM(dest)),
                NULLIF(crs_dep_time,  '')
            )) AS _record_hash
        FROM bronze.csv_flight_raw;
        end_time := CLOCK_TIMESTAMP();
        RAISE NOTICE 'silver.flight_raw loaded in % sec',
            EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed: silver.flight_raw → %', SQLERRM;
    END;

    batch_end_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Silver Load Completed';
    RAISE NOTICE 'Total Duration: % sec',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::INT;
    RAISE NOTICE '================================================';

END;
$$;
