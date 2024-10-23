const model = require('../models/cart.model');

exports.addtoCart = async (req, res) => {
    const userId = parseInt(req.params.userId);
    const { variant_id, quantity } = req.body;
    try {
        await model.addtoCart({ userId, variant_id, quantity });
        res.status(200).json({
            message: 'Added to cart successfully!',
        });
    } catch (err) {
        console.error('Error inserting into cart:', err);
        res.status(500).json({ message: 'Error inserting into cart.', error: err.message });
    }
};


exports.showCart = async (req, res) => {
    const userId = parseInt(req.params.userId);
    try {
        const response = await model.showCart({ userId });
        res.status(200).json(response);
    } catch (err) {
        console.error('Error showing the cart:', err);
        res.status(500).json({ message: 'Error showing the cart.', error: err.message });
    }
};

exports.deletefromCart = async (req, res) => {
    const userId = parseInt(req.params.userId);
    const { variant_id} = req.body;
    try {
        await model.deletefromCart({ userId, variant_id });
        res.status(200).json({
            message: `UserId ${userId} deleted variant_id ${variant_id} from cart successfully!` ,
        });
    } catch (err) {
        console.error('Error deleting from cart:', err);
        res.status(500).json({ message: 'Error deleting cart.', error: err.message });
    }
};

exports.setQuantity = async (req, res) => {
    const userId = parseInt(req.params.userId);
    const { variant_id,quantity} = req.body;

    try {
        await model.setQuantity({ userId,variant_id,quantity });
        res.status(200).json({
            message: 'Cart updated successfully!',
        });
    } catch (err) {
        console.error('Error updating Cart:', err);
        res.status(500).json({
            message: 'Error updating Cart',
            error: err.message
        });
    }
};

exports.checkout = async (req, res) => {
    const userId = parseInt(req.params.userId);
    const order_items = req.body;
    try {
        await model.checkout({ userId , order_items });
        res.status(200).json({
            message: 'Checkout successful!'
        });
    } catch (err) {
        console.error('Error checking out:', err);
        res.status(500).json({ message: 'Error checking out.', error: err.message });
    }
};

exports.placeOrder = async (req, res) => {
    const userId = parseInt(req.params.userId);
    const { 
        order_id, 
        contact_email, 
        contact_phone, 
        delivery_method, 
        delivery_location_id, 
        payment_method, 
        delivery_estimate 
    } = req.body;
    try {
        await model.placeOrder({ userId, 
            order_id, 
            contact_email, 
            contact_phone, 
            delivery_method, 
            delivery_location_id, 
            payment_method, 
            delivery_estimate });
        res.status(200).json({
            message: 'Order placing successful!'
        });
    } catch (err) {
        console.error('Error placing order :', err);
        res.status(500).json({ message: 'Error placing order.', error: err.message });
    }
}

exports.getPaymentInfo = async (req, res) => {
    const userId = parseInt(req.params.userId);
    try {
        const response = await model.getPaymentInfo({ userId });
        res.status(200).json(response);
    } catch (err) {
        console.error('Error getting payment info:', err);
        res.status(500).json({ message: 'Error getting payment info.', error: err.message });
    }
};