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

// Create a new variant
exports.createVariant = ({ productId, name, price, imageUrl }) => {
    const query = `
        INSERT INTO Variant (product_id, name, price, image_url, created_at, updated_at)
        VALUES (?, ?, ?, ?, NOW(), NOW())`;
    return runQuery(query, [productId, name, price, imageUrl]);
};

// Get all variants
exports.getAllVariants = () => {
    const query = `
    SELECT v.product_id, v.variant_id, v.name, v.price, v.image_url, i.quantity_available
    FROM Variant v
    LEFT JOIN Inventory i ON v.variant_id = i.variant_id
    ORDER BY v.product_id, v.variant_id`;
    return runQuery(query);
};

// Get a variant by ID
exports.getVariantById = (variantId) => {
    const query = `SELECT * FROM Variant WHERE variant_id = ?`;
    return runQuery(query, [variantId]);
};

// Update a variant
exports.updateVariant = ({ variantId, name, price, imageUrl }) => {
    const query = `
        UPDATE Variant 
        SET name = ?, price = ?, image_url = ?, updated_at = NOW() 
        WHERE variant_id = ?`;
    return runQuery(query, [name, price, imageUrl, variantId]);
};

// Update a variant stock
exports.updateStock = (variantId, quantity) => {
    const query = `
        UPDATE Inventory
        SET quantity_available = ?
        WHERE variant_id = ?
    `;
    return runQuery(query, [quantity, variantId]);
};

// Delete a variant
exports.deleteVariant = (variantId) => {
    const query = `DELETE FROM Variant WHERE variant_id = ?`;
    return runQuery(query, [variantId]);
};
