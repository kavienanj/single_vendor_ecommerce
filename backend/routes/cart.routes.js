const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');

// Route to add to cart
// if the user select items from home page or anybrowsing page quantity should
// be set to one
// this function can only increase the quantity or place a variant for the first time in the cart
router.post('/:userId/cart/', cartController.addtoCart);


//route to set the quantity of a variant (no increase or decrease)
router.put('/:userId/cart/', cartController.setQuantity);

// Route to remove from cart
router.delete('/:userId/cart/', cartController.deletefromCart);

// Route to show all the items in the cart
// delete the whole quatity (complete row from the cart)
router.get('/:userId/cart/', cartController.showCart);

// after click on checkout button
// might be false functionality
router.post('/:userId/cart/checkout', cartController.checkout);

module.exports = router;
