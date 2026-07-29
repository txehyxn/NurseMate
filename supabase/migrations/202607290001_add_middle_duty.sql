alter table public.duties
drop constraint if exists duties_duty_type_check;

alter table public.duties
add constraint duties_duty_type_check
check (
  duty_type in ('day', 'evening', 'night', 'middle', 'off', 'annualLeave')
);
