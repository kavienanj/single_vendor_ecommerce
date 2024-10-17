const db = require('../db');

exports.getTopMonthsForProductSales = (product_id) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                MONTHNAME(o.purchased_time) AS month,
                COUNT(oi.order_item_id) AS total_sold
            FROM 
                OrderItem oi
            JOIN 
                \`Order\` o ON oi.order_id = o.order_id
            WHERE 
                oi.variant_id IN (SELECT variant_id FROM Variant WHERE product_id = ?)
            GROUP BY 
                month
            ORDER BY 
                total_sold DESC
            LIMIT 2;
        `;

        db.query(query, [product_id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
};
