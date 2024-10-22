const db = require('../db');

// Function to create a delivery location
exports.createDeliveryLocation = ({ location_name, location_type, with_stock_delivery_days, without_stock_delivery_days }) => {
    return new Promise((resolve, reject) => {
        const query = `INSERT INTO DeliveryLocation (location_name, location_type, with_stock_delivery_days, without_stock_delivery_days)
                       VALUES (?, ?, ?, ?)`;

        db.query(query, [location_name, location_type, with_stock_delivery_days, without_stock_delivery_days], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to get all delivery locations
exports.getAllDeliveryLocations = () => {
    return new Promise((resolve, reject) => {
        const query = `SELECT * FROM DeliveryLocation`;

        db.query(query, (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to update a delivery location
exports.updateDeliveryLocation = ({ id, location_name, location_type, with_stock_delivery_days, without_stock_delivery_days }) => {
    return new Promise((resolve, reject) => {
        const query = `UPDATE DeliveryLocation SET location_name = ?, location_type = ?, with_stock_delivery_days = ?, without_stock_delivery_days = ? WHERE delivery_location_id = ?`;

        db.query(query, [location_name, location_type, with_stock_delivery_days, without_stock_delivery_days, id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// Function to delete a delivery location
exports.deleteDeliveryLocation = ({ id }) => {
    return new Promise((resolve, reject) => {
        const query = `DELETE FROM DeliveryLocation WHERE delivery_location_id = ?`;

        db.query(query, [id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}
