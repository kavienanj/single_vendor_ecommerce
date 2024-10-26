const reportsModel = require('../models/reports.model');

exports.getCustomerOrderReport = async (req, res) => {
    try {
        const reportData = await reportsModel.getCustomerOrderReport();
        res.status(200).json({
            message: 'Customer-Order report',
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching Customer-Order report:', err);
        res.status(500).json({ message: 'Error fetching Customer-Order report', error: err.message });
    }
};

exports.getTopMonthsForProductSales = async (req, res) => {
    const { product_id } = req.query;

    if (!product_id) {
        return res.status(400).json({ message: 'Product ID is a required query parameter' });
    }

    try {
        const reportData = await reportsModel.getTopMonthsForProductSales(product_id);
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


exports.getCategoryWithMostOrders = async (req, res) => {
    try {
        const reportData = await reportsModel.getCategoryWithMostOrders();
        
        // Get the top 10 categories or fewer if there are less than 10 results
        const topCategories = reportData.slice(0, 10);  
        
        if (topCategories.length === 0) {
            return res.status(404).json({ message: 'No categories found with orders' });
        }

        res.status(200).json({
            message: 'Top 10 categories with most orders',
            data: topCategories,
        });
    } catch (err) {
        console.error('Error fetching top categories with most orders:', err);
        res.status(500).json({ message: 'Error fetching top categories with most orders', error: err.message });
    }
};



exports.getProductsBySales = async (req, res) => {
    const { start_date, end_date } = req.query;

    // Check for required query parameters
    if (!start_date || !end_date) {
        return res.status(400).json({ message: 'Both start_date and end_date are required query parameters' });
    }

    try {
        // Fetch the top products from the model
        const reportData = await reportsModel.getProductsBySales(start_date, end_date);
        
        // Check if any products were returned
        if (reportData.length === 0) {
            return res.status(404).json({ message: 'No products found for the given period' });
        }

        // Slice the array to get the top 10 products
        const topProducts = reportData.slice(0, 10);

        res.status(200).json({
            message: `Top 10 products with most sales from ${start_date} to ${end_date}`,
            data: topProducts,
        });
    } catch (err) {
        console.error('Error fetching top products:', err);
        res.status(500).json({ message: 'Error fetching top products', error: err.message });
    }
};


exports.getQuarterlySalesReport = async (req, res) => {
    console.log(req.query);  // Log the query object to debug
    
    const year = req.query.year;  // Extract the year from the query parameter

    if (!year) {
        return res.status(400).json({ message: 'Year is required as a query parameter' });
    }

    try {
        const reportData = await reportsModel.getQuarterlySalesReport(year);
        res.status(200).json({
            message: `Quarterly sales report for the year ${year}`,
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching quarterly sales report:', err);
        res.status(500).json({ message: 'Error fetching quarterly sales report', error: err.message });
    }
};
