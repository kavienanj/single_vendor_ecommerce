const express = require('express');
const router = express.Router();

// Import the MySQL connection from db.js
const model = require('../models/products.model')

// Route to add a product
router.post('/products', async (req, res) => {
    const { title, description, sku, weight } = req.body;
    
    try {
        await model.createProduct({ title, description, sku, weight });
        res.status(200).json({
            message: 'Product added successfullyyy!',
        });
    } catch (err) {
        console.error('Error inserting product:', err);
        res.status(500).json({ message: 'Error inserting product', error: err.message });
    }
});

// Route to get all products
router.get('/products', async (req, res) => {
    try {
        const response = await model.getAllProducts();
        res.json(response);
    } catch (err) {
        console.error('Error inserting product:', err);
        res.status(500).json({ message: 'Error inserting product', error: err.message });
    }
});

// Route to update a product
router.put('/products/:id', async (req, res) => {
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
});


// Route to delete a product
router.delete('/products/:id', async (req, res) => {
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
});


module.exports = router;
