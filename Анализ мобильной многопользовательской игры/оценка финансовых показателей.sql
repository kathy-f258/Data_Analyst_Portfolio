Рассчет динамики суммарных клиентских выплат по месяцам в разрезе по типам продукта. 

select date_trunc('month', dtime_pay) as mm
, type
, sum(cnt_buy*price) as sum_rev
from skygame.monetary as m
join skygame.log_prices p
on m.id_item_buy=p.id_item
and dtime_pay between valid_from and coalesce (valid_to, '2100-01-01')
join skygame.item_list t
on m.id_item_buy=t.id_item
group by mm, type
order by mm


С 1 января 2023 года была увеличена стоимость одного кристалла. 
Смотрим динамику среднего количества приобретаемых кристаллов на одну покупку и суммарную выручку.

select date_trunc('month', dtime_pay) as mm
, avg (cnt_buy) as cnt_1b
, sum (cnt_buy*price) as sum_rev
from skygame.monetary as m
join skygame.log_prices p
on m.id_item_buy=p.id_item
and dtime_pay between valid_from and coalesce (valid_to, '2100-01-01')
join skygame.item_list t
on m.id_item_buy=t.id_item
where name_item='Crystal'
group by mm
order by mm


Вопрос: Надо ли нам наше маркетинговое воздействие распределять на все когорты поровну? Возможно, какие-то когорты более «щедрые» на покупку игровых предметов.

Рассчитываю среднюю выручку на одного человека на один месяц для каждой когорты.

select *
, extract ('day' from ((select max(dtime_pay) from skygame.monetary) - mon_reg)) / 30 as lt
, rev_us / (extract ('day' from ((select max(dtime_pay) from skygame.monetary) - mon_reg)) / 30) as rev_mm
from (
select date_trunc ('month', reg_date) as mon_reg
, sum (cnt_buy*price) as rev
, count (distinct m.id_user) as cnt_us
, sum (cnt_buy*price) / count (distinct m.id_user) rev_us
from skygame.monetary as m
join skygame.log_prices p
on m.id_item_buy=p.id_item
and dtime_pay between valid_from and coalesce (valid_to, '2100-01-01')
join skygame.users u
on m.id_user=u.id_user
where reg_date < '2023-04-01'
group by mon_reg
order by mon_reg
) a
