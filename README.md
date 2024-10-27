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
   JWT_SECRET=your_secret_key
   ```

   Replace `your_password` with your actual MySQL password and `YourDatabaseName` with the name of your database.

5. **Run the SQL script**

   Run the following command to create the database and table:

   ```bash
   mysql -u root -p < FinalDatabase.sql
   ```
   Enter your MySQL password when prompted.

6. **Run the server**

   To start the server, and listen for changes, run the following command:

   ```bash
   cd backend
   npm run dev
   ```

   The server will start on the port `3000` defined in the `server.js` file.

7. **Setup the frontend**

   The Next.js frontend is located in the `frontend` directory. To run the frontend, navigate to the `frontend` directory and run the following command:

   ```bash
   npm install
   npm run dev
   ```
   The frontend will start on the port `3001`.


## Project Structure

```
├── backend/
│   ├── routes/                 # Express routing
│   ├── controllers/            # API controllers
│   ├── models/                 # Database models
|   ├── middleware/             # Middleware functions
│   ├── db.js                   # Database connection logic
│   ├── server.js               # Main server setup and middleware
│   ├── package.json            # Backend dependencies and scripts
│   └── .env                    # Environment variables
|-- frontend/
|   ├── src/
|   |   ├── app/                # Main app component
|   |   ├── components/         # React components
|   |   └── services/           # API service
|   └── package.json            # Frontend dependencies and scripts
├── .gitignore                  # Git ignore file
├── FinalDatabase.sql           # SQL script for creating the database and table
└── README.md                   # Project documentation
```

## Team Members
Kavienan J. 220314M
