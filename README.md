# Jens van Bellen's solution to the Swapfiets dbt Analytics Engineer Case Project

Welcome to my solution to the Swapfiets dbt case project. I cloned the [original repo](https://github.com/swapfiets-data/dbt-template) and added my changes in this personal repo.

To get started:
1. Add the Swapfiets CSV source files in the swapfiets_raw_data directory.
2. Run the create_duckdb.py script to set up the database and populate it with source data.
3. Run usual commands such as `dbt run` and `dbt test` to create and test my dbt models
4. Run `dbt docs generate` and `dbt docs serve` to be able to read my documentation and check the lineage graph.

Below I have included the original README for visibility:

---

# Swapfiets dbt Analytics Engineer Case Project

Welcome to the Swapfiets dbt Analytics Engineer case project! This README provides step-by-step instructions for setting up and running the project.

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Python** (version 3.8 or higher)
- **Poetry** (for dependency management)j
  - Run the following command in your terminal: 
```bash
curl -sSL https://install.python-poetry.org | python3 -
```

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

# Activate the poetry environment that was just created
poetry shell

# Check whether dbt works
dbt --version
```

### 3. Set Up dbt Profile

dbt requires a profiles.yml file to connect to the database. This file is included in the project root and is configured to use DuckDB. Ensure the following configuration is present in profiles.yml:
```yaml
default:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ./dbt.duckdb
```

### 4. Run dbt

You can use dbt to create data models.

### Running on Windows

The steps are the same for Windows. Ensure Python and Poetry are installed correctly, and use PowerShell for executing the commands.

### Notes

	•	Adhere to dbt’s best practices while working on this project
	•	If you encounter issues, refer to the dbt documentation for help.

Good luck, and feel free to reach out if you have any questions!

