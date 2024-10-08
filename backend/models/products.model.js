const db = require('../db');

// Function to create a product
const createProduct = ({ title, description, sku, weight }) => {
    return new Promise((resolve, reject) => {
        const created_at = new Date();
        const query = `INSERT INTO Product (title, description, sku, weight, created_at, updated_at)
                       VALUES (?, ?, ?, ?, ?, NULL)`;

        db.query(query, [title, description, sku, weight, created_at], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

const getAllProducts = () => {
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

const updateProduct = ({ id, title, description, sku, weight }) => {
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

const deleteProduct = ({ id }) => {
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

// Export functions as properties of an object
module.exports = {
    createProduct,
    getAllProducts,
    updateProduct,
    deleteProduct,
};
