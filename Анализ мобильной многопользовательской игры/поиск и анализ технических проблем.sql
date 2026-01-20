--- В таблице в данными об игровых сессиях game_sessions были обнаружены нуловые значения времени окончания сессии. 
--- Суммарное количество подобных записей и доля подобных строк среди всех строк:

select  sum (case when end_session is null then 1.0 else 0.0 end) as fault_ses,
        sum (case when end_session is null then 1.0 else 0.0 end) / count(id_user) as fault_share
from skygame.game_sessions

--- Я выдвинула гипотезу, что проблема связана и типом утройств, на котором запускается игра. Считаю долю проблемных записей для каждого device_type:
select  users.dev_type,
        sum (case when end_session is null then 1.0 else 0.0 end) / count(*) as fault_share
from skygame.game_sessions as gses
        join skygame.users as users
        on users.id_user = gses.id_user
group by users.dev_type

--- а таже доли проблемных записей на iOS и на Android:
select  sum (case when users.dev_type = 'android' then 1.0 else 0.0 end)/count(*) as fault_share_and,
        sum (case when users.dev_type = 'ios' then 1.0 else 0.0 end)/count(*) as fault_share_ios
from skygame.game_sessions as gses
        join skygame.users as users
        on users.id_user = gses.id_user
where end_session is null



