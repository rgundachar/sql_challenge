-- database 
use sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
select first_name,last_name from sakila.actor;


-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

select  CONCAT(first_name, ',', last_name) AS 'Actor Name' FROM sakila.actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id,first_name,last_name from sakila.actor where upper(first_name)='JOE';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
select actor_id,first_name,last_name from sakila.actor where upper(last_name) like '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

select actor_id,first_name,last_name from sakila.actor where upper(last_name) like '%LI%' order by last_name,first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id,country from sakila.country where lower(country) in ('afghanistan', 'bangladesh','china');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table sakila.actor add(description blob);

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table sakila.actor drop column description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.

select count(*), last_name from sakila.actor where last_name is not null group by last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select count(*) cnt , last_name from sakila.actor where last_name is not null group by last_name having cnt>=2;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update sakila.actor set first_name='HARPO' where first_name='GROUCHO' and last_name='WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update sakila.actor set first_name='HARPO' where first_name='GROUCHO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
desc address;
create table address(
address_id smallint(5) auto_increment not null primary key,
address varchar(50) not null,
address2 varchar(50) ,
district varchar(20),
city_id smallint(5) not null ,
postal_code varchar(10),
phone varchar(20),
location geometry not null ,
last_update timestamp not null);

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT S.first_name,S.last_name,A.*
FROM sakila.staff S
INNER JOIN sakila.address A
ON S.address_id =A.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT sum(amount),S.*
FROM sakila.staff S
INNER JOIN sakila.payment P
ON S.staff_id =P.staff_id group by s.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select count(*) as '# of actors',title from sakila.film F 
inner join sakila.film_actor FA
on F.film_id=FA.film_id  
group by title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select count(*) as '# of copies' ,F.title  from sakila.film F 
inner join sakila.inventory I 
on F.film_id=I.film_id
where title='Hunchback Impossible';


-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT C.first_name,C.last_name,sum(P.amount) as 'Total Paid'
FROM sakila.Customer C
INNER JOIN sakila.payment P
ON C.customer_id =P.customer_id
group by C.customer_id;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select F.title as 'Title' from sakila.film F where title like 'Q%' or title like 'K%' and F.language_id in (select L.language_id 
from sakila.language L where lower(L.name)='english');

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT A.first_name, A.last_name
FROM sakila.actor A
WHERE A.actor_id
	IN (SELECT FA.actor_id FROM sakila.film_actor FA WHERE FA.film_id 
		IN (SELECT F.film_id from sakila.film F where F.title='ALONE TRIP'));

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT C.first_name, C.last_name, C.email 
FROM sakila.customer C
JOIN sakila.address a ON (C.address_id = a.address_id)
JOIN sakila.city cit ON (a.city_id=cit.city_id)
JOIN sakila.country cntry ON (cit.country_id=cntry.country_id);

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title from sakila.film f
JOIN sakila.film_category fc on (f.film_id=fc.film_id)
JOIN sakila.category c on (fc.category_id=c.category_id);

-- * 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(f.film_id) AS 'Count of Rented Movies'
FROM  film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) 
FROM sakila.payment p
JOIN sakila.staff s ON (p.staff_id=s.staff_id)
GROUP BY store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM sakila.store s
JOIN sakila.address a ON (s.address_id=a.address_id)
JOIN sakila.city c ON (a.city_id=c.city_id)
JOIN sakila.country cntry ON (c.country_id=cntry.country_id);

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM sakila.category c
JOIN sakila.film_category fc ON (c.category_id=fc.category_id)
JOIN sakila.inventory i ON (fc.film_id=i.film_id)
JOIN sakila.rental r ON (i.inventory_id=r.inventory_id)
JOIN sakila.payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create sakila.view top_five_generes as 
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM sakila.category c
JOIN sakila.film_category fc ON (c.category_id=fc.category_id)
JOIN sakila.inventory i ON (fc.film_id=i.film_id)
JOIN sakila.rental r ON (i.inventory_id=r.inventory_id)
JOIN sakila.payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;


-- * 8b. How would you display the view that you created in 8a?
select * from sakila.top_five_generes;
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view sakila.top_five_generes;
