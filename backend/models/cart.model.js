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
