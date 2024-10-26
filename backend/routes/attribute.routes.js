const express = require('express');
const router = express.Router();
const AttributeController = require('../controllers/attribute.controller');

// Create a new attribute
router.post('/', AttributeController.createAttribute);

// Create a new attribute value
router.post('/value', AttributeController.createAttributeValue);

// Delete an attribute
router.delete('/:id', AttributeController.deleteAttribute);



// Get all attributes for a product
router.get('/:productId', AttributeController.getAttributesByProductId);

// Get all attributes
router.get('/', AttributeController.getAllAttributes);



module.exports = router;
