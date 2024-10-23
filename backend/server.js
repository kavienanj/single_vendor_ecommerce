const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth.routes');
const productRoutes = require('./routes/products.routes');
const orderRoutes = require('./routes/orders.routes');
const reportRoutes = require('./routes/reports.routes');
const deliveryLocationRoutes = require('./routes/delivery_location.routes');
const categoryRoutes = require('./routes/category.routes');
const variantRoutes = require('./routes/variant.routes');
const attributeRoutes = require('./routes/attribute.routes');

const cartRoutes = require('./routes/cart.routes');

// Create an Express app
const app = express();

// Enable CORS for all routes
app.use(cors());

app.use(express.json());

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Use the product routes
app.use('/', productRoutes);
app.use('/', authRoutes);
app.use('/', orderRoutes);
app.use('/', reportRoutes);
app.use('/', deliveryLocationRoutes);
app.use('/category', categoryRoutes);
app.use('/variant', variantRoutes);
app.use('/attribute', attributeRoutes);

app.use('/', cartRoutes); // can't be changed accordingly  (the first argument '/' to '/something')

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
