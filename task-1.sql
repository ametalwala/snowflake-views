with base as (

select 
    user_id
    , min(created_at)::date as first_donation_date 
    , cast(min_by(amount_cents, created_at) as float) as first_donation_amount
    , max(created_at)::date as last_donation_date     
    , datediff(day, min(created_at::timestamp), max(created_at::timestamp)) as days_to_second_donation
    , cast(max_by(amount_cents, created_at) as float) as last_donation_amount 
   
from public.donations 
group by 1 
), 
aggregations as (
select
    donations.user_id
    , count(*) as count_donations_all_time
    , sum(amount_cents) as sum_donations_all_time
    , sum(case when created_at <= dateadd(year, 1, base.first_donation_date) then amount_cents else 0 end)::float as sum_donations_first_year 
    , cast(avg(amount_cents) as float) avg_donation_amount

from public.donations
left join base 
    on donations.user_id = base.user_id
group by 1 
) 
select 
    base.* 
    , aggregations.sum_donations_first_year
    , aggregations.avg_donation_amount
from base
left join extended
    on base.user_id = aggregations.user_id 