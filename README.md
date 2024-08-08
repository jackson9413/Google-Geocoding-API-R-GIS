# Google Geoencoding to Match New Zealand DHB and Meshblock Region

This project uses the Google Geoencoding API to obtain geocoordinates based on input addresses. It then uses R GIS tools to map these geocoordinates to New Zealand DHB and Meshblock regions. Deprivation information can be obtained after that.

## Table of Contents
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Getting Started

These instructions will help you set up the project on your local machine for development and testing purposes.

### Prerequisites

You will need the following software and tools:
- Python
- R
- Google Cloud Account
- Bash Environment

### Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/jackson9413/Google-Geocoding-API-R-GIS.git
    cd Google-Geocoding-API-R-GIS
    ```

2. **Set up Python environment**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. **Set up R environment**:
    Install the necessary R packages as specified in your R scripts.

4. **Configure Google Cloud**:
    Follow the instructions to set up your Google Cloud account and obtain the API key for the Google Geoencoding API.

## Usage

1. **Run R_Geoencode_Match_Address.R**:
    This script gets the geocoordinates based on the addresses input using the Google Geoencoding API.
    ```bash
    Rscript R_Geoencode_Match_Address.R
    ```

2. **Run Python_Address_fuzzy_match.py**:
    This script compares the addresses matched and validated by the Google Geoencoding API with the original addresses.
    ```bash
    python Python_Address_fuzzy_match.py
    ```

3. **Run R_Match_DHB_Deprevation_Based_on_Geocoordinates_Load_to_SQL.R**:
    This script maps the validated addresses to different DHBs and meshblock regions with other metadata information by geocoordinates. The deprivation information is then obtained and loaded into an SQL database.
    ```bash
    Rscript R_Match_DHB_Deprevation_Based_on_Geocoordinates_Load_to_SQL.R
    ```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.