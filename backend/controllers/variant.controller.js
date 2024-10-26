const Variant = require('../models/variant.model');

// Create a new variant
exports.createVariant = async (req, res) => {
    const { productId, name, price, imageUrl } = req.body;
    try {
        const result = await Variant.createVariant({ productId, name, price, imageUrl });
        res.status(201).json({ message: 'Variant created successfully', variantId: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get all variants
exports.getAllVariants = async (req, res) => {
    try {
        const variants = await Variant.getAllVariants();
        res.status(200).json(variants);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get a variant by ID
exports.getVariantById = async (req, res) => {
    const { id } = req.params;
    try {
        const variant = await Variant.getVariantById(id);
        if (!variant.length) {
            return res.status(404).json({ error: 'Variant not found' });
        }
        res.status(200).json(variant[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update a variant
exports.updateVariant = async (req, res) => {
    const { id } = req.params;
    const { name, price, imageUrl } = req.body;
    try {
        await Variant.updateVariant({ variantId: id, name, price, imageUrl });
        res.status(200).json({ message: 'Variant updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update a variant stock
exports.updateStock = async (req, res) => {
    if (req.user === undefined || req.user.role_id !== 1) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const { id } = req.params;
    const { quantity } = req.body;
    try {
        await Variant.updateStock(id, quantity);
        res.status(200).json({ message: 'Stock updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Delete a variant
exports.deleteVariant = async (req, res) => {
    const { id } = req.params;
    try {
        await Variant.deleteVariant(id);
        res.status(200).json({ message: 'Variant deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
