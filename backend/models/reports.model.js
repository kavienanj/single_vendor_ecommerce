const db = require('../db');

// Customer Report Model
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

// Most Interest Model
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

// Most Orders Model
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

// Most Selling Product Model
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

// Quarterly Sales Report Model
exports.getQuarterlySalesReport = (year) => {
    return new Promise((resolve, reject) => {
        const query = 'CALL Get_Quarterly_Sales_By_Year(?)';

        db.query(query, [year], (err, result) => {
            if (err) {
                return reject(err);
            }
            // Assuming the result is in the first element of the array
            resolve(result[0]);
        });
    });
};
