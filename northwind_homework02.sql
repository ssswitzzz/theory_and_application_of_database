select productname, unitprice from products
where unitprice > 30 order by unitprice asc;

select productname, unitsinstock, unitsonorder from products
where unitsinstock < unitsonorder;

select productname,quantityperunit from products
where quantityperunit like '%jars%';

select productname, unitprice, concat(floor(unitprice),'$')
as price from products;

select productname, round(cast(unitprice as decimal) * 0.9,1) as discountprice, unitprice from products;

select supplierid, round(avg(cast(unitprice as decimal)),1) as averageprice from products
group by supplierid;

select country, count(*) as numberofemployees from employees
group by country order by numberofemployees desc;

select concat(firstname,' ',lastname) as employee, notes from employees
where lower(notes) like '%university%';

select concat(firstname,' ',lastname) as employee, hiredate from employees
where date(hiredate) > '1993-09-11' order by hiredate desc;

select concat(firstname,' ',lastname) as employee, birthdate from employees
where date(birthdate) < '1963-07-02' and date(birthdate) > '1952-02-17' order by birthdate desc;

select count(distinct city) as numberofcities from employees;

select city, count(*) as numberofemployees from employees
group by city order by numberofemployees desc;

select firstname, birthdate, age(birthdate) as days from employees;

select photopath, substring(photopath, 8) as extracted,
       length(substring(photopath, 8)) as length from employees;

select contactname, contacttitle, phone from suppliers where contactname like 'Michael%';

select contactname, contacttitle, fax from suppliers where contacttitle = 'Marketing Manager' and fax is not null;

select count(supplierid) as numberfsuppliers from suppliers where region is not null;

select count(supplierid) as numberfsuppliers from suppliers where region is null;

select companyname, contactname, length(companyname) as companylength from suppliers where length(companyname) > 20 order by companylength desc;

select country || repeat('.',12) || contactname as contact from suppliers;

select phone, translate(phone,'()','[]') as newphone from suppliers;

select companyname, contactname, city from customers where city = 'Buenos Aires';

select contactname from customers where contactname like '%r' and (contactname like '_i%' or contactname like '__i%');

select phone from customers where right(phone,4) like '%39%';
select phone from customers where substring(phone, length(phone)-3) like '%39%';

select split_part(contactname,' ',1) as firstname, split_part(contactname,' ',-1) as lastname from customers;

select distinct c1.contactname from customers c1
join customers c2 on split_part(c1.contactname,' ',1) = split_part(c2.contactname,' ',1)
where c1.customerid <> c2.customerid order by c1.contactname;

select * from customers order by random() limit 1;

select round(unitprice * 6.89) || '元' as pricecny from order_details;

select orderdate, extract(year from orderdate) as year from orders;

select to_char(orderdate, 'TMDay') AS weekday_name, count(*) as numberoforders from orders
group by weekday_name,extract(dow from orderdate) order by extract(dow from orderdate);


