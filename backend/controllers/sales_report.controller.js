const salesReportModel = require('../models/sales_report.model');

exports.getQuarterlySalesReport = async (req, res) => {
    console.log(req.query);  // Log the query object to debug
    
    const year = req.query.year;  // Extract the year from the query parameter

    if (!year) {
        return res.status(400).json({ message: 'Year is required as a query parameter' });
    }

    try {
        const reportData = await salesReportModel.getQuarterlySalesReport(year);
        res.status(200).json({
            message: `Quarterly sales report for the year ${year}`,
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching quarterly sales report:', err);
        res.status(500).json({ message: 'Error fetching quarterly sales report', error: err.message });
    }
};

/*const report1Model = require('../models/report1.model');

exports.getQuarterlySalesReport = async (req, res) => {
    console.log(req.query);  // Log the query object to debug
    
    const year = req.query.year;  // Extract the year from the query parameter

    if (!year) {
        return res.status(400).json({ message: 'Year is required as a query parameter' });
    }

    try {
        const reportData = await report1Model.getQuarterlySalesReport(year);
        res.status(200).json({
            message: `Quarterly sales report for the year ${year}`,
            data: reportData,
        });
    } catch (err) {
        console.error('Error fetching quarterly sales report:', err);
        res.status(500).json({ message: 'Error fetching quarterly sales report', error: err.message });
    }
};*/

