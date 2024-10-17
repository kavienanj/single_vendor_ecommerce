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

// Create a new attribute for a product
exports.createAttribute = ({ productId, attributeName }) => {
    const query = `
        INSERT INTO Custom_Attribute (product_id, attribute_name)
        VALUES (?, ?)`;
    return runQuery(query, [productId, attributeName]);
};

// Get all attributes for a product
exports.getAttributesByProductId = (productId) => {
    const query = `SELECT * FROM Custom_Attribute WHERE product_id = ?`;
    return runQuery(query, [productId]);
};

// Get all attributes
exports.getAllAttributes = () => {
    const query = `SELECT * FROM Custom_Attribute`;
    return runQuery(query);
};