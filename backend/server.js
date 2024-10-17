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
const report1Routes = require('./routes/report1.routes');
const report2Routes = require('./routes/report2.routes');
const report3Routes = require('./routes/report3.routes');
const report5Routes = require('./routes/report5.routes');
const report4Routes = require('./routes/report4.routes');

// Create an Express app
const app = express();

// Enable CORS for all routes
app.use(cors());

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Use the product routes
app.use('/', productRoutes);
app.use('/', authRoutes);
app.use('/', orderRoutes);
app.use('/', report1Routes);
app.use('/', report2Routes);
app.use('/', report3Routes);
app.use('/', report5Routes);
app.use('/', report4Routes);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
