/* BRONZE-SILVER-GOLD DATA PROCESING PIPELINE - BOOK RECOMMENDATIONS
dataset: https://www.kaggle.com/datasets/arashnic/book-recommendation-dataset

Files:
Books.csv (271 360 rows)
Ratings.csv (1 149 780 rows)  
Users.csv (278 858 rows)

Data source: www.bookcrossing.com, Amazon Web Services in 2004
-----------------------------------------------------------------------------------

BRONZE LAYER
Uploading into database - Postgres

Books.csv 	- recoding of HTML entities (&amp;) 	-> 1. sudo apt install recode
												-> cat Books.csv | recode html..utf-8 > Books_HTML_entity
			- error in encoding - not able to solve


------------------------------------------------------------------------------------
SILVER LAYER - DATA CLEANING

BOOK_SILVER

- 3 rows - columns shifted to the left (Title and Author joined in one column - erased
- "Year-Of-Publication" -> integer
- "Year-Of-Publication" '0'-> NULL (4 618 rows)
- "Year-Of-Publication" over 2004 -> NULL (72 rows)
- "Book-Author" 'Not Applicable (Na )' -> NULL (286 rows)

- "ISBN"
	- Regular Expressions
-Ratings:

CREATE TABLE ratings_silver_ER AS
SELECT REGEXP_REPLACE (isbn, '[^a-zA-Z0-9]', '') AS isbn
FROM
	ratings_silver
WHERE
	REGEXP_LIKE (REGEXP_REPLACE (isbn, '[^a-zA-Z0-9]', ''), '^(\d{9}x)|(\d{10})|(\d{13})$', 'i')
	
-- 1 142 433 rows
----------------------------------------------------------------------
- Books:
CREATE TABLE books_silver_ER AS
SELECT REGEXP_REPLACE (isbn, '[^a-zA-Z0-9]', '') AS isbn
FROM
	books_silver
WHERE
	REGEXP_LIKE (REGEXP_REPLACE (isbn, '[^a-zA-Z0-9]', ''), '^(\d{9}x)|(\d{10})|(\d{13})$', 'i')
	
-- 71 654  rows
-------------------------------------------------------------------------
TEST JOIN
SELECT *
FROM books_silver_ER as b
INNER JOIN ratings_silver_ER as r
  ON b.isbn = r.isbn

-- 196 300 rows

SELECT b.isbn, COUNT(1) AS cnt
FROM books_silver_ER as b
INNER JOIN ratings_silver_ER as r
  ON b.isbn = r.isbn
GROUP BY b.isbn
ORDER BY cnt DESC

-- 71 161 rows

*/

DROP TABLE IF EXISTS "books_silver";

CREATE TABLE books_silver AS
SELECT
	"ISBN" AS isbn,
	"Book-Title" AS title,
	NULLIF("Book-Author", 'Not Applicable (Na )') AS author,
	CASE
		WHEN "Year-Of-Publication" = '0' THEN NULL
		 WHEN CAST("Year-Of-Publication" AS integer) > 2004 THEN NULL
        ELSE CAST("Year-Of-Publication" AS integer)
    END AS year,
	"Publisher" AS publisher,
	"Image-URL-S" as imgs,
	"Image-URL-M" as imgm,
	"Image-URL-L" as imgl
FROM "Books_HTML_entity"
WHERE length("Year-Of-Publication") <= 4
--- in case of future new data loading -> AND "Year-Of-Publication" <= DATE_PART(year, CURRENT_DATE)

---SELECT * FROM books_silver
---271 357 rows

---------------------------------------------------------------------------------
/* USERS_SILVER
- "Location" -> town, state, country
- "Age" - values up to 244 -> 100 - 244 => NULL
- "Age" - real to integer
- town, state and country - sigle values as ,.!/ -> smaller then 2 THEN NULL
- town, state and country - 'n/a' -: NULL
*/

DROP TABLE IF EXISTS users_silver;

CREATE TABLE users_silver as
WITH users_loc_split AS (
	SELECT "User-ID" AS user_id, 
		TRIM(SPLIT_PART("Location", ',', 1)) AS town, 
		TRIM(SPLIT_PART("Location", ',', 2)) AS state, 
		TRIM(SPLIT_PART("Location", ',', 3)) AS country,
		CASE 
			WHEN "Age" > '100' THEN NULL
			ELSE "Age" :: integer
		END AS age
	FROM "Users"
)
SELECT user_id, 
	CASE
		WHEN LENGTH(town) < 2 THEN NULL
		WHEN town = 'n/a' THEN NULL
		ELSE town
	END as town,
	CASE
		WHEN LENGTH(state) < 2 THEN NULL
		WHEN state = 'n/a' THEN NULL
		ELSE state
	END as state,
	CASE
		WHEN LENGTH(country) < 2 THEN NULL
		WHEN country = 'n/a' THEN NULL
		ELSE country
	END as country,
	age
FROM users_loc_split;

--- SELECT * FROM users_silver
--- 278 858 rows
---------------------------------------------------------------------------
--RATINGS_SILVER

CREATE TABLE ratings_silver AS
SELECT "User-ID" AS user_id, "ISBN" AS isbn, "Book-Rating" AS rating
FROM "Ratings"

--- SELECT * FROM ratings_silver
--- 1 149 780 

--------------------------------------------
/* GOLD LAYER - for visualization in Tableau

BOOKS_GOLD
- erase columns with images (imgs, imgm, imgl)
- erase books (isbn), which aren't in ratings_silver
*/

DROP TABLE IF EXISTS books_gold;

CREATE TABLE books_gold AS

insert into books_gold (isbn, title, author, year, publisher)
SELECT isbn, title, author, year, publisher FROM books_silver AS bs
WHERE EXISTS (
    SELECT 1
    FROM ratings_silver AS rs
	WHERE rs.isbn = bs.isbn
)

---select * from books_gold
--- from 271 285 to 71 624 rows

----------------------------------------------------------------------------
/* RATINGS GOLD
- erase ratings (isbn), which aren't in books_silver
- implicit rating '0' -> NULL (115 987  rows)
*/

DROP TABLE IF EXISTS ratings_gold;

CREATE TABLE ratings_gold AS
SELECT user_id, isbn, NULLIF(rating, 0) AS rating FROM ratings_silver AS rs
WHERE EXISTS (
    SELECT 1
    FROM books_gold AS bg
	WHERE bg.isbn = rs.isbn
)

select * from ratings_gold
--- from 1 149 780 to 196 763 rows

-------------------------------------------------------------------
--- TEST JOIN
SELECT *
FROM books_gold as b
INNER JOIN ratings_gold as r
  ON b.isbn = r.isbn
-- 196 763 
  
SELECT b.isbn, COUNT(1) AS cnt
FROM books_gold as b
INNER JOIN ratings_gold as r
  ON b.isbn = r.isbn
GROUP BY b.isbn
ORDER BY cnt DESC

--- 71 605 rows
--------------------------------------------------------------------
/*INDEXES IN POSTGRES
- books_gold_author
- books_gold_year
- ratings_gold_rating
*/

