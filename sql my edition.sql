use music;

-- -----------------------------Written by: Sium Ahameed Bhuyan -----------------------------------------------------
-- Question Set1 - Easy 

-- Q1: Find 3 most senior employee based on job title? 

SELECT 
    employee_id, first_name, last_name, levels
FROM
    employee
ORDER BY levels DESC LIMIT 3;


-- Q2: Top 5 countries which have the most Invoices? 

SELECT 
    billing_country, COUNT(*) AS c
FROM
    invoice
GROUP BY billing_country
ORDER BY c DESC
LIMIT 5;


-- What are top 3 values of total invoice? 

SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;


-- Q4: Which are the top 5 city has the best customers? Return both the city name & sum of all invoice totals.

SELECT 
    billing_city, SUM(total) AS TotalInvoices
FROM
    invoice
GROUP BY billing_city
ORDER BY TotalInvoices DESC
LIMIT 5;

-- Q5: Who is the best 3 customer? Best customer will be count based on spending money.


SELECT 
    customer.customer_id,
    first_name,
    last_name,
    SUM(total) AS total_spending
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id , first_name , last_name
ORDER BY total_spending DESC
LIMIT 3;




-- Question Set 2 - Moderate 

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.


SELECT DISTINCT
    first_name AS FirstName,
    last_name AS LastName,
    email AS Email,
    genre.name AS Name
FROM
    customer
        JOIN
    invoice ON invoice.customer_id = customer.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
ORDER BY email;



-- Q2: Let's invite the 5 artists who have written the most rock music in our dataset. 

SELECT 
    artist.artist_id,
    artist.name,
    COUNT(artist.artist_id) AS number_of_songs
FROM
    track
        JOIN
    album ON album.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY number_of_songs DESC
LIMIT 5;


-- Q3: Return all the track names that have a song length longer than the average song length. 

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_track_length
        FROM
            track)
ORDER BY milliseconds DESC;




-- Question Set 3 - Advance 


-- Q1: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


/* Method 2: : Using Recursive */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;
