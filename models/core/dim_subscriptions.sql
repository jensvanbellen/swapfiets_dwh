{{ config(
    materialized = 'table',
    tags = ['core', 'subscriptions']
) }}

-- Considerations for materialization:
-- 1. Currently materialized as a table because there's no last_updated_on timestamp available
--    to facilitate incremental refreshes.
-- 2. Performing incremental refreshes with existing columns and a set refresh date range
--    could risk missing updates on certain subscriptions.
-- 3. The future inclusion of a last_updated_on timestamp would be helpful.
-- 4. A materialized_view might also offer a compromise between table and incremental,
--    but it has limitations (e.g., when used for downstream models, depending on the data warehouse used).
--    Also, this is not yet available for the DuckDB dbt adapter!

select
	subscriptions.subscription_id,
	subscriptions.subscription_type_id,
	subscriptions.subscription_created_on,
	subscriptions.subscription_start,
	subscriptions.subscription_end,
	subscriptions.is_active_subscription,
	subscriptions.customer_id,
	subscriptions.customer_created_on,
	subscriptions.country,
    -- Included country_code from a seed here since it's good practice to work with
    -- country codes instead of names. This allows country_code to be used downstream if needed.
	countries.country_code,
	subscriptions.load_date_time
from {{ source('core', 'subscriptions') }}
left join {{ ref("dim_countries") }} as countries
    on countries.country_name = subscriptions.country
