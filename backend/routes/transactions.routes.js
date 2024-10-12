const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transaction.controller');

// Route to create a new transaction
router.post('/transactions', transactionController.createTransaction);

// Route to get a transaction by its ID
router.get('/transactions/:id', transactionController.getTransactionById);

// Route to get all transactions
router.get('/transactions', transactionController.getAllTransactions);

// Route to update a transaction by its ID
router.put('/transactions/:id', transactionController.updateTransaction);

// Route to delete a transaction by its ID
router.delete('/transactions/:id', transactionController.deleteTransaction);

module.exports = router;
