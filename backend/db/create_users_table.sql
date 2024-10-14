USE ECommerceDatabase;

-- Create Role Table
CREATE TABLE `Role` (
  `role_id` INT AUTO_INCREMENT,
  `role_name` ENUM("Admin", "User", "Guest") NOT null,
  `description` VARCHAR(255),
  PRIMARY KEY (`role_id`)
);

-- Insert into Role Table
INSERT INTO `Role` (`role_name`, `description`) VALUES
  ('Admin', 'Admin Role'),
  ('User', 'User Role'),
  ('Guest', 'Guest Role');

-- DeliveryLocation Table
CREATE TABLE `DeliveryLocation` (
  `delivery_location_id` INT AUTO_INCREMENT,
  `location_name` VARCHAR(255) NOT NULL,
  `location_type` ENUM('store', 'city') NOT NULL DEFAULT 'city',
  `with_stock_delivery_days` INT,
  `without_stock_delivery_days` INT,
  PRIMARY KEY (`delivery_location_id`)
);

-- Create User Table
CREATE TABLE `User` (
  `user_id` INT AUTO_INCREMENT,
  `first_name` VARCHAR(255) not null,
  `last_name` VARCHAR(255) not null,
  `email` VARCHAR(255) not null unique,
  `password_hash` VARCHAR(255) not null,
  `phone_number` VARCHAR(255) not null unique,
  `delivery_location_id` INT,
  `is_guest` BOOLEAN not null,
  `role_id` INT not null,
  `created_at` DATETIME not null,
  `last_login` DATETIME,
  PRIMARY KEY (`user_id`),
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `Role`(`role_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
