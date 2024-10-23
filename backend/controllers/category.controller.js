const Category = require('../models/category.model');

// Create a new category
exports.createCategory = async (req, res) => {
    const { categoryName, description } = req.body;
    try {
        const result = await Category.createCategory({ categoryName, description });
        res.status(201).json({ message: 'Category created successfully', categoryId: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const categories = await Category.getAllCategories();
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get a category by ID
exports.getCategoryById = async (req, res) => {
    const { id } = req.params;
    try {
        const category = await Category.getCategoryById(id);
        if (!category.length) {
            return res.status(404).json({ error: 'Category not found' });
        }
        res.status(200).json(category[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update a category
exports.updateCategory = async (req, res) => {
    const { id } = req.params;
    const { categoryName, description } = req.body;
    try {
        await Category.updateCategory({ categoryId: id, categoryName, description });
        res.status(200).json({ message: 'Category updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Delete a category
exports.deleteCategory = async (req, res) => {
    const { id } = req.params;
    try {
        await Category.deleteCategory(id);
        res.status(200).json({ message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
