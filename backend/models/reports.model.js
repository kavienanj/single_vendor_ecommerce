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
                COUNT(oi.order_item_id) AS number_of_items,  -- Count the number of items
                GROUP_CONCAT(v.name) AS variant_names,
                SUM(oi.quantity) AS total_quantity,
                ROUND(SUM(oi.quantity * oi.price), 2) AS total_price  -- Round to 2 decimal places
            FROM 
                User u
            JOIN 
                \`Order\` o ON u.user_id = o.customer_id
            JOIN 
                OrderItem oi ON o.order_id = oi.order_id
            JOIN 
                Variant v ON oi.variant_id = v.variant_id
            GROUP BY 
                u.user_id, o.order_id
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
                total_sold DESC;
            
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
                pc.category_name AS parent_category_name,
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
            JOIN 
                ParentCategory_Match pcmatch ON c.category_id = pcmatch.category_id
            JOIN 
                Category pc ON pcmatch.parent_category_id = pc.category_id
            GROUP BY 
                pc.category_id
            ORDER BY 
                total_orders DESC;
        `;

        db.query(query, [], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);  // Return the result with the top parent categories
        });
    });
};


// Most Selling Product Model

exports.getProductsBySales = (start_date, end_date) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT p.title,  SUM(o.quantity) AS total_sales
            FROM OrderItem o
            JOIN Variant v ON v.variant_id = o.variant_id
            JOIN Product p ON v.product_id = p.product_id
            JOIN \`Order\` t ON t.order_id = o.order_id
            WHERE t.purchased_time BETWEEN ? AND ?
            GROUP BY p.title
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
            const salesReport = result[0].map(row => ({
                quarter: row.quarter,
                total_sales: parseFloat(row.total_sales).toFixed(2)  // Round to 2 decimal places
            }));
            resolve(salesReport);
        });
    });
};

