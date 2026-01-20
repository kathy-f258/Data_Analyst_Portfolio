Задача: рассчитать LMAU, LDAU, LWAU (Loyal MAU/DAU/WAU).
Для того чтобы произвести этот расчет, необходимо определиться: какого пользователя мы считаем лояльным?
Основные гипотезы для определения "лояльного пользователя"
  
1. Допустим, лояльным считается тот пользователь, который пригласил как минимум троих друзей, из которых как минимум один в результате зарегистрировался в нашей игре.
Назовем данный критерий crit_invite. LMAU для критерия лояльности crit_invite:

with crit_invite as
(select id_user
from skygame.referral
group by id_user
having count(*)>2 and sum (ref_reg)>=1)

select date_trunc('month', start_session) as mm
, count (distinct a.id_user) as cnt_us
from skygame.game_sessions as a
join crit_invite as b
on a.id_user=b.id_user
group by mm

2. Допустим, лояльным считается тот пользователь, который заплатил суммарно больше 1000 рублей за всё время (не строго).
Назовем данный критерий crit_1000. Динамика LMAU для критерия лояльности crit_1000.

with crit_1000 as
(select id_user
from skygame.monetary as m
join skygame.log_prices as lp
on m.id_item_buy=lp.id_item
and m.dtime_pay between lp.valid_from and coalesce (lp.valid_to,'3000-01-01')
group by id_user
having sum(cnt_buy*price)>=1000)

select date_trunc('month', start_session) as mm
, count (distinct a.id_user) as cnt_us
from skygame.game_sessions as a
where id_user in (select * from crit_1000)
group by mm

3. Возьмем оба вышеуказанных критерия. 
То есть чтобы считаться лояльным, клиенту необходимо пригласить как минимум троих друзей и заплатить суммарно больше 1000 рублей за всё время.

with crit_1000 as
(select id_user
from skygame.monetary as m
join skygame.log_prices as lp
on m.id_item_buy=lp.id_item
and m.dtime_pay between lp.valid_from and coalesce (lp.valid_to,'3000-01-01')
group by id_user
having sum(cnt_buy*price)>=1000),
crit_invite as
(select id_user
from skygame.referral
group by id_user
having count(*)>2 and sum (ref_reg)>=1)

select date_trunc('month', start_session) as mm
, count (distinct a.id_user) as cnt_us
from skygame.game_sessions as a
where id_user in (select * from crit_1000) and id_user in (select * from crit_invite)
group by mm


4. Допустим, лояльным считается пользователь, который входит в топ-100 пользователей по средним выплатам за один месяц своей жизни. 
Вывожу список таких клиентов.

select m.id_user
, sum(cnt_buy*price) / ceil(extract('day' from max(m.dtime_pay) - min(u.reg_date)) / 30) as spending
from skygame.monetary as m
join skygame.log_prices as lp
on m.id_item_buy=lp.id_item
and m.dtime_pay between lp.valid_from and coalesce (lp.valid_to,'3000-01-01')
join skygame.users as u
on m.id_user=u.id_user
group by m.id_user
order by spending desc
limit 100
