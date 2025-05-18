select * from album;

--Q1 who is the senior most employee based on job title ?
select * from employee
order by levels desc
limit 1;

--Q2 which countries have the most invoices?
select count(*) as Total_invoices,billing_country
from invoice
group by billing_country
order by Total_invoices desc;

--Q3 What are top 3 values of total invoices?
select total from invoice 
order by total desc
limit 3;

--Q4: Which city has the best customers? We would like to throw a 
--    promotional Music Festival in the city we made the most money. 
--    Write a query that returns one city that 
--    has the highest sum of invoice totals. 
--    Return both the city name & sum of all invoice totals

select billing_city,sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc
limit 1;

--Q5 Who is the best customer? The customer who has spent the most money
-- will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select first_name,last_name,c.customer_id,sum(total) as money_spent
from customer as c
join invoice as i 
on i.customer_id=c.customer_id
group by c.customer_id
order by money_spent desc
limit 1;

--Q6 Write query to return the email, first name, last name, 
--  & Genre of all Rock Music listeners. 
--  Return your list ordered alphabetically by email starting with A. 

select distinct email,first_name,last_name
from customer as c 
join invoice as i on 
c.customer_id=i.customer_id
join invoice_line as il 
on i.invoice_id=il.invoice_id
where track_id in (
	select t.track_id from track as t
	join genre as g on
	t.genre_id=g.genre_id
	where g.name like 'Rock'
)
order by c.email;

--Q7 Let's invite the artists who have written the most rock music 
--in our dataset. 
--Write a query that returns the Artist name and total track count 
--of the top 10 rock bands.

select at.name,at.artist_id,count(at.artist_id) as num_of_songs
from artist as at 
join album as al on 
at.artist_id=al.artist_id
join track as t on
t.album_id=al.album_id
join genre as g on
g.genre_id=t.genre_id
where g.name like 'Rock'
group by at.artist_id
order by num_of_songs desc
limit 10;


--Q8 Return all the track names that have a song length
--longer than the average song length. 
--Return the Name and Milliseconds for each track. 
--Order by the song length with the longest songs listed first.

select name , milliseconds 
from track
where milliseconds >  
	(select avg(milliseconds) as avg_track_length
	 from track)
order by milliseconds desc;

--Q9 Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent.

select c.first_name||'  '||c.last_name as customer_name,att.name as artist_name,
sum(il.unit_price*il.quantity)as total_spent 
from customer as c join invoice as i
on c.customer_id=i.customer_id 
join invoice_line as il 
on i.invoice_id=il.invoice_id 
join track as t 
on t.track_id=il.track_id 
join album as al 
on al.album_id=t.album_id
join artist as att
on att.artist_id=al.artist_id
group by c.first_name,c.last_name,att.name;

--Q10 We want to find out the most popular music Genre for each country.
--We determine the most popular genre as the genre 
--with the highest amount of purchases.
--Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is 
--shared return all Genres.

WITH genre_purchases AS (
    SELECT 
        c.country AS country_name,
        g.name AS genre_name,
        COUNT(il.invoice_line_id) AS total_purchases 
    FROM customer AS c 
    JOIN invoice AS i ON c.customer_id = i.customer_id 
    JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
    JOIN track AS t ON il.track_id = t.track_id
    JOIN genre AS g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
),
max_purchase AS (
    SELECT 
        country_name, 
        MAX(total_purchases) AS max_purchase
    FROM genre_purchases
    GROUP BY country_name
)
SELECT 
    gp.country_name,
    gp.genre_name,
    gp.total_purchases
FROM genre_purchases gp
JOIN max_purchase mp 
    ON gp.country_name = mp.country_name
WHERE gp.total_purchases = mp.max_purchase
ORDER BY gp.country_name;

