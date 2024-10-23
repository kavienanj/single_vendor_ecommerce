const model = require('../models/auth.model'); // Adjust the path as needed
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Secret key for JWT
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Controller function for user registration
exports.registerUser = async (req, res) => {
    const { is_guest, first_name, last_name, email, password, phone_number } = req.body;

    try {
        let token;
        if (is_guest) {
            // Create new guest user
            const user = await model.createUser({
                first_name: "Guest",
                last_name: "User",
                email: null,
                password_hash: null,
                phone_number: null,
                is_guest: true,
                role_id: 3,
            });

            // Generate JWT token
            token = jwt.sign({
                id: user.user_id,
                first_name: user.first_name,
                last_name: user.last_name,
                role_id: user.role_id,
            }, JWT_SECRET);
        } else {

            if (!first_name || !last_name || !email || !password || !phone_number) {
                return res.status(400).json({ message: 'Please fill in all fields' });
            }

            // Check if the user already exists
            const existingUser = await model.findUserByEmail(email);
            if (existingUser) {
                return res.status(400).json({ message: 'User already exists' });
            }

            // Hash the password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Create new user
            const user = await model.createUser({
                first_name,
                last_name,
                email,
                password_hash: hashedPassword,
                phone_number,
                is_guest: false,
                role_id: 2, // Default role_id for registered users
            });

            // Generate JWT token
            token = jwt.sign({
                id: user.user_id,
                email: user.email,
                first_name: user.first_name,
                last_name: user.last_name,
                role_id: user.role_id,
            }, JWT_SECRET, { expiresIn: '1h' });
        }

        res.status(201).json({ message: 'User registered successfully!', token });
    } catch (err) {
        console.error('Error registering user:', err);
        res.status(500).json({ message: 'Error registering user', error: err.message });
    }
};

// Controller function for user login
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        // Find the user by email
        const user = await model.findUserByEmail(email);
        if (!user) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Check if password is correct
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Generate JWT token
        const token = jwt.sign({
            id: user.user_id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            role_id: user.role_id,
        }, JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({
            message: 'Login successful!',
            token,
        });
    } catch (err) {
        console.error('Error logging in:', err);
        res.status(500).json({ message: 'Error logging in', error: err.message });
    }
};

// Controller function for user logout (handled client-side by deleting the token)
exports.logoutUser = (req, res) => {
    res.status(200).json({ message: 'Logout successful!' });
};
