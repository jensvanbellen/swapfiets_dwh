import duckdb

# Connect to a new or existing database file.
conn = duckdb.connect('dbt.duckdb')

# Create the schema if it doesn't exist.
conn.execute("create schema if not exists sources;")

# Create customers table if it doesn't exist.
conn.execute("""
    create table if not exists sources.customers (
        load_date_time timestamp,
        customer_id varchar,
        contact_id varchar,
        created_on timestamp,
        last_updated_on timestamp,
        country varchar,
        language varchar,
        has_active_subscription boolean
    );
""")

# Create subscriptions table if it doesn't exist.
conn.execute("""
    create table if not exists sources.subscriptions (
        load_date_time timestamp,
        country varchar,
        subscription_created_on timestamp,
        customer_created_on timestamp,
        customer_id varchar,
        subscription_id varchar,
        subscription_start timestamp,
        subscription_end timestamp,
        subscription_type_id varchar,
        is_active_subscription boolean
    );
""")

# Create actions table if it doesn't exist.
conn.execute("""
    create table if not exists sources.actions (
        load_date_time timestamp,
        country varchar,
        action_id varchar,
        asset_id varchar,
        customer_id varchar,
        subscription_id varchar,
        -- column is duplicated in source data
        action_id_2 varchar,
        created_on timestamp,
        completed_on timestamp,
        action_type_code integer,
        action_type_name varchar,
        status_name varchar
    );
""")

# Load the customers CSV file into the table.
conn.execute("""
    copy sources.customers from 'swapfiets_raw_data/customers.csv'
    with (
        format csv, 
        header true,
        delim ',',
        null_padding true
    );
""")

# Load the subscriptions CSV file into the table.
conn.execute("""
    copy sources.subscriptions from 'swapfiets_raw_data/subscriptions.csv'
    with (
        format csv, 
        header true,
        delim ',',
        null_padding true
    );
""")

# Load the actions CSV file into the table.
conn.execute("""
    copy sources.actions from 'swapfiets_raw_data/actions.csv'
    with (
        format csv, 
        header true,
        delim ',',
        null_padding true
    );
""")

# Close the connection.
conn.close()
