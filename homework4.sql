select distinct s.companyname
from customers c
join orders o on c.customerid = o.customerid
join order_details od on o.orderid = od.orderid
join products p on od.productid = p.productid
join suppliers s on p.supplierid = s.supplierid
where c.companyname = 'Let''s Stop N Shop';

select o.orderid, e.firstname || ' ' || e.lastname as employee, c.companyname, c.city
from orders o
join customers c on o.customerid = c.customerid
join employees e on o.employeeid = e.employeeid
where c.city = e.city;

select c.companyname as customer_company, s.companyname as supplier_company, c.city
from customers c
join suppliers s on c.city = s.city;

select s.companyname, count(distinct shipcountry) as countries, count(distinct shipcity) as cities
from shippers s
left join orders o on s.shipperid = o.shipvia
group by s.shipperid, s.companyname order by countries desc, cities desc;

select p.supplierid, s.companyname, count(p.productid) as product_count, count(distinct p.categoryid) as category_count from products p
join suppliers s on p.supplierid = s.supplierid
group by p.supplierid, s.companyname order by product_count desc;

select distinct c.categoryname
from categories c
join products p on c.categoryid = p.categoryid
join suppliers s on s.supplierid = p.supplierid
where s.city = 'Stockholm';

select distinct categoryname from categories
where categoryid in (
    select categoryid from products
                      where supplierid in (
                          select supplierid from suppliers
                                            where city = 'Stockholm'
                          )
          );

select count(distinct p.categoryid)
from products p
join suppliers s on s.supplierid = p.supplierid
where s.country = 'Italy'

select p.productname, sum(od.quantity) as total_quantity
from products p
join order_details od on p.productid = od.productid
join orders o on od.orderid = o.orderid
where orderdate between '1996-07-01' and '1996-9-30'
group by p.productname
order by total_quantity desc;

select p.productname, sum(od.unitprice * od.quantity * (1 - od.discount)) as total_price
from products p
join order_details od on p.productid = od.productid
join orders o on od.orderid = o.orderid
where orderdate between '1996-07-01' and '1996-9-30'
group by p.productname
order by total_price desc;

select *
from orders
where freight > all(
    select freight from orders o
                   join shippers s on o.shipvia = s.shipperid
                   where s.companyname = 'United Package'
    );

select od1.productid, od2.productid, count(*) as order_count
from order_details od1
inner join order_details od2 on od1.orderid = od2.orderid and od1.productid < od2.productid
group by od1.productid, od2.productid
order by order_count desc;

select e.firstname || ' ' || e.lastname as employee
from employees e
where birthdate between '1960-01-01' and '1969-12-31';

select e.firstname || ' ' || e.lastname as employee,
    case when (extract(year from e.birthdate)::int % 4 = 0
        and extract(year from e.birthdate)::int % 100 <> 0)
             or (extract(year from e.birthdate)::int % 400 = 0)
        then 'yes' else 'no' end as is_leap_year
from employees e
order by is_leap_year desc;

select e1.firstname || ' ' || e1.lastname as employee, e1.reportsto, e2.firstname || ' ' || e2.lastname as manager,
       (select count(*) from employees e3 where e3.reportsto = e1.employeeid) as report_count
from employees e1
inner join employees e2 on e1.reportsto = e2.employeeid
where e2.firstname || ' ' || e2.lastname = 'Andrew Fuller'
order by report_count desc;

select c.companyname
from customers c
where not exists(
    select 1 from orders o
             where o.customerid = c.customerid
         );

select o.orderid, c.companyname, count(distinct categoryid)
from customers c
join orders o on o.customerid = c.customerid
join order_details od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by o.orderid, c.companyname
having count(distinct categoryid) > 4
order by count(categoryid) desc;

select c.categoryname, p.productname, p.unitprice
from products p
join categories c on c.categoryid = p.categoryid
where p.unitprice = (
    select max(unitprice) from products
    where categoryid = c.categoryid
    );

select c.companyname, c.country, (select count(*) from suppliers s where s.country = c.country) as supplier_count
from customers c
order by supplier_count desc;
