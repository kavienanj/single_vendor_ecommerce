const db = require('../db');

exports.getCategoryWithMostOrders = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                c.category_name,
                COUNT(oi.order_item_id) AS total_orders
            FROM 
                OrderItem oi
            JOIN 
                Variant v ON oi.variant_id = v.variant_id
            JOIN 
                Product p ON v.product_id = p.product_id
            JOIN 
                Product_Category_Match pcm ON p.product_id = pcm.product_id
            JOIN 
                Category c ON pcm.category_id = c.category_id
            GROUP BY 
                c.category_id
            ORDER BY 
                total_orders DESC
            LIMIT 1;
        `;

        db.query(query, [], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);  // Return the result with the top category
        });
    });
};

/*const db = require('../db');

exports.getCategoryWithMostOrders = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                c.category_name,
                COUNT(oi.order_item_id) AS total_orders
            FROM 
                OrderItem oi
            JOIN 
                Variant v ON oi.variant_id = v.variant_id
            JOIN 
                Product p ON v.product_id = p.product_id
            JOIN 
                Product_Category_Match pcm ON p.product_id = pcm.product_id
            JOIN 
                Category c ON pcm.category_id = c.category_id
            GROUP BY 
                c.category_id
            ORDER BY 
                total_orders DESC
            LIMIT 1;
        `;

        db.query(query, [], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);  // Return the result with the top category
        });
    });
};*/
