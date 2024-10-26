const express = require('express');
const router = express.Router();
const CategoryController = require('../controllers/category.controller');

// Create a new category
router.post('/', CategoryController.createCategory);

// Get all categories
router.get('/', CategoryController.getAllCategories);

// Get a category by ID
router.get('/:id', CategoryController.getCategoryById);

// Update a category by ID
router.put('/:id', CategoryController.updateCategory);

// Delete a category by ID
router.delete('/:id', CategoryController.deleteCategory);

module.exports = router;
