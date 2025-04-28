# Library Management System Project using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/CoDy23x/library_management_sql_project/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/CoDy23x/library_management_sql_project/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B Lippincott & Co.');
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_member_id
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_book_name) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT *
FROM books
WHERE category = 'Dystopian';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT *
FROM members
WHERE reg_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY);
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e1.*, e2.emp_id as manager_id, e2.emp_name as manager_name
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_price_greater_than_7
AS
SELECT * 
FROM books 
WHERE rental_price > 7;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT DISTINCT issued_book_name
FROM issued_status
LEFT JOIN return_status
ON issued_status.issued_id = return_status.issued_id
WHERE return_status.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT members.member_id, members.member_name, ist.issued_book_name, ist.issued_date, DATEDIFF('2024-04-29', ist.issued_date) as overdue_days
FROM issued_status as ist
JOIN members
ON ist.issued_member_id = members.member_id
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL AND DATEDIFF('2024-04-29', ist.issued_date) > 30
ORDER BY 1;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * 
FROM members
WHERE member_id IN (
                        SELECT DISTINCT issued_member_id
                        FROM issued_status
                        WHERE DATE_SUB('2024-09-29', INTERVAL 6 MONTH) <= issued_date
);

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql
SELECT member_name, issued_book_name, COUNT(book_quality) AS number_of_time_issued_damaged_books
FROM issued_status
JOIN return_status
ON issued_status.issued_id = return_status.issued_id
JOIN members
ON issued_status.issued_member_id = members.member_id
WHERE book_quality = 'Damaged'
GROUP BY return_status.issued_id;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
SELECT
    members.member_id,
    COUNT(rs.return_date IS NULL) AS number_of_overdue_books,
    (DATEDIFF('2024-04-29', ist.issued_date)-30) AS overdue_days,
    (DATEDIFF('2024-04-29', ist.issued_date)-30) * 0.5 AS fine
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
```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Zero Analyst

Thank you for your interest in this project!
