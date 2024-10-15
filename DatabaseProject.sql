create schema ECommerceDatabase;
use ECommerceDatabase;

-- Create Category Table
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

-- Create Warehouse Table
CREATE TABLE `Warehouse` (
  `warehouse_id` INT AUTO_INCREMENT,
  `location` VARCHAR(255) not null,
  `capacity` INT NOT null,
  `avaliable_capacity` INT,
  PRIMARY KEY (`warehouse_id`)
);
delimiter $$
CREATE TRIGGER enter_avalible_capacity
BEFORE INSERT ON Warehouse
FOR EACH ROW
BEGIN
    SET NEW.avaliable_capacity = NEW.capacity ;
END$$
delimiter ;


-- Create Product Table
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

-- Create Variant Table
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

-- Create Custom_Attribute Table
CREATE TABLE `Custom_Attribute` (
  `attribute_id` INT AUTO_INCREMENT,
  `product_id` INT,
  `attribute_name` VARCHAR(255),
  PRIMARY KEY (`attribute_id`),
  FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
);

-- Create Custom_Attribute_Value Table
CREATE TABLE `Custom_Attribute_Value` (
  `variant_id` INT,
  `attribute_id` INT,
  `attribute_value` VARCHAR(255),
  PRIMARY KEY (`variant_id`, `attribute_id`),
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`),
  FOREIGN KEY (`attribute_id`) REFERENCES `Custom_Attribute`(`attribute_id`)
);

-- Create Inventory Table
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

-- DeliveryLocation Table
CREATE TABLE `DeliveryLocation` (
  `delivery_location_id` INT AUTO_INCREMENT,
  `location_name` VARCHAR(255) NOT NULL,
  `location_type` ENUM('store', 'city') NOT NULL DEFAULT 'city',
  `with_stock_delivery_days` INT,
  `without_stock_delivery_days` INT,
  PRIMARY KEY (`delivery_location_id`)
);

-- Create Role Table
CREATE TABLE `Role` (
  `role_id` INT AUTO_INCREMENT,
  `role_name` ENUM("Admin", "User", "Guest") NOT null,
  `description` VARCHAR(255),
  PRIMARY KEY (`role_id`)
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

-- DeliveryEstimate Table
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
  FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`),
  FOREIGN KEY (`variant_id`) REFERENCES `Variant`(`variant_id`)
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

INSERT INTO `Role` (`role_name`, `description`) 
VALUES 
    ('Admin', 'Has full access to the system'),
    ('User', 'Registered customer with limited access'),
    ('Guest', 'Unregistered customer with minimal access');
INSERT INTO `User` (`first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `is_guest`, `role_id`, `created_at`, `last_login`)
VALUES 
    ('John', 'Doe', 'john.doe@example.com', 'hashed_password_1', '1234567890', FALSE, 2, NOW(), NOW()),
    ('Jane', 'Smith', 'jane.smith@example.com', 'hashed_password_2', '0987654321', FALSE, 2, NOW(), NULL),
    ('Guest', 'User', 'guest.user@example.com', 'hashed_password_3', '1122334455', TRUE, 3, NOW(), NULL);
-- INSERT INTO `Order` (`customer_id`, `contact_email`, `contact_phone`, `delivery_method`, `payment_method`, `total_amount`, `order_status`, `purchased_time`)
-- VALUES 
--     (1, 'john.doe@example.com', '1234567890', 'delivery', 'card', 199.99, 'Completed', '2024-03-02'),
--     (2, 'jane.smith@example.com', '0987654321', 'store_pickup', 'Cash_on_delivery', 59.99, 'Shipped', '2024-09-04'),
--     (3, 'guest.user@example.com', '1122334455', 'delivery', 'Cash_on_delivery', 120.00, 'Processing', '2024-09-05');
-- use DataBaseProject;
-- CALL Get_Quarterly_Sales_By_Year(2024);
