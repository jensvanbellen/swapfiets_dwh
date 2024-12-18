{{ config(
    materialized = 'incremental',
    unique_key = 'action_id',
    tags = ['core', 'actions']
) }}

select
	actions.action_id,
	actions.action_type_code,
	actions.action_type_name,
	actions.created_on,
	actions.completed_on,
	actions.status_name,
	actions.asset_id,
	actions.subscription_id,
	actions.customer_id,
	actions.country,
	-- Included country_code from a seed here since it's good practice to work with
    -- country codes instead of names. This allows country_code to be used downstream if needed.
	countries.country_code,
	actions.load_date_time
from {{ source('core', 'actions') }}
left join {{ ref("dim_countries") }} as countries
    on countries.country_name = actions.country
-- Incremental refresh strategy:
-- 1. No last_updated_on timestamp is available, but the action table might become large, so incremental refresh is advisable.
-- 2. Based the incremental refresh on the created_on timestamp for now. The maximum completion duration observed
--    so far is 159 days, so setting the interval to half a year (6 months), would need rechecking if used with real data.
-- 3. This approach ensures that actions completed after a long duration still have their rows updated (based on this data sample at least).
{% if is_incremental() %}
where
    actions.created_on::date > (select max(created_on::date) from {{ this }}) - interval 6 month
{% endif %}
