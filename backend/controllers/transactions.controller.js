// Importing models
const Transaction = require('../models/transaction.model');
const Product = require('../models/product.model');
const User = require('../models/user.model');

// Create a new transaction
const createTransaction = async (req, res) => {
    try {
        const { userId, productId, quantity } = req.body;

        // Fetch product details to calculate total price
        const product = await Product.findByPk(productId);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }

        // Calculate total price
        const totalPrice = product.price * quantity;

        // Create the transaction
        const newTransaction = await Transaction.create({
            userId,
            productId,
            quantity,
            totalPrice,
            paymentStatus: 'Pending'
        });

        return res.status(201).json({ message: 'Transaction created', transaction: newTransaction });
    } catch (error) {
        return res.status(500).json({ message: 'Error creating transaction', error: error.message });
    }
};

// Get a specific transaction by ID
const getTransactionById = async (req, res) => {
    try {
        const { id } = req.params;
        const transaction = await Transaction.findByPk(id, {
            include: [
                { model: Product, as: 'product' }, 
                { model: User, as: 'user' }
            ]
        });
        if (!transaction) {
            return res.status(404).json({ message: 'Transaction not found' });
        }
        return res.status(200).json(transaction);
    } catch (error) {
        return res.status(500).json({ message: 'Error fetching transaction', error: error.message });
    }
};

// Update payment status of a transaction
const updatePaymentStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { paymentStatus } = req.body;

        const updatedTransaction = await Transaction.update(
            { paymentStatus },
            { where: { id } }
        );

        if (!updatedTransaction) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        return res.status(200).json({ message: 'Payment status updated' });
    } catch (error) {
        return res.status(500).json({ message: 'Error updating payment status', error: error.message });
    }
};

// Delete a transaction
const deleteTransaction = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedTransaction = await Transaction.destroy({ where: { id } });
        if (!deletedTransaction) {
            return res.status(404).json({ message: 'Transaction not found' });
        }
        return res.status(200).json({ message: 'Transaction deleted successfully' });
    } catch (error) {
        return res.status(500).json({ message: 'Error deleting transaction', error: error.message });
    }
};

module.exports = {
    createTransaction,
    getTransactionById,
    updatePaymentStatus,
    deleteTransaction
};
