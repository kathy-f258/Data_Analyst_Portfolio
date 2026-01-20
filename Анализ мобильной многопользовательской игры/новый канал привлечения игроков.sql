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

