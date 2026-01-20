В ноябре и декабре 2022 года была опробована альтернативная стратегия привлечения клиентов.
Я проверяла следующую гипотезу: 
в ноябре и декабре 2022 года из-за более дорогой и таргетированной рекламы мы приобрели более «лояльных» игроков, 
которые больше времени посвящают нашей игре. */

select 	case when date_part ('month',reg_date) in ('11','12')
            	then 'nov.-dec.2022' else 'others' 
            	end as cogort 
        , avg (end_session - start_session) as len    
from skygame.users t1
left join skygame.game_sessions t2
        on t1.id_user=t2.id_user
where end_session - start_session > interval '5 minute'
group by cogort


Отдел маркетинга проводил акцию, по которой более частый заход в игру позволял получить больше бесплатных кристаллов. 
Акция длилась первые три недели марта 2023 года.
Видим ли мы позитивные результаты этой акции на графиках маркетинговых клиентских метрик?

--DAU (Daily Active Users)
select      date_trunc ('day',start_session) as day
            ,count (distinct id_user) as active_day
from        skygame.game_sessions
where       start_session between '2023-03-01' and '2023-03-21' 
group by    day
--WAU (Weekly Active Users)
select      date_trunc ('week',start_session) as week
            ,count (distinct id_user) as active_week
from        skygame.game_sessions
where       start_session between '2023-03-01' and '2023-03-21' 
group by    week
--MAU (Monthly Active Users)
select      date_trunc ('month',start_session) as month
            ,count (distinct id_user) as active_month
from        skygame.game_sessions
where       start_session between '2023-03-01' and '2023-03-21' 
group by    month 


