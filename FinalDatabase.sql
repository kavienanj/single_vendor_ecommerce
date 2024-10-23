drop database if exists ECommerceDatabase;
create schema ECommerceDatabase;
use ECommerceDatabase;


CREATE TABLE `Category` (
  `category_id` INT AUTO_INCREMENT,
  `category_name` VARCHAR(255) NOT NULL UNIQUE,
  `description` VARCHAR(255),
  PRIMARY KEY (`category_id`)
);

-- Table to store parent-child category relationships
CREATE TABLE `ParentCategory_Match` (
  `category_id` INT,
  `parent_category_id` INT,
  PRIMARY KEY (`category_id`, `parent_category_id`),
  FOREIGN KEY (`category_id`) REFERENCES `Category`(`category_id`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`parent_category_id`) REFERENCES `Category`(`category_id`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Add indexes to improve performance
CREATE INDEX idx_category_id ON `ParentCategory_Match` (`category_id`);
CREATE INDEX idx_parent_category_id ON `ParentCategory_Match` (`parent_category_id`);


CREATE TABLE `Warehouse` (
  `warehouse_id` INT AUTO_INCREMENT,
  `location` VARCHAR(255) not null,
  `capacity` INT NOT null,
  `available_capacity` INT,
  PRIMARY KEY (`warehouse_id`)
);
delimiter $$
CREATE TRIGGER enter_avalible_capacity
BEFORE INSERT ON Warehouse
FOR EACH ROW
BEGIN
    SET NEW.available_capacity = NEW.capacity ;
END$$
delimiter ;



CREATE TABLE `Product` (
  `product_id` INT AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255),
  `sku` VARCHAR(255),
  `weight` FLOAT,
  -- `default_price` FLOAT,
  -- `warehouse_id` INT,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME,
  PRIMARY KEY (`product_id`)
  -- FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouse`(`warehouse_id`)
    -- ON DELETE RESTRICT
    -- ON UPDATE CASCADE
);

-- Table to store many-to-many relationship between products and categories
CREATE TABLE `Product_Category_Match` (
  `product_id` INT,
  `category_id` INT,
  PRIMARY KEY (`product_id`, `category_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `Category`(`category_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- Add indexes to improve performance
CREATE INDEX idx_product_id ON `Product_Category_Match` (`product_id`);
CREATE INDEX idx_category_id ON `Product_Category_Match` (`category_id`);


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

-- Indexes to improve performance
CREATE INDEX idx_variant_product_id ON `Variant` (`product_id`);


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
  `quantity_available` INT not null,
  `assigned_capacity` INT default 50,
  `last_updated` DATETIME,
  PRIMARY KEY (`inventory_id`),
  FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouse`(`warehouse_id`)
  on delete restrict
  on update cascade,
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
  on delete restrict
  on update cascade
);


CREATE TABLE `DeliveryLocation` (
  `delivery_location_id` INT AUTO_INCREMENT,
  `location_name` VARCHAR(255) NOT NULL,
  `location_type` ENUM('store', 'city') NOT NULL DEFAULT 'city',
  `with_stock_delivery_days` INT,
  `without_stock_delivery_days` INT,
  PRIMARY KEY (`delivery_location_id`)
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

delimiter $$
create trigger increase_interested
after insert on Cart
for each row
begin
    update Variant 
    set interested = interested + 1
    where variant_id = new.variant_id ;
end$$

create trigger decrease_interested
after delete on Cart
for each row
begin
    update Variant 
    set interested = interested - 1
    where variant_id = old.variant_id ;
end$$
delimiter ;


CREATE TABLE `Order` (
  `order_id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `contact_email` VARCHAR(255),
  `contact_phone` VARCHAR(255),
  `delivery_method` ENUM('store_pickup', 'delivery') NOT NULL,
  `delivery_location_id` INT,
  `payment_method` ENUM('cash_on_delivery', 'card'),
  `total_amount` FLOAT,
  `order_status` ENUM('Pending','Processing','Failed' 'Shipped', 'Completed', 'Failed'),
  `purchased_time` DATETIME,
  `delivery_estimate` INT,
  `created_at` DATETIME DEFAULT current_timestamp,
  `updated_at` DATETIME ,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`customer_id`) REFERENCES `User`(`user_id`),
 
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`)
);


CREATE TABLE `DeliveryEstimate` (
  `delivery_estimate_id` INT AUTO_INCREMENT,
  `delivery_method_id` INT,
  `delivery_location_id` INT,
  `base_delivery_days` INT NOT NULL,
  PRIMARY KEY (`delivery_estimate_id`),
  
  FOREIGN KEY (`delivery_location_id`) REFERENCES `DeliveryLocation`(`delivery_location_id`),
  UNIQUE (`delivery_method_id`, `delivery_location_id`)
);

CREATE TABLE `OrderItem` (
  `order_item_id` INT AUTO_INCREMENT,
  `order_id` INT,
  `variant_id` INT,
  `discount` FLOAT,
  `quantity` INT,
  `price` FLOAT,
  PRIMARY KEY (`order_item_id`),
  FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`)
  on delete cascade
  on update cascade,
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
    on delete restrict
    on update RESTRICT
);

DELIMITER $$

CREATE PROCEDURE ADD_WAREHOUSE (location VARCHAR(255) , capacity INT)
BEGIN
INSERT INTO Warehouse VALUES (default,location,capacity);
END$$

CREATE PROCEDURE InsertCustomAttributeWithDefaultValues (
    IN input_product_id INT,
    IN input_attribute_name VARCHAR(255)
)
BEGIN
    DECLARE new_attribute_id INT;

    -- Step 1: Insert new custom attribute for the product
    INSERT INTO Custom_Attribute (product_id, attribute_name)
    VALUES (input_product_id, input_attribute_name);

    -- Retrieve the new attribute_id generated
    SET new_attribute_id = LAST_INSERT_ID();

    -- Step 2: Insert 'not specified' for each variant of the product
    INSERT INTO Custom_Attribute_Value (variant_id, attribute_id, attribute_value)
    SELECT v.variant_id, new_attribute_id, 'Not specified'
    FROM Variant v
    WHERE v.product_id = input_product_id;

END $$

create procedure CHANGE_VARIANT_ATTRIBUTE_VALUE (variant_id INT, attribute_id INT, new_attribute_value VARCHAR(255))
BEGIN
	update Custom_Attribute_Value set attribute_value = new_attribute_value
    where Custom_Attribute_Value.variant_id = variant_id and Custom_Attribute_Value.attribute_id = attribute_id;
END$$


-- when a product is added, a variant should be added to variant table as well
-- Otherwise adding a product is not allowed. 
-- adding a product must always add a variant.
create procedure ADD_PRODUCT (title VARCHAR(255) , description varchar(255) , sku varchar(255), weight float)
begin
	insert into Product values (default,title,description,sku,weight,warehouse_id,now(),now());
END$$

CREATE PROCEDURE ADD_VARIANT( product_id INT , name varchar(255), price float,quantity INT, warehouse_id INT,assigned_capacity INT)
begin
	insert into Variant values (default,product_id,name,price,now(),now());
    
    -- set @warehouse_id = (
-- 		select warehouse_id 
--         from Product p
--         where p.product_id = product_id
--         );
	set @variant_id = LAST_INSERT_ID();
    
    insert into Inventory values (default,warehouse_id,@varinat_id,quantity,assigned_capacity,now());
end$$

CREATE PROCEDURE SET_CATEGORY (IN product_id INT, IN category_id INT)
BEGIN
  INSERT INTO Product_Category_Match values (product_id, category_id);
END$$

CREATE FUNCTION GetSubCategories(
    input_category_id INT
) 
RETURNS text -- Adjust the length as per your needs
DETERMINISTIC
BEGIN
    -- Variable to hold the concatenated result
    DECLARE subcategories_list text DEFAULT '';

    -- Use a recursive Common Table Expression (CTE)
    WITH RECURSIVE SubCategoryCTE AS (
        -- Anchor member: Select all immediate subcategories of the given category
        SELECT 
            pc.category_id,
            pc.parent_category_id
        FROM 
            ParentCategory_Match pc
        WHERE 
            pc.parent_category_id = input_category_id

        UNION ALL

        -- Recursive member: Find the subcategories of the current subcategory
        SELECT 
            pcm.category_id,
            pcm.parent_category_id
        FROM 
            ParentCategory_Match pcm
        INNER JOIN 
            SubCategoryCTE sc ON pcm.parent_category_id = sc.category_id
    )
    -- Build a comma-separated list of subcategory IDs
    SELECT GROUP_CONCAT(sc.category_id)
    INTO subcategories_list
    FROM SubCategoryCTE sc
    JOIN Category c ON sc.category_id = c.category_id;

    -- Return the comma-separated list
    RETURN subcategories_list;
    
END $$

CREATE FUNCTION GetProductsInSubCategories(
    input_category_id INT
)
RETURNS text -- Adjust the length as needed
DETERMINISTIC
BEGIN
    -- Declare a variable to store the concatenated product IDs
    DECLARE product_list text DEFAULT '';

    -- Retrieve subcategories using the GetSubCategories function
    DECLARE subcategories_list text;
    SET subcategories_list = GetSubCategories(input_category_id);

    -- If subcategories list is empty, return NULL (no products)
    IF subcategories_list IS NULL THEN
        RETURN NULL;
    END IF;

    -- Retrieve product IDs belonging to the subcategories
    SELECT GROUP_CONCAT(p.product_id)
    INTO product_list
    FROM Product p
    WHERE FIND_IN_SET(p.category_id, subcategories_list);

    -- Return the concatenated list of product IDs
    RETURN product_list;
END $$

CREATE FUNCTION GetVariantsForSubCategories(
    category_id INT
)
RETURNS text -- Adjust the length as necessary
DETERMINISTIC
BEGIN
    -- Variable to hold the concatenated result of variant IDs
    DECLARE variant_list text DEFAULT '';

    -- Temporary variable to hold product IDs
    DECLARE product_ids text;
    
    -- Step 1: Get product IDs returned by GetProductsInSubCategories
    SET product_ids = GetProductsInSubCategories(category_id);
    
    -- If no product IDs found, return NULL
    IF product_ids IS NULL THEN
        RETURN NULL;
    END IF;

    -- Step 2: Get all variants for the products
    SELECT GROUP_CONCAT(v.variant_id)
    INTO variant_list
    FROM Variant v
    WHERE FIND_IN_SET(v.product_id, product_ids);

    -- Step 3: Return the comma-separated list of variant IDs
    RETURN variant_list;
END $$


-- Register the user
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


-- remove from cart.

CREATE PROCEDURE RemoveFromCart (
    IN p_user_id INT,
    IN p_variant_id INT
)
BEGIN
    DELETE FROM Cart
    WHERE user_id = p_user_id AND variant_id = p_variant_id;
END;

-- Get cart items

-- CREATE PROCEDURE CheckoutOrder(IN orderID INT)
-- BEGIN
--     DECLARE variantID INT;
--     DECLARE orderQuantity INT;
--     DECLARE availableQuantity INT;
--     DECLARE done INT DEFAULT FALSE;
--     
--     -- Cursor to loop through all items in the order
--     DECLARE orderItems CURSOR FOR
--     SELECT variant_id, quantity
--     FROM OrderItem
--     WHERE order_id = orderID;

--     -- Handler to exit the loop
--     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

--     OPEN orderItems;

--     orderLoop: LOOP
--         FETCH orderItems INTO variantID, orderQuantity;
--         
--         IF done THEN
--             LEAVE orderLoop;
--         END IF;
--         
--         -- Check the available stock
--         SELECT quantity_available INTO availableQuantity
--         FROM Inventory
--         WHERE variant_id = variantID;

--         IF availableQuantity < orderQuantity THEN
--             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for one or more items';
--         ELSE
--             -- Reduce the stock
--             UPDATE Inventory
--             SET quantity_available = quantity_available - orderQuantity
--             WHERE variant_id = variantID;
--         END IF;
--     END LOOP;

--     CLOSE orderItems;
-- END$$

-- Update product price

CREATE PROCEDURE UpdateProductPrice(
    IN variantID INT,
    IN newPrice FLOAT
)
BEGIN
    -- Update the price of the product variant
    UPDATE Variant
    SET price = newPrice
    WHERE variant_id = variantID;
END$$

-- Add stock quantity

CREATE PROCEDURE AddStockQuantity(
    IN variantID INT,
    IN additionalQuantity INT
)
BEGIN
    -- Update the stock by adding the new quantity to the existing quantity
    UPDATE Inventory
    SET quantity_available = quantity_available + additionalQuantity
    WHERE variant_id = variantID;
END$$

-- no need of this function 
-- new implementation is done in the checkout procedure
-------------------------------------------------------------------------------------
-- CREATE PROCEDURE CheckoutOrder(IN orderID INT)
-- BEGIN
--     DECLARE variantID INT;
--     DECLARE orderQuantity INT;
--     DECLARE availableQuantity INT;
--     DECLARE done INT DEFAULT FALSE;
    
--     -- Cursor to loop through all items in the order
--     DECLARE orderItems CURSOR FOR
--     SELECT variant_id, quantity
--     FROM OrderItem
--     WHERE order_id = orderID;

--     -- Handler to exit the loop
--     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

--     OPEN orderItems;

--     orderLoop: LOOP
--         FETCH orderItems INTO variantID, orderQuantity;
        
--         IF done THEN
--             LEAVE orderLoop;
--         END IF;
        
--         -- Check the available stock
--         SELECT quantity_available INTO availableQuantity
--         FROM Inventory
--         WHERE variant_id = variantID;

--         IF availableQuantity < orderQuantity THEN
--             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for one or more items';
--         ELSE
--             -- Reduce the stock
--             UPDATE Inventory
--             SET quantity_available = quantity_available - orderQuantity
--             WHERE variant_id = variantID;
--         END IF;
--     END LOOP;

--     CLOSE orderItems;
-- END$$
---------------------------------------------------------------------------
CREATE PROCEDURE Get_Quarterly_Sales_By_Year (IN input_year INT)
BEGIN
    -- Create a temporary table for quarters
    CREATE TEMPORARY TABLE Quarters (
        quarter INT
    );

    -- Insert the quarters 1 to 4 into the temporary table
    INSERT INTO Quarters (quarter) VALUES (1), (2), (3), (4);

    -- Select the sales data for all quarters in the specified year
    SELECT 
        q.quarter,
        IFNULL(SUM(o.total_amount), 0) AS total_sales
    FROM 
        Quarters q
    LEFT JOIN 
        `Order` o ON QUARTER(o.purchased_time) = q.quarter 
                    AND YEAR(o.purchased_time) = input_year
    GROUP BY 
        q.quarter
    ORDER BY 
        q.quarter;

    -- Drop the temporary table
    DROP TEMPORARY TABLE Quarters;

END$$

DELIMITER ;

INSERT INTO `Role` (`role_name`, `description`) 
VALUES 
    ('Admin', 'Has full access to the system'),
    ('User', 'Registered customer with limited access'),
    ('Guest', 'Unregistered customer with minimal access');
    
-- INSERT INTO `User` (`first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `is_guest`, `role_id`, `created_at`, `last_login`)
--    ('John', 'Doe', 'john.doe@example.com', 'hashed_password_1', '1234567890', FALSE, 2, NOW(), NOW()),
--    ('Jane', 'Smith', 'jane.smith@example.com', 'hashed_password_2', '0987654321', FALSE, 2, NOW(), NULL),
--    ('Guest', 'User', 'guest.user@example.com', 'hashed_password_3', '1122334455', TRUE, 3, NOW(), NULL);
-- INSERT INTO `Order` (`customer_id`, `contact_email`, `contact_phone`, `delivery_method`, `payment_method`, `total_amount`, `order_status`, `purchased_time`)
-- VALUES 
--     (1, 'john.doe@example.com', '1234567890', 'delivery', 'card', 199.99, 'Completed', '2024-03-02'),
--     (2, 'jane.smith@example.com', '0987654321', 'store_pickup', 'Cash_on_delivery', 59.99, 'Shipped', '2024-09-04'),
--     (3, 'guest.user@example.com', '1122334455', 'delivery', 'Cash_on_delivery', 120.00, 'Processing', '2024-09-05');
-- use DataBaseProject;
-- CALL Get_Quarterly_Sales_By_Year(2024);


-- Insert categories
INSERT INTO `Category` (`category_name`, `description`) 
VALUES 
('Electronics', 'Consumer Electronics'),
('Toys', 'Children toys and games'),
('Mobile Phones', 'Smartphones and mobile devices'),
('Laptops', 'Portable computers'),
('Video Games', 'Gaming consoles and accessories'),
('Smart Home', 'Smart home appliances'),
('Audio Equipment', 'Speakers, headphones, and audio devices');

-- Insert products
INSERT INTO `Product` (`title`, `description`, `sku`, `weight`, `created_at`, `updated_at`) 
VALUES 
('Samsung Galaxy S21', 'Latest Samsung flagship smartphone', 'SGS21', 0.5, NOW(), NOW()),
('Apple iPhone 13', 'New Apple iPhone with improved features', 'AIP13', 0.6, NOW(), NOW()),
('Dell XPS 13', 'High-end ultraportable laptop', 'DXPS13', 1.2, NOW(), NOW()),
('Sony PlayStation 5', 'Next-generation gaming console', 'PS5', 4.5, NOW(), NOW()),
('Bose QuietComfort 45', 'Noise-cancelling over-ear headphones', 'BQC45', 0.3, NOW(), NOW()),
('Nintendo Switch', 'Hybrid gaming console', 'NSWITCH', 1.0, NOW(), NOW()),
('Amazon Echo Dot', 'Smart speaker with Alexa', 'AED4', 0.3, NOW(), NOW()),
('Logitech G502', 'Gaming mouse with customizable buttons', 'LG502', 0.2, NOW(), NOW()),
('Lego Star Wars', 'Building toy for kids', 'LSWARS', 2.5, NOW(), NOW()),
('Hot Wheels Track', 'Car track set for kids', 'HWT', 1.5, NOW(), NOW());

-- Insert product categories
INSERT INTO `Product_Category_Match` (`product_id`, `category_id`) 
VALUES 
(1, 3),  -- Samsung Galaxy S21 in Mobile Phones
(2, 3),  -- Apple iPhone 13 in Mobile Phones
(3, 4),  -- Dell XPS 13 in Laptops
(4, 5),  -- PlayStation 5 in Video Games
(5, 7),  -- Bose QC 45 in Audio Equipment
(6, 5),  -- Nintendo Switch in Video Games
(7, 6),  -- Amazon Echo Dot in Smart Home
(8, 5),  -- Logitech G502 in Video Games
(9, 2),  -- Lego Star Wars in Toys
(10, 2); -- Hot Wheels Track in Toys

-- Insert warehouse data
INSERT INTO `Warehouse` (`location`, `capacity`, `available_capacity`) 
VALUES 
('New York', 1000, 1000),
('Los Angeles', 800, 800);

-- Insert product variants
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`) 
VALUES 
(1, 'Samsung Galaxy S21 - 128GB', 'url_sgs21_128gb.jpg', 799.99, NOW(), NOW()),
(2, 'Apple iPhone 13 - 256GB', 'url_iphone13_256gb.jpg', 999.99, NOW(), NOW()),
(3, 'Dell XPS 13 - 16GB RAM', 'url_dellxps13_16gb.jpg', 1199.99, NOW(), NOW()),
(4, 'PlayStation 5 - Standard Edition', 'url_ps5_standard.jpg', 499.99, NOW(), NOW()),
(5, 'Bose QC 45 - Black', 'url_boseqc45_black.jpg', 329.99, NOW(), NOW()),
(6, 'Nintendo Switch - Neon Red/Blue', 'url_switch_neon.jpg', 299.99, NOW(), NOW()),
(7, 'Amazon Echo Dot 4th Gen', 'url_echo_dot4.jpg', 49.99, NOW(), NOW()),
(8, 'Logitech G502 Hero', 'url_g502.jpg', 49.99, NOW(), NOW()),
(9, 'Lego Star Wars Set', 'url_lego_star_wars.jpg', 149.99, NOW(), NOW()),
(10, 'Hot Wheels Track Builder', 'url_hotwheels.jpg', 29.99, NOW(), NOW());

-- Insert inventory
INSERT INTO `Inventory` (`warehouse_id`, `variant_id`, `quantity_available`, `last_updated`) 
VALUES 
(1, 1, 100, NOW()),
(1, 2, 50, NOW()),
(1, 3, 30, NOW()),
(2, 4, 200, NOW()),
(2, 5, 75, NOW()),
(1, 6, 100, NOW()),
(2, 7, 300, NOW()),
(1, 8, 150, NOW()),
(2, 9, 200, NOW()),
(1, 10, 500, NOW());


-- Insert Parent-Category relationships
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`) 
VALUES
(3, 1),  -- Mobile Phones under Electronics
(4, 1),  -- Laptops under Electronics
(5, 1),  -- Video Games under Electronics
(7, 1);  -- Audio Equipment under Electronics


INSERT INTO `DeliveryLocation` (`location_name`, `location_type`, `with_stock_delivery_days`, `without_stock_delivery_days`)
VALUES
('New York', 'city', 2, 7),
('Los Angeles', 'city', 3, 8),
('Store #1', 'store', 1, NULL),
('Store #2', 'store', 1, NULL);


-- Insert roles
INSERT INTO `Role` (`role_name`, `description`) 
VALUES
('Admin', 'Administrator role'),
('User', 'Regular user'),
('Guest', 'Guest user');

-- Insert users
INSERT INTO `User` (`first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `delivery_location_id`, `is_guest`, `role_id`, `created_at`)
VALUES 
('John', 'Doe', 'john@example.com', SHA2('password123', 256), '1234567890', 1, 0, 2, NOW()),
('Jane', 'Smith', 'jane@example.com', SHA2('password456', 256), '0987654321', 2, 0, 2, NOW());

-- Insert cart items for users
INSERT INTO `Cart` (`user_id`, `variant_id`, `quantity`) 
VALUES
(1, 1, 2),  -- John has 2 Samsung Galaxy S21 in his cart
(2, 4, 1);  -- Jane has 1 PS5 in her cart


-- Insert orders
INSERT INTO `Order` (`customer_id`, `contact_email`, `contact_phone`, `delivery_method`, `delivery_location_id`, `payment_method`, `total_amount`, `order_status`, `purchased_time`, `created_at`)
VALUES
(1, 'john@example.com', '1234567890', 'delivery', 1, 'card', 1599.98, 'Shipped', NOW(), NOW()),
(2, 'jane@example.com', '0987654321', 'store_pickup', 3, 'cash_on_delivery', 499.99, 'Completed', NOW(), NOW());

-- Insert order items
INSERT INTO `OrderItem` (`order_id`, `variant_id`, `discount`, `quantity`, `price`)
VALUES
(1, 1, 0, 2, 799.99),  -- John ordered 2 Samsung Galaxy S21
(2, 4, 0, 1, 499.99);  -- Jane ordered 1 PS5


-- Insert custom attributes for products
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) 
VALUES
(1, 'Color'),
(1, 'Storage'),
(2, 'Color'),
(2, 'Storage');

-- Insert custom attribute values for variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) 
VALUES
(1, 1, 'Black'),  -- Samsung Galaxy S21 is Black
(1, 2, '128GB'),  -- Samsung Galaxy S21 has 128GB storage
(2, 1, 'Blue'),  -- iPhone 13 is Blue
(2, 2, '256GB');  -- iPhone 13 has 256GB storage


INSERT INTO `DeliveryEstimate` (`delivery_method_id`, `delivery_location_id`, `base_delivery_days`)
VALUES
(1, 1, 2),  -- Store Pickup for New York takes 2 days
(1, 2, 3);  -- Store Pickup for Los Angeles takes 3 days


UPDATE `Variant` 
SET interested = interested + 5
WHERE `variant_id` = 1;  -- 5 people are interested in Samsung Galaxy S21



USE `ecommercedatabase`;
DROP procedure IF EXISTS `ShowCartofUser`;

DELIMITER $$
USE `ecommercedatabase`$$
CREATE PROCEDURE `ShowCartofUser` (
	IN p_user_id INT
)
BEGIN
	select *
    from variant 
    where variant_id in (
    select variant_id from cart where user_id = p_user_id
    );
END$$

DELIMITER ;

DELIMITER //

-- Trigger for INSERT and UPDATE on OrderItem
CREATE TRIGGER update_total_amount_after_insert_update
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
  DECLARE total FLOAT;
  SELECT SUM((price - discount) * quantity) INTO total
  FROM OrderItem
  WHERE order_id = NEW.order_id;
  
  UPDATE `Order`
  SET total_amount = total
  WHERE order_id = NEW.order_id;
END //

CREATE TRIGGER update_total_amount_after_update
AFTER UPDATE ON OrderItem
FOR EACH ROW
BEGIN
  DECLARE total FLOAT;
  SELECT SUM((price - discount) * quantity) INTO total
  FROM OrderItem
  WHERE order_id = NEW.order_id;
  
  UPDATE `Order`
  SET total_amount = total
  WHERE order_id = NEW.order_id;
END //

-- Trigger for DELETE on OrderItem
CREATE TRIGGER update_total_amount_after_delete
AFTER DELETE ON OrderItem
FOR EACH ROW
BEGIN
  DECLARE total FLOAT;
  SELECT SUM((price - discount) * quantity) INTO total
  FROM OrderItem
  WHERE order_id = OLD.order_id;
  
  UPDATE `Order`
  SET total_amount = total
  WHERE order_id = OLD.order_id;
END //

DELIMITER ;


USE `ecommercedatabase`;
DROP procedure IF EXISTS `Checkout`;

DELIMITER $$
USE `ecommercedatabase`$$
CREATE PROCEDURE `Checkout` (IN userID int, IN order_items JSON)
BEGIN
	DECLARE orderID INT;
    DECLARE i INT DEFAULT 0;
    DECLARE array_length INT;
    DECLARE variantID INT;
    DECLARE availableQuantity INT;
	set autocommit = 0;
    start transaction;
    
    INSERT INTO `order` (customer_id, created_at,order_status) VALUES (userID , NOW(), 'Pending');
    
	
    SET orderID = LAST_INSERT_ID();
    
    SET array_length = JSON_LENGTH(order_items);
    WHILE i < array_length DO
    
		SET variantID = JSON_UNQUOTE(JSON_EXTRACT(order_items, CONCAT('$[', counter, '].variant_id')));
        select quantity_available into availableQuantity from Inventory where variant_id = variantID;
        -- set desiredQuantity = 0;
        -- select quantity into desiredQuantity from cart where user_id = userID and variant_id = variantID;
        
        if (
        SELECT EXISTS(
        SELECT 1 FROM cart
        WHERE user_id = userID and 
        variant_id = variantID and 
        quantity <= avaliableQuantity) ) then
			DELETE FROM cart 
            WHERE user_id = userID AND variant_id = variantID;
            INSERT INTO orderitem (order_id, variant_id, quantity) 
            VALUES (orderID, variantID, old.quantity);
            update Inventory 
            set quantity_available = quantity_available - old.quantity
            where variant_id = variantID;
        else
			select variantID,desiredQuantity as desiredQuantity , 'item not in the cart | not enough stock | wrong variant_id' ;
			ROLLBACK;
		end if;
        SET i = i + 1;
    END WHILE;
    
    commit;
    set autocommit = 1;
END $$

DELIMITER ;



delimiter $$
drop event if exists `30minutes_delete_pending_orders`;
create event `30minutes_delete_pending_orders` 
on schedule
	every 30 minute
do BEGIN
    start transaction;
    -- Update inventory for the deleted orders
    UPDATE Inventory i
    JOIN OrderItem oi ON i.variant_id = oi.variant_id
    JOIN `Order` o ON oi.order_id = o.order_id
    SET i.quantity_available = i.quantity_available + oi.quantity
    WHERE o.order_status = 'Pending' AND o.updated_at + INTERVAL 30 MINUTE <= CURRENT_TIMESTAMP();
    -- Delete orders that are pending and older than 30 minutes
    DELETE FROM `Order`
    WHERE order_status = 'Pending' AND updated_at + INTERVAL 30 MINUTE <= CURRENT_TIMESTAMP();
    commit;
END$$
-- need an index cuz this a background process 
delimiter ;

CREATE INDEX idx_order_status_updated_at ON `Order` (order_status, updated_at);
CREATE INDEX idx_order_item_order_id ON OrderItem (order_id);
CREATE INDEX idx_inventory_variant_id ON Inventory (variant_id);