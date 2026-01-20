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

--DAU (Daily Active Users)
select      date_trunc ('day',start_session) as day
            ,count (distinct id_user) as active_day
from        skygame.game_sessions
group by    day

--WAU (Weekly Active Users)
select      date_trunc ('week',start_session) as week
            ,count (distinct id_user) as active_week
from        skygame.game_sessions
group by    week

--MAU (Monthly Active Users)
select      date_trunc ('month',start_session) as month
            ,count (distinct id_user) as active_month
from        skygame.game_sessions
group by    month 

-- K-factor
select (count(ref_reg)/count(distinct t1.id_user)::float) * (sum(ref_reg)/count(ref_reg)) as kf 
                    from skygame.users t1
                    full join skygame.referral t2
                            on t1.id_user=t2.id_user

-- Cколько пользователей нам принесет одна будущая среднестатистическая когорта
with k_faktor   as  (
                    select (count(ref_reg)/count(distinct t1.id_user)::float) * (sum(ref_reg)/count(ref_reg)) as kf 
                    from skygame.users t1
                    full join skygame.referral t2
                            on t1.id_user=t2.id_user
                    ),
cogort          as  (
                    select avg(users) as av_cog
                    from    (select  count (id_user) as users,
                                    date_trunc ('month', reg_date) as mm
                            from    skygame.users 
                            group by mm        
                            ) as all_cog 
                    )

select (select kf from k_faktor) * (select av_cog from cogort)
