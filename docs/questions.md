## Gold Layer — Business Questions by Domain

---

### **Operations & Performance**
*Sourced from: `fact_flights`, `flight_raw`*

**On-Time Performance**
- What is the overall on-time arrival rate across the network, and how has it trended month over month?
- Which routes have the worst on-time performance, and are they getting better or worse over time?
- What percentage of flights arrive early, on time, within 15 minutes, or severely late?
- Which day of the week has the highest rate of on-time departures network-wide?
- What hour of the day has the most delayed departures — is there a morning bank or evening peak effect?
- How does on-time performance differ between domestic and international routes?
- Which quarter of the year sees the sharpest degradation in punctuality?

**Delay Analysis**
- What is the average delay in minutes per route, per airline, and per airport?
- Which delay category (Weather, Carrier, NAS, Security, Late Aircraft) is responsible for the most total delay minutes in the network?
- How much of total delay is attributable to factors within the airline's control (Carrier delay) versus external (Weather, NAS)?
- Which routes have the highest proportion of severe delays (>120 mins)?
- Is late aircraft delay cascading — are certain hub airports propagating delays across the network?
- What is the average ground time (taxi out + taxi in) per airport, and which airports are the worst offenders?
- How does delay severity distribution differ between peak travel months and off-peak months?
- Which responsible party (Airline, ATC, Airport, Government) accounts for the most total delay minutes?

**Cancellation & Disruption**
- What is the cancellation rate per airline, per route, and per season?
- Which cancellation code (A=Carrier, B=Weather, C=NAS, D=Security) drives the most cancellations?
- Which routes are most prone to diversions, and what is the average extra flying time incurred?
- How do cancellation rates change during extreme weather months versus normal months?
- Which airports generate the most downstream cancellations due to their role as connection hubs?

**Fleet & Aircraft**
- Which aircraft tail numbers accumulate the most delay minutes — potential maintenance flags?
- What is the average air time per aircraft type, and which types fly the longest routes?
- Are certain tail numbers disproportionately involved in late aircraft delays, suggesting maintenance issues?
- What is the utilisation rate (flights per day) of each aircraft in the fleet?
- Which aircraft types have the best on-time performance record?

---

### **Route & Network Intelligence**
*Sourced from: `fact_flights`, `flight_raw`, `dim_airports`*

**Route Performance**
- What are the top 20 busiest routes by number of flights and by total passengers carried?
- Which routes generate the most delay minutes in absolute terms — highest operational burden?
- Which routes consistently underperform their scheduled duration — scheduled time too optimistic?
- What is the average load factor (passengers vs aircraft capacity) per route?
- Which origin-destination pairs have zero direct service but high connecting traffic — route gap opportunities?
- How does route performance differ between hub-to-hub, hub-to-spoke, and spoke-to-spoke operations?
- Which routes have the highest average flight duration variance — least predictable schedules?

**Airport Intelligence**
- Which airports are the top departure hubs by total outbound flights and passengers?
- Which airports have the highest arrival delay absorption — flights land late more than they depart late?
- What is the average taxi-out time per departure airport — which airports have the worst ground congestion?
- Which airports see the highest volume of diversions into them — unexpected traffic burden?
- How does hub status (hub vs non-hub) correlate with on-time performance?
- Which African hub airports carry the most international connecting traffic?
- Which airports have improved or deteriorated the most in on-time rankings year over year?
- What is the network centrality of each airport — how many other airports does it serve directly?

**Geographic & Continent Analysis**
- Which continent-to-continent corridor has the highest volume of flights?
- What is the average delay by continent of origin versus continent of destination?
- Which countries are underserved relative to their airport count?
- How does the African aviation network compare to European and Asian networks in terms of on-time performance?
- Which intercontinental routes have the worst cancellation rates?

---

### **Airline & Carrier Analytics**
*Sourced from: `fact_flights`, `flight_raw`, `dim_airlines`*

**Carrier Performance Benchmarking**
- Which airline has the best on-time departure performance across all routes?
- How do full-service carriers compare to low-cost and ultra low-cost carriers in punctuality?
- Which alliance (Star Alliance, Oneworld, SkyTeam) has the best collective on-time performance?
- Which airline has the highest cancellation rate, and what is the dominant cancellation cause?
- How does carrier-caused delay vary between alliance members and non-alliance carriers?
- Which airline carries the most passengers network-wide, and what is their average load per flight?
- Which airline operates the most routes, and how does route breadth correlate with punctuality?

**Alliance Intelligence**
- Does alliance membership correlate with better operational performance?
- Which alliance's member airlines contribute the most total delay minutes?
- How do interline connectivity patterns differ between the three major alliances?
- Which non-alliance carriers are performing at alliance-member levels — acquisition or partnership targets?

**Competitive Analysis**
- On shared routes (same origin–destination), which airline consistently performs better?
- Which low-cost carrier has the best on-time performance — competitive advantage in the budget segment?
- How does an airline's home country market share compare to its international share?
- Which airlines have grown or shrunk their route networks the most over the observed period?

---

### **Passenger & Revenue Intelligence**
*Sourced from: `fact_flights`, `dim_airports`, `dim_airlines`*

**Passenger Volume & Demand**
- What is the total passenger volume per route, per airline, and per month?
- Which routes have the highest passenger density — candidates for larger aircraft or higher frequency?
- How does passenger volume seasonally fluctuate, and which months are peak vs trough?
- Which airports serve as the largest passenger gateways by total enplanements?
- Which airlines carry the most passengers on transcontinental versus short-haul routes?
- What is the passenger distribution across airline types — how much of the market is low-cost?

**Capacity Planning**
- Which routes are consistently full (high passengers) but also frequently delayed — capacity constraint indicators?
- Which routes have declining passenger numbers — possible route retirement candidates?
- Where is there unmet demand (high delay, high load) that could justify new direct service?
- What is the trend in total seat capacity offered per month across the network?

---

### **Time & Seasonality Analysis**
*Sourced from: `fact_flights`, `flight_raw`*

- Which months have the highest total delay minutes — seasonal operational planning?
- How does delay performance differ between Q1 (winter) and Q3 (summer) travel peaks?
- Which day of the week has the lowest cancellation rate — best day to fly?
- What time of day has the highest probability of an on-time departure — best booking window?
- How does the network recover from large disruption events over subsequent days?
- Are delays more severe on Mondays and Fridays (business travel peaks) than mid-week?
- Which holiday periods (by month/week) show the sharpest spike in severe delays?
- What is the year-over-year growth in total flights operated per airline?

---

### **Data Quality & Operational Auditing**
*Sourced from: all silver tables via `_is_valid`, `_rejection_reason`*

- What percentage of bronze records failed silver validation per table and per load run?
- Which rejection reasons are most common — data quality issues to flag upstream?
- Are certain source files or ingestion batches producing systematically dirty data?
- Which airlines or airports have the highest rate of invalid records submitted?
- How has data quality improved or degraded across ingestion batches over time?
- Are there specific columns (e.g. `cancellation_code`, `air_time`) that are disproportionately NULL or malformed?

---

### **Executive & Strategic Reporting**
*Sourced from: all tables combined*

- What is the network-wide on-time performance rate this month versus the same month last year?
- Which airline is the most operationally reliable across all KPIs (delay, cancellation, diversion)?
- What is the total economic cost of delay in passenger-minutes lost this quarter?
- Which three routes should be prioritised for operational intervention based on compound KPI scores?
- How does our African hub network compare to global benchmarks on punctuality and passenger volume?
- What is the month-over-month trend in severe delay rates across the top 10 busiest routes?
- Which airports and airlines are driving 80% of total delay minutes (Pareto / 80-20 analysis)?
- What would network on-time performance look like if the top 5 delay-causing airports improved by 20%?

---

### Summary — Questions by Gold Table They Would Power

| Gold Table | Feeds |
|---|---|
| `gold.otp_by_route` | Route performance, delay analysis, competitive analysis |
| `gold.otp_by_airline` | Carrier benchmarking, alliance intelligence |
| `gold.otp_by_airport` | Airport intelligence, network centrality |
| `gold.delay_cause_summary` | Delay attribution, responsible party analysis |
| `gold.passenger_volume` | Demand planning, capacity, revenue intelligence |
| `gold.cancellation_summary` | Disruption analysis, seasonal planning |
| `gold.fleet_performance` | Aircraft utilisation, maintenance flags |
| `gold.time_series_kpis` | Seasonality, executive dashboards, YoY trends |
| `gold.data_quality_summary` | Auditing, upstream data issue escalation |