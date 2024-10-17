const mostSellingProductModel = require('../models/most_selling_product.model');

exports.getProductsBySales = async (req, res) => {
    const { start_date, end_date } = req.query;

    if (!start_date || !end_date) {
        return res.status(400).json({ message: 'Both start_date and end_date are required query parameters' });
    }

    try {
        const reportData = await mostSellingProductModel.getProductsBySales(start_date, end_date);
        const topProduct = reportData.length > 0 ? reportData[0] : null; // Get only the first product

        if (!topProduct) {
            return res.status(404).json({ message: 'No products found for the given period' });
        }

        res.status(200).json({
            message: `Top product with most sales from ${start_date} to ${end_date}`,
            data: topProduct,  // Return only the first item
        });
    } catch (err) {
        console.error('Error fetching top products:', err);
        res.status(500).json({ message: 'Error fetching top products', error: err.message });
    }
};

/*const report2Model = require('../models/report2.model');

exports.getProductsBySales = async (req, res) => {
    const { start_date, end_date } = req.query;

    if (!start_date || !end_date) {
        return res.status(400).json({ message: 'Both start_date and end_date are required query parameters' });
    }

    try {
        const reportData = await report2Model.getProductsBySales(start_date, end_date);
        const topProduct = reportData.length > 0 ? reportData[0] : null; // Get only the first product

        if (!topProduct) {
            return res.status(404).json({ message: 'No products found for the given period' });
        }

        res.status(200).json({
            message: `Top product with most sales from ${start_date} to ${end_date}`,
            data: topProduct,  // Return only the first item
        });
    } catch (err) {
        console.error('Error fetching top products:', err);
        res.status(500).json({ message: 'Error fetching top products', error: err.message });
    }
};*/

