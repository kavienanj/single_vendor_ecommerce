const express = require('express');
const router = express.Router();
const VariantController = require('../controllers/variant.controller');

// Create a new variant
router.post('/', VariantController.createVariant);

// Get all variants
router.get('/', VariantController.getAllVariants);

// Get a variant by ID
router.get('/:id', VariantController.getVariantById);

// Update a variant by ID
router.put('/:id', VariantController.updateVariant);

// Update a variant stock by ID
router.post('/:id/stock', VariantController.updateStock);

// Delete a variant by ID
router.delete('/:id', VariantController.deleteVariant);

module.exports = router;
