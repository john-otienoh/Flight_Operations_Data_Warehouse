# ER DIAGRAMS

## 1. Traditional ER Diagram (Crow's Foot Notation)

```text
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           FLIGHT OPERATIONS STAR SCHEMA                              │
└─────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────────┐
                                    │    dim_date      │
                                    ├──────────────────┤
                                    │ date_key (PK)    │
                                    │ full_date        │
                                    │ year             │
                                    │ quarter          │
                                    │ month            │
                                    │ month_name       │
                                    │ week             │
                                    │ day_of_week      │
                                    │ day_name         │
                                    │ is_weekend       │
                                    │ is_public_holiday│
                                    │ season           │
                                    │ iata_season      │
                                    └────────┬─────────┘
                                             │
                                             │ 1 : M
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
    ┌──────────────────────┐   ┌──────────────────────────┐   ┌──────────────────────┐
    │   dim_airports (Dep) │   │      fact_flights        │   │   dim_airports (Arr) │
    ├──────────────────────┤   ├──────────────────────────┤   ├──────────────────────┤
    │ airport_key (PK)     │   │ flight_key (PK)          │   │ airport_key (PK)     │
    │ iata_code            │   │ dep_airport_key (FK)─────┼───┼─┘                     │
    │ airport_name         │   │ arr_airport_key (FK)─────┼───┼─┐                     │
    │ city                 │   │ airline_key (FK)         │   │ iata_code            │
    │ country              │   │ date_key (FK)            │   │ airport_name         │
    │ continent            │   │ aircraft_key (FK)        │   │ city                 │
    │ timezone             │   │ scheduled_duration_mins  │   │ country              │
    │ airport_type         │   │ actual_duration_mins     │   │ continent            │
    │ hub_flag             │   │ delay_mins               │   │ timezone             │
    └──────────┬───────────┘   │ passengers               │   │ airport_type         │
               │               │ status                   │   │ hub_flag             │
               │               │ delay_category           │   └──────────────────────┘
               │               │ responsible_party        │
               │               └──────────┬───────────────┘
               │                          │
               │ 1 : M                    │ 1 : M
               │                          │
               ▼                          ▼
    ┌──────────────────────┐   ┌──────────────────────┐
    │    dim_airlines      │   │    dim_aircraft      │
    ├──────────────────────┤   ├──────────────────────┤
    │ airline_key (PK)     │   │ aircraft_key (PK)    │
    │ iata_code            │   │ aircraft_type        │
    │ airline_name         │   │ manufacturer         │
    │ country_of_origin    │   │ family               │
    │ alliance             │   │ range_km             │
    │ airline_type         │   │ typical_seats        │
    └──────────────────────┘   │ engine_count         │
                               │ engine_type          │
                               │ generation           │
                               └──────────────────────┘

Legend:
    (PK) = Primary Key
    (FK) = Foreign Key
    1 : M = One-to-Many Relationship
```

## 2. Flowchart-Style Relationship Map

```text
                    ┌─────────────────────────────────────────────────┐
                    │              FACT FLIGHTS TABLE                  │
                    │                 (Central Hub)                    │
                    └─────────────────────────────────────────────────┘
                                          │
            ┌─────────────────┬───────────┼───────────┬─────────────────┐
            │                 │           │           │                 │
            ▼                 ▼           ▼           ▼                 ▼
    ┌─────────────┐   ┌─────────────┐ ┌─────────┐ ┌─────────┐   ┌─────────────┐
    │  Airlines   │   │   Origin    │ │  Date   │ │Aircraft│   │Destination  │
    │   Dim       │   │  Airport    │ │  Dim    │ │  Dim   │   │  Airport    │
    │             │   │    Dim      │ │         │ │        │   │    Dim      │
    └─────────────┘   └─────────────┘ └─────────┘ └─────────┘   └─────────────┘
         │                   │              │          │               │
         │                   │              │          │               │
         ▼                   ▼              ▼          ▼               ▼
    [1:M]                [1:M]           [1:M]      [1:M]           [1:M]
    Each airline        Each origin      Each date  Each aircraft   Each dest
    has many flights    airport has      has many   has many        airport has
                        many flights     flights    flights         many flights
```

## 3. Detailed Relationship Matrix

```sql
-- Relationship Summary Table
┌─────────────────┬──────────────────┬─────────────────┬──────────────────────────┐
│  Parent Table   │  Foreign Key in   │  Relationship   │     Business Rule        │
│                 │   fact_flights    │    Type         │                          │
├─────────────────┼──────────────────┼─────────────────┼──────────────────────────┤
│  dim_airlines   │  airline_key      │  One-to-Many    │ One airline can operate  │
│                 │                   │                 │ multiple flights         │
├─────────────────┼──────────────────┼─────────────────┼──────────────────────────┤
│  dim_airports   │  dep_airport_key  │  One-to-Many    │ One airport can be the   │
│  (as origin)    │                   │                 │ origin for many flights  │
├─────────────────┼──────────────────┼─────────────────┼──────────────────────────┤
│  dim_airports   │  arr_airport_key  │  One-to-Many    │ One airport can be the   │
│  (as dest)      │                   │                 │ destination for many     │
│                 │                   │                 │ flights                  │
├─────────────────┼──────────────────┼─────────────────┼──────────────────────────┤
│  dim_date       │  date_key         │  One-to-Many    │ One date can have many   │
│                 │                   │                 │ flights                  │
├─────────────────┼──────────────────┼─────────────────┼──────────────────────────┤
│  dim_aircraft   │  aircraft_key     │  One-to-Many    │ One aircraft can operate │
│                 │                   │                 │ many flights over time   │
└─────────────────┴──────────────────┴─────────────────┴──────────────────────────┘
```


## 4. Mermaid.js ER Diagram (for markdown documentation)

```mermaid
erDiagram
    dim_airlines {
        int airline_key PK
        varchar iata_code
        varchar airline_name
        varchar country_of_origin
        varchar alliance
        varchar airline_type
    }
    
    dim_airports {
        int airport_key PK
        varchar iata_code
        varchar airport_name
        varchar city
        varchar country
        varchar continent
        varchar timezone
        varchar airport_type
        varchar hub_flag
    }
    
    dim_date {
        int date_key PK
        date full_date
        int year
        int quarter
        int month
        varchar month_name
        int week
        int day_of_week
        varchar day_name
        boolean is_weekend
        boolean is_public_holiday
        varchar season
        varchar iata_season
    }
    
    dim_aircraft {
        int aircraft_key PK
        varchar aircraft_type
        varchar manufacturer
        varchar family
        int range_km
        int typical_seats
        int engine_count
        varchar engine_type
        varchar generation
    }
    
    fact_flights {
        bigint flight_key PK
        int dep_airport_key FK
        int arr_airport_key FK
        int airline_key FK
        int date_key FK
        int aircraft_key FK
        int scheduled_duration_mins
        int actual_duration_mins
        int delay_mins
        int passengers
        varchar status
        varchar delay_category
        varchar responsible_party
    }
    
    %% Relationships
    dim_airlines ||--o{ fact_flights : "operates"
    dim_airports ||--o{ fact_flights : "origin"
    dim_airports ||--o{ fact_flights : "destination"
    dim_date ||--o{ fact_flights : "scheduled"
    dim_aircraft ||--o{ fact_flights : "assigned"
```

## 5. ASCII Art Data Flow Diagram

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW DIAGRAM                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Source Systems ──────► ETL Process ──────► Data Warehouse ──────► Reports
         │                      │                     │                    │
         │                      │                     │                    │
         ▼                      ▼                     ▼                    ▼
    ┌─────────┐           ┌──────────┐          ┌──────────┐        ┌──────────┐
    │Ops DB   │           │ Extract  │          │  Star    │        │ Monthly  │
    │Flight   │──────────►│          │─────────►│  Schema  │───────►│ OTP      │
    │Data     │           │Transform │          │          │        │ Report   │
    └─────────┘           │Load (ETL)│          └──────────┘        └──────────┘
                          └──────────┘                │                    │
                                                      │                    │
                                                      ▼                    ▼
                                                ┌──────────┐        ┌──────────┐
                                                │  PowerBI │        │ Delay    │
                                                │  Dashboard│───────►│ Analysis │
                                                └──────────┘        └──────────┘
```
