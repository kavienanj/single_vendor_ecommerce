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

// Function to get all products with their variants and attributes
exports.getAllProductsWithVariantsAndAttributes = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                p.product_id, p.title, p.description, p.sku, p.weight,
                v.variant_id, v.name AS variant_name, v.price, v.image_url,
                a.attribute_name, av.attribute_value
            FROM Product p
            LEFT JOIN Variant v ON p.product_id = v.product_id
            LEFT JOIN Custom_Attribute_Value av ON v.variant_id = av.variant_id
            LEFT JOIN Custom_Attribute a ON av.attribute_id = a.attribute_id
            ORDER BY p.product_id, v.variant_id;
        `;

        db.query(query, (err, rows) => {
            if (err) {
                return reject(err);
            }
            resolve(rows);
        });
    });
};



