const db = require('../db'); // Adjust the path as needed

exports.addtoCart = ({ userId, variant_id, quantity }) => {
    return new Promise((resolve, reject) => {
        const query = `call AddToCart(?,?,?);`;
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
        const query = `call ShowCartofUser(?);`;
        db.query(query, [userId], (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results[0]);
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

exports.setQuantity = ({ userId, variant_id, quantity }) => {
    return new Promise((resolve, reject) => {
        if (quantity === 0) {
            query = `DELETE FROM cart WHERE user_id = ? AND variant_id = ?`;
            params = [userId, variant_id];
        } else {
            query = `UPDATE cart SET quantity = ? WHERE user_id = ? AND variant_id = ?`;
            params = [quantity, userId, variant_id];
        }

        db.query(query, [quantity, userId, variant_id], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

exports.checkout = ({ userId }) => {
    return new Promise((resolve, reject) => {
        const query = `
            SET @new_order_id = 0;
            CALL move_cart_to_order(?, @new_order_id);
            SELECT @new_order_id AS order_id;
        `;
        db.query(query, [userId], (err, results) => {
            if (err) {
                return reject(err);
            }
            console.log(results);
            resolve(results[2][0]); // The result of the SELECT statement
        });
    });
}

exports.placeOrder = ({ userId,
    order_id,
    contact_email,
    contact_phone,
    delivery_method,
    delivery_location_id,
    payment_method,
    delivery_estimate }) => {
    return new Promise((resolve, reject) => {
        const query = `
        update order set 
            contact_email = ?, 
            contact_phone = ?, 
            delivery_method = ?, 
            delivery_location_id = ?,
            payment_method = ?, 
            order_status = 'processing', 
            delivery_estimate = ?
            where order_id = ? and customer_id = ?;
        `; // enum for order_status ('pending','processing','successful' 'shipped', 'delivered', 'cancelled', )
        db.query(query, [contact_email, contact_phone, delivery_method, delivery_location_id, payment_method, delivery_estimate, order_id, userId], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}

exports.getPaymentInfo = ({ userId }) => {
    return new Promise((resolve, reject) => {
        const query = `
        SELECT email,phone_number FROM user WHERE user_id = ?;
        `;
        db.query(query, [userId], (err, result) => {
            if (err) {
                return reject(err);
            }
            resolve(result);
        });
    });
}