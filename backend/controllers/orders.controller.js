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
    const { orderId } = req.params;

    try {
        const response = await model.getOrderById(orderId);
        if (!response) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.json(response);
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
