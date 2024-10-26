const express = require('express');
const router = express.Router();
const productsController = require('../controllers/products.controller');

// Route to add a product
router.post('/products', productsController.addProduct);

// Route to get all products
router.get('/products', productsController.getAllProducts);

// Route to update a product
router.put('/products/:id', productsController.updateProduct);

// Route to delete a product
router.delete('/products/:id', productsController.deleteProduct);

// Route to get all products with variants and attributes
router.get('/products/:id', productsController.getProductWithVariantsAndAttributes);

module.exports = router;
