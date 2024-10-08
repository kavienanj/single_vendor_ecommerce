# Single Vendor E-Commerce DB Project

This project is a simple product management API built using Node.js, Express, and MySQL. It allows you to create, read, update, and delete (CRUD) products in a MySQL database. The project uses environment-based configurations to manage different database credentials for development and production environments.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v14.x or higher)
- [MySQL](https://www.mysql.com/) (v5.7 or higher)
- [npm](https://www.npmjs.com/) (comes with Node.js)

## Project Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/kavienanj/single_vendor_ecommerce.git
   ```

2. **Navigate to the backend directory**

   ```bash
   cd single_vendor_ecommerce/backend
   ```

3. **Install dependencies**

   Run the following command to install the necessary dependencies:

   ```bash
   npm install
   ```

4. **Set up the environment file**

   Create a `.env` file in the `backend` directory with the following content:

   ```bash
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=YourDatabaseName
   ```

   Replace `your_password` with your actual MySQL password and `YourDatabaseName` with the name of your database.

5. **Configure MySQL database**

   Make sure you have a MySQL database set up that matches the credentials in your `.env` file. You also need to create a table for the products.

   Example SQL to create the `Product` table:

   ```sql
   CREATE TABLE Product (
       product_id INT AUTO_INCREMENT PRIMARY KEY,
       title VARCHAR(255),
       description TEXT,
       sku VARCHAR(100),
       weight DECIMAL(5,2),
       created_at DATETIME,
       updated_at DATETIME
   );
   ```

6. **Run the server**

   To start the server, run the following command:

   ```bash
   node server.js
   ```

   The server will start on the port defined in the `server.js` file (by default, port 3000).

7. **Testing the API**

   Once the server is running, you can interact with the API using an API testing tool like [Postman](https://www.postman.com/) or [cURL](https://curl.se/).

   - **Add a product** (POST): `http://localhost:3000/products`
   - **Get all products** (GET): `http://localhost:3000/products`
   - **Update a product** (PUT): `http://localhost:3000/products/:id`
   - **Delete a product** (DELETE): `http://localhost:3000/products/:id`

## Project Structure

```
├── backend/
│   ├── db.js               # Database connection logic
│   ├── productRoutes.js     # Routes related to product management
│   ├── server.js            # Main server setup and middleware
│   └── .env                 # Environment variables
├── .gitignore               # Git ignore file
├── package.json             # Project dependencies and scripts
└── README.md                # Project documentation
```

## Available Scripts

- **`npm install`**: Install dependencies inside the `backend` directory.
- **`node server.js`**: Run the server.
