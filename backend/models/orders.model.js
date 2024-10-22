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
        INSERT INTO Order (customer_id, contact_email, contact_phone, delivery_method, delivery_location_id, payment_method, total_amount, order_status, purchased_time, delivery_estimate, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    return runQuery(query, [customerId, contactEmail, contactPhone, deliveryMethod, deliveryLocationId, paymentMethod, totalAmount, orderStatus, purchasedTime, deliveryEstimate, createdAt]);
};

exports.getAllOrders = () => {
    const query = `SELECT * FROM Order`;
    return runQuery(query);
};

// Function to get an order by ID
exports.getOrderById = (orderId) => {
    const query = `SELECT * FROM Order WHERE order_id = ?`;
    return runQuery(query, [orderId]);
};

// Function to update an order
exports.updateOrder = ({ orderId, orderStatus, deliveryEstimate, updatedAt = new Date() }) => {
    const query = `
        UPDATE Order SET order_status = ?, delivery_estimate = ?, updated_at = ? WHERE order_id = ?`;
    return runQuery(query, [orderStatus, deliveryEstimate, updatedAt, orderId]);
};

// Function to delete an order
exports.deleteOrder = (orderId) => {
    const query = `DELETE FROM Order WHERE order_id = ?`;
    return runQuery(query, [orderId]);
};

// Function to get orders by user ID
exports.getUserOrders = (userId) => {
    const query = `SELECT * FROM Order WHERE customer_id = ?`;
    return runQuery(query, [userId]);
};

