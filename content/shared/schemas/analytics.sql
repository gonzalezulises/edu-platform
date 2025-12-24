-- Analytics Database Schema
-- Sample schema for SQL exercises

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    country TEXT
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status TEXT CHECK(status IN ('pending', 'completed', 'cancelled')),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Sample data
INSERT INTO users (id, name, email, country) VALUES
(1, 'Ana Garcia', 'ana@example.com', 'Mexico'),
(2, 'Carlos Lopez', 'carlos@example.com', 'Spain'),
(3, 'Maria Rodriguez', 'maria@example.com', 'Argentina'),
(4, 'Juan Martinez', 'juan@example.com', 'Colombia'),
(5, 'Sofia Hernandez', 'sofia@example.com', 'Chile');

INSERT INTO products (id, name, category, price, stock) VALUES
(1, 'Laptop Pro', 'Electronics', 1299.99, 50),
(2, 'Wireless Mouse', 'Electronics', 29.99, 200),
(3, 'USB-C Hub', 'Electronics', 49.99, 150),
(4, 'Python Book', 'Books', 39.99, 100),
(5, 'Data Science Guide', 'Books', 44.99, 75);

INSERT INTO orders (id, user_id, total, status, created_at) VALUES
(1, 1, 1349.97, 'completed', '2024-01-15'),
(2, 2, 89.98, 'completed', '2024-01-16'),
(3, 1, 44.99, 'pending', '2024-01-17'),
(4, 3, 1329.98, 'completed', '2024-01-18'),
(5, 4, 29.99, 'cancelled', '2024-01-19');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1299.99),
(1, 2, 1, 29.99),
(1, 3, 1, 49.99),
(2, 2, 2, 29.99),
(2, 3, 1, 29.99),
(3, 5, 1, 44.99),
(4, 1, 1, 1299.99),
(4, 2, 1, 29.99),
(5, 2, 1, 29.99);
