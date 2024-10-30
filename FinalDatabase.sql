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
  `default_price` FLOAT,
  `default_image` VARCHAR(255),
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
  `last_name` VARCHAR(255),
  `email` VARCHAR(255) unique,
  `password_hash` VARCHAR(255),
  `phone_number` VARCHAR(255),
  `delivery_location_id` INT,
  `address` VARCHAR(255),
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
  `user_id` INT not null,
  `variant_id` INT not null,
  `quantity` INT not null,
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
  `customer_name` VARCHAR(255),
  `contact_email` VARCHAR(255),
  `contact_phone` VARCHAR(255),
  `delivery_method` ENUM('store_pickup', 'delivery') NOT NULL,
  `delivery_location_id` INT,
  `delivery_address` VARCHAR(255),
  `payment_method` ENUM('cash_on_delivery', 'card'),
  `total_amount` FLOAT,
  `order_status` ENUM('Processing', 'Confirmed', 'Shipped', 'Completed', 'Failed'),
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



DELIMITER $$

CREATE PROCEDURE GetProductDetails(IN product_id INT)
BEGIN
    SELECT 
        p.product_id AS product_id,
        p.title AS product_name,
        p.description AS product_description,
        p.default_price AS price,
        p.default_image AS image_url,
        p.sku,
        p.weight,
        JSON_ARRAYAGG(c.category_name) AS categories,
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'variant_id', dv.variant_id,
                    'variant_name', dv.name,
                    'price', dv.price,
                    'image_url', dv.image_url,
                    'quantity_available', dv.quantity_available,
                    'attributes', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'attribute_name', ca.attribute_name,
                                'attribute_value', cav.attribute_value
                            )
                        )
                        FROM Custom_Attribute ca
                        JOIN Custom_Attribute_Value cav ON ca.attribute_id = cav.attribute_id
                        WHERE cav.variant_id = dv.variant_id
                    )
                )
            )
            FROM (
                SELECT DISTINCT v.*, i.quantity_available
                FROM Variant v
                LEFT JOIN Inventory i ON v.variant_id = i.variant_id 
                WHERE v.product_id = p.product_id
            ) AS dv
        ) AS variants
    FROM Product p
    JOIN Product_Category_Match pcm ON p.product_id = pcm.product_id
    JOIN Category c ON pcm.category_id = c.category_id
    WHERE p.product_id = product_id
    GROUP BY p.product_id
    ORDER BY p.title;
END$$


CREATE PROCEDURE move_cart_to_order(IN p_user_id INT, OUT p_order_id INT)
BEGIN
    DECLARE v_total_amount FLOAT DEFAULT 0;
    DECLARE v_contact_email VARCHAR(255);
    DECLARE v_contact_phone VARCHAR(255);
    DECLARE v_delivery_address VARCHAR(255);
    DECLARE v_first_name VARCHAR(255);
    DECLARE v_last_name VARCHAR(255);
    DECLARE v_customer_name VARCHAR(255);

    -- Step 1: Retrieve the user's email, phone number, address, first name, and last name from the User table
    SELECT email, phone_number, address, first_name, last_name
    INTO v_contact_email, v_contact_phone, v_delivery_address, v_first_name, v_last_name
    FROM User
    WHERE user_id = p_user_id;

    -- Step 2: Concatenate the first and last names to form customer_name
    SET v_customer_name = CONCAT(v_first_name, ' ', v_last_name);

    -- Step 3: Create a new order with the retrieved contact information, delivery address, and customer_name
    INSERT INTO `Order` (customer_id, contact_email, contact_phone, delivery_address, customer_name, order_status, purchased_time, created_at, updated_at)
    VALUES (p_user_id, v_contact_email, v_contact_phone, v_delivery_address, v_customer_name, 'Processing', NOW(), NOW(), NOW());

    -- Step 4: Get the order_id of the newly created order
    SET p_order_id = LAST_INSERT_ID();

    -- Step 4: Move items from Cart to OrderItem and calculate total amount
    INSERT INTO OrderItem (order_id, variant_id, quantity, price)
    SELECT p_order_id, c.variant_id, c.quantity, v.price
    FROM Cart c
    JOIN Variant v ON c.variant_id = v.variant_id
    WHERE c.user_id = p_user_id;

    -- Step 5: Calculate total amount
    SELECT SUM(oi.price * oi.quantity) INTO v_total_amount
    FROM OrderItem oi
    WHERE oi.order_id = p_order_id;

    -- Step 6: Update the total_amount in the Order table
    UPDATE `Order`
    SET total_amount = v_total_amount
    WHERE order_id = p_order_id;

    -- Step 7: Clear the Cart for the user
    DELETE FROM Cart WHERE user_id = p_user_id;
END$$


CREATE TRIGGER update_inventory_and_calculate_total
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE v_total_amount FLOAT DEFAULT 0;

    -- Step 1: Decrement the quantity in Inventory, even if it results in negative stock
    UPDATE Inventory
    SET quantity_available = quantity_available - NEW.quantity
    WHERE variant_id = NEW.variant_id;

    -- Step 2: Recalculate total_amount in the Order table
    SELECT SUM(price * quantity) INTO v_total_amount
    FROM OrderItem
    WHERE order_id = NEW.order_id;

    -- Step 3: Update the total_amount in the Order table
    UPDATE `Order`
    SET total_amount = v_total_amount
    WHERE order_id = NEW.order_id;
END$$


CREATE PROCEDURE complete_checkout(
    IN orderId INT,
    IN userId INT,
    IN name VARCHAR(255),
    IN phone VARCHAR(255),
    IN email VARCHAR(255),
    IN address VARCHAR(255),
    IN deliveryMethod ENUM('store_pickup', 'delivery'),
    IN deliveryLocationId INT,
    IN paymentMethod ENUM('cash_on_delivery', 'card')
)
BEGIN
    -- Declare variables at the beginning of the procedure
    DECLARE v_total_amount FLOAT DEFAULT 0;
    DECLARE v_delivery_estimate INT;
    DECLARE v_with_stock_delivery_days INT;
    DECLARE v_without_stock_delivery_days INT;
    DECLARE v_item_quantity INT;
    DECLARE v_inventory_quantity INT;
    DECLARE done INT DEFAULT FALSE;

    -- Declare cursor for order items
    DECLARE order_item_cursor CURSOR FOR
        SELECT quantity, variant_id
        FROM OrderItem
        WHERE order_id = orderId;

    -- Declare continue handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Check if the user is the owner of the order
    IF NOT EXISTS (
        SELECT 1
        FROM `Order`
        WHERE order_id = orderId AND customer_id = userId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User does not have permission to complete this order';
    END IF;

    -- Step 1: Retrieve the delivery location details
    SELECT with_stock_delivery_days, without_stock_delivery_days
    INTO v_with_stock_delivery_days, v_without_stock_delivery_days
    FROM DeliveryLocation
    WHERE delivery_location_id = deliveryLocationId;

    -- Initialize the delivery estimate
    SET v_delivery_estimate = v_with_stock_delivery_days;

    -- Open the cursor
    OPEN order_item_cursor;

    -- Loop through order items
    read_loop: LOOP
        FETCH order_item_cursor INTO v_item_quantity, v_inventory_quantity;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Step 2: Check if item quantity exceeds inventory stock
        SELECT quantity_available INTO v_inventory_quantity
        FROM Inventory
        WHERE variant_id = v_item_quantity;

        IF v_item_quantity > v_inventory_quantity THEN
            SET v_delivery_estimate = v_without_stock_delivery_days;
        END IF;
    END LOOP;

    -- Close the cursor
    CLOSE order_item_cursor;

    -- Step 3: Update the Order with provided details and estimated delivery time
    UPDATE `Order`
    SET contact_email = email,
        contact_phone = phone,
        delivery_address = address,
        customer_name = name,
        delivery_method = deliveryMethod,
        delivery_location_id = deliveryLocationId,
        payment_method = paymentMethod,
        delivery_estimate = v_delivery_estimate,
        order_status = 'Confirmed',  -- Updated status to 'Confirmed'
        updated_at = NOW()
    WHERE order_id = orderId;
END$$


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
        SET quantity = p_quantity
        WHERE user_id = p_user_id AND variant_id = p_variant_id;
    ELSE
        INSERT INTO Cart (user_id, variant_id, quantity)
        VALUES (p_user_id, p_variant_id, p_quantity);
    END IF;
END;

-- Show cart of user

DROP PROCEDURE IF EXISTS `ShowCartofUser`;
CREATE PROCEDURE `ShowCartofUser` (
    IN p_user_id INT
)
BEGIN
    SELECT 
        v.variant_id,
        v.name as variant_name,
        v.price,
        v.image_url,
        c.quantity,
        i.quantity_available,
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'attribute_name', a.attribute_name,
                    'attribute_value', va.attribute_value
                )
            )
            FROM custom_attribute_value va
            JOIN custom_attribute a ON va.attribute_id = a.attribute_id
            WHERE va.variant_id = v.variant_id
        ) AS attributes
    FROM variant v
    JOIN cart c ON v.variant_id = c.variant_id
    JOIN inventory i ON v.variant_id = i.variant_id
    WHERE c.user_id = p_user_id;
END$$

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

CREATE PROCEDURE CheckoutOrder(IN orderID INT)
BEGIN
    DECLARE variantID INT;
    DECLARE orderQuantity INT;
    DECLARE availableQuantity INT;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor to loop through all items in the order
    DECLARE orderItems CURSOR FOR
    SELECT variant_id, quantity
    FROM OrderItem
    WHERE order_id = orderID;

    -- Handler to exit the loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN orderItems;

    orderLoop: LOOP
        FETCH orderItems INTO variantID, orderQuantity;
        
        IF done THEN
            LEAVE orderLoop;
        END IF;
        
        -- Check the available stock
        SELECT quantity_available INTO availableQuantity
        FROM Inventory
        WHERE variant_id = variantID;

        IF availableQuantity < orderQuantity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for one or more items';
        ELSE
            -- Reduce the stock
            UPDATE Inventory
            SET quantity_available = quantity_available - orderQuantity
            WHERE variant_id = variantID;
        END IF;
    END LOOP;

    CLOSE orderItems;
END$$

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

-- Insert roles
INSERT INTO `Role` (`role_name`, `description`) 
VALUES
('Admin', 'Administrator role'),
('User', 'Regular user'),
('Guest', 'Guest user');

-- Insert Warehouse Data
INSERT INTO `Warehouse` (`location`, `capacity`, `available_capacity`) 
VALUES 
('New York Warehouse', 10000, 10000),
('Los Angeles Warehouse', 8000, 8000);

INSERT INTO `DeliveryLocation` (`location_name`, `location_type`, `with_stock_delivery_days`, `without_stock_delivery_days`)
VALUES
('Texas', 'store', 1, 3),
('New York', 'store', 3, 5),
('Texas', 'city', 5, 8), -- Main city in Texas
('New York', 'city', 7, 10),
('Los Angeles', 'city', 7, 10),
('California', 'city', 7, 10);

-- Insert users
INSERT INTO `User` (`first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `delivery_location_id`, `is_guest`, `role_id`, `created_at`)
VALUES 
('Admin', 'C', 'admin@c.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '1234567890', 1, 0, 1, NOW()),
('Jane', 'Smith', 'jane@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('John', 'Doe', 'john@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('Nick', 'Noah', 'nick@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('Pilip', 'Man', 'pilip@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW());

-- Insert Main Categories
INSERT INTO `Category` (`category_name`, `description`) 
VALUES 
('Computers', 'Desktops, Laptops, and Computer Accessories'), -- ID 1
('Mobile Phones', 'Smartphones and Mobile Accessories'),       -- ID 2
('Speakers', 'Audio speakers and sound systems'),             -- ID 3
('Toys', 'Children\'s toys and games');                       -- ID 4

-- Insert Sub-Categories
INSERT INTO `Category` (`category_name`, `description`) 
VALUES 
('Apple', 'Apple products'),                         -- ID 5
('Samsung', 'Samsung products'),                     -- ID 6
('Lenovo', 'Lenovo products'),                       -- ID 7
('HP', 'HP products'),                               -- ID 8
('OnePlus', 'OnePlus smartphones'),                  -- ID 9
('JBL', 'JBL Speakers'),                             -- ID 10
('Sony', 'Sony Speakers'),                           -- ID 11
('Bose', 'Bose Speakers'),                           -- ID 12
('Building Blocks', 'Building and construction toys'),-- ID 13
('Action Figures', 'Action figure toys'),            -- ID 14
('Board Games', 'Board games for all ages'),         -- ID 15
('Puzzles', 'Puzzles and brain teasers'),            -- ID 16
('Outdoor Toys', 'Toys for outdoor play'),           -- ID 17
('Toy Vehicles', 'Toy cars, trucks, and other vehicles'), -- ID 18
('Musical Toys', 'Musical instruments for kids'),    -- ID 19
('Educational Toys', 'Learning and educational toys'),-- ID 20
('Trading Card Games', 'Collectible card games');    -- ID 21

-- Parent Category Relationships
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`) 
VALUES
(5, 1),  -- Apple under Computers
(5, 2),  -- Apple under Mobile Phones
(6, 2),  -- Samsung under Mobile Phones
(7, 1),  -- Lenovo under Computers
(8, 1),  -- HP under Computers
(9, 2),  -- OnePlus under Mobile Phones
(10, 3), -- JBL under Speakers
(11, 3), -- Sony under Speakers
(12, 3), -- Bose under Speakers
(13, 4), -- Building Blocks under Toys
(14, 4), -- Action Figures under Toys
(15, 4), -- Board Games under Toys
(16, 4), -- Puzzles under Toys
(17, 4), -- Outdoor Toys under Toys
(18, 4), -- Toy Vehicles under Toys
(19, 4), -- Musical Toys under Toys
(20, 4), -- Educational Toys under Toys
(21, 4); -- Trading Card Games under Toys

-- Insert Products
INSERT INTO `Product` (`title`, `description`, `sku`, `weight`, `default_price`, `default_image`, `created_at`, `updated_at`)
VALUES 
-- Tech Products
('Dell XPS 13 Laptop', 'A compact and powerful laptop', 'SKU001', 1.2, 999.99, 'https://www.asifcomputers.com/wp-content/uploads/2022/08/DELL-XPS-PLUS-01-min.jpg', NOW(), NOW()),       -- ID 1
('Apple MacBook Pro', 'High performance laptop from Apple', 'SKU002', 1.4, 1299.99, 'https://images.kabum.com.br/produtos/fotos/sync_mirakl/287136/Macbook-Pro-M1-256GB-A2338-Space-Gray_1660237256_gg.jpg', NOW(), NOW()), -- ID 2
('HP Pavilion Desktop', 'A reliable desktop computer', 'SKU003', 7.5, 799.99, 'https://www.bhphotovideo.com/images/images2500x2500/HP_Hewlett_Packard_h3y80aa_aba_Pavilion_p7_1430_Desktop_PC_891243.jpg', NOW(), NOW()), -- ID 3
('Lenovo ThinkPad Laptop', 'Durable business laptop', 'SKU004', 1.5, 1099.99, 'https://media.ldlc.com/r1600/ld/products/00/06/05/14/LD0006051479_0006090475_0006142661_0006142720.jpg', NOW(), NOW()),   -- ID 4
('Samsung Galaxy S21 Smartphone', 'Latest Samsung smartphone', 'SKU005', 0.169, 799.99, 'https://i5.walmartimages.com/asr/53db60c3-1e00-49f2-847c-5eea66169943.1e3f214c752760f0cee394257b237126.png?odnHeight=612&odnWidth=612&odnBg=FFFFFF', NOW(), NOW()), -- ID 5
('Apple iPhone 13', 'Latest iPhone model', 'SKU006', 0.174, 999.99, 'https://a.allegroimg.com/s1024/0c33fb/d66398b04e4eb5b9fcbf702aa2d4', NOW(), NOW()),                   -- ID 6
('Logitech Wireless Mouse', 'Ergonomic wireless mouse', 'SKU007', 0.1, 29.99, 'https://computersolutionranchi.com/wp-content/uploads/2020/05/Logitech-M171-wireless-mouse-768x768.jpg', NOW(), NOW()),    -- ID 7
('Microsoft Surface Pro', 'Versatile 2-in-1 laptop', 'SKU008', 0.77, 899.99, 'https://d1eh9yux7w8iql.cloudfront.net/product_images/486011_dd997560-a79d-4569-9aaf-c24fbf90bd12.jpg', NOW(), NOW()),        -- ID 8
('Asus ZenBook Laptop', 'Slim and stylish laptop', 'SKU009', 1.3, 1099.99, 'https://www.asus.com/media/global/gallery/dZipgASPflUPV6LH_setting_fff_1_90_end_1000.png', NOW(), NOW()),         -- ID 9
('Canon EOS M50 Camera', 'Mirrorless digital camera', 'SKU010', 0.387, 599.99, 'https://th.bing.com/th/id/OIP.Ud8EP-qepv4QXcubnZ_FTwAAAA?rs=1&pid=ImgDetMain', NOW(), NOW()),    -- ID 10
('Bose QuietComfort Headphones', 'Noise-cancelling headphones', 'SKU011', 0.25, 299.99, 'https://th.bing.com/th/id/OIP.1pfrYCKBRdZRYcPJ0y0IdAAAAA?rs=1&pid=ImgDetMain', NOW(), NOW()), -- ID 11
('Sony WH-1000XM4 Headphones', 'Premium noise-cancelling headphones', 'SKU012', 0.254, 349.99, 'https://www.bhphotovideo.com/images/images2500x2500/sony_wh1000xm4_b_wh_1000xm4_wireless_noise_canceling_over_ear_1582549.jpg', NOW(), NOW()), -- ID 12
('Google Pixel 6 Smartphone', 'Google\'s latest smartphone', 'SKU013', 0.178, 699.99, 'https://m.media-amazon.com/images/I/71AFAa4sgbL._AC_SL1500_.jpg', NOW(), NOW()),   -- ID 13
('Anker PowerCore Portable Charger', 'High-capacity portable charger', 'SKU014', 0.355, 49.99, 'https://flashdealfinder.com/wp-content/uploads/2020/01/Anker-Charging-Accessories.jpg', NOW(), NOW()), -- ID 14
('Nintendo Switch Console', 'Hybrid gaming console', 'SKU015', 0.88, 299.99, 'https://i5.walmartimages.com/asr/41b40bbc-8c9c-4a1d-88ee-b0be32f21922.04219b45da8d33d3c3d9c3b2e8c7cfa1.jpeg', NOW(), NOW()),   -- ID 15
('Apple iPad Air', 'Lightweight and powerful tablet', 'SKU016', 0.46, 599.99, 'https://www.wearesync.co.uk/wp-content/uploads/2020/09/ipad-air-rose-gold.jpg', NOW(), NOW()),          -- ID 16
('Fitbit Versa 3 Smartwatch', 'Fitness smartwatch', 'SKU017', 0.039, 229.95, 'https://www.pointekonline.com/wp-content/uploads/2021/08/fitbit-versa-3.png', NOW(), NOW()),      -- ID 17
('GoPro HERO9 Camera', 'Action camera with 5K video', 'SKU018', 0.158, 399.99, 'https://pic.clubic.com/v1/images/1845895/raw', NOW(), NOW()),      -- ID 18
('Samsung Galaxy Tab S7', 'High-end Android tablet', 'SKU019', 0.498, 649.99, 'https://th.bing.com/th/id/R.3fc3bb5fb0e49cc7f8d3a0ac407f275a?rik=gkjqiUAvQSI1cw&pid=ImgRaw&r=0', NOW(), NOW()),     -- ID 19
('Amazon Echo Dot', 'Smart speaker with Alexa', 'SKU020', 0.3, 49.99, 'https://m.media-amazon.com/images/G/35/kindle/journeys/Mvq9IW0GZYhQQxsK3yOI2P3mAwEpOFjw7I006Eo32BTY3D/YTIwMTU1Y2It._CB608384139_.jpg', NOW(), NOW()),                  -- ID 20
-- Toy Products
('LEGO Star Wars Millennium Falcon', 'Iconic LEGO Star Wars set', 'SKU021', 1.5, 159.99, 'https://s.ecrater.com/stores/401629/5a30566e5089c_401629b.jpg', NOW(), NOW()), -- ID 21
('Barbie Dreamhouse', 'Barbie\'s ultimate dream home', 'SKU022', 10.0, 199.99, 'https://www.tradeinn.com/f/14017/140176932/mattel-barbie-dreamhouse-2023.jpg', NOW(), NOW()),                -- ID 22
('Nerf N-Strike Elite Blaster', 'High-performance Nerf blaster', 'SKU023', 0.7, 49.99, 'https://i5.walmartimages.com/asr/2e82fd2b-c8ed-4683-979e-afef40f9857b_1.65997a515fcab69787766968c3369811.jpeg', NOW(), NOW()),       -- ID 23
('Hot Wheels 20 Car Gift Pack', 'Set of 20 Hot Wheels cars', 'SKU024', 0.5, 19.99, 'https://toyworld.com.my/wp-content/uploads/2018/11/16015253905f75568e5a6c4.jpeg', NOW(), NOW()),           -- ID 24
('Monopoly Classic Board Game', 'Family board game classic', 'SKU025', 1.0, 19.99, 'https://image.smythstoys.com/zoom/159143_3.jpg', NOW(), NOW()),             -- ID 25
('Rubik\'s Cube', 'Classic 3x3 Rubik\'s Cube', 'SKU026', 0.2, 9.99, 'https://d3qyu496o2hwvq.cloudfront.net/wp-content/uploads/2019/07/FINALRUBIK-copy.jpg', NOW(), NOW()),                                  -- ID 26
('Jenga Classic Game', 'Tower stacking game', 'SKU027', 1.2, 14.99, 'https://cdn.playtherapysupply.com/img/f/82723fc0c798.jpg', NOW(), NOW()),                               -- ID 27
('UNO Card Game', 'Popular card game', 'SKU028', 0.3, 5.99, 'https://www.avalankids.com.au/assets/full/W2087.jpg?20200707033535', NOW(), NOW()),                                       -- ID 28
('Play-Doh Modeling Compound', 'Colorful modeling clay', 'SKU029', 1.0, 7.99, 'https://images-na.ssl-images-amazon.com/images/I/81tEFtVFzBL.jpg', NOW(), NOW()),                          -- ID 29
('Crayola Ultimate Crayon Collection', '152 crayons in storage tub', 'SKU030', 1.5, 14.99, 'https://shop.crayola.com/dw/image/v2/AALB_PRD/on/demandware.static/-/Sites-crayola-storefront/default/dw9d1e23c3/images/52-0030-2.jpg?sw=1200&sh=1500&sm=fit&sfrm=jpg', NOW(), NOW()),      -- ID 30
('Melissa & Doug Wooden Blocks', 'Wooden building blocks set', 'SKU031', 2.0, 19.99, 'https://cdn.shopify.com/s/files/1/0472/7118/2499/products/SBU-39077567-Melissa-_-Doug-100-Wooden-Blocks-Set-FRONT.png?v=1646115534', NOW(), NOW()),              -- ID 31
('Transformers Optimus Prime Figure', 'Action figure of Optimus Prime', 'SKU032', 0.6, 29.99, 'https://m.media-amazon.com/images/I/71uRENNFM4L.jpg', NOW(), NOW()),     -- ID 32
('Ravensburger Disney Puzzle', '1000 piece Disney puzzle', 'SKU033', 0.8, 19.99, 'https://th.bing.com/th/id/R.154e6815051545a5e0e7ac96175d661a?rik=iNXWvk8xU9UlFQ&pid=ImgRaw&r=0', NOW(), NOW()),                  -- ID 33
('Pokemon Trading Card Game', 'Pokemon TCG Battle Academy', 'SKU034', 1.0, 19.99, 'https://morethanmeeples.com.au/product/pokemon-battle-academy-board-game/pokemon-battle-academy-board-game-01.jpg', NOW(), NOW()),                   -- ID 34
('Fisher-Price Laugh & Learn Smart Stages Chair', 'Interactive learning chair', 'SKU035', 2.5, 39.99, 'https://toysdirect.ie/cdn/shop/products/fisher-price-laugh-learn-smart-stages-chair-704174_1024x1024@2x.jpg?v=1666842488', NOW(), NOW()), -- ID 35
('Paw Patrol Ultimate Rescue Fire Truck', 'Paw Patrol fire truck toy', 'SKU036', 3.0, 59.99, 'https://www.costco.co.uk/medias/sys_master/images/hfb/h73/46203167899678.jpg', NOW(), NOW()), -- ID 36
('Baby Einstein Take Along Tunes', 'Musical toy for infants', 'SKU037', 0.2, 9.99, 'https://brands.amazrock.com/wp-content/uploads/2018/08/Baby-Einstein-Take-Along-Tunes-Musical-Toy-Ages-3-months-Plus.jpg', NOW(), NOW()),           -- ID 37
('Little Tikes Cozy Coupe', 'Classic ride-on car', 'SKU038', 8.0, 54.99, 'https://cdn.ecommercedns.uk/files/7/234067/1/11496051/little-tikes-cozy-coupe-30th-anniversary-toymaster-ballina-3.jpg', NOW(), NOW()),                             -- ID 38
('Hape Pound & Tap Bench with Slide Out Xylophone', 'Musical instrument toy', 'SKU039', 1.2, 29.99, 'https://i.pinimg.com/originals/ee/03/5d/ee035dfc02ef4777f807bd3163dd98f5.jpg', NOW(), NOW()), -- ID 39
('Magic: The Gathering Starter Kit', 'MTG card game starter set', 'SKU040', 0.5, 14.99, 'https://th.bing.com/th/id/OIP.ADD2WhXiH4dB8WNq6EuyoAHaHa?rs=1&pid=ImgDetMain', NOW(), NOW());         -- ID 40

-- Map Products to Categories
INSERT INTO `Product_Category_Match` (`product_id`, `category_id`)
VALUES
-- Tech Products
(1, 1),   -- Dell XPS 13 Laptop under Computers
(2, 1),   -- MacBook Pro under Computers
(2, 5),   -- MacBook Pro under Apple
(3, 1),   -- HP Pavilion Desktop under Computers
(3, 8),   -- HP Pavilion Desktop under HP
(4, 1),   -- Lenovo ThinkPad under Computers
(4, 7),   -- Lenovo ThinkPad under Lenovo
(5, 2),   -- Samsung Galaxy S21 under Mobile Phones
(5, 6),   -- Samsung Galaxy S21 under Samsung
(6, 2),   -- iPhone 13 under Mobile Phones
(6, 5),   -- iPhone 13 under Apple
(7, 1),   -- Logitech Wireless Mouse under Computers
(8, 1),   -- Microsoft Surface Pro under Computers
(9, 1),   -- Asus ZenBook Laptop under Computers
(10, 1),  -- Canon EOS M50 under Computers
(11, 3),  -- Bose Headphones under Speakers
(11, 12), -- Bose Headphones under Bose
(12, 3),  -- Sony Headphones under Speakers
(12, 11), -- Sony Headphones under Sony
(13, 2),  -- Google Pixel 6 under Mobile Phones
(14, 1),  -- Anker PowerCore under Computers
(15, 1),  -- Nintendo Switch under Computers
(16, 1),  -- Apple iPad Air under Computers
(17, 2),  -- Fitbit Versa 3 under Mobile Phones
(18, 1),  -- GoPro HERO9 under Computers
(19, 1),  -- Samsung Galaxy Tab S7 under Computers
(20, 3),  -- Amazon Echo Dot under Speakers
-- Toy Products
(21, 13), -- LEGO under Building Blocks
(22, 14), -- Barbie Dreamhouse under Action Figures
(23, 14), -- Nerf Blaster under Action Figures
(24, 18), -- Hot Wheels under Toy Vehicles
(25, 15), -- Monopoly under Board Games
(26, 16), -- Rubik's Cube under Puzzles
(27, 15), -- Jenga under Board Games
(28, 15), -- UNO under Board Games
(29, 13), -- Play-Doh under Building Blocks
(30, 13), -- Crayola Crayons under Building Blocks
(31, 13), -- Wooden Blocks under Building Blocks
(32, 14), -- Transformers under Action Figures
(33, 16), -- Disney Puzzle under Puzzles
(34, 21), -- Pokemon TCG under Trading Card Games
(35, 20), -- Fisher-Price Chair under Educational Toys
(36, 18), -- Paw Patrol under Toy Vehicles
(37, 19), -- Baby Einstein under Musical Toys
(38, 17), -- Cozy Coupe under Outdoor Toys
(39, 19), -- Hape Xylophone under Musical Toys
(40, 21); -- Magic: The Gathering under Trading Card Games

-- Insert Variants
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
-- Variants for Tech Products
(1, 'Intel i5, 8GB RAM, 256GB SSD', 'https://www.asifcomputers.com/wp-content/uploads/2022/08/DELL-XPS-PLUS-01-min.jpg', 999.99, NOW(), NOW()),          -- ID 1
(1, 'Intel i7, 16GB RAM, 512GB SSD', 'https://image.citycenter.jo/cache/catalog/092022/93203-1200x1200.jpg', 1299.99, NOW(), NOW()),        -- ID 2
(2, 'M1 Chip, 8GB RAM, 256GB SSD', 'https://images.kabum.com.br/produtos/fotos/sync_mirakl/287136/Macbook-Pro-M1-256GB-A2338-Space-Gray_1660237256_gg.jpg', 1299.99, NOW(), NOW()),         -- ID 3
(2, 'M1 Chip, 16GB RAM, 512GB SSD', 'https://images.kabum.com.br/produtos/fotos/sync_mirakl/287136/Macbook-Pro-M1-256GB-A2338-Space-Gray_1660237256_gg.jpg', 1699.99, NOW(), NOW()),        -- ID 4
(3, 'AMD Ryzen 5, 8GB RAM, 1TB HDD', 'https://www.bhphotovideo.com/images/images2500x2500/HP_Hewlett_Packard_h3y80aa_aba_Pavilion_p7_1430_Desktop_PC_891243.jpg', 799.99, NOW(), NOW()),        -- ID 5
(3, 'AMD Ryzen 7, 16GB RAM, 512GB SSD', 'https://www.bhphotovideo.com/images/images2500x2500/HP_Hewlett_Packard_h3y80aa_aba_Pavilion_p7_1430_Desktop_PC_891243.jpg', 999.99, NOW(), NOW()),     -- ID 6
(4, 'Intel i5, 8GB RAM, 256GB SSD', 'https://media.ldlc.com/r1600/ld/products/00/06/05/14/LD0006051479_0006090475_0006142661_0006142720.jpg', 1099.99, NOW(), NOW()),    -- ID 7
(4, 'Intel i7, 16GB RAM, 512GB SSD', 'https://www.bhphotovideo.com/images/images1500x1500/lenovo_20ks003nus_e580_i7_8550u_8gb_256ssd_1400230.jpg', 1399.99, NOW(), NOW()),   -- ID 8
(5, '128GB Storage', 'https://i5.walmartimages.com/asr/53db60c3-1e00-49f2-847c-5eea66169943.1e3f214c752760f0cee394257b237126.png?odnHeight=612&odnWidth=612&odnBg=FFFFFF', 799.99, NOW(), NOW()),                         -- ID 9
(5, '256GB Storage', 'https://www.4gltemall.com/media/catalog/product/cache/1/image/650x650/9df78eab33525d08d6e5fb8d27136e95/s/a/samsung_galaxy_s21_plus_1_.jpg', 849.99, NOW(), NOW()),                         -- ID 10
(6, '128GB Storage', 'https://a.allegroimg.com/s1024/0c33fb/d66398b04e4eb5b9fcbf702aa2d4', 999.99, NOW(), NOW()),                          -- ID 11
(6, '256GB Storage', 'https://a.allegroimg.com/s1024/0c33fb/d66398b04e4eb5b9fcbf702aa2d4', 1099.99, NOW(), NOW()),                         -- ID 12
(7, 'Black Color', 'https://computersolutionranchi.com/wp-content/uploads/2020/05/Logitech-M171-wireless-mouse-768x768.jpg', 29.99, NOW(), NOW()),                           -- ID 13
(7, 'Blue Color', 'https://www.eezepc.com/wp-content/uploads/2020/05/logitech-m171-blue-1.jpg', 29.99, NOW(), NOW()),                             -- ID 14
(8, 'Intel i5, 8GB RAM, 128GB SSD', 'https://d1eh9yux7w8iql.cloudfront.net/product_images/486011_dd997560-a79d-4569-9aaf-c24fbf90bd12.jpg', 899.99, NOW(), NOW()),         -- ID 15
(8, 'Intel i7, 16GB RAM, 256GB SSD', 'https://d1eh9yux7w8iql.cloudfront.net/product_images/486011_dd997560-a79d-4569-9aaf-c24fbf90bd12.jpg', 1199.99, NOW(), NOW()),       -- ID 16
(9, 'Intel i5, 8GB RAM, 256GB SSD', 'https://th.bing.com/th/id/R.a4f8fbca8e93d496c4dd75ae77cca5bb?rik=lu%2bpp7ZWDhILyg&pid=ImgRaw&r=0', 1099.99, NOW(), NOW()),       -- ID 17
(9, 'Intel i7, 16GB RAM, 512GB SSD', 'https://www.asus.com/media/global/gallery/dZipgASPflUPV6LH_setting_fff_1_90_end_1000.png', 1399.99, NOW(), NOW()),      -- ID 18
(10, 'With 15-45mm Lens', 'https://th.bing.com/th/id/OIP.Ud8EP-qepv4QXcubnZ_FTwAAAA?rs=1&pid=ImgDetMain', 599.99, NOW(), NOW()),                 -- ID 19
(10, 'With 55-200mm Lens', 'https://th.bing.com/th/id/OIP.Ud8EP-qepv4QXcubnZ_FTwAAAA?rs=1&pid=ImgDetMain', 799.99, NOW(), NOW()),  -- ID 20
(11, 'Silver Color', 'https://th.bing.com/th/id/OIP.1pfrYCKBRdZRYcPJ0y0IdAAAAA?rs=1&pid=ImgDetMain', 299.99, NOW(), NOW()),                      -- ID 21
(11, 'Black Color', 'https://assets.bose.com/content/dam/Bose_DAM/Web/consumer_electronics/global/products/headphones/qc45/product_silo_images/QC45_PDP_Ecom-Gallery-B03.jpg/jcr:content/renditions/cq5dam.web.1000.1000.jpeg', 299.99, NOW(), NOW()),                        -- ID 22
(12, 'Black Color', 'https://www.bhphotovideo.com/images/images2500x2500/sony_wh1000xm4_b_wh_1000xm4_wireless_noise_canceling_over_ear_1582549.jpg', 349.99, NOW(), NOW()),                         -- ID 23
(12, 'Silver Color', 'https://www.bhphotovideo.com/images/images2500x2500/sony_wh1000xm4_s_wh_1000xm4_wireless_noise_canceling_over_ear_1582976.jpg', 349.99, NOW(), NOW()),                       -- ID 24
(13, '128GB Storage', 'https://m.media-amazon.com/images/I/71AFAa4sgbL._AC_SL1500_.jpg', 699.99, NOW(), NOW()),                           -- ID 25
(13, '256GB Storage', 'https://smartusedphones.com/wp-content/uploads/2022/11/Best-Unlocked-Original-Used-Refurbished-5G-Android-Phone-Google-Pixel-6-4.jpg', 799.99, NOW(), NOW()),                           -- ID 26
(14, '10000mAh', 'https://flashdealfinder.com/wp-content/uploads/2020/01/Anker-Charging-Accessories.jpg', 49.99, NOW(), NOW()),                            -- ID 27
(14, '20000mAh', 'https://flashdealfinder.com/wp-content/uploads/2020/01/Anker-Charging-Accessories.jpg', 69.99, NOW(), NOW()),                            -- ID 28
(15, 'Neon Red and Blue', 'https://i5.walmartimages.com/asr/41b40bbc-8c9c-4a1d-88ee-b0be32f21922.04219b45da8d33d3c3d9c3b2e8c7cfa1.jpeg', 299.99, NOW(), NOW()),                   -- ID 29
(15, 'Gray', 'https://th.bing.com/th/id/R.2bdc4a3b8748a5f88229feca0b9258db?rik=4mMg3%2bV6hecKWw&pid=ImgRaw&r=0', 299.99, NOW(), NOW()),                                -- ID 30
(16, '64GB Storage', 'https://www.wearesync.co.uk/wp-content/uploads/2020/09/ipad-air-rose-gold.jpg', 599.99, NOW(), NOW()),                               -- ID 31
(16, '256GB Storage', 'https://www.wearesync.co.uk/wp-content/uploads/2020/09/ipad-air-rose-gold.jpg', 749.99, NOW(), NOW()),                             -- ID 32
(17, 'Black Band', 'https://www.pointekonline.com/wp-content/uploads/2021/08/fitbit-versa-3.png', 229.95, NOW(), NOW()),                           -- ID 33
(17, 'Pink Band', 'https://static3.nordic.pictures/29120383-thickbox_default/fitbit-versa-2-petal-copper-rose.jpg', 229.95, NOW(), NOW()),                             -- ID 34
(18, 'Standard Bundle', 'https://pic.clubic.com/v1/images/1845895/raw', 399.99, NOW(), NOW()),                     -- ID 35
(18, 'Bundle with Accessories', 'https://pic.clubic.com/v1/images/1845895/raw', 449.99, NOW(), NOW()),               -- ID 36
(19, '128GB Storage', 'https://th.bing.com/th/id/R.3fc3bb5fb0e49cc7f8d3a0ac407f275a?rik=gkjqiUAvQSI1cw&pid=ImgRaw&r=0', 649.99, NOW(), NOW()),                        -- ID 37
(19, '256GB Storage', 'https://th.bing.com/th/id/R.3fc3bb5fb0e49cc7f8d3a0ac407f275a?rik=gkjqiUAvQSI1cw&pid=ImgRaw&r=0', 729.99, NOW(), NOW()),                        -- ID 38
(20, 'Charcoal', 'https://m.media-amazon.com/images/G/35/kindle/journeys/Mvq9IW0GZYhQQxsK3yOI2P3mAwEpOFjw7I006Eo32BTY3D/YTIwMTU1Y2It._CB608384139_.jpg', 49.99, NOW(), NOW()),                                -- ID 39
(20, 'Glacier White', 'https://pnghq.com/wp-content/uploads/buy-amazon-echo-dot-4th-gen-with-built-in-alexa-smart-wi-fi-speaker-controls-smart-devices-89826.png', 49.99, NOW(), NOW()),                              -- ID 40
-- Variants for Toy Products
(21, 'Standard Version', 'https://s.ecrater.com/stores/401629/5a30566e5089c_401629b.jpg', 159.99, NOW(), NOW()),                  -- ID 41
(22, 'Standard Version', 'https://www.tradeinn.com/f/14017/140176932/mattel-barbie-dreamhouse-2023.jpg', 199.99, NOW(), NOW()),                       -- ID 42
(23, 'Standard Version', 'https://i5.walmartimages.com/asr/2e82fd2b-c8ed-4683-979e-afef40f9857b_1.65997a515fcab69787766968c3369811.jpeg', 49.99, NOW(), NOW()),                       -- ID 43
(24, 'Standard Version', 'https://toyworld.com.my/wp-content/uploads/2018/11/16015253905f75568e5a6c4.jpeg', 19.99, NOW(), NOW()),                       -- ID 44
(25, 'Standard Version', 'https://image.smythstoys.com/zoom/159143_3.jpg', 19.99, NOW(), NOW()),                         -- ID 45
(26, 'Standard Version', 'https://d3qyu496o2hwvq.cloudfront.net/wp-content/uploads/2019/07/FINALRUBIK-copy.jpg', 9.99, NOW(), NOW()),                               -- ID 46
(27, 'Standard Version', 'https://cdn.playtherapysupply.com/img/f/82723fc0c798.jpg', 14.99, NOW(), NOW()),                            -- ID 47
(28, 'Standard Version', 'https://www.avalankids.com.au/assets/full/W2087.jpg?20200707033535', 5.99, NOW(), NOW()),                             -- ID 48
(29, 'Standard Version', 'https://images-na.ssl-images-amazon.com/images/I/81tEFtVFzBL.jpg', 7.99, NOW(), NOW()),                                  -- ID 49
(30, 'Standard Version', 'https://shop.crayola.com/dw/image/v2/AALB_PRD/on/demandware.static/-/Sites-crayola-storefront/default/dw9d1e23c3/images/52-0030-2.jpg?sw=1200&sh=1500&sm=fit&sfrm=jpg', 14.99, NOW(), NOW()),                          -- ID 50
(31, 'Standard Version', 'https://cdn.shopify.com/s/files/1/0472/7118/2499/products/SBU-39077567-Melissa-_-Doug-100-Wooden-Blocks-Set-FRONT.png?v=1646115534', 19.99, NOW(), NOW()),                            -- ID 51
(32, 'Standard Version', 'https://m.media-amazon.com/images/I/71uRENNFM4L.jpg', 29.99, NOW(), NOW()),                            -- ID 52
(33, 'Standard Version', 'https://th.bing.com/th/id/R.154e6815051545a5e0e7ac96175d661a?rik=iNXWvk8xU9UlFQ&pid=ImgRaw&r=0', 19.99, NOW(), NOW()),                            -- ID 53
(34, 'Standard Version', 'https://morethanmeeples.com.au/product/pokemon-battle-academy-board-game/pokemon-battle-academy-board-game-01.jpg', 19.99, NOW(), NOW()),                              -- ID 54
(35, 'Standard Version', 'https://toysdirect.ie/cdn/shop/products/fisher-price-laugh-learn-smart-stages-chair-704174_1024x1024@2x.jpg?v=1666842488', 39.99, NOW(), NOW()),                       -- ID 55
(36, 'Standard Version', 'https://www.costco.co.uk/medias/sys_master/images/hfb/h73/46203167899678.jpg', 59.99, NOW(), NOW()),                    -- ID 56
(37, 'Standard Version', 'https://brands.amazrock.com/wp-content/uploads/2018/08/Baby-Einstein-Take-Along-Tunes-Musical-Toy-Ages-3-months-Plus.jpg', 9.99, NOW(), NOW()),                       -- ID 57
(38, 'Standard Version', 'https://cdn.ecommercedns.uk/files/7/234067/1/11496051/little-tikes-cozy-coupe-30th-anniversary-toymaster-ballina-3.jpg', 54.99, NOW(), NOW()),                               -- ID 58
(39, 'Standard Version', 'https://i.pinimg.com/originals/ee/03/5d/ee035dfc02ef4777f807bd3163dd98f5.jpg', 29.99, NOW(), NOW()),                           -- ID 59
(40, 'Standard Version', 'https://th.bing.com/th/id/OIP.ADD2WhXiH4dB8WNq6EuyoAHaHa?rs=1&pid=ImgDetMain', 14.99, NOW(), NOW());                          -- ID 60

-- Insert Inventory Records with specific quantities within 1 to 15
INSERT INTO `Inventory` (`warehouse_id`, `variant_id`, `quantity_available`, `assigned_capacity`, `last_updated`)
VALUES
(1, 1, 15, 2, NOW()),
(1, 2, 8, 4, NOW()),
(1, 3, 12, 1, NOW()),
(1, 4, 7, 5, NOW()),
(1, 5, 10, 4, NOW()),
(1, 6, 5, 50, NOW()),
(1, 7, 9, 50, NOW()),
(1, 8, 6, 50, NOW()),
(1, 9, 13, 50, NOW()),
(1, 10, 11, 50, NOW()),
(1, 11, 14, 50, NOW()),
(1, 12, 4, 50, NOW()),
(1, 13, 2, 50, NOW()),
(1, 14, 7, 50, NOW()),
(1, 15, 3, 50, NOW()),
(1, 16, 10, 50, NOW()),
(1, 17, 1, 50, NOW()),
(1, 18, 12, 50, NOW()),
(1, 19, 9, 50, NOW()),
(1, 20, 14, 50, NOW()),
(1, 21, 8, 50, NOW()),
(1, 22, 5, 50, NOW()),
(1, 23, 6, 50, NOW()),
(1, 24, 11, 50, NOW()),
(1, 25, 13, 50, NOW()),
(1, 26, 15, 50, NOW()),
(1, 27, 4, 50, NOW()),
(1, 28, 7, 50, NOW()),
(1, 29, 1, 50, NOW()),
(1, 30, 10, 50, NOW()),
(1, 31, 9, 50, NOW()),
(1, 32, 3, 50, NOW()),
(1, 33, 5, 50, NOW()),
(1, 34, 2, 50, NOW()),
(1, 35, 8, 50, NOW()),
(1, 36, 13, 50, NOW()),
(1, 37, 7, 50, NOW()),
(1, 38, 11, 50, NOW()),
(1, 39, 15, 50, NOW()),
(1, 40, 14, 50, NOW()),
(1, 41, 6, 50, NOW()),
(1, 42, 12, 50, NOW()),
(1, 43, 10, 50, NOW()),
(1, 44, 5, 50, NOW()),
(1, 45, 4, 50, NOW()),
(1, 46, 3, 50, NOW()),
(1, 47, 2, 50, NOW()),
(1, 48, 1, 50, NOW()),
(1, 49, 8, 50, NOW()),
(1, 50, 9, 50, NOW()),
(1, 51, 13, 50, NOW()),
(1, 52, 11, 50, NOW()),
(1, 53, 15, 50, NOW()),
(1, 54, 6, 50, NOW()),
(1, 55, 14, 50, NOW()),
(1, 56, 7, 50, NOW()),
(1, 57, 3, 50, NOW()),
(1, 58, 10, 50, NOW()),
(1, 59, 12, 50, NOW()),
(1, 60, 4, 50, NOW());

-- Insert Custom Attributes for Products
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`)
VALUES
-- Dell XPS 13 Laptop (Product ID: 1)
(1, 'Processor'),          -- Attribute ID: 1
(1, 'RAM'),                -- Attribute ID: 2
(1, 'Storage'),            -- Attribute ID: 3

-- Apple MacBook Pro (Product ID: 2)
(2, 'Processor'),          -- Attribute ID: 4
(2, 'RAM'),                -- Attribute ID: 5
(2, 'Storage'),            -- Attribute ID: 6

-- HP Pavilion Desktop (Product ID: 3)
(3, 'Processor'),          -- Attribute ID: 7
(3, 'RAM'),                -- Attribute ID: 8
(3, 'Storage'),            -- Attribute ID: 9

-- Lenovo ThinkPad Laptop (Product ID: 4)
(4, 'Processor'),          -- Attribute ID:10
(4, 'RAM'),                -- Attribute ID:11
(4, 'Storage'),            -- Attribute ID:12

-- Samsung Galaxy S21 Smartphone (Product ID: 5)
(5, 'Storage'),            -- Attribute ID:13
(5, 'Color'),              -- Attribute ID:14

-- Apple iPhone 13 (Product ID: 6)
(6, 'Storage'),            -- Attribute ID:15
(6, 'Color'),              -- Attribute ID:16

-- Logitech Wireless Mouse (Product ID: 7)
(7, 'Color'),              -- Attribute ID:17

-- Microsoft Surface Pro (Product ID: 8)
(8, 'Processor'),          -- Attribute ID:18
(8, 'RAM'),                -- Attribute ID:19
(8, 'Storage'),            -- Attribute ID:20

-- Asus ZenBook Laptop (Product ID: 9)
(9, 'Processor'),          -- Attribute ID:21
(9, 'RAM'),                -- Attribute ID:22
(9, 'Storage'),            -- Attribute ID:23

-- Canon EOS M50 Camera (Product ID: 10)
(10, 'Lens'),              -- Attribute ID:24

-- Bose QuietComfort Headphones (Product ID: 11)
(11, 'Color'),             -- Attribute ID:25

-- Sony WH-1000XM4 Headphones (Product ID: 12)
(12, 'Color'),             -- Attribute ID:26

-- Google Pixel 6 Smartphone (Product ID: 13)
(13, 'Storage'),           -- Attribute ID:27
(13, 'Color'),             -- Attribute ID:28

-- Anker PowerCore Portable Charger (Product ID: 14)
(14, 'Capacity'),          -- Attribute ID:29

-- Nintendo Switch Console (Product ID: 15)
(15, 'Color'),             -- Attribute ID:30

-- Apple iPad Air (Product ID: 16)
(16, 'Storage'),           -- Attribute ID:31
(16, 'Color'),             -- Attribute ID:32

-- Fitbit Versa 3 Smartwatch (Product ID: 17)
(17, 'Band Color'),        -- Attribute ID:33

-- GoPro HERO9 Camera (Product ID: 18)
(18, 'Bundle'),            -- Attribute ID:34

-- Samsung Galaxy Tab S7 (Product ID: 19)
(19, 'Storage'),           -- Attribute ID:35

-- Amazon Echo Dot (Product ID: 20)
(20, 'Color');             -- Attribute ID:36

-- Insert Custom Attribute Values for Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Dell XPS 13 Laptop Variants (Variant IDs: 1,2)
(1, 1, 'Intel i5'),        -- Variant 1, Processor
(1, 2, '8GB'),             -- Variant 1, RAM
(1, 3, '256GB SSD'),       -- Variant 1, Storage
(2, 1, 'Intel i7'),        -- Variant 2, Processor
(2, 2, '16GB'),            -- Variant 2, RAM
(2, 3, '512GB SSD'),       -- Variant 2, Storage

-- Apple MacBook Pro Variants (Variant IDs: 3,4)
(3, 4, 'Apple M1'),        -- Variant 3, Processor
(3, 5, '8GB'),             -- Variant 3, RAM
(3, 6, '256GB SSD'),       -- Variant 3, Storage
(4, 4, 'Apple M1'),        -- Variant 4, Processor
(4, 5, '16GB'),            -- Variant 4, RAM
(4, 6, '512GB SSD'),       -- Variant 4, Storage

-- HP Pavilion Desktop Variants (Variant IDs: 5,6)
(5, 7, 'AMD Ryzen 5'),     -- Variant 5, Processor
(5, 8, '8GB'),             -- Variant 5, RAM
(5, 9, '1TB HDD'),         -- Variant 5, Storage
(6, 7, 'AMD Ryzen 7'),     -- Variant 6, Processor
(6, 8, '16GB'),            -- Variant 6, RAM
(6, 9, '512GB SSD'),       -- Variant 6, Storage

-- Lenovo ThinkPad Laptop Variants (Variant IDs: 7,8)
(7,10, 'Intel i5'),        -- Variant 7, Processor
(7,11, '8GB'),             -- Variant 7, RAM
(7,12, '256GB SSD'),       -- Variant 7, Storage
(8,10, 'Intel i7'),        -- Variant 8, Processor
(8,11, '16GB'),            -- Variant 8, RAM
(8,12, '512GB SSD'),       -- Variant 8, Storage

-- Samsung Galaxy S21 Smartphone Variants (Variant IDs: 9,10)
(9,13, '128GB'),           -- Variant 9, Storage
(9,14, 'Phantom Gray'),    -- Variant 9, Color
(10,13, '256GB'),          -- Variant 10, Storage
(10,14, 'Phantom Silver'), -- Variant 10, Color

-- Apple iPhone 13 Variants (Variant IDs: 11,12)
(11,15, '128GB'),          -- Variant 11, Storage
(11,16, 'Black'),          -- Variant 11, Color
(12,15, '256GB'),          -- Variant 12, Storage
(12,16, 'White'),          -- Variant 12, Color

-- Logitech Wireless Mouse Variants (Variant IDs: 13,14)
(13,17, 'Black'),          -- Variant 13, Color
(14,17, 'Blue'),           -- Variant 14, Color

-- Microsoft Surface Pro Variants (Variant IDs: 15,16)
(15,18, 'Intel i5'),       -- Variant 15, Processor
(15,19, '8GB'),            -- Variant 15, RAM
(15,20, '128GB SSD'),      -- Variant 15, Storage
(16,18, 'Intel i7'),       -- Variant 16, Processor
(16,19, '16GB'),           -- Variant 16, RAM
(16,20, '256GB SSD'),      -- Variant 16, Storage

-- Asus ZenBook Laptop Variants (Variant IDs: 17,18)
(17,21, 'Intel i5'),       -- Variant 17, Processor
(17,22, '8GB'),            -- Variant 17, RAM
(17,23, '256GB SSD'),      -- Variant 17, Storage
(18,21, 'Intel i7'),       -- Variant 18, Processor
(18,22, '16GB'),           -- Variant 18, RAM
(18,23, '512GB SSD'),      -- Variant 18, Storage

-- Canon EOS M50 Camera Variants (Variant IDs: 19,20)
(19,24, '15-45mm Lens'),               -- Variant 19, Lens
(20,24, '15-45mm and 55-200mm Lenses'),-- Variant 20, Lens

-- Bose QuietComfort Headphones Variants (Variant IDs: 21,22)
(21,25, 'Silver'),          -- Variant 21, Color
(22,25, 'Black'),           -- Variant 22, Color

-- Sony WH-1000XM4 Headphones Variants (Variant IDs: 23,24)
(23,26, 'Black'),           -- Variant 23, Color
(24,26, 'Silver'),          -- Variant 24, Color

-- Google Pixel 6 Smartphone Variants (Variant IDs: 25,26)
(25,27, '128GB'),           -- Variant 25, Storage
(25,28, 'Stormy Black'),    -- Variant 25, Color
(26,27, '256GB'),           -- Variant 26, Storage
(26,28, 'Cloudy White'),    -- Variant 26, Color

-- Anker PowerCore Portable Charger Variants (Variant IDs: 27,28)
(27,29, '10000mAh'),        -- Variant 27, Capacity
(28,29, '20000mAh'),        -- Variant 28, Capacity

-- Nintendo Switch Console Variants (Variant IDs: 29,30)
(29,30, 'Neon Red and Blue'),-- Variant 29, Color
(30,30, 'Gray'),             -- Variant 30, Color

-- Apple iPad Air Variants (Variant IDs: 31,32)
(31,31, '64GB'),             -- Variant 31, Storage
(31,32, 'Space Gray'),       -- Variant 31, Color
(32,31, '256GB'),            -- Variant 32, Storage
(32,32, 'Rose Gold'),        -- Variant 32, Color

-- Fitbit Versa 3 Smartwatch Variants (Variant IDs: 33,34)
(33,33, 'Black Band'),       -- Variant 33, Band Color
(34,33, 'Pink Band'),        -- Variant 34, Band Color

-- GoPro HERO9 Camera Variants (Variant IDs: 35,36)
(35,34, 'Standard Bundle'),  -- Variant 35, Bundle
(36,34, 'Bundle with Accessories'),-- Variant 36, Bundle

-- Samsung Galaxy Tab S7 Variants (Variant IDs: 37,38)
(37,35, '128GB'),            -- Variant 37, Storage
(38,35, '256GB'),            -- Variant 38, Storage

-- Amazon Echo Dot Variants (Variant IDs: 39,40)
(39,36, 'Charcoal'),         -- Variant 39, Color
(40,36, 'Glacier White');    -- Variant 40, Color



-- Add 'Color' attribute to laptops and iPhones
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`)
VALUES
-- Dell XPS 13 Laptop (Product ID: 1)
(1, 'Color'),   -- Attribute ID: 37
-- Apple MacBook Pro (Product ID: 2)
(2, 'Color'),   -- Attribute ID: 38
-- Lenovo ThinkPad Laptop (Product ID: 4)
(4, 'Color'),   -- Attribute ID: 39
-- Asus ZenBook Laptop (Product ID: 9)
(9, 'Color');   -- Attribute ID: 40

-- Add more color variants for laptops and iPhones
-- For Dell XPS 13 Laptop (Product ID: 1)
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
(1, 'Intel i5, 8GB RAM, 256GB SSD - Silver', 'https://www.asifcomputers.com/wp-content/uploads/2022/08/DELL-XPS-PLUS-01-min.jpg', 999.99, NOW(), NOW()),    -- Variant ID: 61
(1, 'Intel i5, 8GB RAM, 256GB SSD - Black', 'https://image.citycenter.jo/cache/catalog/092022/93203-1200x1200.jpg', 999.99, NOW(), NOW()),     -- Variant ID: 62
(1, 'Intel i7, 16GB RAM, 512GB SSD - Silver', 'https://www.asifcomputers.com/wp-content/uploads/2022/08/DELL-XPS-PLUS-01-min.jpg', 1299.99, NOW(), NOW()), -- Variant ID: 63
(1, 'Intel i7, 16GB RAM, 512GB SSD - Black', 'https://image.citycenter.jo/cache/catalog/092022/93203-1200x1200.jpg', 1299.99, NOW(), NOW());   -- Variant ID: 64

-- For Apple MacBook Pro (Product ID: 2)
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
(2, 'M1 Chip, 8GB RAM, 256GB SSD - Space Gray', 'macbook_pro_space_gray.jpg', 1299.99, NOW(), NOW()), -- Variant ID: 65
(2, 'M1 Chip, 8GB RAM, 256GB SSD - Silver', 'macbook_pro_silver.jpg', 1299.99, NOW(), NOW()),        -- Variant ID: 66
(2, 'M1 Chip, 16GB RAM, 512GB SSD - Space Gray', 'macbook_pro_space_gray.jpg', 1699.99, NOW(), NOW()), -- Variant ID: 67
(2, 'M1 Chip, 16GB RAM, 512GB SSD - Silver', 'macbook_pro_silver.jpg', 1699.99, NOW(), NOW());       -- Variant ID: 68

-- For Lenovo ThinkPad Laptop (Product ID: 4)
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
(4, 'Intel i5, 8GB RAM, 256GB SSD - Black', 'https://media.ldlc.com/r1600/ld/products/00/06/05/14/LD0006051479_0006090475_0006142661_0006142720.jpg', 1099.99, NOW(), NOW()),     -- Variant ID: 69
(4, 'Intel i5, 8GB RAM, 256GB SSD - Silver', 'https://www.bhphotovideo.com/images/images1500x1500/lenovo_20ks003nus_e580_i7_8550u_8gb_256ssd_1400230.jpg', 1099.99, NOW(), NOW()),   -- Variant ID: 70
(4, 'Intel i7, 16GB RAM, 512GB SSD - Black', 'https://media.ldlc.com/r1600/ld/products/00/06/05/14/LD0006051479_0006090475_0006142661_0006142720.jpg', 1399.99, NOW(), NOW()),    -- Variant ID: 71
(4, 'Intel i7, 16GB RAM, 512GB SSD - Silver', 'https://www.bhphotovideo.com/images/images1500x1500/lenovo_20ks003nus_e580_i7_8550u_8gb_256ssd_1400230.jpg', 1399.99, NOW(), NOW());  -- Variant ID: 72

-- For Asus ZenBook Laptop (Product ID: 9)
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
(9, 'Intel i5, 8GB RAM, 256GB SSD - Royal Blue', 'https://www.asus.com/media/global/gallery/dZipgASPflUPV6LH_setting_fff_1_90_end_1000.png', 1099.99, NOW(), NOW()), -- Variant ID: 73
(9, 'Intel i5, 8GB RAM, 256GB SSD - Slate Gray', 'https://th.bing.com/th/id/R.a4f8fbca8e93d496c4dd75ae77cca5bb?rik=lu%2bpp7ZWDhILyg&pid=ImgRaw&r=0', 1099.99, NOW(), NOW()), -- Variant ID: 74
(9, 'Intel i7, 16GB RAM, 512GB SSD - Royal Blue', 'https://www.asus.com/media/global/gallery/dZipgASPflUPV6LH_setting_fff_1_90_end_1000.png', 1399.99, NOW(), NOW()),-- Variant ID: 75
(9, 'Intel i7, 16GB RAM, 512GB SSD - Slate Gray', 'https://th.bing.com/th/id/R.a4f8fbca8e93d496c4dd75ae77cca5bb?rik=lu%2bpp7ZWDhILyg&pid=ImgRaw&r=0', 1399.99, NOW(), NOW());-- Variant ID: 76

-- For Apple iPhone 13 (Product ID: 6)
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`)
VALUES
(6, '128GB Storage - Red', 'https://th.bing.com/th/id/R.891d6a4a3d6e813da27a9ff6b5bbcd8c?rik=y868ivvxm7d5OQ&pid=ImgRaw&r=0', 999.99, NOW(), NOW()),      -- Variant ID: 77
(6, '128GB Storage - Blue', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/refurb-iphone-13-blue-2023?wid=2000&hei=1897&fmt=jpeg&qlt=95&.v=1679072983869', 999.99, NOW(), NOW()),     -- Variant ID: 78
(6, '256GB Storage - Red', 'https://th.bing.com/th/id/R.891d6a4a3d6e813da27a9ff6b5bbcd8c?rik=y868ivvxm7d5OQ&pid=ImgRaw&r=0', 1099.99, NOW(), NOW()),      -- Variant ID: 79
(6, '256GB Storage - Blue', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/refurb-iphone-13-blue-2023?wid=2000&hei=1897&fmt=jpeg&qlt=95&.v=1679072983869', 1099.99, NOW(), NOW());    -- Variant ID: 80

-- Insert Custom Attribute Values for new variants
-- Dell XPS 13 Laptop Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Variant ID 61
(61, 1, 'Intel i5'),        -- Processor
(61, 2, '8GB'),             -- RAM
(61, 3, '256GB SSD'),       -- Storage
(61,37, 'Silver'),          -- Color
-- Variant ID 62
(62, 1, 'Intel i5'),
(62, 2, '8GB'),
(62, 3, '256GB SSD'),
(62,37, 'Black'),
-- Variant ID 63
(63, 1, 'Intel i7'),
(63, 2, '16GB'),
(63, 3, '512GB SSD'),
(63,37, 'Silver'),
-- Variant ID 64
(64, 1, 'Intel i7'),
(64, 2, '16GB'),
(64, 3, '512GB SSD'),
(64,37, 'Black');

-- Apple MacBook Pro Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Variant ID 65
(65, 4, 'Apple M1'),
(65, 5, '8GB'),
(65, 6, '256GB SSD'),
(65,38, 'Space Gray'),
-- Variant ID 66
(66, 4, 'Apple M1'),
(66, 5, '8GB'),
(66, 6, '256GB SSD'),
(66,38, 'Silver'),
-- Variant ID 67
(67, 4, 'Apple M1'),
(67, 5, '16GB'),
(67, 6, '512GB SSD'),
(67,38, 'Space Gray'),
-- Variant ID 68
(68, 4, 'Apple M1'),
(68, 5, '16GB'),
(68, 6, '512GB SSD'),
(68,38, 'Silver');

-- Lenovo ThinkPad Laptop Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Variant ID 69
(69,10, 'Intel i5'),
(69,11, '8GB'),
(69,12, '256GB SSD'),
(69,39, 'Black'),
-- Variant ID 70
(70,10, 'Intel i5'),
(70,11, '8GB'),
(70,12, '256GB SSD'),
(70,39, 'Silver'),
-- Variant ID 71
(71,10, 'Intel i7'),
(71,11, '16GB'),
(71,12, '512GB SSD'),
(71,39, 'Black'),
-- Variant ID 72
(72,10, 'Intel i7'),
(72,11, '16GB'),
(72,12, '512GB SSD'),
(72,39, 'Silver');

-- Asus ZenBook Laptop Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Variant ID 73
(73,21, 'Intel i5'),
(73,22, '8GB'),
(73,23, '256GB SSD'),
(73,40, 'Royal Blue'),
-- Variant ID 74
(74,21, 'Intel i5'),
(74,22, '8GB'),
(74,23, '256GB SSD'),
(74,40, 'Slate Gray'),
-- Variant ID 75
(75,21, 'Intel i7'),
(75,22, '16GB'),
(75,23, '512GB SSD'),
(75,40, 'Royal Blue'),
-- Variant ID 76
(76,21, 'Intel i7'),
(76,22, '16GB'),
(76,23, '512GB SSD'),
(76,40, 'Slate Gray');

-- Apple iPhone 13 Variants
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`)
VALUES
-- Variant ID 77
(77,15, '128GB'),
(77,16, 'Red'),
-- Variant ID 78
(78,15, '128GB'),
(78,16, 'Blue'),
-- Variant ID 79
(79,15, '256GB'),
(79,16, 'Red'),
-- Variant ID 80
(80,15, '256GB'),
(80,16, 'Blue');

-- Update Inventory for new variants with specific quantities within 1 to 15
INSERT INTO `Inventory` (`warehouse_id`, `variant_id`, `quantity_available`, `assigned_capacity`, `last_updated`)
VALUES
(1, 61, 5, 50, NOW()),
(1, 62, 12, 50, NOW()),
(1, 63, 8, 50, NOW()),
(1, 64, 3, 50, NOW()),
(1, 65, 15, 50, NOW()),
(1, 66, 10, 50, NOW()),
(1, 67, 7, 50, NOW()),
(1, 68, 13, 50, NOW()),
(1, 69, 2, 50, NOW()),
(1, 70, 14, 50, NOW()),
(1, 71, 4, 50, NOW()),
(1, 72, 9, 50, NOW()),
(1, 73, 1, 50, NOW()),
(1, 74, 6, 50, NOW()),
(1, 75, 11, 50, NOW()),
(1, 76, 3, 50, NOW()),
(1, 77, 5, 50, NOW()),
(1, 78, 15, 50, NOW()),
(1, 79, 8, 50, NOW()),
(1, 80, 7, 50, NOW());

-- Now you have additional color variants for laptops and iPhones with corresponding attributes and images.



-- Adding Attributes to Existing Toy Products

-- For any toy products that may not have attributes yet, we'll add custom attributes and corresponding attribute values for their variants.

-- Let's first identify any toy products that might be missing attributes.

-- List of Toy Products (Product IDs from 21 to 40):

-- Product ID: 21 - LEGO Star Wars Millennium Falcon
-- Product ID: 22 - Barbie Dreamhouse
-- Product ID: 23 - Nerf N-Strike Elite Blaster
-- Product ID: 24 - Hot Wheels 20 Car Gift Pack
-- Product ID: 25 - Monopoly Classic Board Game
-- Product ID: 26 - Rubik's Cube
-- Product ID: 27 - Jenga Classic Game
-- Product ID: 28 - UNO Card Game
-- Product ID: 29 - Play-Doh Modeling Compound
-- Product ID: 30 - Crayola Ultimate Crayon Collection
-- Product ID: 31 - Melissa & Doug Wooden Blocks
-- Product ID: 32 - Transformers Optimus Prime Figure
-- Product ID: 33 - Ravensburger Disney Puzzle
-- Product ID: 34 - Pokemon Trading Card Game
-- Product ID: 35 - Fisher-Price Laugh & Learn Smart Stages Chair
-- Product ID: 36 - Paw Patrol Ultimate Rescue Fire Truck
-- Product ID: 37 - Baby Einstein Take Along Tunes
-- Product ID: 38 - Little Tikes Cozy Coupe
-- Product ID: 39 - Hape Pound & Tap Bench with Slide Out Xylophone
-- Product ID: 40 - Magic: The Gathering Starter Kit

-- Now, we'll ensure all these toy products have attributes.

-- Insert Custom Attributes for Each Toy Product

-- Product ID: 21 - LEGO Star Wars Millennium Falcon
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(21, 'Number of Pieces'),    -- Attribute ID: [Auto-Incremented]
(21, 'Recommended Age');

-- Product ID: 22 - Barbie Dreamhouse
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(22, 'Dimensions'),
(22, 'Includes Accessories');

-- Product ID: 23 - Nerf N-Strike Elite Blaster
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(23, 'Range'),
(23, 'Ammo Type');

-- Product ID: 24 - Hot Wheels 20 Car Gift Pack
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(24, 'Number of Cars'),
(24, 'Scale');

-- Product ID: 25 - Monopoly Classic Board Game
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(25, 'Players'),
(25, 'Play Time');

-- Product ID: 26 - Rubik's Cube
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(26, 'Difficulty Level');

-- Product ID: 27 - Jenga Classic Game
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(27, 'Number of Blocks'),
(27, 'Material');

-- Product ID: 28 - UNO Card Game
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(28, 'Cards in Deck');

-- Product ID: 29 - Play-Doh Modeling Compound
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(29, 'Colors Included');

-- Product ID: 30 - Crayola Ultimate Crayon Collection
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(30, 'Number of Crayons');

-- Product ID: 31 - Melissa & Doug Wooden Blocks
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(31, 'Number of Pieces'),
(31, 'Material');

-- Product ID: 32 - Transformers Optimus Prime Figure
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(32, 'Figure Height'),
(32, 'Articulation Points');

-- Product ID: 33 - Ravensburger Disney Puzzle
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(33, 'Number of Pieces'),
(33, 'Puzzle Dimensions');

-- Product ID: 34 - Pokemon Trading Card Game
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(34, 'Included Cards'),
(34, 'Set Name');

-- Product ID: 35 - Fisher-Price Laugh & Learn Smart Stages Chair
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(35, 'Features'),
(35, 'Batteries Required');

-- Product ID: 36 - Paw Patrol Ultimate Rescue Fire Truck
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(36, 'Vehicle Length'),
(36, 'Includes Figures');

-- Product ID: 37 - Baby Einstein Take Along Tunes
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(37, 'Melodies Included'),
(37, 'Volume Control');

-- Product ID: 38 - Little Tikes Cozy Coupe
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(38, 'Maximum Weight'),
(38, 'Assembly Required');

-- Product ID: 39 - Hape Pound & Tap Bench with Slide Out Xylophone
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(39, 'Material'),
(39, 'Includes Mallet');

-- Product ID: 40 - Magic: The Gathering Starter Kit
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) VALUES
(40, 'Decks Included'),
(40, 'Set Name');

-- Now, assign attribute values to the variants of these toy products.

-- Since each toy product has one variant (Standard Version), we'll assign attribute values accordingly.

-- Variant IDs correspond to the Variant IDs of the products.

-- LEGO Star Wars Millennium Falcon Variant (Variant ID: 41)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(41, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 21 AND attribute_name = 'Number of Pieces'), '7541'),
(41, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 21 AND attribute_name = 'Recommended Age'), '16+');

-- Barbie Dreamhouse Variant (Variant ID: 42)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(42, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 22 AND attribute_name = 'Dimensions'), '3ft x 4ft x 1.5ft'),
(42, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 22 AND attribute_name = 'Includes Accessories'), 'Yes');

-- Nerf N-Strike Elite Blaster Variant (Variant ID: 43)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(43, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 23 AND attribute_name = 'Range'), '90 feet'),
(43, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 23 AND attribute_name = 'Ammo Type'), 'Elite Darts');

-- Hot Wheels 20 Car Gift Pack Variant (Variant ID: 44)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(44, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 24 AND attribute_name = 'Number of Cars'), '20'),
(44, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 24 AND attribute_name = 'Scale'), '1:64');

-- Monopoly Classic Board Game Variant (Variant ID: 45)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(45, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 25 AND attribute_name = 'Players'), '2-6'),
(45, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 25 AND attribute_name = 'Play Time'), '60-180 minutes');

-- Rubik's Cube Variant (Variant ID: 46)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(46, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 26 AND attribute_name = 'Difficulty Level'), 'Intermediate');

-- Jenga Classic Game Variant (Variant ID: 47)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(47, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 27 AND attribute_name = 'Number of Blocks'), '54'),
(47, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 27 AND attribute_name = 'Material'), 'Wood');

-- UNO Card Game Variant (Variant ID: 48)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(48, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 28 AND attribute_name = 'Cards in Deck'), '112');

-- Play-Doh Modeling Compound Variant (Variant ID: 49)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(49, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 29 AND attribute_name = 'Colors Included'), 'Red, Blue, Yellow, Green');

-- Crayola Ultimate Crayon Collection Variant (Variant ID: 50)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(50, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 30 AND attribute_name = 'Number of Crayons'), '152');

-- Melissa & Doug Wooden Blocks Variant (Variant ID: 51)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(51, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 31 AND attribute_name = 'Number of Pieces'), '100'),
(51, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 31 AND attribute_name = 'Material'), 'Wood');

-- Transformers Optimus Prime Figure Variant (Variant ID: 52)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(52, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 32 AND attribute_name = 'Figure Height'), '12 inches'),
(52, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 32 AND attribute_name = 'Articulation Points'), '15');

-- Ravensburger Disney Puzzle Variant (Variant ID: 53)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(53, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 33 AND attribute_name = 'Number of Pieces'), '1000'),
(53, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 33 AND attribute_name = 'Puzzle Dimensions'), '27" x 20"');

-- Pokemon Trading Card Game Variant (Variant ID: 54)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(54, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 34 AND attribute_name = 'Included Cards'), '60'),
(54, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 34 AND attribute_name = 'Set Name'), 'Battle Academy');

-- Fisher-Price Laugh & Learn Smart Stages Chair Variant (Variant ID: 55)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(55, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 35 AND attribute_name = 'Features'), 'Music, Lights, Learning Content'),
(55, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 35 AND attribute_name = 'Batteries Required'), 'Yes');

-- Paw Patrol Ultimate Rescue Fire Truck Variant (Variant ID: 56)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(56, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 36 AND attribute_name = 'Vehicle Length'), '2 feet'),
(56, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 36 AND attribute_name = 'Includes Figures'), 'Marshall Figure');

-- Baby Einstein Take Along Tunes Variant (Variant ID: 57)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(57, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 37 AND attribute_name = 'Melodies Included'), '7'),
(57, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 37 AND attribute_name = 'Volume Control'), 'Yes');

-- Little Tikes Cozy Coupe Variant (Variant ID: 58)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(58, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 38 AND attribute_name = 'Maximum Weight'), '50 lbs'),
(58, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 38 AND attribute_name = 'Assembly Required'), 'Yes');

-- Hape Pound & Tap Bench with Slide Out Xylophone Variant (Variant ID: 59)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(59, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 39 AND attribute_name = 'Material'), 'Wood'),
(59, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 39 AND attribute_name = 'Includes Mallet'), 'Yes');

-- Magic: The Gathering Starter Kit Variant (Variant ID: 60)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) VALUES
(60, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 40 AND attribute_name = 'Decks Included'), '2 Decks'),
(60, (SELECT attribute_id FROM `Custom_Attribute` WHERE product_id = 40 AND attribute_name = 'Set Name'), 'Core Set 2021');

-- Now, all existing toy products have attributes and their variants have corresponding attribute values.


-- Step 1: Fetch Category IDs
SET @toys_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toys');
SET @board_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Board Games');
SET @arts_and_crafts_id = (SELECT category_id FROM `Category` WHERE category_name = 'Arts and Crafts');
SET @dolls_id = (SELECT category_id FROM `Category` WHERE category_name = 'Dolls');
SET @card_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Card Games');
SET @toy_weapons_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toy Weapons');

-- Step 2: Insert Parent Category Relationships
-- Set @arts_and_crafts_id
SET @arts_and_crafts_id = (SELECT category_id FROM `Category` WHERE category_name = 'Arts and Crafts');

-- Set @toys_id
SET @toys_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toys');


-- Step 1: Ensure Categories Exist

-- 'Dolls' Category
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Dolls', 'Dolls and dollhouses'
WHERE NOT EXISTS (
    SELECT 1 FROM `Category` WHERE category_name = 'Dolls'
);

-- 'Toy Weapons' Category
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Toy Weapons', 'Toy blasters and weapons for play'
WHERE NOT EXISTS (
    SELECT 1 FROM `Category` WHERE category_name = 'Toy Weapons'
);

-- 'Card Games' Category
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Card Games', 'Playing cards and card-based games'
WHERE NOT EXISTS (
    SELECT 1 FROM `Category` WHERE category_name = 'Card Games'
);

-- 'Board Games' Category
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Board Games', 'Board games for all ages'
WHERE NOT EXISTS (
    SELECT 1 FROM `Category` WHERE category_name = 'Board Games'
);

-- 'Toys' Category
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Toys', 'Children\'s toys and games'
WHERE NOT EXISTS (
    SELECT 1 FROM `Category` WHERE category_name = 'Toys'
);

-- Step 2: Set Variables

SET @dolls_id = (SELECT category_id FROM `Category` WHERE category_name = 'Dolls');
SET @toy_weapons_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toy Weapons');
SET @card_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Card Games');
SET @board_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Board Games');
SET @toys_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toys');



-- Step 3: Execute INSERT Statements

-- Link 'Dolls' under 'Toys'
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`)
VALUES
(@dolls_id, @toys_id)
ON DUPLICATE KEY UPDATE parent_category_id = @toys_id;

-- Link 'Toy Weapons' under 'Toys'
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`)
VALUES
(@toy_weapons_id, @toys_id)
ON DUPLICATE KEY UPDATE parent_category_id = @toys_id;

-- Link 'Card Games' under 'Board Games'
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`)
VALUES
(@card_games_id, @board_games_id)
ON DUPLICATE KEY UPDATE parent_category_id = @board_games_id;



-- Step 4: Ensure Products are Matched Appropriately
DELETE FROM `Product_Category_Match` WHERE product_id BETWEEN 21 AND 40;




-- List of category names used
-- 'Building Blocks'
-- 'Dolls'
-- 'Toy Weapons'
-- 'Outdoor Toys'
-- 'Toy Vehicles'
-- 'Board Games'
-- 'Puzzles'
-- 'Educational Toys'
-- 'Card Games'
-- 'Arts and Crafts'
-- 'Action Figures'
-- 'Trading Card Games'
-- 'Musical Toys'

-- Insert categories if they don't exist
INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Building Blocks', 'Building and construction toys'
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Building Blocks');

INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Dolls', 'Dolls and dollhouses'
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Dolls');

INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Toy Weapons', 'Toy blasters and weapons for play'
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Toy Weapons');

INSERT INTO `Category` (`category_name`, `description`)
SELECT 'Outdoor Toys', 'Toys for outdoor play' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Outdoor Toys')
UNION ALL
SELECT 'Toy Vehicles', 'Toy cars, trucks, and other vehicles' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Toy Vehicles')
UNION ALL
SELECT 'Board Games', 'Board games for all ages' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Board Games')
UNION ALL
SELECT 'Puzzles', 'Puzzles and brain teasers' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Puzzles')
UNION ALL
SELECT 'Educational Toys', 'Learning and educational toys' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Educational Toys')
UNION ALL
SELECT 'Card Games', 'Playing cards and card-based games' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Card Games')
UNION ALL
SELECT 'Arts and Crafts', 'Art supplies and crafting kits' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Arts and Crafts')
UNION ALL
SELECT 'Action Figures', 'Action figure toys' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Action Figures')
UNION ALL
SELECT 'Trading Card Games', 'Collectible card games' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Trading Card Games')
UNION ALL
SELECT 'Musical Toys', 'Musical instruments for kids' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Category` WHERE category_name = 'Musical Toys');

-- Set variables for specific categories
SET @toys_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toys');
SET @dolls_id = (SELECT category_id FROM `Category` WHERE category_name = 'Dolls');
SET @toy_weapons_id = (SELECT category_id FROM `Category` WHERE category_name = 'Toy Weapons');
SET @board_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Board Games');
SET @arts_and_crafts_id = (SELECT category_id FROM `Category` WHERE category_name = 'Arts and Crafts');
SET @card_games_id = (SELECT category_id FROM `Category` WHERE category_name = 'Card Games');

-- Insert product-category matches, including the "Toys" category for each product
INSERT INTO `Product_Category_Match` (`product_id`, `category_id`)
VALUES
-- Add "Toys" category for each product
(21, @toys_id),
(22, @toys_id),
(23, @toys_id),
(24, @toys_id),
(25, @toys_id),
(26, @toys_id),
(27, @toys_id),
(28, @toys_id),
(29, @toys_id),
(30, @toys_id),
(31, @toys_id),
(32, @toys_id),
(33, @toys_id),
(34, @toys_id),
(35, @toys_id),
(36, @toys_id),
(37, @toys_id),
(38, @toys_id),
(39, @toys_id),
(40, @toys_id),

-- Original category associations
(21, (SELECT category_id FROM `Category` WHERE category_name = 'Building Blocks')),
(22, @dolls_id),
(23, @toy_weapons_id),
(23, (SELECT category_id FROM `Category` WHERE category_name = 'Outdoor Toys')),
(24, (SELECT category_id FROM `Category` WHERE category_name = 'Toy Vehicles')),
(25, @board_games_id),
(26, (SELECT category_id FROM `Category` WHERE category_name = 'Puzzles')),
(26, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(27, @board_games_id),
(28, @card_games_id),
(28, @board_games_id),
(29, @arts_and_crafts_id),
(29, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(30, @arts_and_crafts_id),
(30, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(31, (SELECT category_id FROM `Category` WHERE category_name = 'Building Blocks')),
(31, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(32, (SELECT category_id FROM `Category` WHERE category_name = 'Action Figures')),
(33, (SELECT category_id FROM `Category` WHERE category_name = 'Puzzles')),
(34, (SELECT category_id FROM `Category` WHERE category_name = 'Trading Card Games')),
(35, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(36, (SELECT category_id FROM `Category` WHERE category_name = 'Toy Vehicles')),
(36, (SELECT category_id FROM `Category` WHERE category_name = 'Action Figures')),
(37, (SELECT category_id FROM `Category` WHERE category_name = 'Musical Toys')),
(37, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(38, (SELECT category_id FROM `Category` WHERE category_name = 'Outdoor Toys')),
(38, (SELECT category_id FROM `Category` WHERE category_name = 'Toy Vehicles')),
(39, (SELECT category_id FROM `Category` WHERE category_name = 'Musical Toys')),
(39, (SELECT category_id FROM `Category` WHERE category_name = 'Educational Toys')),
(40, (SELECT category_id FROM `Category` WHERE category_name = 'Trading Card Games'));


-- Insert cart items for users
INSERT INTO `Cart` (`user_id`, `variant_id`, `quantity`) 
VALUES
(2, 1, 2),  -- John has 2 Samsung Galaxy S21 in his cart
(3, 4, 1);  -- Jane has 1 PS5 in her cart

INSERT INTO `Order` (`customer_id`, `contact_email`, `contact_phone`, `delivery_method`, `delivery_location_id`, `payment_method`, `total_amount`, `order_status`, `purchased_time`, `delivery_estimate`, `created_at`, `updated_at`)
VALUES 
(2, 'jane@example.com', '555-123-4567', 'delivery', 3, 'card', 1299.99, 'Completed', '2023-01-05 09:30:00', 7, NOW(), NOW()),
(3, 'john@example.com', '444-555-6666', 'store_pickup', 4, 'card', 99.99, 'Failed', '2023-04-07 11:45:00', 0, NOW(), NOW()),
(4, 'nick@example.com', '333-222-1111', 'delivery', 1, 'card', 399.99, 'Completed', '2023-10-09 08:20:00', 4, NOW(), NOW()),
(5, 'pilip@example.com', '777-888-9999', 'delivery', 1, 'cash_on_delivery', 1199.99, 'Processing', '2024-01-11 13:10:00', 6, NOW(), NOW()),
(2, 'jane@example.com', '222-333-4444', 'store_pickup', 2, 'card', 699.99, 'Shipped', '2024-01-13 16:25:00', 1, NOW(), NOW()),
(3, 'john@example.com', '111-444-7777', 'delivery', 3, 'card', 1499.99, 'Completed', '2024-05-15 14:50:00', 5, NOW(), NOW()),
(4, 'nick@example.com', '666-555-4444', 'store_pickup', 4, 'cash_on_delivery', 799.99, 'Failed', '2023-01-17 10:40:00', 0, NOW(), NOW()),
(5, 'pilip@example.com', '888-999-0000', 'delivery', 1, 'card', 299.99, 'Processing', '2024-10-19 15:35:00', 3, NOW(), NOW());

INSERT INTO `OrderItem` (order_id, variant_id, discount, quantity, price) 
VALUES 
(1, 4, 0, 1, 1299.99),  -- Jane's order has 1 iPhone 14 Pro
(1, 2, 0, 2, 1099.99),  -- Jane's order has 2 MacBook Air M2
(1, 6, 0, 1, 399.99),   -- Jane's order has 1 Samsung Galaxy A52
(2, 7, 0, 1, 99.99),    -- John's order has 1 JBL Flip 6
(2, 8, 0, 2, 249.99),   -- John's order has 1 Sony SRS-XB43
(3, 3, 0, 1, 399.99),  -- Nick's order has 1 Samsung Galaxy A52
(3, 14, 0, 3, 389.97),  -- Nick's order has 3 Bose SoundLink Revolve
(3, 3, 0, 1, 249.99),  -- Nick's order has 1 Sony SRS-XB43
(4, 1, 0, 1, 1199.99),  -- Pilip's order has 1 MacBook Air M2
(4, 3, 0, 1, 799.99),   -- Pilip's order has 1 HP Pavilion Desktop
(5, 5, 0, 1, 699.99),   -- Jane's order has 1 OnePlus 11
(6, 16, 0, 1, 1499.99),  -- John's order has 1 Sony SRS-XB43
(7, 12, 0, 1, 799.99),  -- Nick's order has 1 Samsung Galaxy A52
(8, 18, 0, 1, 299.99);   -- Pilip's order has 1 OnePlus 11

UPDATE `Variant` 
SET interested = interested + 5
WHERE `variant_id` = 1;  -- 5 people are interested in Samsung Galaxy S21



delimiter $$

DROP EVENT IF EXISTS `2minutes__cancel_processing_orders`;

CREATE EVENT `2minutes__cancel_processing_orders`
ON SCHEDULE
    EVERY 2 MINUTE
DO
BEGIN
    START TRANSACTION;

        UPDATE Inventory i
        JOIN OrderItem oi ON i.variant_id = oi.variant_id
        JOIN `Order` o ON oi.order_id = o.order_id
        SET i.quantity_available = i.quantity_available + oi.quantity,
            o.order_status = 'Failed'
        WHERE o.order_status = 'Processing'
        AND o.updated_at + INTERVAL 2 MINUTE <= CURRENT_TIMESTAMP();
        
    COMMIT;
END$$

-- Added indexes for optimization
ALTER TABLE `Order` 
ADD INDEX `idx_order_status_updated_at` (order_status, updated_at);

delimiter ;
