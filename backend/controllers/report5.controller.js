const report5Model = require('../models/report5.model');

exports.getCustomerOrderReport = async (req, res) => {
    try {
        const reportData = await report5Model.getCustomerOrderReport();
        res.status(200).json({
            message: 'Customer-Order report',
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching Customer-Order report:', err);
        res.status(500).json({ message: 'Error fetching Customer-Order report', error: err.message });
    }
};
