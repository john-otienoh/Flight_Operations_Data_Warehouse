# Flight Operations Data Warehouse
**What it is**: A classic star schema warehouse built around a central flight facts table, supporting operational reporting on delays, cancellations, and on-time performance across airlines, airports, and time periods.</br>
**Real-world use**: The operational core of any airline analytics team. Every OTP report, delay attribution analysis, and schedule adherence dashboard reads from a warehouse structured exactly like this.

## Schema
```sql
fact_flights
  flight_key, dep_airport_key, arr_airport_key,
  airline_key, date_key, aircraft_key,
  scheduled_duration_mins, actual_duration_mins,
  delay_mins, passengers, status,
  delay_category, responsible_party

dim_airports
  airport_key, iata_code, airport_name,
  city, country, continent, timezone,
  airport_type, hub_flag

dim_airlines
  airline_key, iata_code, airline_name,
  country_of_origin, alliance, airline_type

dim_date
  date_key, full_date, year, quarter,
  month, month_name, week, day_of_week,
  day_name, is_weekend, is_public_holiday,
  season, iata_season

dim_aircraft
  aircraft_key, aircraft_type, manufacturer,
  family, range_km, typical_seats,
  engine_count, engine_type, generation

```

**Key reports supported**

- Monthly OTP by airline and alliance
- Delay minutes by responsible party and category
- Busiest routes by passenger volume
- Airport hub performance scorecard
- Year-over-year flight volume trends

Let’s start what we will do:

First, I will do my research to understand how airline companies work and what are the main business processes we are interested in analyzing.
Then, I will gather some of the questions that we need our model to answer.
Then we will dive into the modeling process, defining the dimensions, facts, measurements, granularity, sparsity, and summarizability issues for our model.
Next step will be designing the schema for our model.
Then I will collect some data to populate into the data warehouse.
Next step, I will integrate the data into the database (SQL SERVER Database).
Before diving into the analysis, I will spend some time talking about indexes.
The last step is what we are doing all those steps for, which is analyzing the data warehouse and getting interesting insights to help the Management Team make data-driven decisions.

In the project files you will see some files:

Project Documentations.pdf: The project's documentations.
DWH Schema.png: The schema for our data warehouse model.
DWH Tables.xlsx: The dimensions / facts / indexes of the data warehouse.
DWH Creation.SQL: The SQL Scripts for creating the data warehouse tables.
Schema.pdf: The schema for our data warehouse generated from SQL SERVER.
Tables' Populations: The SQL Scripts to poulate the data into the tables.
DWHProjAirlineCom.bak: Backup of the data warehouse, you can restore it using SQL Server Management Studio.
Insights.SQL: The SQL Queries used to gain insights and answer questions from the data warehouse.
