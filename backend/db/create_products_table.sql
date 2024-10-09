USE ECommerceDatabase;

-- Create the Product table
CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) NOT NULL,
    weight DECIMAL(10, 2),
    created_at DATETIME NOT NULL,
    updated_at DATETIME
);
