{{ config(
    materialized = 'table',
    tags = ['data_marts', 'hubspot']
) }}

-- 1. I initially planned to materialize as incremental, but held off for now due to not all underlying models having
--    good timestamp columns available to use for 'if is_incremental()' statements. As of yet, it could be made
--    partially incremental if needed though (the swap_actions CTE).
-- 2. If performance is not good enough in production then this model should be looked at to refactor to a fully
--    incremental model.
-- 3. A materialized_view could also offer a performance compromise between table & incremental,
--    but it's not yet available for the DuckDB dbt adapter.

-- Note:
--    If you have data marts that end up being rarely used they could also be made into a regular view,
--    to only have the performance hit whenever it does get queried by someone. But this model should see regular use
--    as a data feed into HubSpot.

with swap_actions as (
    select
        customer_id,
        subscription_id,
        status_name as status,
        max(created_on) as last_swap_created_on,
        max(completed_on) as last_swap_completed_on,
        count(distinct action_id) as number_of_swaps
    from {{ ref('fct_actions') }}
    where
    	action_type_code = 1
        and status_name in (
            'Completed',
            'Cancelled'
        )
    group by
        customer_id,
        subscription_id,
        status_name
),

recent_swaps as (
    select
        customer_id,
        subscription_id,
        min(
            case
                when status = 'Completed' then last_swap_created_on
            end
        ) as last_completed_swap_created_on,
        min(
            case
                when status = 'Completed' then last_swap_completed_on
            end
        ) as last_completed_swap_completed_on,
        min(
            case
                when status = 'Cancelled' then last_swap_created_on
            end
        ) as last_cancelled_swap_created_on,
        min(
            case
                when status = 'Cancelled' then last_swap_completed_on
            end
        ) as last_cancelled_swap_completed_on,
        min(
            case
                when status = 'Completed' then number_of_swaps
            end
        ) as completed_number_of_swaps,
        min(
            case
                when status = 'Cancelled' then number_of_swaps
            end
        ) as cancelled_number_of_swaps,
        sum(number_of_swaps) as total_number_of_swaps
    from swap_actions
    group by
        customer_id,
        subscription_id
),

customer_subscription_data as (
    select
        customers.customer_id,
        customers.contact_id as customer_contact_id,
        customers.created_on as customer_created_on,
        customers.country_code as customer_country_code,
        customers.language as customer_language,
        customers.has_active_subscription as customer_has_active_subscription,
        subscriptions.subscription_id,
        subscriptions.subscription_created_on,
        subscriptions.subscription_start,
        subscriptions.subscription_end,
        subscriptions.is_active_subscription as subscription_is_active_subscription
    from {{ ref('dim_customers') }} as customers
    -- In the sample data not all customer_id's in dim_subscriptions overlap with dim_customers, possible due to the
    -- samples not being aligned when they were taken. In production I assume this to not be a problem, but with the
    -- current sample data, this inner join will cut the scope down a bit and only include customer_id's found in both tables.
    inner join {{ ref('dim_subscriptions') }} as subscriptions
        on subscriptions.customer_id = customers.customer_id
)

select
    customer_subscription.customer_id,
    customer_subscription.subscription_id,
    customer_subscription.customer_has_active_subscription,
    customer_subscription.subscription_is_active_subscription,
    customer_subscription.customer_country_code,
    customer_subscription.customer_language,
    customer_subscription.customer_contact_id,
    customer_subscription.customer_created_on,
    customer_subscription.subscription_created_on,
    customer_subscription.subscription_start,
    customer_subscription.subscription_end,
    recent_swaps.last_completed_swap_created_on,
    recent_swaps.last_completed_swap_completed_on,
    recent_swaps.last_cancelled_swap_created_on,
    recent_swaps.last_cancelled_swap_completed_on,
    recent_swaps.completed_number_of_swaps,
    recent_swaps.cancelled_number_of_swaps,
    recent_swaps.total_number_of_swaps
from customer_subscription_data as customer_subscription
-- Made use of a left join here to retain customers with subscriptions that don't have any recent swaps yet,
-- if the scope of the data feed should be to only include customers with subscriptions that already have recent swaps,
-- then this could be made into an inner join (also better performance).
left join recent_swaps
    on recent_swaps.customer_id = customer_subscription.customer_id
    and recent_swaps.subscription_id = customer_subscription.subscription_id
