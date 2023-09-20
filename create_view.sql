with base as (

select 
    user_id
    , min(created_at)::date as first_donation_date 
    , cast(min_by(amount_cents, created_at) as float) as first_donation_amount
    , max(created_at)::date as last_donation_date     
    , nullif(datediff(day, min(created_at::timestamp), max(created_at::timestamp)), 0) as days_to_second_donation
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
    , cast(round(avg(amount_cents), 2) as float) avg_donation_amount

from public.donations
left join base 
    on donations.user_id = base.user_id
group by 1 

) 
select 
    base.user_id as donor_user_id
    , base.first_donation_date
    , base.first_donation_amount
    , base.last_donation_date
    , base.days_to_second_donation
    , base.last_donation_amount 
    
    , aggregations.count_donations_all_time
    , aggregations.sum_donations_all_time
    , aggregations.sum_donations_first_year
    , aggregations.avg_donation_amount
    
from base
left join aggregations
    on base.user_id = aggregations.user_id 