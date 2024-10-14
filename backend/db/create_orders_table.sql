USE ECommerceDatabase;

-- Create Order Table
CREATE TABLE `Order` (
  `order_id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `contact_email` VARCHAR(255),
  `contact_phone` VARCHAR(255),
  `delivery_method` ENUM('store_pickup', 'delivery') NOT NULL,
  `delivery_location_id` INT,
  `payment_method` ENUM('cash_on_delivery', 'card'),
  `total_amount` FLOAT,
  `order_status` ENUM('Processing', 'Shipped', 'Completed', 'Failed'),
  `purchased_time` DATETIME,
  `delivery_estimate` INT,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`customer_id`) REFERENCES `User`(`user_id`),
 
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`)
);

CREATE TABLE `OrderItem` (
  `order_item_id` INT AUTO_INCREMENT,
  `order_id` INT,
  `variant_id` INT,
  `discount` FLOAT,
  `quantity` INT,
  `price` FLOAT,
  PRIMARY KEY (`order_item_id`),
  FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`),
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
);
