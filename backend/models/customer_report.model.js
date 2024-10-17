const db = require('../db');

exports.getCustomerOrderReport = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                u.user_id,
                CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
                u.email,
                o.order_id,
                o.purchased_time,
                o.order_status,
                o.total_amount,
                v.name AS variant_name,
                oi.quantity,
                oi.price AS item_price,
                (oi.quantity * oi.price) AS total_price
            FROM 
                User u
            JOIN 
                \`Order\` o ON u.user_id = o.customer_id
            JOIN 
                OrderItem oi ON o.order_id = oi.order_id
            JOIN 
                Variant v ON oi.variant_id = v.variant_id
            ORDER BY 
                o.purchased_time DESC;
        `;

        db.query(query, (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
};

/*const db = require('../db');

exports.getCustomerOrderReport = () => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT 
                u.user_id,
                CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
                u.email,
                o.order_id,
                o.purchased_time,
                o.order_status,
                o.total_amount,
                v.name AS variant_name,
                oi.quantity,
                oi.price AS item_price,
                (oi.quantity * oi.price) AS total_price
            FROM 
                User u
            JOIN 
                \`Order\` o ON u.user_id = o.customer_id
            JOIN 
                OrderItem oi ON o.order_id = oi.order_id
            JOIN 
                Variant v ON oi.variant_id = v.variant_id
            ORDER BY 
                o.purchased_time DESC;
        `;

        db.query(query, (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
};*/
