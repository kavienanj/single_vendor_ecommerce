const model = require('../models/products.model');

// Controller function to add a product
exports.addProduct = async (req, res) => {
    const { title, description, sku, weight } = req.body;
    
    try {
        await model.createProduct({ title, description, sku, weight });
        res.status(200).json({
            message: 'Product added successfully!',
        });
    } catch (err) {
        console.error('Error inserting product:', err);
        res.status(500).json({ message: 'Error inserting product', error: err.message });
    }
};

// Controller function to get all products with filters, sorting, and limiting
exports.getAllProducts = async (req, res) => {
    try {
        const { categoryId, search, sort, order, limit } = req.query;  // Extract query parameters
        const response = await model.getAllProducts({ categoryId, search, sort, order, limit });
        res.json(response);
    } catch (err) {
        console.error('Error fetching products:', err);
        res.status(500).json({ message: 'Error fetching products', error: err.message });
    }
};

// Controller function to update a product
exports.updateProduct = async (req, res) => {
    const { id } = req.params;
    const { title, description, sku, weight } = req.body;

    try {
        await model.updateProduct({ id, title, description, sku, weight });
        res.status(200).json({
            message: 'Product updated successfully!',
        });
    } catch (err) {
        console.error('Error updating product:', err);
        res.status(500).json({
            message: 'Error updating product',
            error: err.message
        });
    }
};

// Controller function to delete a product
exports.deleteProduct = async (req, res) => {
    const { id } = req.params;

    try {
        await model.deleteProduct({ id });
        res.status(200).json({
            message: 'Product deleted successfully!',
        });
    } catch (err) {
        console.error('Error deleting product:', err);
        res.status(500).json({
            message: 'Error deleting product',
            error: err.message
        });
    }
};

// Controller function to get a product by ID
exports.getProductById = async (req, res) => {
    const { id } = req.params;

    try {
        const response = await model.getProductById({ id });
        res.json(response);
    } catch (err) {
        console.error('Error fetching product:', err);
        res.status(500).json({
            message: 'Error fetching product',
            error: err.message
        });
    }
};

// Controller function to get all products with variants and attributes
exports.getProductWithVariantsAndAttributes = async (req, res) => {
    const { id } = req.params;
    try {
        const products = await model.getProductWithVariantsAndAttributes({ id });
        res.json(products);
    } catch (err) {
        console.error('Error fetching product details:', err);
        res.status(500).json({ message: 'Error fetching product details', error: err.message });
    }
};
