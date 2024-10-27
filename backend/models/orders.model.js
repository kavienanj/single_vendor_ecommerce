const db = require('../db');

// Helper function for querying the database
const runQuery = (query, params) => {
    return new Promise((resolve, reject) => {
        db.query(query, params, (err, result) => {
            if (err) {
                return reject(new Error(`Database query failed: ${err.message}`));
            }
            resolve(result);
        });
    });
};

// Function to create a new order
exports.createOrder = ({ customerId, contactEmail, contactPhone, deliveryMethod, deliveryLocationId, paymentMethod, totalAmount, orderStatus = 'Processing', deliveryEstimate }) => {
    const purchasedTime = new Date();
    const createdAt = new Date();
    const query = `
        INSERT INTO \`Order\` (customer_id, contact_email, contact_phone, delivery_method, delivery_location_id, payment_method, total_amount, order_status, purchased_time, delivery_estimate, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    return runQuery(query, [customerId, contactEmail, contactPhone, deliveryMethod, deliveryLocationId, paymentMethod, totalAmount, orderStatus, purchasedTime, deliveryEstimate, createdAt]);
};

// for admin to see all orders
exports.getAllOrders = () => {
    const query = "SELECT * FROM `Order`";
    return runQuery(query);
};

// Function to get an order by ID
exports.getOrderById = (orderId) => {
    const query = `
        SELECT 
            o.order_id,
            o.customer_id,
            o.customer_name,
            o.contact_email,
            o.contact_phone,
            o.delivery_address,
            o.delivery_method,
            o.delivery_location_id,
            o.payment_method,
            o.total_amount,
            o.order_status,
            o.purchased_time,
            o.delivery_estimate,
            o.created_at,
            o.updated_at,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'variant_id', v.variant_id,
                    'variant_name', v.name,
                    'price', ROUND(oi.price, 2),
                    'quantity', oi.quantity,
                    'quantity_available', inv.quantity_available,
                    'total_price', ROUND(oi.price * oi.quantity, 2)
                )
            ) AS items
        FROM \`Order\` o
        JOIN OrderItem oi ON o.order_id = oi.order_id
        JOIN Variant v ON oi.variant_id = v.variant_id
        JOIN Inventory inv ON v.variant_id = inv.variant_id 
        WHERE o.order_id = ?
        GROUP BY o.order_id;
    `
    return runQuery(query, [orderId]);
};

// Function to update an order
// this should allowed only for pending orders
// OTHERWISE NOT!!!
// THIS IS NOT PRACTICAL        
exports.updateOrder = ({ orderId, orderStatus, deliveryEstimate, updatedAt = new Date() }) => {
    const query = `
        UPDATE \`Order\` SET order_status = ?, delivery_estimate = ?, updated_at = ? WHERE order_id = ?`;
    return runQuery(query, [orderStatus, deliveryEstimate, updatedAt, orderId]);
};

// Function to delete an order
// this should allowed only for pending orders
// OTHERWISE NOT!!!
exports.deleteOrder = (orderId) => {
    const query = "DELETE FROM `Order` WHERE order_id = ?";
    return runQuery(query, [orderId]);
};

// Function to get orders by user ID
exports.getUserOrders = (userId) => {
    const query = `
    SELECT 
    o.order_id,
    o.customer_id,
    o.customer_name,
    o.contact_email,
    o.contact_phone,
    o.delivery_address,
    o.delivery_method,
    o.delivery_location_id,
    o.payment_method,
    o.total_amount,
    o.order_status,
    o.purchased_time,
    o.delivery_estimate,
    o.created_at,
    o.updated_at,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'variant_id', v.variant_id,
            'variant_name', v.name,
            'price', ROUND(oi.price, 2),
            'quantity', oi.quantity,
            'quantity_available', inv.quantity_available,
            'total_price', ROUND(oi.price * oi.quantity, 2)
        )
    ) AS items
FROM \`Order\` o
JOIN OrderItem oi ON o.order_id = oi.order_id
JOIN Variant v ON oi.variant_id = v.variant_id
JOIN Inventory in ON v.variant_id = inv.variant_id 
WHERE o.customer_id = ?
GROUP BY o.order_id
ORDER BY o.order_id;
`;
    return runQuery(query, [userId]);
};

