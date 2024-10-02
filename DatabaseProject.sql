create schema DataBaseProject;
use DataBaseProject;

CREATE TABLE `Category` (
  `category_id` INT AUTO_INCREMENT,
  `category_name` VARCHAR(255) not null unique,
  `description` VARCHAR(255),
  PRIMARY KEY (`category_id`)
);

CREATE TABLE `ParentCategory_Match` (
  `category_id` INT,
  `parent_category_id` INT,
  PRIMARY KEY (`category_id`, `parent_category_id`),
  FOREIGN KEY (`category_id`) REFERENCES `Category`(`category_id`)
  on update cascade
  on delete cascade,
  FOREIGN KEY (`parent_category_id`) REFERENCES `Category`(`category_id`)
  ON update cascade
  on delete restrict
);

CREATE TABLE `Warehouse` (
  `warehouse_id` INT AUTO_INCREMENT,
  `location` VARCHAR(255) not null,
  `capacity` INT NOT null,
  PRIMARY KEY (`warehouse_id`)
);

CREATE TABLE `Product` (
  `product_id` INT AUTO_INCREMENT,
  `title` VARCHAR(255) NOT null,
  `description` VARCHAR(255),
  `sku` VARCHAR(255),
  `weight` FLOAT,
  -- `default_price` FLOAT,
  `warehouse_id` INT,
  `created_at` DATETIME not null,
  `updated_at` DATETIME,
  PRIMARY KEY (`product_id`),
  FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouse`(`warehouse_id`)
  ON DELETE restrict
  on update cascade
);

CREATE TABLE `Product_Category_Match` (
  `product_id` INT,
  `category_id` INT,
  PRIMARY KEY (`product_id`, `category_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
  on delete cascade
  on update cascade,
  FOREIGN KEY (`category_id`) REFERENCES `Category`(`category_id`)
  on update cascade
  on delete restrict
);

CREATE TABLE `Role` (
  `role_id` INT AUTO_INCREMENT,
  `role_name` ENUM("Admin", "User", "Guest") NOT null,
  `description` VARCHAR(255),
  PRIMARY KEY (`role_id`)
);

CREATE TABLE `User` (
  `user_id` INT AUTO_INCREMENT,
  `first_name` VARCHAR(255) not null,
  `last_name` VARCHAR(255) not null,
  `email` VARCHAR(255) not null unique,
  `password_hash` VARCHAR(255) not null,
  `phone_number` VARCHAR(255) not null unique,
  `is_guest` BOOLEAN not null,
  `role_id` INT not null,
  `created_at` DATETIME not null,
  `last_login` DATETIME,
  PRIMARY KEY (`user_id`),
  FOREIGN KEY (`role_id`) REFERENCES `Role`(`role_id`)
  ON DELETE restrict
  on update cascade
);

CREATE TABLE `Cart` (
  -- `cart_item_id` INT AUTO_INCREMENT,
  `user_id` INT,
  `variant_id` INT,
  `quantity` INT,
  -- PRIMARY KEY (`cart_item_id`),
  PRIMARY KEY (`user_id`,`variant_id`),
  FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
  on delete cascade
  on update cascade,
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
  on delete cascade
  on update cascade
);

CREATE TABLE `Transaction` (
  `transaction_id` INT AUTO_INCREMENT,
  `order_id` INT,
  `status` ENUM("Completed", "Failed"),
  `transaction_date` DATETIME,
  `amount` FLOAT,
  PRIMARY KEY (`transaction_id`),
  FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`)
);

-- DeliveryMethod Table
CREATE TABLE `DeliveryMethod` (
  `delivery_method_id` INT AUTO_INCREMENT,
  `method_name` ENUM('store_pickup', 'delivery') NOT NULL,
  `description` VARCHAR(255),
  PRIMARY KEY (`delivery_method_id`),
  UNIQUE (`method_name`)
);

-- DeliveryLocation Table
CREATE TABLE `DeliveryLocation` (
  `delivery_location_id` INT AUTO_INCREMENT,
  `location_type` ENUM('Main City', 'Non-Main City') NOT NULL,
  `additional_days` INT DEFAULT 0,
  PRIMARY KEY (`delivery_location_id`),
  UNIQUE (`location_type`)
);

-- DeliveryEstimate Table
CREATE TABLE `DeliveryEstimate` (
  `delivery_estimate_id` INT AUTO_INCREMENT,
  `delivery_method_id` INT,
  `delivery_location_id` INT,
  `base_delivery_days` INT NOT NULL,
  PRIMARY KEY (`delivery_estimate_id`),
  FOREIGN KEY (`delivery_method_id`) REFERENCES `DeliveryMethod`(`delivery_method_id`),
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`),
  UNIQUE (`delivery_method_id`, `delivery_location_id`)
);

-- Updated Order Table
CREATE TABLE `Order` (
  `order_id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `contact_email` VARCHAR(255),
  `contact_phone` VARCHAR(255),
  `delivery_method_id` INT,
  `delivery_location_id` INT,
  `payment_method` ENUM('Cash_on_delivery', 'card'),
  `total_amount` FLOAT,
  `order_status` ENUM('Processing', 'Shipped', 'Completed'),
  `purchased_time` DATETIME,
  `delivery_estimate` INT,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`customer_id`) REFERENCES `User`(`user_id`),
  FOREIGN KEY (`delivery_method_id`) REFERENCES `DeliveryMethod`(`delivery_method_id`),
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`)
);

  
);

CREATE TABLE `Variant` (
  `variant_id` INT AUTO_INCREMENT,
  `product_id` INT,
  `name` VARCHAR(255),
  `price` FLOAT,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY (`variant_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
  on update cascade
  on delete restrict
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

CREATE TABLE `Custom_Attribute` (
  `attribute_id` INT AUTO_INCREMENT,
  `product_id` INT,
  `attribute_name` VARCHAR(255),
  PRIMARY KEY (`attribute_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
);

CREATE TABLE `Custom_Attribute_Value` (
  `variant_id` INT,
  `attribute_id` INT,
  `attribute_value` VARCHAR(255),
  PRIMARY KEY (`variant_id`, `attribute_id`),
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`),
  FOREIGN KEY (`attribute_id`) REFERENCES `Custom_Attribute`(`attribute_id`)
);

CREATE TABLE `Inventory` (
  `inventory_id` INT AUTO_INCREMENT,
  `warehouse_id` INT,
  `variant_id` INT,
  `quantity_available` INT,
  `last_updated` DATETIME,
  PRIMARY KEY (`inventory_id`),
  FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouse`(`warehouse_id`)
  on delete restrict
  on update cascade,
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
  on delete restrict
  on update cascade
);

DELIMITER $$

CREATE PROCEDURE ADD_WAREHOUSE (location VARCHAR(255) , capacity INT)
BEGIN
INSERT INTO Warehouse VALUES (default,location,capacity);
END$$

CREATE PROCEDURE ADD_TO_CART (user_id INT , variant_d INT , quantity INT)
BEGIN
IF quantity IS NULL THEN
	SET quantity = 1 ;
END IF;
INSERT INTO Cart VALUES (user_id,variant_id,quantity);
END$$


DELIMITER ;

--Register the user

CREATE PROCEDURE RegisterUser (
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_phone_number VARCHAR(255),
    IN p_is_guest BOOLEAN
)
BEGIN
    DECLARE hashed_password VARCHAR(255);
    
    -- Hash the password using SHA2 (you can use a more secure hashing function as needed)
    SET hashed_password = SHA2(p_password, 256);
    
    INSERT INTO User (first_name, last_name, email, password_hash, phone_number, is_guest, role_id, created_at)
    VALUES (
        p_first_name,
        p_last_name,
        p_email,
        hashed_password,
        p_phone_number,
        p_is_guest,
        (SELECT role_id FROM Role WHERE role_name = 'User'), -- Assign default role
        NOW()
    );
END;

-- Add new Product.

CREATE PROCEDURE AddNewProduct (
    IN p_title VARCHAR(255),
    IN p_description VARCHAR(255),
    IN p_sku VARCHAR(255),
    IN p_weight FLOAT,
    IN p_default_price FLOAT,
    IN p_warehouse_id INT,
    IN p_variant_name VARCHAR(255),
    IN p_variant_price FLOAT,
    IN p_quantity_available INT
)
BEGIN
    DECLARE new_product_id INT;
    DECLARE new_variant_id INT;
    
    -- Insert into Product
    INSERT INTO Product (title, description, sku, weight, default_price, warehouse_id, created_at, updated_at)
    VALUES (p_title, p_description, p_sku, p_weight, p_default_price, p_warehouse_id, NOW(), NOW());
    
    SET new_product_id = LAST_INSERT_ID();
    
    -- Insert into Variant
    INSERT INTO Variant (product_id, name, price, created_at, updated_at)
    VALUES (new_product_id, p_variant_name, p_variant_price, NOW(), NOW());
    
    SET new_variant_id = LAST_INSERT_ID();
    
    -- Insert into Inventory
    INSERT INTO Inventory (warehouse_id, variant_id, quantity_available, last_updated)
    VALUES (p_warehouse_id, new_variant_id, p_quantity_available, NOW());
END;


-- Update inventory..

CREATE PROCEDURE UpdateInventory (
    IN p_variant_id INT,
    IN p_quantity_change INT
)
BEGIN
    UPDATE Inventory
    SET 
        quantity_available = quantity_available + p_quantity_change,
        last_updated = NOW()
    WHERE variant_id = p_variant_id;
END;


-- Add to cart

CREATE PROCEDURE AddToCart (
    IN p_user_id INT,
    IN p_variant_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE existing_quantity INT;
    
    SELECT quantity INTO existing_quantity 
    FROM Cart 
    WHERE user_id = p_user_id AND variant_id = p_variant_id;
    
    IF existing_quantity IS NOT NULL THEN
        UPDATE Cart
        SET quantity = quantity + p_quantity
        WHERE user_id = p_user_id AND variant_id = p_variant_id;
    ELSE
        INSERT INTO Cart (user_id, variant_id, quantity)
        VALUES (p_user_id, p_variant_id, p_quantity);
    END IF;
END;


--remove from cart.

CREATE PROCEDURE RemoveFromCart (
    IN p_user_id INT,
    IN p_variant_id INT
)
BEGIN
    DELETE FROM Cart
    WHERE user_id = p_user_id AND variant_id = p_variant_id;
END;





