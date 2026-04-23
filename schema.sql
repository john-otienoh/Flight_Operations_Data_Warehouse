-- Create fact_flights table with proper PostgreSQL data types and constraints
CREATE TABLE fact_flights (
    -- Primary Key
    flight_key BIGSERIAL PRIMARY KEY,
    
    -- Foreign Keys (referencing dimension tables)
    dep_airport_key INTEGER NOT NULL,
    arr_airport_key INTEGER NOT NULL,
    airline_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    aircraft_key INTEGER NOT NULL,
    
    -- Flight Duration Metrics (in minutes)
    scheduled_duration_mins INTEGER NOT NULL CHECK (scheduled_duration_mins > 0),
    actual_duration_mins INTEGER CHECK (actual_duration_mins >= 0),
    
    -- Delay Information (in minutes)
    delay_mins INTEGER DEFAULT 0,
    
    -- Passenger Information
    passengers INTEGER DEFAULT 0 CHECK (passengers >= 0),
    
    -- Flight Status Information
    status VARCHAR(20) NOT NULL,
    delay_category VARCHAR(20),
    responsible_party VARCHAR(20),
    
    -- Audit Columns (optional but recommended)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_status CHECK (status IN ('On Time', 'Delayed', 'Cancelled', 'Diverted')),
    CONSTRAINT valid_delay_category CHECK (delay_category IN ('None', 'Technical', 'Weather', 'Crew', 'ATC', 'Security')),
    CONSTRAINT valid_responsible_party CHECK (responsible_party IN ('None', 'Airline', 'External', 'NAS')),
    CONSTRAINT valid_duration_logic CHECK (
        (status = 'Cancelled' AND actual_duration_mins IS NULL) OR
        (status != 'Cancelled' AND actual_duration_mins IS NOT NULL)
    )
);
-- dim_airports
CREATE TABLE dim_airports (
    airport_key INTEGER PRIMARY KEY,
    iata_code VARCHAR(3) NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    continent VARCHAR(20) NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    airport_type VARCHAR(20) NOT NULL,
    hub_flag VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- dim_airlines
CREATE TABLE dim_airlines (
    airline_key INTEGER PRIMARY KEY,
    iata_code VARCHAR(3) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL,
    country_of_origin VARCHAR(50) NOT NULL,
    alliance VARCHAR(20),
    airline_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- dim_date
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name VARCHAR(20) NOT NULL,
    week INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_public_holiday BOOLEAN DEFAULT FALSE,
    season VARCHAR(10) NOT NULL,
    iata_season VARCHAR(10) NOT NULL
);

-- dim_aircraft
CREATE TABLE dim_aircraft (
    aircraft_key INTEGER PRIMARY KEY,
    aircraft_type VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    family VARCHAR(50) NOT NULL,
    range_km INTEGER NOT NULL,
    typical_seats INTEGER NOT NULL,
    engine_count INTEGER NOT NULL,
    engine_type VARCHAR(20) NOT NULL,
    generation VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraints to fact_flights
ALTER TABLE fact_flights 
    ADD CONSTRAINT fk_fact_flights_dep_airport 
    FOREIGN KEY (dep_airport_key) REFERENCES dim_airports(airport_key);

ALTER TABLE fact_flights 
    ADD CONSTRAINT fk_fact_flights_arr_airport 
    FOREIGN KEY (arr_airport_key) REFERENCES dim_airports(airport_key);

ALTER TABLE fact_flights 
    ADD CONSTRAINT fk_fact_flights_airline 
    FOREIGN KEY (airline_key) REFERENCES dim_airlines(airline_key);

ALTER TABLE fact_flights 
    ADD CONSTRAINT fk_fact_flights_date 
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key);

ALTER TABLE fact_flights 
    ADD CONSTRAINT fk_fact_flights_aircraft 
    FOREIGN KEY (aircraft_key) REFERENCES dim_aircraft(aircraft_key);
    
-- Create indexes for better query performance
CREATE INDEX idx_fact_flights_dep_airport ON fact_flights(dep_airport_key);
CREATE INDEX idx_fact_flights_arr_airport ON fact_flights(arr_airport_key);
CREATE INDEX idx_fact_flights_airline ON fact_flights(airline_key);
CREATE INDEX idx_fact_flights_date ON fact_flights(date_key);
CREATE INDEX idx_fact_flights_aircraft ON fact_flights(aircraft_key);
CREATE INDEX idx_fact_flights_status ON fact_flights(status);
CREATE INDEX idx_fact_flights_delay_category ON fact_flights(delay_category);
CREATE INDEX idx_fact_flights_date_status ON fact_flights(date_key, status);
CREATE INDEX idx_fact_flights_airline_date ON fact_flights(airline_key, date_key);

-- Composite index for common query patterns
CREATE INDEX idx_fact_flights_airline_date_status ON fact_flights(airline_key, date_key, status);