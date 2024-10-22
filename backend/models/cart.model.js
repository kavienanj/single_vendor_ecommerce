const db = require('../db'); // Adjust the path as needed

exports.addtoCart = ({ userId, variant_id, quantity }) => {
    return new Promise((resolve, reject) => {
        const query = `call AddToCart(?,?,?);` ;
        db.query(query, [userId, variant_id, quantity], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// if necessary we can create view and request from hear --better => need to do
// we can use same view to show products well.. 
// requesting the whole variant object not just id s
exports.showCart = ({ userId }) => {
    return new Promise((resolve, reject) => {
       const query = `call ShowCartofUser(?);` ; 
        db.query(query, [userId], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

exports.deletefromCart = ({ userId, variant_id }) => {
    return new Promise((resolve, reject) => {
        const query = `
            DELETE FROM cart WHERE (user_id,variant_id) = (?,?);` 
        ;
        db.query(query, [userId, variant_id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

exports.setQuantity = ({ userId,variant_id,quantity }) => {
    return new Promise((resolve, reject) => {
        if (quantity === 0) {
            query = `DELETE FROM cart WHERE user_id = ? AND variant_id = ?`;
            params = [userId, variant_id];
        } else {
            query = `UPDATE cart SET quantity = ? WHERE user_id = ? AND variant_id = ?`;
            params = [quantity, userId, variant_id];
        }

        db.query(query, [quantity,userId,variant_id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

// consider updating indexes in the database for better performance
// when we delete the enitre row from the cart 
// so customer should either buy the whole quantity from the cart or ignore it
// we need to implement the button such that if the cart is empty it should not be allowed to click the button
exports.checkout = ({ userId, order_items }) => {
    return new Promise((resolve, reject) => {
        const query1 = `
        INSERT INTO \`order\` (customer_id, created_at) VALUES (?, NOW());
        `;
        db.query(query1, [userId], (err, result) => {
            if (err) {
                return reject(err);
            }
            const orderId = result.insertId; // Get the last inserted ID
            for (let i of order_items) {
                const query4 = `
                SELECT * FROM \`cart\` WHERE user_id = ? AND variant_id = ?;
                `;
                db.query(query4, [userId, i.variant_id], (err, deletedRowData) => {
                    if (err) {
                        return reject(err);
                    }
                    const query3 = `
                    DELETE FROM \`cart\` WHERE user_id = ? AND variant_id = ?;
                    `;
                    db.query(query3, [userId, i.variant_id], (err, result) => {
                        if (err) {
                            return reject(err);
                        }
                        const deletedRows = result.affectedRows; // Get the number of deleted rows
                        const query2 = `
                        INSERT INTO \`orderitem\` (order_id, variant_id, quantity) VALUES (?, ?, ?);
                        `;
                        db.query(query2, [orderId, i.variant_id, i.quantity], (err, result) => {
                            if (err) {
                                return reject(err);
                            }
                            resolve({ result, deletedRows: JSON.stringify({ deletedRows, deletedRowData }) });
                        });
                    });
                });
            }
        });
    });
}

