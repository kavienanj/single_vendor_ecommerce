const express = require('express');
const router = express.Router();
const deliveryLocationController = require('../controllers/delivery_location.controller');

// Route to add a delivery location
router.post('/delivery-locations', deliveryLocationController.addDeliveryLocation);

// Route to get all delivery locations
router.get('/delivery-locations', deliveryLocationController.getAllDeliveryLocations);

// Route to update a delivery location
router.put('/delivery-locations/:id', deliveryLocationController.updateDeliveryLocation);

// Route to delete a delivery location
router.delete('/delivery-locations/:id', deliveryLocationController.deleteDeliveryLocation);

module.exports = router;
