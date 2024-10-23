const db = require('../db');

// Helper function to query the database using promises
const runQuery = (query, params) => {
    return new Promise((resolve, reject) => {
        db.query(query, params, (err, result) => {
            if (err) {
                return reject(new Error(`Database query failed: ${err.message}`));
            }
            resolve(result);
        });
    });
};

// Function to create a new category
exports.createCategory = ({ categoryName, description }) => {
    const query = `
        INSERT INTO Category (category_name, description) 
        VALUES (?, ?)`;
    return runQuery(query, [categoryName, description]);
};

// Function to get all categories
exports.getAllCategories = () => {
    const query = `
        SELECT 
        parent.category_id AS category_id,
        parent.category_name AS category_name,
        parent.description AS category_description,
        JSON_ARRAYAGG(JSON_OBJECT(
            'category_id', child.category_id,
            'category_name', child.category_name,
            'category_description', child.description
        )) AS sub_categories
        FROM Category parent
        LEFT JOIN ParentCategory_Match pcm ON parent.category_id = pcm.parent_category_id
        LEFT JOIN Category child ON pcm.category_id = child.category_id
        WHERE pcm.category_id IS NOT NULL  -- Ensure there are child categories
        GROUP BY parent.category_id, parent.category_name, parent.description
        ORDER BY parent.category_name;
    `;
    return runQuery(query);
};

// Function to get a category by ID
exports.getCategoryById = (categoryId) => {
    const query = `SELECT * FROM Category WHERE category_id = ?`;
    return runQuery(query, [categoryId]);
};

// Function to update a category
exports.updateCategory = ({ categoryId, categoryName, description }) => {
    const query = `
        UPDATE Category 
        SET category_name = ?, description = ? 
        WHERE category_id = ?`;
    return runQuery(query, [categoryName, description, categoryId]);
};

// Function to delete a category
exports.deleteCategory = (categoryId) => {
    const query = `DELETE FROM Category WHERE category_id = ?`;
    return runQuery(query, [categoryId]);
};
