CREATE TABLE Books (

    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(255) NOT NULL,
    isbn VARCHAR(255) NOT NULL,
    publication_year YEAR NOT NULL,
    genre VARCHAR(255) NOT NULL,
    available TINYINT(1) NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL );

INSERT INTO Books (title, author, publisher, isbn, publication_year, genre, available, price) VALUES ('Book1', 'Alan Smith', 'Penguin', '9780143103558', 2014, 'Fantasy', 4, 10.99);
INSERT INTO Books (title, author, publisher, isbn, publication_year, genre, available, price) VALUES ('Book2', 'Alan Smith', 'DC', '9780143145678', 2024, 'Horror', 8, 15.99);

CREATE TABLE Members (

    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    register_date DATE NOT NULL
);

INSERT INTO Members (first_name, last_name, address, phone, email, register_date) VALUES ('John', 'Doe', '123 Main St', '123-456-7890', 'JohnDoe@Email.com', '2020-01-01');
INSERT INTO Members (first_name, last_name, address, phone, email, register_date) VALUES ('Jane', 'Doe', '4 Miami St', '098-765-4321', 'JaneDoe@Email.com', '2022-04-06');

CREATE TABLE Loans(
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    loan_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES Members(id),
    FOREIGN KEY (book_id) REFERENCES Books(id)
);

INSERT INTO Loans (member_id, book_id, loan_date, return_date) VALUES (1, 1, '2025-01-01', NULL);
INSERT INTO Loans (member_id, book_id, loan_date, return_date) VALUES (2, 2, '2024-02-02', '2025-02-16');
INSERT INTO Loans (member_id, book_id, loan_date, return_date) VALUES (2, 1, '2025-03-03', NULL);

SELECT
    m.id,
    m.first_name,
    m.last_name,
    GROUP_CONCAT(b.title) as loaned_books
FROM
    Members m
        LEFT JOIN Loans l ON m.id = l.member_id
        LEFT JOIN Books b ON l.book_id = b.id
GROUP BY
    m.id, m.first_name, m.last_name;

SELECT
    m.first_name,
    m.last_name,
    GROUP_CONCAT(b.title) as unreturned_books
FROM
    Members m
        INNER JOIN Loans l ON m.id = l.member_id
        INNER JOIN Books b ON l.book_id = b.id
WHERE
    l.return_date IS NULL
GROUP BY
    m.first_name, m.last_name;

SELECT
    b.publisher as publisher_name,
    COUNT(*) as total_loans
FROM
    Books b
        INNER JOIN Loans l ON b.id = l.book_id
WHERE
    YEAR(l.loan_date) = YEAR(CURRENT_DATE)
GROUP BY
    b.publisher
ORDER BY
    total_loans DESC
LIMIT 1;

SELECT
    b.author,
    COUNT(*) as total_loans
FROM
    Books b
        INNER JOIN Loans l ON b.id = l.book_id
WHERE
    YEAR(l.loan_date) = YEAR(CURRENT_DATE)
GROUP BY
    b.author
ORDER BY
    total_loans
LIMIT 1;

SELECT
    b.title,
    IF((SELECT COUNT(*)
        FROM Loans l
        WHERE l.book_id = b.id
          AND l.return_date IS NULL) >= b.available, 'Unavailable', 'Available') as availability_status
FROM
    Books b
ORDER BY
    b.title;

SELECT
    b.genre,
    COUNT(*) as book_count
FROM
    Books b
GROUP BY
    b.genre
ORDER BY
    b.genre;

SELECT
    'Book' as type,
    b.title as name
FROM
    Books b
WHERE
    NOT EXISTS (
        SELECT 1
        FROM Loans l
        WHERE l.book_id = b.id
    )

UNION

SELECT
    'Member' as type,
    CONCAT(m.first_name, ' ', m.last_name) as name
FROM
    Members m
WHERE
    NOT EXISTS (
        SELECT 1
        FROM Loans l
        WHERE l.member_id = m.id
    )
ORDER BY
    type, name;

SELECT
    AVG(b.price) as average_price
FROM
    Books b
        INNER JOIN Loans l ON b.id = l.book_id
WHERE
    EXTRACT(YEAR FROM b.publication_year) = 2024
GROUP BY
    b.id;

CREATE INDEX idx_genre ON Books(genre);
CREATE INDEX idx_author ON Books(author);
CREATE INDEX idx_publisher ON Books(publisher);

CREATE UNIQUE INDEX idx_email_unique ON Members(email);

