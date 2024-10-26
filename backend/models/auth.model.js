const db = require('../db'); // Adjust the path as needed

// Function to find a user by email
exports.findUserByEmail = (email) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM User WHERE email = ?';
        
        db.query(query, [email], (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results.length > 0 ? results[0] : null); // Return the user if found, otherwise null
        });
    });
};

// Function to create a new user
exports.createUser = ({ first_name, last_name, email, password_hash, phone_number, is_guest, role_id }) => {
    return new Promise((resolve, reject) => {
        const created_at = new Date();
        const query = `
            INSERT INTO User (first_name, last_name, email, password_hash, phone_number, is_guest, role_id, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `;

        db.query(query, [first_name, last_name, email, password_hash, phone_number, is_guest, role_id, created_at], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve({ user_id: result.insertId, first_name, last_name, email, phone_number, is_guest, role_id });
        });
    });
};

// Function to get all users
exports.getUsers = () => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM User Where role_id = 2';
        
        db.query(query, (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results);
        });
    });
}
