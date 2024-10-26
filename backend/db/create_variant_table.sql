CREATE TABLE `Variant` (
  `variant_id` INT AUTO_INCREMENT,
  `product_id` INT,
  `name` VARCHAR(255),
  `image_url` VARCHAR(255),
  `price` FLOAT,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME,
   `interested` INT default 0,
  PRIMARY KEY (`variant_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

