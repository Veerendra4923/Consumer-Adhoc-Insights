# Question 1
SELECT distinct(market),customer,
	region
 FROM gdb0041.dim_customer
 where customer="Atliq Exclusive" and region="APAC";
 
# Question 2
with cte1 as (SELECT 
count(distinct(product_code)) as uni_prod,
fiscal_year
FROM gdb0041.fact_sales_monthly
group by fiscal_year)

select 
y20.uni_prod as unique_prod_2020,
y21.uni_prod as unique_prod_2021,
round(((y21.uni_prod-y20.uni_prod)*100)/y20.uni_prod,2) as pct_change
from 
(select uni_prod from cte1 where fiscal_year=2020) y20
join
(select uni_prod from cte1 where fiscal_year=2021) y21
on 1=1;

# Question 3
select count(distinct(product_code)) as ct,segment from dim_product group by segment order by ct desc;

# Question 4
with cte3 as (
select distinct(p.product_code),
p.segment,
s.fiscal_year
from fact_sales_monthly s 
join dim_product p
on p.product_code=s.product_code
)
select 
y20.segment,
y20.uni_prod as unique_sales_2020,
y21.uni_prod as unique_sales_2021,
round(((y21.uni_prod-y20.uni_prod)*100)/y21.uni_prod,2) as pct_change
from 
(select segment,count(distinct(product_code)) as uni_prod from cte3 where fiscal_year=2020 group by segment) y20
join 
(select segment,count(distinct(product_code)) as uni_prod from cte3 where fiscal_year=2021 group by segment) y21
on y20.segment=y21.segment;

# Question 5
select 
p.product,
p.product_code,
m.manufacturing_cost
from dim_product p 
join fact_manufacturing_cost m
on p.product_code=m.product_code;

# Question 6
select
c.customer_code,
c.customer,
round(avg(prein.pre_invoice_discount_pct),2) as avg_discount
from dim_customer c 
join fact_pre_invoice_deductions prein
on c.customer_code=prein.customer_code
where c.market="India" and prein.fiscal_year=2021
group by c.customer;

# Question 7
select 
concat(monthname(fs.date),"(",year(fs.date),")") as 'month',
fs.fiscal_year,
round(sum(g.gross_price*fs.sold_quantity)/1000000,2) as gross_sales_mln
from fact_sales_monthly fs
join dim_customer c 
		on fs.customer_code=c.customer_code
join fact_gross_price g
		on fs.product_code=g.product_code
where c.customer="Atliq Exclusive" 
group by month,fs.fiscal_year
order by fs.fiscal_year;


# Question 8
select
My_Quarter(date) as Quarteri,
fiscal_year,
sum(sold_quantity) as total_sold_quantity
from
fact_sales_monthly
where fiscal_year=2020
group by Quarteri;

# Question 9
SELECT
    c.channel,
    SUM(g.gross_price_total) AS gross_price_total,
    ROUND(
        SUM(g.gross_price_total)*100
        / SUM(SUM(g.gross_price_total)) OVER (),
        2
    ) AS contribution_pct
FROM dim_customer c
JOIN gross_sales g
    ON c.customer_code = g.customer_code
WHERE g.fiscal_year = 2021
GROUP BY c.channel;


# Question 10
with ctel as(
select 
p.division,
p.product_code,
p.product,
s.sold_quantity,
dense_rank() over(partition by p.division 
order by s.sold_quantity desc) as rank_with_region
from dim_product p
join fact_sales_monthly s
on p.product_code=s.product_code
where s.fiscal_year=2021
group by p.division, p.product_code, p.product)

select * from ctel 
where 
rank_with_region<=3;