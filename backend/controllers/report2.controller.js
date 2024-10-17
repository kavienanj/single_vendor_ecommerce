const report2Model = require('../models/report2.model');

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
};

/*const report2Model = require('../models/report2.model');

exports.getProductsBySales = async (req, res) => {
    console.log(req.query);  // Log the query object to debug

    const startDate = req.query.start_date;  // Extract the start_date from query parameters
    const endDate = req.query.end_date;  // Extract the end_date from query parameters

    if (!startDate || !endDate) {
        return res.status(400).json({ message: 'Start date and end date are required as query parameters' });
    }

    try {
        const reportData = await report2Model.getProductsBySales(startDate, endDate);
        res.status(200).json({
            message: `Products with most sales from ${startDate} to ${endDate}`,
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching product sales report:', err);
        res.status(500).json({ message: 'Error fetching product sales report', error: err.message });
    }
};*/
