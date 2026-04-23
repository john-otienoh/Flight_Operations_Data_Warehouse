# Flight Operations Data Warehouse
**What it is**: A classic star schema warehouse built around a central flight facts table, supporting operational reporting on delays, cancellations, and on-time performance across airlines, airports, and time periods.
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
