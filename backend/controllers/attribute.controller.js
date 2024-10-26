const Attribute = require('../models/attribute.model');

// Create a new attribute
exports.createAttribute = async (req, res) => {
    const { productId, attributeName } = req.body;
    try {
        const result = await Attribute.createAttribute({ productId, attributeName });
        res.status(201).json({ message: 'Attribute created successfully', attributeId: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

//create a new attribute value
exports.createAttributeValue = async (req, res) => {
    const { variantId, attributeId, attributeValue } = req.body;

    try {
        await Attribute.createAttributeValue({ variantId, attributeId, attributeValue });
        res.status(201).json({ message: 'Custom attribute value added successfully!' });
    } catch (err) {
        console.error('Error adding attribute value:', err);
        res.status(500).json({ message: 'Error adding attribute value', error: err.message });
    }
};

// Get all attributes for a product
exports.getAttributesByProductId = async (req, res) => {
    const { productId } = req.params;
    try {
        const attributes = await Attribute.getAttributesByProductId(productId);
        res.status(200).json(attributes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


// Get all attributes
exports.getAllAttributes = async (req, res) => {
    try {
        const attributes = await Attribute.getAllAttributes();
        res.status(200).json(attributes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteAttribute = async (req, res) => {
    const attributeId = parseInt(req.params.id, 10); // Convert ID to integer

    if (isNaN(attributeId)) {
        return res.status(400).json({ message: 'Invalid attribute ID' }); // Handle invalid ID input
    }

    try {
        await Attribute.deleteAttribute(attributeId);
        res.status(200).json({ message: 'Attribute deleted successfully!' });
    } catch (err) {
        console.error('Error deleting attribute:', err);
        res.status(500).json({ message: 'Error deleting attribute', error: err.message });
    }
};








