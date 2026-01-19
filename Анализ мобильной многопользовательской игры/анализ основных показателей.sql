Исследование пользовательской базы.

-- Структура таблицы : 
select *
from skygame.users
limit 10


-- Подсчет кол-ва пользователей, уникальных пользователей, проверка данных на нулы:
select    count(*) as all_users
        ,   count(distinct id_user) as dist_users
        ,   count(id_user) as id_user
        ,   count(reg_date) as reg_date
        ,   count(dev_type) as dev_type
from skygame.users 

-- Пользователи, которые регистрировались более одного раза:
select       id_user
         ,   count(id_user) as cnt_users
from skygame.users
group by id_user
having count(id_user)>1 
order by cnt_users desc 

-- Исследование динамики пользовательской базы --> считаю кол-во пользователей по месяцам, строю линейный график:
select      date_trunc('month', reg_date) as mm 
         ,   count(id_user) as users
from skygame.users
group by mm
order by mm 

Исследование данных игровых сессий.

select *
from skygame.game_sessions
limit 10

select    count(*) as all_sessions
	, count(id_user) as cnt_id
        , count(start_session) as cnt_start
        , count(end_session) as cnt_end
from skygame.game_sessions


-- Суммарное количество игровых сессий дольше 5 минут.

select      count(*) as cnt_all 
        ,   sum(case when end_session - start_session > interval '5 minute' then 1 else 0 end) as cnt_5min
from skygame.game_sessions

-- Распределение по месяцам:
select      date_trunc('month',start_session) as mm
        ,   count(*)
from skygame.game_sessions
group by mm 
order by mm

-- Распределение количества игровых сессий, суммарного количества сессий дольше 5 минут, доли сессий дольше 5 минут среди всех сессий.
select      count(*) as cnt_all 
        ,   sum(case when end_session - start_session > interval '5 minute' then 1 else 0 end) as cnt_5min
        ,   sum(case when end_session - start_session > interval '5 minute' then 1.0 else 0.0 end) / count(*) as per
from skygame.game_sessions

-- В дальнейшем анализе убираю все сессии меньше 5 минут.
-- Динамика средней длительности одной игровой сессии по месяцам.
select          date_trunc('month', start_session) as mm
            ,   avg(end_session - start_session) as avg_session
from skygame.game_sessions
where end_session - start_session > interval'5 minute'
group by mm
order by mm

-- Динамика доли «длинных» сессий среди всех сессий. 
select          date_trunc('month', start_session) as mm
           ,    sum(case when end_session - start_session > interval'1 hour' then 1.0 else 0.0 end) / count(*)
from skygame.game_sessions
where end_session - start_session > interval'5 minute'
group by mm
order by mm


