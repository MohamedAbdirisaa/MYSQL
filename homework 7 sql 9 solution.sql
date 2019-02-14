-- Unit 10 Assignment - SQL

-- Create these queries to develop greater fluency in SQL,
-- an important database language.

-- * 1a. Display the first and last names of all actors FROM the
-- TABLE `actor`.
SELECT actor.first_name, actor.last_name
FROM sakila.actor;
-- * 1b. Display the first and last name of each 
-- actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(UPPER(first_name), ' ', UPPER(last_name)) 
AS 'Actor Name' FROM sakila.actor;

-- * 2a. You need to find the ID number, first name
-- , and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor.actor_id,actor.first_name,actor.last_name
FROM sakila.actor
WHERE first_name like '%Joe%';
-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT *
FROM sakila.actor
WHERE sakila.actor.last_name like '%GEN%';
-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM sakila.actor
WHERE sakila.actor.last_name like '%LI%'
order by sakila.actor.last_name ,sakila.actor.first_name
;
-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country.country_id, country.country
FROM sakila.country
WHERE country.country 
in ("Afghanistan", "Bangladesh","China");
-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the TABLE `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE sakila.actor
  ADD description BLOB;
-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE sakila.actor
DROP column description;
-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT actor.last_name,count(*) as total_actor
FROM sakila.actor
GROUP BY actor.last_name
;
-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT actor.last_name, count(*) as total_actor
FROM sakila.actor
GROUP by actor.last_name
having total_actor > 2;

SET SQL_SAFE_UPDATES = 0;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` TABLE as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE sakila.actor
SET actor.first_name = "HARPO"
WHERE actor.first_name = "GROUCHO" and actor.last_name = "WILLIAMS";

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE sakila.actor
SET actor.first_name = "HARPO"
WHERE actor.first_name = "HARPO" and
actor.last_name = "WILLIAMS";

-- * 5a. You cannot locate the schema of the `address` TABLE. Which query would you use 
-- to re-create it?
CREATE TABLE address (
  `Address_id` smallint(10) not null,
  `Address` varchar(45) not null,
  `Address2` varchar(45) null,
  `District` varchar(30) not null,
  `City_id` smallint(5) not null,
  `Postal_code` varchar(10) not null,
  `Phone` varchar(20) not null,
   `LAST_UPDATE` TIMESTAMP DEFAULT current_timestamp
);

-- * 6a. Use `JOIN` to display the first and last names, 
-- as well as the address, of each staff member. Use the TABLEs `staff` 
-- and `address`:

SELECT first_name, last_name, address 
FROM sakila.staff JOIN sakila.address
WHERE staff.address_id = address.address_id;
-- * 6b. Use `JOIN` to display the total amount rung up by each 
-- staff member in August of 2005. Use TABLEs `staff` and `payment`
SELECT staff.staff_id,sum(payment.amount) as total_amount
FROM sakila.staff join sakila.payment
WHERE staff.staff_id = payment.staff_id
and (YEAR(payment.payment_date) = 2005 AND MONTH(payment.payment_date) = 8)
GROUP by staff.staff_id
;
-- * 6c. List each film and the number of actors who are listed for that film.
-- Use TABLEs `film_actor` and `film`. Use inner join.

SELECT title, count(*) as total_actor
FROM sakila.film_actor  INNER JOIN sakila.film
ON film_actor.film_id = film.film_id
GROUP by title
;
-- * 6d. How many copies of the film `Hunchback Impossible` exist 
-- in the inventory system?
SELECT film.title,count(*) as total_copy
FROM film  left join inventory
on film.film_id = inventory.film_id
WHERE film.title like  "%Hunchback Impossible%"
;
-- * 6e. Using the TABLEs `payment` and `customer` and the `JOIN` command
-- , list the total paid by each customer. List the customers alphabetically 
-- by last name:
SELECT first_name, last_name,sum(payment.amount) as tot_pay
FROM sakila.customer join sakila.payment
WHERE customer.customer_id = payment.customer_id
GROUP by customer.customer_id
order by customer.last_name
;

-- * 7a. The music of Queen and Kris Kristofferson have seen an 
-- unlikely resurgence. As an unintended consequence, films
--  starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters
--  `K` and `Q` whose language is English.

SELECT title as Title, name as MovieLanguage
FROM
(SELECT language_id, name FROM sakila.language WHERE sakila.language.name = "English") tbl_eng
inner join
(SELECT title, language_id FROM film WHERE title like  'K%' or title like 'Q%') tbl_kq
on tbl_eng.language_id = tbl_kq.language_id
;

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT title, tbl_film.actor_id, tbl_actor.first_name,tbl_actor.last_name
FROM
(SELECT title, actor_id
FROM sakila.film_actor  left join sakila.film
on film_actor.film_id = film.film_id
WHERE film.title = "Alone Trip") tbl_film
inner join
(SELECT *
FROM actor)  tbl_actor
on tbl_film.actor_id = tbl_actor.actor_id
;

-- * 7c. You want to run an email marketing campaign in Canada,
--  for which you will need the names and email addresses of all Canadian customers.
--  Use joins to retrieve this information.

SELECT city_customer.email,city_country.country
FROM
(SELECT address.city_id, customer.email
FROM sakila.customer
join sakila.address
on customer.address_id = address.address_id) city_customer
inner join
(SELECT city.city_id, country.country
FROM sakila.country
join sakila.city
on country.country_id = city.country_id WHERE country.country = "Canada")  
city_country
on city_customer.city_id = city_country.city_id
;

-- * 7d. Sales have been lagging among young families, and you wish to target all 
-- family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title as Title, name as Category
FROM
(SELECT title, film_id
FROM film) tbl_film
inner join
(
SELECT film_category.film_id, category.category_id, category.name
FROM film_category join category
on film_category.category_id = category.category_id
WHERE category.name = "Family"
)  tbl_category
on tbl_film.film_id = tbl_category.film_id
;

-- * 7e. Display the most frequently rented movies in descending order.

SELECT tbl_film.title as Title, count(tbl_rent.film_id) as Frequency
FROM
(SELECT film_id,rental_id
FROM rental join inventory
on rental.inventory_id = inventory.inventory_id) tbl_rent
inner join
(
SELECT film_id, title
FROM film
)  tbl_film
on tbl_rent.film_id = tbl_film.film_id
GROUP by tbl_rent.film_id
order by  Frequency desc
;
-- * 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, sum(amount) as Total
FROM
(SELECT store.store_id, inventory.inventory_id
FROM store join inventory
on store.store_id = inventory.store_id) tbl_store
 join
(
SELECT rental.rental_id, rental.inventory_id, payment.amount
FROM rental join payment
on rental.rental_id = payment.rental_id
)  tbl_rental
on tbl_store.inventory_id = tbl_rental.inventory_id
GROUP by store_id
;

-- * 7g. Write a query to display for each store its store ID, city, and country.

SELECT tbl_address.city_id,address_id, city as City, country as Country
FROM
(SELECT address.address_id, address.city_id
FROM store join
address 
on store.address_id = address.address_id) tbl_address
join
(SELECT city.city_id, city.city, country.country
FROM city join country
on city.country_id = country.country_id) tbl_city
on tbl_address.city_id = tbl_city.city_id;
-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following TABLEs: category, film_category, inventory, payment, and rental.)
SELECT genre, sum(amount) as Revenue 
FROM
(SELECT tbl_film.film_id,tbl_rental.amount
FROM
(SELECT inventory.inventory_id, inventory.film_id
FROM  inventory
) tbl_film
inner join
(
SELECT rental.rental_id, rental.inventory_id, payment.amount
FROM rental join payment
on rental.rental_id = payment.rental_id
)  tbl_rental
on tbl_film.inventory_id = tbl_rental.inventory_id) table1
join
(SELECT tbl_film.film_id, tbl_film.title, tbl_category.name as genre
FROM
(SELECT title, film_id
FROM film) tbl_film
join
(
SELECT film_category.film_id, category.category_id, category.name
FROM film_category join category
on film_category.category_id = category.category_id
)  tbl_category
on tbl_film.film_id = tbl_category.film_id) table2
on table1.film_id = table2.film_id
GROUP by genre
order by Revenue desc limit 5
;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution FROM the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view Top_Revenue_View
as
(
SELECT genre, sum(amount) as Revenue 
FROM
(SELECT tbl_film.film_id,tbl_rental.amount
FROM
(SELECT inventory.inventory_id, inventory.film_id
FROM  inventory
) tbl_film
inner join
(
SELECT rental.rental_id, rental.inventory_id, payment.amount
FROM rental join payment
on rental.rental_id = payment.rental_id
)  tbl_rental
on tbl_film.inventory_id = tbl_rental.inventory_id) table1
join
(SELECT tbl_film.film_id, tbl_film.title, tbl_category.name as genre
FROM
(SELECT title, film_id
FROM film) tbl_film
join
(
SELECT film_category.film_id, category.category_id, category.name
FROM film_category join category
on film_category.category_id = category.category_id
)  tbl_category
on tbl_film.film_id = tbl_category.film_id) table2
on table1.film_id = table2.film_id
GROUP by genre
order by Revenue desc limit 5
);


-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM
Top_Revenue_View;
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view Top_Revenue_View;
