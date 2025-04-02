/* 1. Who is the senior most employee based on the job title? */
select * from employee
order by levels desc
limit 1;

/* 2  . Which countries have the most invoices? */
select billing_country,count(*) from invoice line
group by billing_country
limit 3;

/* 3. What are top 3 values of total invoice? */ 

select total from invoice
order by total desc limit 3;



/* 4 . Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals. */ 

select billing_city,round(sum(total),2) as total_invoice FROM invoice
group by billing_city
order by total_invoice desc
limit 1;


/* 5 . Who is the best customer? The customer who has spent the most money will be 
 declared the best customer. Write a query that returns the person who has spent the 
    most money. */

select C.customer_id,C.first_name,C.last_name,round(sum(I.total),2) as money_spent from customer as C
join invoice as I
on C.customer_id=I.customer_id
group by C.customer_id,C.first_name,C.last_name
order by money_spent desc
limit 1;



/* 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
 listeners. Return your list ordered alphabetically by email starting with A .*/

select first_name,last_name,email
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on genre.genre_id=track.genre_id
where genre.name='rock'
order by email;


/* 7.Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */ 
 
select artist.name,count(track.genre_id)  as total_count
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.name
order by total_count desc
limit 10;

/* 8 . Return all the track names that have a song length longer than the average song length. 
 Return the Name and Milliseconds for each track. Order by the song length with the 
 longest songs listed first.*/


select name ,milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;
 
 
 /* 9. Find how much amount spent by each customer on artists? Write a query to return 
 customer name, artist name and total spent. */

with CTE as (
select art.artist_id as artist_id,art.name as artist_name,sum(I.unit_price*I.quantity) as total_sell
 from artist as art
join album as alb on art.artist_id=alb.artist_id
join track on track.album_id=alb.album_id
join invoice_line as I on I.track_id=track.track_id
group by art.artist_id,art.name
order by total_sell desc

)
select C.first_name,C.last_name,CTE.artist_name,sum(I.unit_price*I.quantity) as total_spent
from  customer as C
join invoice  as inv on inv.customer_id=C.customer_id
join  invoice_line as I on I.invoice_id=inv.invoice_id
join track on I.track_id=track.track_id
join album on album.album_id=track.album_id
join CTE on CTE.artist_id=album.artist_id
group by 1,2,3
order by 3 desc;

/* 10. We want to find out the most popular music Genre for each country. We determine the 
 most popular genre as the genre with the highest amount of purchases. Write a query 
 that returns each country along with the top Genre. For countries where the maximum 
 number of purchases is shared return all Genres */

with Genre_Purchases as (
    select  I.billing_country as country,G.name as Genre_name, COUNT(*) as total
    from genre as G
    join track as T on T.genre_id = G.genre_id
    join invoice_line as IL on IL.track_id = T.track_id
    join invoice as I on I.invoice_id = IL.invoice_id
    group by  1,2
),
Max_Purchases as (
    select country, MAX(total) AS max_total
    from Genre_Purchases
    group by country
)
select GP.country, GP.Genre_name, GP.total
from Genre_Purchases as GP
join Max_Purchases as MP 
on GP.country = MP.country and GP.total = MP.max_total
order by GP.country;

/* 11 . Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount  */

with CTE as (
select inv.billing_country AS country,C.first_name,sum(inv.total) AS total_spent,
dense_rank() over (partition by  inv.billing_country order by sum(inv.total) desc) as rnk
    from customer as C
    join invoice as inv on inv.customer_id = C.customer_id
    group by inv.billing_country, C.first_name
)
select * from CTE 
where rnk = 1;









