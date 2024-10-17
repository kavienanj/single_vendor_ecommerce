const db = require('../db');

exports.getQuarterlySalesReport = (year) => {
    return new Promise((resolve, reject) => {
        const query = 'CALL Get_Quarterly_Sales_By_Year(?)';

        db.query(query, [year], (err, result) => {
            if (err) {
                return reject(err);
            }
            // Assuming the result is in the first element of the array
            resolve(result[0]);
        });
    });
};
