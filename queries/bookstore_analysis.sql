-- =====================================================
-- SQL Bookstore Analysis
-- Author: Javiera Lobos
-- Project: TripleTen Data Analysis Bootcamp
-- Database: Online bookstore
-- =====================================================
--
-- Objective:
-- Analyze a relational database from an online bookstore to answer
-- business questions about books, authors, publishers, ratings, and reviews.
--
-- Tables:
--   books(book_id, author_id, title, num_pages, publication_date, publisher_id)
--   authors(author_id, author)
--   publishers(publisher_id, publisher)
--   ratings(rating_id, book_id, username, rating)
--   reviews(review_id, book_id, username, text)
--
-- =====================================================


-- =====================================================
-- 1. Data Exploration
-- =====================================================

-- Preview books table
SELECT *
FROM books
LIMIT 5;


-- Preview authors table
SELECT *
FROM authors
LIMIT 5;


-- Preview publishers table
SELECT *
FROM publishers
LIMIT 5;


-- Preview ratings table
SELECT *
FROM ratings
LIMIT 5;


-- Preview reviews table
SELECT *
FROM reviews
LIMIT 5;


-- Count total records by table
SELECT COUNT(*) AS total_books
FROM books;

SELECT COUNT(*) AS total_authors
FROM authors;

SELECT COUNT(*) AS total_publishers
FROM publishers;

SELECT COUNT(*) AS total_ratings
FROM ratings;

SELECT COUNT(*) AS total_reviews
FROM reviews;


-- =====================================================
-- 2. Business Questions
-- =====================================================

-- =====================================================
-- Question 1
-- Find the number of books released after January 1, 2000
-- Result: 819 books
-- =====================================================

SELECT
    COUNT(*) AS total_books
FROM books
WHERE publication_date > '2000-01-01';


-- =====================================================
-- Question 2
-- Find the number of text reviews and the average rating for each book
-- Main result: "Twilight (Twilight #1)" had the highest number of reviews (7)
-- =====================================================

SELECT
    b.book_id,
    b.title,
    COUNT(DISTINCT rv.review_id) AS total_reviews,
    ROUND(AVG(rt.rating), 2) AS avg_rating
FROM books AS b
LEFT JOIN reviews AS rv
    ON b.book_id = rv.book_id
LEFT JOIN ratings AS rt
    ON b.book_id = rt.book_id
GROUP BY
    b.book_id,
    b.title
ORDER BY total_reviews DESC;


-- =====================================================
-- Question 3
-- Identify the publisher that has released the greatest number
-- of books with more than 50 pages
-- Result: Penguin Books, 42 books
-- =====================================================

SELECT
    p.publisher,
    COUNT(b.book_id) AS total_books
FROM books AS b
INNER JOIN publishers AS p
    ON b.publisher_id = p.publisher_id
WHERE b.num_pages > 50
GROUP BY p.publisher
ORDER BY total_books DESC
LIMIT 5;


-- =====================================================
-- Question 4
-- Identify the author with the highest average book rating,
-- considering only books with at least 50 ratings
-- Result: J.K. Rowling/Mary GrandPré, average rating 4.29
-- =====================================================

WITH books_50_ratings AS (
    SELECT
        book_id
    FROM ratings
    GROUP BY book_id
    HAVING COUNT(rating_id) >= 50
)

SELECT
    a.author,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM books AS b
INNER JOIN authors AS a
    ON b.author_id = a.author_id
INNER JOIN ratings AS r
    ON b.book_id = r.book_id
WHERE b.book_id IN (
    SELECT book_id
    FROM books_50_ratings
)
GROUP BY a.author
ORDER BY avg_rating DESC
LIMIT 10;


-- =====================================================
-- Question 5
-- Find the average number of text reviews among users
-- who rated more than 50 books
-- Result: 24.33 average text reviews
-- =====================================================

WITH active_users AS (
    SELECT
        username
    FROM ratings
    GROUP BY username
    HAVING COUNT(book_id) > 50
)

SELECT
    ROUND(AVG(review_count), 2) AS avg_reviews
FROM (
    SELECT
        username,
        COUNT(review_id) AS review_count
    FROM reviews
    WHERE username IN (
        SELECT username
        FROM active_users
    )
    GROUP BY username
) AS user_reviews;
