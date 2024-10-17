const model = require('../models/cart.model');

exports.addtoCart = async (req, res) => {
    const { userId } = req.params;
    
    try {
        await model.addtoCart({ title, description, sku, weight });
        res.status(200).json({
            message: 'Product added successfully!',
        });
    } catch (err) {
        console.error('Error inserting product:', err);
        res.status(500).json({ message: 'Error inserting product', error: err.message });
    }
};
