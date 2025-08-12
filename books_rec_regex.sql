-- SELECT
-- 	AUTHOR
-- FROM
-- 	BOOKS_GOLD
-- 	---WHERE author like '%Rowling%'
-- 	---WHERE author ~ 'Rowl'
-- 	---WHERE REGEXP_LIKE(author,'Rowl')
-- WHERE
-- 	REGEXP_LIKE (AUTHOR, '(j\.|joan(n?)e) k\. rowl', 'i')
-- LIMIT
-- 	10

-- Validni ISBN podle standardu:
--  1. 10 nebo 13 mist
--  2. pokud je 10 mist, tak je posledni znak X/x
--  3. muze obsahovat pomlcky uvnitr (ne na zacatku a konci)

-- Jak vypadaji nevalidni isbn:
-- SELECT
-- 	isbn
-- FROM
-- 	BOOKS_SILVER
-- WHERE
-- 	-- REGEXP_LIKE (isbn, '\d+[^x\d]$', 'i') OR
-- 	-- REGEXP_LIKE (isbn, '^[^\d]', 'i') OR
-- 	REGEXP_LIKE (isbn, '[^\da-z\-]', 'i')
-- LIMIT
-- 	10
-- -- 117 rows
-----------------------------------------------------------------
-- Pouze validni isbn - Ratings:
-- (napr. 1234-5-6-78-90)
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Ratings"
WHERE
	--REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '')
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(.{10})|(.{13})$', 'i')
	--"ISBN" LIKE '%/%'
--1 143 897  rows
----------------------------------------------------------------------
-- Pouze validni isbn - Books:
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Books"
WHERE
	--REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '')
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(.{10})|(.{13})$', 'i')
---71 770 rows
------------------------------------------------------------------

--- TEST JOIN
SELECT b."ISBN", COUNT(1) AS cnt
FROM "Books" as b
INNER JOIN "Ratings" as r
  ON b."ISBN" = r."ISBN"
GROUP BY b."ISBN"
ORDER BY cnt DESC

-- 71 626 rows






-- SELECT
-- 	AUTHOR
-- FROM
-- 	BOOKS_GOLD
-- 	---WHERE author like '%Rowling%'
-- 	---WHERE author ~ 'Rowl'
-- 	---WHERE REGEXP_LIKE(author,'Rowl')
-- WHERE
-- 	REGEXP_LIKE (AUTHOR, '(j\.|joan(n?)e) k\. rowl', 'i')
-- LIMIT
-- 	10

-- Validni ISBN podle standardu:
--  1. 10 nebo 13 mist
--  2. pokud je 10 mist, tak je posledni znak X/x
--  3. muze obsahovat pomlcky uvnitr (ne na zacatku a konci)

-- Jak vypadaji nevalidni isbn:
-- SELECT
-- 	isbn
-- FROM
-- 	BOOKS_SILVER
-- WHERE
-- 	-- REGEXP_LIKE (isbn, '\d+[^x\d]$', 'i') OR
-- 	-- REGEXP_LIKE (isbn, '^[^\d]', 'i') OR
-- 	REGEXP_LIKE (isbn, '[^\da-z\-]', 'i')
-- LIMIT
-- 	10
-- -- 117 rows
-----------------------------------------------------------------
-- Pouze validni isbn - Ratings:
-- (napr. 1234-5-6-78-90)
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Ratings"
WHERE
	--REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '')
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(.{10})|(.{13})$', 'i')
	--"ISBN" LIKE '%/%'
--1 143 897  rows
----------------------------------------------------------------------
-- Pouze validni isbn - Books:
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Books"
WHERE
	--REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '')
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(.{10})|(.{13})$', 'i')
---71 770 rows
------------------------------------------------------------------

--- TEST JOIN
SELECT b."ISBN", COUNT(1) AS cnt
FROM "Books" as b
INNER JOIN "Ratings" as r
  ON b."ISBN" = r."ISBN"
GROUP BY b."ISBN"
ORDER BY cnt DESC

-- 71 626 rows

CREATE TABLE ratings_silver_ER AS
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Ratings"
WHERE
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(\d{9}x)|(\d{10})|(\d{13})$', 'i')

--1 142 433 rows

CREATE TABLE books_silver_ER AS
SELECT REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', '') AS "ISBN"
FROM
	"Books"
WHERE
	REGEXP_LIKE (REGEXP_REPLACE ("ISBN", '[^a-zA-Z0-9]', ''), '^(\d{9}x)|(\d{10})|(\d{13})$', 'i')
