{{ config(
    materialized = 'incremental',
    unique_key = 'customer_id',
    tags = ['core', 'customers']
) }}

select
    customers.customer_id,
    customers.contact_id,
    customers.created_on,
    customers.country,
    -- Included country_code from a seed here since it's good practice to work with
    -- country codes instead of names. This allows country_code to be used downstream if needed.
    countries.country_code,
    customers.language,
    customers.has_active_subscription,
    customers.load_date_time,
    customers.last_updated_on
from {{ source('core', 'customers') }}
left join {{ ref("dim_countries") }} as countries
    on countries.country_name = customers.country
{% if is_incremental() %}
where
    -- Only refreshes rows that have had updates since last refresh.
    customers.last_updated_on::date > (select max(last_updated_on::date) from {{ this }})
{% endif %}
