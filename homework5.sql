select count(distinct p.categoryid)
from products p
join order_details od on od.productid = p.productid
join orders o on o.orderid = od.orderid
join customers cu on cu.customerid = o.customerid
where cu.city = 'London';

select count(distinct p.categoryid)
from products p
where productid in (select productid
                    from order_details
                    where orderid in (select orderid
                                      from orders
                                      where customerid in (select customerid
                                                           from customers
                                                           where city = 'London')));
select avg(o.freight) as average_freight
from orders o
    where o.shipcountry = 'Venezuela'
and exists(
select 1 from order_details od
join products p on p.productid = od.productid
join categories c on c.categoryid = p.categoryid
        where o.orderid = od.orderid
        and c.categoryname = 'Dairy Products'
);

select extract(year from orderdate) as year, extract(month from orderdate) as month, count(distinct o.orderid) as number_of_orders
from orders o
group by rollup(extract(year from orderdate), extract(month from orderdate))
order by year, month;

-- select extract(quarter from o.orderdate), p.productname
-- from order_details od
-- join orders o on o.orderid = od.orderid
-- join products p on od.productid = p.productid
-- group by extract(quarter from o.orderdate), p.productname
-- order by extract(quarter from o.orderdate);

select distinct s.contactname
from suppliers s
where country = (
    select country from employees
                   where lastname = 'Dodsworth' and firstname = 'Anne'
    )
and contacttitle = (
    select title from employees
                   where lastname = 'Dodsworth' and firstname = 'Anne'
    );

select e.firstname || ' ' || e.lastname as employee_name, count(distinct o.orderid) as number_of_orders
from employees e
join orders o on o.employeeid = e.employeeid
group by employee_name
having count(o.orderid) > (select count(*) from orders o) / 7.0
order by number_of_orders desc;

select e.firstname, sum(od.quantity * od.unitprice) as total_sales
from employees e
join orders o on o.employeeid = e.employeeid
join order_details od on od.orderid = o.orderid
group by e.firstname
order by total_sales desc;

select e2.firstname, extract(year from age(e2.birthdate)) as age,
       extract(year from (select avg(age(birthdate)) from employees e1
                           where e1.title = e2.title)) as average_age
from employees e2;

select c.contactname
from customers c
join orders o on o.customerid = c.customerid
join employees e on e.employeeid = o.employeeid
group by c.contactname
having count(distinct e.employeeid) = (select count(*) from employees);

select e.firstname || ' ' || e.lastname as employee_name,
    count(distinct p.supplierid) + count(distinct o.customerid) as total_suppliers_and_customers
from employees e
join orders o on e.employeeid = o.employeeid
join order_details od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by e.employeeid
order by total_suppliers_and_customers desc;

select c.categoryname,
    (select p.productname from products p
     where p.categoryid = c.categoryid
     order BY RANDOM() limit 1) as random_product
from categories c;

select distinct on (p.categoryid) p.productname, c.categoryname
from products p
join categories c on c.categoryid = p.categoryid
order by p.categoryid, random();

select round((select count(distinct orderid) from order_details od
               join products p on od.productid = p.productid
               join categories c on c.categoryid = p.categoryid
               where c.categoryname = 'Produce'
) * 100 / count(*) ,2) || '%' as percentage_of_orders_with_produce
from orders o;

select max(p.unitprice) as max_unit_price, c.categoryname
from products p
join categories c on c.categoryid = p.categoryid
group by c.categoryid, c.categoryname
having max(p.unitprice) > avg(p.unitprice) * 2;

select c.companyname, c.country, count(distinct s.supplierid) as number_of_suppliers
from customers c
join orders o on o.customerid = c.customerid
join order_details od on od.orderid = o.orderid
join products p on p.productid = od.productid
join suppliers s on s.supplierid = p.supplierid
where c.country = s.country
group by c.customerid, c.companyname, c.country
order by number_of_suppliers desc;

select c.companyname
from customers c
join orders o on o.customerid = c.customerid
join order_details od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by c.companyname, c.customerid
having count(distinct p.supplierid) = 2;

select c.companyname
from customers c
join orders o on o.customerid = c.customerid
join order_details od on od.orderid = o.orderid
join products p on p.productid = od.productid
join suppliers s on s.supplierid = p.supplierid
group by c.companyname, c.customerid
having sum(case when s.country = c.country then 1 else 0 end) = 0;

create or replace procedure get_odd_numbers()
language plpgsql
as $$
    declare
    i int;
    begin
    for i in 1..100 loop
        if i % 2 = 1 then
            raise notice '%', i;
        end if;
    end loop;
    end;
$$;
-- DROP FUNCTION IF EXISTS get_orders_by_employee_date(VARCHAR, DATE);
create or replace function get_orders_by_employee_date(p_firstname varchar, p_target_date date)
returns table(order_no smallint, order_dt date)
language plpgsql
as $$
begin
    return query
    select o.orderid, o.orderdate
    from orders o
    join employees e on o.employeeid = e.employeeid
    where e.firstname = p_firstname
      and o.orderdate < p_target_date;
end;
$$;

create or replace procedure proc_new_order(
    p_orderid smallint,
    p_customer_id varchar,
    p_employee_id int,
    p_product_name varchar,
    p_quantity smallint
)
language plpgsql
as $$
declare
    stock smallint;
begin
    select unitsinstock into stock
    from products
    where productname = p_product_name;
    if p_quantity > stock then
        raise notice '添加订单失败！产品 % 库存不足。当前库存: %, 需求量: %', p_product_name, stock, p_quantity;
        rollback;
    else
        insert into orders (orderid, customerid, employeeid, orderdate)
        values (p_orderid, p_customer_id, p_employee_id, current_date);
        raise notice '订单 % 添加成功！', p_orderid;
        commit;
    end if;
end;
$$;

alter table shippers
add column ship_num int default 0;
create or replace function update_ship_num()
returns trigger
language plpgsql
as $$
begin
    if new.shipvia is null then
        raise exception '添加失败：订单的 shipvia 不能为空！';
    end if;

    update shippers
    set ship_num = ship_num + 1
    where shipperid = new.shipvia;

    if not found then
        raise exception '添加失败：货运公司编号 % 不存在！', new.shipvia;
    end if;
    return new;
end;
$$;
create trigger trg_after_insert_order
after insert on orders
for each row
execute function update_ship_num();

alter table shippers
drop column ship_num;

