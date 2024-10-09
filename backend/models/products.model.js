const db = require('../db');

// Function to create a product
exports.createProduct = ({ title, description, sku, weight }) => {
    return new Promise((resolve, reject) => {
        const created_at = new Date();
        const query = `INSERT INTO Product (title, description, sku, weight, created_at, updated_at)
                       VALUES (?, ?, ?, ?, ?, ?)`;

        db.query(query, [title, description, sku, weight, created_at, created_at], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to get all products
exports.getAllProducts = () => {
    return new Promise((resolve, reject) => {
        const query = `SELECT * FROM Product`;

        db.query(query, (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to update a product
exports.updateProduct = ({ id, title, description, sku, weight }) => {
    return new Promise((resolve, reject) => {
        const updated_at = new Date();

        const query = `UPDATE Product SET title = ?, description = ?, sku = ?, weight = ?, updated_at = ? WHERE product_id = ?`;

        db.query(query, [title, description, sku, weight, updated_at, id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to delete a product
exports.deleteProduct = ({ id }) => {
    return new Promise((resolve, reject) => {
        const query = `DELETE FROM Product WHERE product_id = ?`;

        db.query(query, [id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}
