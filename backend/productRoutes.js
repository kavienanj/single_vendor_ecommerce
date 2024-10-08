const express = require('express');
const router = express.Router();

// Import the MySQL connection from db.js
const db = require('./db');

// Route to add a product
router.post('/products', (req, res) => {
    const { title, description, sku, weight } = req.body;
    const created_at = new Date();
    const query = `INSERT INTO Product (title, description, sku, weight, created_at, updated_at)
                   VALUES (?, ?, ?, ?, ?, NULL)`;

    db.query(query, [title, description, sku, weight, created_at], (err, result) => {
        if (err) {
            console.error('Error inserting product:', err);
            res.status(500).json({ message: 'Error inserting product', error: err.message });
        } else {
            res.status(201).json({
                message: 'Product added successfully!',
                product: {
                    id: result.insertId,
                    title,
                    description,
                    sku,
                    weight,
                    created_at
                }
            });
        }
    });
});

// Route to get all products
router.get('/products', (req, res) => {
    const query = `SELECT * FROM Product`;

    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching products:', err);
            res.status(500).send('Error fetching products');
        } else {
            res.json(results);
        }
    });
});

// Route to update a product
router.put('/products/:id', (req, res) => {
    const { id } = req.params;
    const { title, description, sku, weight } = req.body;
    const updated_at = new Date();

    const query = `UPDATE Product SET title = ?, description = ?, sku = ?, weight = ?, updated_at = ? WHERE product_id = ?`;

    db.query(query, [title, description, sku, weight, updated_at, id], (err, result) => {
        if (err) {
            console.error('Error updating product:', err);
            res.status(500).send('Error updating product');
        } else {
            res.send('Product updated successfully!');
        }
    });
});

// Route to delete a product
router.delete('/products/:id', (req, res) => {
    const { id } = req.params;

    const query = `DELETE FROM Product WHERE product_id = ?`;

    db.query(query, [id], (err, result) => {
        if (err) {
            console.error('Error deleting product:', err);
            res.status(500).send('Error deleting product');
        } else {
            res.send('Product deleted successfully!');
        }
    });
});

module.exports = router;
