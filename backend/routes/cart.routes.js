const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');

// Route to add to cart
// if the user select items from home page or anybrowsing page quantity should
// be set to one
// this function can only increase the quantity or place a variant for the first time in the cart
router.post('/cart', cartController.addtoCart);


//route to set the quantity of a variant (no increase or decrease)
router.put('/cart', cartController.setQuantity);

// Route to remove from cart
router.post('/cart/remove', cartController.deletefromCart);

// Route to show all the items in the cart
// delete the whole quatity (complete row from the cart)
router.get('/cart', cartController.showCart);

// after click on checkout button
// might be false functionality
router.post('/cart/checkout', cartController.checkout);

router.post('/cart/checkout/placeOrder', cartController.placeOrder);

// get the payment info for autofill
router.get('/cart/checkout/placeOrder', cartController.getPaymentInfo);

module.exports = router;
