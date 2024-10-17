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









