select s.country, s.city from suppliers s join products p on s.supplierid = p.supplierid
where p.productname = 'Pâté chinois';

select companyname,
case when homepage is null then '无记录'
else homepage end as homepage from suppliers;

select orderid, count(productid) as product_count from order_details
group by orderid order by product_count desc;

select orderid, round(sum(unitprice*quantity*(1-discount))::numeric, 2) as sum_price, sum(quantity) as sum_quantity from order_details group by orderid;

select distinct s.companyname from suppliers s
join products p on s.supplierid = p.supplierid
join categories c on p.categoryid = c.categoryid
where c.categoryname = 'Condiments';

select avg(unitprice) as average_price from products p
join categories c on c.categoryid = p.categoryid
where c.categoryname = 'Beverages';

select p1.productname, count(p2.productid) as similar_price_count from products p1
left join products p2 on p1.categoryid = p2.categoryid and p1.productid <> p2.productid and abs(p1.unitprice - p2.unitprice) <=10
group by p1.productname order by similar_price_count desc;

select s.country, count(distinct p.categoryid) from suppliers s join products p on s.supplierid = p.supplierid
group by s.country order by count(distinct p.categoryid) desc limit 1;

select c.categoryname, count(distinct p.supplierid) as supplier_count from categories c
join products p on c.categoryid = p.categoryid
group by c.categoryname order by supplier_count desc limit 1;

select c1.contactname from customers c1
join customers c2 on c1.customerid <> c2.customerid and split_part(c1.contactname,' ',1) = split_part(c2.contactname,' ',1)
group by c1.contactname order by c1.contactname;

select e1.firstname || ' ' || e1.lastname as employee from employees e1
join employees e2 on e1.reportsto = e2.employeeid
where e2.firstname = 'Andrew' and e2.lastname = 'Fuller';

select current_date - hiredate as hire_days, firstname, extract(year from age(current_date, birthdate)) as age from employees
order by hire_days desc;

select e.firstname, e.lastname, round((count(o.orderid)::numeric/(current_date - e.hiredate)),4) as order_per_day from employees e
join orders o on e.employeeid = o.employeeid
group by e.employeeid, e.hiredate, e.firstname, e.lastname order by order_per_day desc;

select e1.firstname, count(e2.employeeid) as younger_employees from employees e1
left join employees e2 on e2.birthdate > e1.birthdate
group by e1.firstname order by younger_employees desc;

select distinct s.country, s.city from suppliers s
join customers c on s.country = c.country and s.city = c.city
join employees e on s.country = e.country and s.city = e.city
group by s.country, s.city order by s.country, s.city;

select country, city from suppliers
intersect select country, city from customers
intersect select country, city from employees;

select p.productname, c.companyname, c.phone from shippers s
join orders o on s.shipperid = o.shipvia
join customers c on o.customerid = c.customerid
join order_details od on o.orderid = od.orderid
join products p on od.productid = p.productid
where s.companyname = 'Speedy Express' and o.shipcity = 'Buenos Aires' and o.shippeddate between '1997-05-19' and '1998-02-19'