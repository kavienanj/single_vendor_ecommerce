const db = require('../db');

exports.getProductsBySales = (start_date, end_date) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT p.title, v.name, SUM(o.quantity) AS total_sales
            FROM OrderItem o
            JOIN Variant v ON v.variant_id = o.variant_id
            JOIN Product p ON v.product_id = p.product_id
            JOIN \`Order\` t ON t.order_id = o.order_id
            WHERE t.purchased_time BETWEEN ? AND ?
            GROUP BY p.title, v.name
            ORDER BY total_sales DESC
        `;

        db.query(query, [start_date, end_date], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);  // Return all products, filtering will be done in the controller
        });
    });
};

/*const db = require('../db');

exports.getProductsBySales = (startDate, endDate) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT p.title, v.name, SUM(o.quantity) AS total_sales
            FROM OrderItem o
            JOIN Variant v ON v.variant_id = o.variant_id
            JOIN Product p ON v.product_id = p.product_id
            JOIN \`Order\` t ON t.order_id = o.order_id
            WHERE t.purchased_time BETWEEN ? AND ?
            GROUP BY p.title, v.name
            ORDER BY total_sales DESC
            
        `;

        db.query(query, [startDate, endDate], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
};*/
