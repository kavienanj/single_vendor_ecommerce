const model = require('../models/orders.model');

// Controller function to add a new order
exports.addOrder = async (req, res) => {
    const { customerId, contactEmail, contactPhone, deliveryMethod, deliveryLocationId, paymentMethod, totalAmount, orderStatus, deliveryEstimate } = req.body;

    try {
        await model.createOrder({ customerId, contactEmail, contactPhone, deliveryMethod, deliveryLocationId, paymentMethod, totalAmount, orderStatus, deliveryEstimate });
        res.status(200).json({
            message: 'Order added successfully!',
        });
    } catch (err) {
        console.error('Error inserting order:', err);
        res.status(500).json({ message: 'Error inserting order', error: err.message });
    }
};

// Controller function to get all orders
exports.getAllOrders = async (req, res) => {
    try {
        const response = await model.getAllOrders();
        res.json(response);
    } catch (err) {
        console.error('Error fetching orders:', err);
        res.status(500).json({ message: 'Error fetching orders', error: err.message });
    }
};

// Controller function to get an order by ID
exports.getOrderById = async (req, res) => {
    if (req.user === undefined) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const userId = parseInt(req.user.id);
    const { orderId } = req.params;
    try {
        const response = await model.getOrderById(orderId);
        if (!response) {
            return res.status(404).json({ message: 'Order not found' });
        }
        console.log(response[0], userId);
        if (response[0].customer_id !== userId) {
            return res.status(403).json({ message: 'Forbidden' });
        }
        res.json({
            message: 'Order found',
            order: response[0],
        });
    } catch (err) {
        console.error('Error fetching order:', err);
        res.status(500).json({ message: 'Error fetching order', error: err.message });
    }
};

// Controller function to update an order
exports.updateOrder = async (req, res) => {
    const { orderId } = req.params;
    const { orderStatus, deliveryEstimate } = req.body;

    try {
        await model.updateOrder({ orderId, orderStatus, deliveryEstimate });
        res.status(200).json({
            message: 'Order updated successfully!',
        });
    } catch (err) {
        console.error('Error updating order:', err);
        res.status(500).json({
            message: 'Error updating order',
            error: err.message
        });
    }
};

// Controller function to process an order
exports.processOrder = async (req, res) => {
    if (req.user === undefined) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const userId = parseInt(req.user.id);
    const { orderId } = req.params;
    const { name, phone, email, address, deliveryMethod, deliveryLocationId, paymentMethod } = req.body;
    try {
        await model.processOrder({ orderId, userId, name, phone, email, address, deliveryMethod, deliveryLocationId, paymentMethod });
        res.status(200).json({
            message: 'Order processed successfully!',
        });
    } catch (err) {
        console.error('Error processing order:', err);
        res.status(500).json({
            message: 'Error processing order',
            error: err.message
        });
    }
};

// Controller function to delete an order
exports.deleteOrder = async (req, res) => {
    const { orderId } = req.params;

    try {
        await model.deleteOrder(orderId);
        res.status(200).json({
            message: 'Order deleted successfully!',
        });
    } catch (err) {
        console.error('Error deleting order:', err);
        res.status(500).json({
            message: 'Error deleting order',
            error: err.message
        });
    }
};

// Controller function to get orders by user ID
exports.getUserOrders = async (req, res) => {
    const { userId } = req.params;

    try {
        const response = await model.getUserOrders(userId);
        res.json(response);
    } catch (err) {
        console.error('Error fetching user orders:', err);
        res.status(500).json({ message: 'Error fetching user orders', error: err.message });
    }
}
