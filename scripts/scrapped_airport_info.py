import requests
from requests.exceptions import Timeout

ROUTES_URL = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/routes.dat'
AIRLINES_URL = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airlines.dat'
AIRPORTS_URL = "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"
COUNTRY_URL = "https://raw.githubusercontent.com/jpatokal/openflights/master/data/countries.dat"
AIRCRAFT_URL = "https://raw.githubusercontent.com/jpatokal/openflights/master/data/planes.dat"
try:
    response =  requests.get('https://www.google.com/travel/flights', timeout=100)
    print(response.text)
except Timeout:
    print("The request timed out")

