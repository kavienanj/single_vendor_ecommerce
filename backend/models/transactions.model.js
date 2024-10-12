// Importing Sequelize and the connection
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database'); // Assuming you have a sequelize instance - @kavienan

// Defining the Transaction model
const Transaction = sequelize.define('Transaction', {
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Users', // Assuming you have a Users table - @kavienan
            key: 'id'
        }
    },
    productId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Products', // Assuming you have a Products table
            key: 'id'
        }
    },
    quantity: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    totalPrice: {
        type: DataTypes.FLOAT,
        allowNull: false
    },
    paymentStatus: {
        type: DataTypes.ENUM('Pending', 'Completed', 'Failed'),
        defaultValue: 'Pending'
    },
    transactionDate: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    deliveryStatus: {
        type: DataTypes.ENUM('Processing', 'Shipped', 'Delivered', 'Cancelled'),
        defaultValue: 'Processing'
    }
}, {
    timestamps: false, // Disable automatic timestamps (createdAt, updatedAt)
    tableName: 'transactions'
});

// Exporting the Transaction model
module.exports = Transaction;
