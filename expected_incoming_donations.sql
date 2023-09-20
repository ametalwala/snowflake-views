create or replace view candidate_adam_metalwala.expected_incoming_donations as 

select 
    b.donor_id
    , (total_donated_so_far - avg_first_year_contributions) as expected_incoming_donation
from (
    select 
        donor_user_id as donor_id 
        , sum_donations_all_time as total_donated_so_far
        , round(avg(sum_donations_first_year), 2) as avg_first_year_contributions
    from CANDIDATE_ADAM_METALWALA.donor_facts
    group by 1, 2
    order by 1 desc
) as b
where expected_incoming_donation != 0 
/* 
    ruling out donors who do not have upcoming donations 
*/ 
