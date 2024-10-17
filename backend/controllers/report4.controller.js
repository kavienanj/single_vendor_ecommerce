const report4Model = require('../models/report4.model');

exports.getTopMonthsForProductSales = async (req, res) => {
    const { product_id } = req.query;

    if (!product_id) {
        return res.status(400).json({ message: 'Product ID is a required query parameter' });
    }

    try {
        const reportData = await report4Model.getTopMonthsForProductSales(product_id);
        const topMonths = reportData.length > 0 ? reportData : null;

        if (!topMonths) {
            return res.status(404).json({ message: 'No sales data found for the given product' });
        }

        res.status(200).json({
            message: `Top months with most sales for product ${product_id}`,
            data: topMonths,
        });
    } catch (err) {
        console.error('Error fetching top months:', err);
        res.status(500).json({ message: 'Error fetching top months for product', error: err.message });
    }
};
