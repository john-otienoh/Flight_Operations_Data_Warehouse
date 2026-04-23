from graphviz import Digraph

# Create ER diagram
er = Digraph('Flight_Operations_ERD', filename='flight_operations_erd', format='png')
er.attr(rankdir='LR', size='12,8', dpi='300')

# Define table nodes with their attributes
tables = {
    'fact_flights': [
        'flight_key (PK)',
        'dep_airport_key (FK)',
        'arr_airport_key (FK)',
        'airline_key (FK)',
        'date_key (FK)',
        'aircraft_key (FK)',
        'scheduled_duration_mins',
        'actual_duration_mins',
        'delay_mins',
        'passengers',
        'status',
        'delay_category',
        'responsible_party'
    ],
    'dim_airlines': [
        'airline_key (PK)',
        'iata_code',
        'airline_name',
        'country_of_origin',
        'alliance',
        'airline_type'
    ],
    'dim_airports': [
        'airport_key (PK)',
        'iata_code',
        'airport_name',
        'city',
        'country',
        'continent',
        'timezone',
        'airport_type',
        'hub_flag'
    ],
    'dim_date': [
        'date_key (PK)',
        'full_date',
        'year',
        'quarter',
        'month',
        'month_name',
        'week',
        'day_of_week',
        'day_name',
        'is_weekend',
        'is_public_holiday',
        'season',
        'iata_season'
    ],
    'dim_aircraft': [
        'aircraft_key (PK)',
        'aircraft_type',
        'manufacturer',
        'family',
        'range_km',
        'typical_seats',
        'engine_count',
        'engine_type',
        'generation'
    ]
}

# Add tables to diagram
for table_name, columns in tables.items():
    # Create label with columns
    label = f'<<B>{table_name}</B><BR/>'
    label += '<BR/>'.join(['─' * 20] + columns)
    label += '>'
    
    er.node(table_name, label=label, shape='record', 
            style='filled', fillcolor='lightblue' if table_name == 'fact_flights' else 'lightyellow')

# Define relationships
relationships = [
    ('dim_airlines', 'fact_flights', '1', 'M'),
    ('dim_airports', 'fact_flights', '1', 'M'),
    ('dim_date', 'fact_flights', '1', 'M'),
    ('dim_aircraft', 'fact_flights', '1', 'M')
]

# Add edges with labels
for parent, child, cardinality_min, cardinality_max in relationships:
    if parent == 'dim_airports':
        # Need two relationships for origin and destination
        er.edge(parent, child, label='origin', headlabel=cardinality_max, taillabel=cardinality_min)
        er.edge(parent, child, label='destination', headlabel=cardinality_max, taillabel=cardinality_min, color='red')
    else:
        er.edge(parent, child, label=cardinality_min, headlabel=cardinality_max, taillabel=cardinality_min)

# Render the diagram
er.render(view=True)
print("ER Diagram generated as 'flight_operations_erd.png'")