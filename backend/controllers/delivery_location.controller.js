const model = require('../models/delivery_location.model');

// Controller function to add a delivery location
exports.addDeliveryLocation = async (req, res) => {
    const { location_name, location_type, with_stock_delivery_days, without_stock_delivery_days } = req.body;

    try {
        await model.createDeliveryLocation({ location_name, location_type, with_stock_delivery_days, without_stock_delivery_days });
        res.status(200).json({
            message: 'Delivery location added successfully!',
        });
    } catch (err) {
        console.error('Error inserting delivery location:', err);
        res.status(500).json({ message: 'Error inserting delivery location', error: err.message });
    }
};

// Controller function to get all delivery locations
exports.getAllDeliveryLocations = async (req, res) => {
    try {
        const response = await model.getAllDeliveryLocations();
        res.json({
            message: 'Delivery locations fetched successfully!',
            deliveryLocations: response,
        });
    } catch (err) {
        console.error('Error fetching delivery locations:', err);
        res.status(500).json({ message: 'Error fetching delivery locations', error: err.message });
    }
};

// Controller function to update a delivery location
exports.updateDeliveryLocation = async (req, res) => {
    const { id } = req.params;
    const { location_name, location_type, with_stock_delivery_days, without_stock_delivery_days } = req.body;

    try {
        await model.updateDeliveryLocation({ id, location_name, location_type, with_stock_delivery_days, without_stock_delivery_days });
        res.status(200).json({
            message: 'Delivery location updated successfully!',
        });
    } catch (err) {
        console.error('Error updating delivery location:', err);
        res.status(500).json({
            message: 'Error updating delivery location',
            error: err.message
        });
    }
};

// Controller function to delete a delivery location
exports.deleteDeliveryLocation = async (req, res) => {
    const { id } = req.params;

    try {
        await model.deleteDeliveryLocation({ id });
        res.status(200).json({
            message: 'Delivery location deleted successfully!',
        });
    } catch (err) {
        console.error('Error deleting delivery location:', err);
        res.status(500).json({
            message: 'Error deleting delivery location',
            error: err.message
        });
    }
};
