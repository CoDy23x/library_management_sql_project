-- Library Management System

-- Creating branch table
CREATE TABLE branch(
					branch_id VARCHAR(10) PRIMARY KEY,
                    manager_id VARCHAR(10),
                    branch_address VARCHAR(50),
                    contact_no VARCHAR(20)
                    );

-- Creating employees table
CREATE TABLE employees(
					emp_id VARCHAR(10) PRIMARY KEY,
                    emp_name VARCHAR(20),
                    position VARCHAR(15),
                    salary INT,
                    branch_id VARCHAR(10)
                    );

-- Creating books table
CREATE TABLE books(
					isbn VARCHAR(20) PRIMARY KEY,
                    book_title VARCHAR(75),
                    category VARCHAR(10),
                    rental_price FLOAT,
                    status VARCHAR(15),
                    author VARCHAR(35),
                    publisher VARCHAR(50)
                    );
ALTER TABLE books
MODIFY COLUMN category VARCHAR(20);                    
                    
-- Creating members table
CREATE TABLE members(
					member_id VARCHAR(20) PRIMARY KEY,
                    member_name VARCHAR(25),
                    member_address VARCHAR(75),
                    reg_date DATE
                    );

-- Creating issued_status table
CREATE TABLE issued_status(
							issued_id VARCHAR(10) PRIMARY KEY,
                            issued_member_id VARCHAR(10),
                            issued_book_name VARCHAR(75),
                            issued_date DATE,
                            issued_book_isbn VARCHAR(25),
                            issued_emp_id VARCHAR(10)
                            );
                            
-- Creating return_status table
CREATE TABLE return_status(
							return_id VARCHAR(10) PRIMARY KEY,
                            issued_id VARCHAR(10),
                            return_book_name VARCHAR(75),
                            return_date DATE,
                            return_book_isbn VARCHAR(20)
                            );      
                            
-- ADDING FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_empoyees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Project Task

-- Task.1 Create a New Book Record -- ("978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B Lippincott & Co.');

-- Task.2 Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Task.3 Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task.4 Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task.5 List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id -- COUNT(issued_book_name) as issued_books_number
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_book_name) > 1;

-- CTAS
-- Task.6 Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued-cnt**
CREATE TABLE book_cnts
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts;

-- Task.7 Retrieve All Books in a Specific Category
SELECT *
FROM books
WHERE category = 'Dystopian';

-- Task.8 Find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task.9 List Members Who Registered in the Last 360 Days
SELECT *
FROM members
WHERE reg_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY);

-- Task.10 List Employees with Their Branch Manager's Name and their branch details
SELECT e1.*, e2.emp_id as manager_id, e2.emp_name as manager_name
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;

-- Task.11 Create a Table of Books with Rental Price Above a Certain Threshold ($7)
CREATE TABLE books_price_greater_than_7
AS
SELECT * 
FROM books 
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_7;

-- TASK.12 Retrieve the List of Books Not Yet Returned
SELECT DISTINCT issued_book_name
FROM issued_status
LEFT JOIN return_status
ON issued_status.issued_id = return_status.issued_id
WHERE return_status.return_id IS NULL;

-- Adding new column in return_status
ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS112', 'IS117', 'IS118');

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task.13 Identify Members with Overdue Books. 
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's id, member's name, book title, issue date and days overdue.
SELECT members.member_id, members.member_name, ist.issued_book_name, ist.issued_date, DATEDIFF('2024-04-29', ist.issued_date) as overdue_days
FROM issued_status as ist
JOIN members
ON ist.issued_member_id = members.member_id
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL AND DATEDIFF('2024-04-29', ist.issued_date) > 30
ORDER BY 1;

-- Task.14 Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';
SELECT * FROM return_status WHERE issued_id = 'IS135';

-- Store Procedure
DELIMITER $$
DROP PROCEDURE IF EXISTS add_return_records;
CREATE PROCEDURE add_return_records(
	IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(15)
)
BEGIN
	DECLARE v_isbn VARCHAR(50); 
    DECLARE v_book_name VARCHAR(80);

	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES(p_return_id, p_issued_id, CURRENT_DATE(), p_book_quality);
    
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;
    
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;
    
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END $$
DELIMITER ;

CALL add_return_records('RS135', 'IS135', 'Damaged');
/*
Task.15 Branch Performance Report. Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE branch_reports
AS
SELECT 
	employees.branch_id,
    COUNT(issued_status.issued_id) AS number_of_books_issued,
    COUNT(return_status.return_id) AS number_of_books_returned,
    SUM(books.rental_price) AS total_revenue
FROM employees
JOIN issued_status
ON emp_id = issued_emp_id
LEFT JOIN return_status
ON issued_status.issued_id = return_status.issued_id
JOIN books
ON issued_status.issued_book_isbn = books.isbn
GROUP BY employees.branch_id
ORDER BY 1;

SELECT * FROM branch_reports;

/*
Task.16 CTAS: Create a Table of Active Members. 
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 6 months.
*/
CREATE TABLE active_members
AS
SELECT * 
FROM members
WHERE member_id IN (
					SELECT DISTINCT issued_member_id
					FROM issued_status
					WHERE DATE_SUB('2024-09-29', INTERVAL 6 MONTH) <= issued_date
);

SELECT * FROM active_members;

/* Task.17 Find Employees with the Most Book Issues Processed. 
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/
SELECT emp_name,
		branch.*,
		COUNT(issued_id) AS number_of_books_processed
FROM issued_status
JOIN employees
ON issued_emp_id = emp_id
JOIN branch
ON employees.branch_id = branch.branch_id
GROUP BY issued_emp_id
ORDER BY number_of_books_processed DESC
LIMIT 3;

/* Task.18 Identify Members Issuing High-Risk Books.
Write a query to identify members who have issued books at least once with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/
SELECT member_name, issued_book_name, COUNT(book_quality) AS number_of_time_issued_damaged_books
FROM issued_status
JOIN return_status
ON issued_status.issued_id = return_status.issued_id
JOIN members
ON issued_status.issued_member_id = members.member_id
WHERE book_quality = 'Damaged'
GROUP BY return_status.issued_id;

/* Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS update_status;
CREATE PROCEDURE update_status(
							IN p_book_isbn VARCHAR(20),
                            IN p_issued_id VARCHAR(10),
                            IN p_issued_member_id VARCHAR(10),
                            IN p_issued_emp_id VARCHAR(10)
)
BEGIN
                            DECLARE v_status VARCHAR(15);
                            DECLARE v_book_title VARCHAR(75);
                            
                            SELECT status, book_title
                            INTO v_status, v_book_title
                            FROM books
                            WHERE p_book_isbn = isbn;
                            
                            IF v_status = 'yes' THEN
									UPDATE books
									SET status = 'no'
									WHERE p_book_isbn = isbn;
                                    
									SELECT CONCAT('The book has successfully issued: ', p_book_isbn) AS message;
                                    
                                    INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
                                    VALUES(p_issued_id, p_issued_member_id, v_book_title, CURRENT_DATE(), p_book_isbn, p_issued_emp_id);
							ELSE
									SELECT CONCAT('The book is currently not available: ', p_book_isbn) AS message;
							END IF;
END $$
DELIMITER ;

CALL update_status('978-0-7434-7679-3', '141', 'C110', 'E105');

/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines.
*/
SELECT members.member_id, COUNT(rs.return_date IS NULL) AS number_of_overdue_books, (DATEDIFF('2024-04-29', ist.issued_date)-30) AS overdue_days, (DATEDIFF('2024-04-29', ist.issued_date)-30) * 0.5 AS fine
FROM issued_status as ist
JOIN members
ON ist.issued_member_id = members.member_id
JOIN books
ON books.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL AND (DATEDIFF('2024-04-29', ist.issued_date)-30) > 0
GROUP BY 1, 3, 4
ORDER BY 1;