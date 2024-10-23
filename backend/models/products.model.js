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
        const query = `
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
        GROUP BY p.product_id
        ORDER BY p.title;
    `;

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

// Function to get product with variants and attributes
exports.getProductWithVariantsAndAttributes = ({ id }) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                p.product_id as product_id,
                p.title AS product_name,
                p.description AS product_description,
                p.default_price AS price,
                p.default_image AS image_url,
                p.sku,
                p.weight,
                JSON_ARRAYAGG(c.category_name) AS categories,
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'variant_id', dv.variant_id,
                            'variant_name', dv.name,
                            'price', dv.price,
                            'image_url', dv.image_url,
                            'attributes', (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'attribute_name', ca.attribute_name,
                                        'attribute_value', cav.attribute_value
                                    )
                                )
                                FROM Custom_Attribute ca
                                JOIN Custom_Attribute_Value cav ON ca.attribute_id = cav.attribute_id
                                WHERE cav.variant_id = dv.variant_id
                            )
                        )
                    )
                    FROM (
                        SELECT DISTINCT *
                        FROM Variant v
                        WHERE v.product_id = p.product_id
                    ) AS dv
                ) AS variants
            FROM Product p
            JOIN Product_Category_Match pcm ON p.product_id = pcm.product_id
            JOIN Category c ON pcm.category_id = c.category_id
            WHERE p.product_id = ?
            GROUP BY p.product_id
            ORDER BY p.title;
        `;

        db.query(query, [id], (err, rows) => {
            if (err) {
                return reject(err);
            }
            resolve(rows[0]);
        });
    });
};
