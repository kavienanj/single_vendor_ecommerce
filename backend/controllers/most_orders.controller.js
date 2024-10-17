const mostOrdersModel = require('../models/most_orders.model');

exports.getCategoryWithMostOrders = async (req, res) => {
    try {
        const reportData = await mostOrdersModel.getCategoryWithMostOrders();
        const topCategory = reportData.length > 0 ? reportData[0] : null;  // Get only the first result
        
        if (!topCategory) {
            return res.status(404).json({ message: 'No categories found with orders' });
        }

        res.status(200).json({
            message: `Category with most orders`,
            data: topCategory,
        });
    } catch (err) {
        console.error('Error fetching category with most orders:', err);
        res.status(500).json({ message: 'Error fetching category with most orders', error: err.message });
    }
};

/*const report3Model = require('../models/report3.model');

exports.getCategoryWithMostOrders = async (req, res) => {
    try {
        const reportData = await report3Model.getCategoryWithMostOrders();
        const topCategory = reportData.length > 0 ? reportData[0] : null;  // Get only the first result
        
        if (!topCategory) {
            return res.status(404).json({ message: 'No categories found with orders' });
        }

        res.status(200).json({
            message: `Category with most orders`,
            data: topCategory,
        });
    } catch (err) {
        console.error('Error fetching category with most orders:', err);
        res.status(500).json({ message: 'Error fetching category with most orders', error: err.message });
    }
};*/
