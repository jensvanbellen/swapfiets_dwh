# Swapfiets dbt Analytics Engineer Case Project

Welcome to the Swapfiets dbt Analytics Engineer case project! This README provides step-by-step instructions for setting up and running the project.

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Python** (version 3.8 or higher)
- **Poetry** (for dependency management)
- **DuckDB**
- **dbt** (with the `dbt-duckdb` adapter)

---

## Setup Instructions

### 1. Clone the Repository

First, clone the repository and navigate to the project directory:

```bash
git clone <repository_url>
cd <repository_folder>
```
### 2. Install Dependencies

Install the required Python dependencies using Poetry:
```bash
poetry install
```

### 3. Set Up dbt Profile

dbt requires a profiles.yml file to connect to the database. This file is included in the project root and is configured to use DuckDB. Ensure the following configuration is present in profiles.yml:
```yaml
your_profile_name:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ./dbt.duckdb
```

### 4. Initialize the DuckDB Database

Run the provided script to create an empty DuckDB database:
```bash
python create_duckdb.py
```

### 5. Load Seed Data

Load the CSV seed data into the database:
```bash
dbt seed
```

### 6. Run Models

Execute all dbt models to generate the necessary tables:
```bash
dbt run
```

### 7. Run Tests

Validate the models with dbt’s built-in tests:
```bash
dbt test
```

### Running on Windows

The steps are the same for Windows. Ensure Python and Poetry are installed correctly, and use PowerShell for executing the commands.

### Notes

	•	Adhere to dbt’s best practices while working on this project, including:
	•	Modularizing models into staging, intermediate, and mart layers.
	•	Adding model.yml files for metadata and testing.
	•	Implementing appropriate tests for data quality and integrity.
	•	If you encounter issues, refer to the dbt documentation for help.

Good luck, and feel free to reach out if you have any questions!

