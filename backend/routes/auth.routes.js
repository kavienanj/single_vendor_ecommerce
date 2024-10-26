const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// Route for user registration
router.post('/register', authController.registerUser);

// Route for user login
router.post('/login', authController.loginUser);

// Route for user logout
router.post('/logout', authController.logoutUser);

// Route for get users
router.get('/users', authController.getUsers);

module.exports = router;
