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

// Function to get all products with optional filters, sorting, and limiting
exports.getAllProducts = ({ categoryId, search, sort, order, limit } = {}) => {
    return new Promise((resolve, reject) => {
        // Base query
        let query = `
        SELECT 
            p.product_id as product_id,
            p.title AS product_name,
            p.description AS product_description,
            p.default_price AS price,
            p.default_image AS image_url,
            p.sku,
            p.weight,
            JSON_ARRAYAGG(c.category_name) AS categories
        FROM Product p
        JOIN Product_Category_Match pcm ON p.product_id = pcm.product_id
        JOIN Category c ON pcm.category_id = c.category_id
        `;

        // Optional filtering conditions
        const conditions = [];
        const params = [];

        if (categoryId) {
            conditions.push(`pcm.category_id = ?`);
            params.push(Number(categoryId));
        }

        if (search) {
            conditions.push(`p.title LIKE ?`);
            params.push(`%${search}%`);
        }

        // Append conditions to the query
        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ');
        }

        // Group by clause
        query += ` GROUP BY p.product_id`;

        // Sorting by specified column and order
        let sortColumn = 'p.title'; // Default to sorting by name
        if (sort === 'price') {
            sortColumn = 'p.default_price';
        }

        let sortOrder = 'ASC'; // Default to ascending order
        if (order && (order.toLowerCase() === 'asc' || order.toLowerCase() === 'desc')) {
            sortOrder = order.toUpperCase();
        }

        query += ` ORDER BY ${sortColumn} ${sortOrder}`;

        // Limiting the number of results
        if (limit && !isNaN(limit)) {
            query += ` LIMIT ?`;
            params.push(Number(limit));
        }

        // Execute the query with params
        db.query(query, params, (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
};

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

// Function to get product with variants and attributes
exports.getProductWithVariantsAndAttributes = ({ id }) => {
    return new Promise((resolve, reject) => {
        const query = `CALL GetProductDetails(?)`;

        db.query(query, [id], (err, rows) => {
            if (err) {
                return reject(err);
            }
            resolve(rows[0][0]);
        });
    });
};
