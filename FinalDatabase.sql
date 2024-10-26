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

-- Insert warehouse data
INSERT INTO `Warehouse` (`location`, `capacity`, `available_capacity`) 
VALUES 
('New York', 1000, 1000),
('Los Angeles', 800, 800);

-- Insert main categories
INSERT INTO `Category` (`category_name`, `description`) 
VALUES 
('Computers', 'Desktops, Laptops, and Computer Accessories'),
('Mobile Phones', 'Smartphones and Mobile Accessories'),
('Speakers', 'Audio speakers and sound systems');

-- Insert sub-categories (Brands under each main category)
INSERT INTO `Category` (`category_name`, `description`) 
VALUES 
('Apple', 'Apple products'),   -- Sub-category under Computers & Mobile Phones
('Samsung', 'Samsung products'), -- Sub-category under Computers & Mobile Phones
('Lenovo', 'Lenovo products'),   -- Sub-category under Computers
('HP', 'HP products'),           -- Sub-category under Computers
('OnePlus', 'OnePlus smartphones'), -- Sub-category under Mobile Phones
('JBL', 'JBL Speakers'),         -- Sub-category under Speakers
('Sony', 'Sony Speakers'),       -- Sub-category under Speakers
('Bose', 'Bose Speakers');       -- Sub-category under Speakers

-- Parent Category relationships
INSERT INTO `ParentCategory_Match` (`category_id`, `parent_category_id`) 
VALUES
(4, 1),  -- Apple under Computers
(4, 2),  -- Apple under Computers
(5, 2),  -- Samsung under Mobile Phones
(6, 1),  -- Lenovo under Computers
(7, 1),  -- HP under Computers
(8, 2),  -- OnePlus under Mobile Phones
(9, 3),  -- JBL under Speakers
(10, 3), -- Sony under Speakers
(11, 3); -- Bose under Speakers

-- Insert products
INSERT INTO `Product` (`title`, `description`, `sku`, `weight`, `created_at`, `updated_at`, `default_price`, `default_image`)
VALUES 
('Apple MacBook Air M2', '13-inch laptop with Apple M2 chip', 'MBA_M2', 1.24, NOW(), NOW(), 999.99, 'url_macbook_air_m2.jpg'),
('Lenovo ThinkPad X1 Carbon', '14-inch ultrabook with Intel Core i7', 'LTP_X1C', 1.09, NOW(), NOW(), 1299.99, 'url_lenovo_x1_carbon.jpg'),
('HP Pavilion Desktop', 'High-performance desktop computer', 'HP_PVD', 8.5, NOW(), NOW(), 849.99, 'url_hp_pavilion_desktop.jpg'),
('Apple iPhone 14 Pro', 'Latest iPhone with Pro features', 'IP14_PRO', 0.7, NOW(), NOW(), 1099.99, 'url_iphone14_pro.jpg'),
('OnePlus 11', 'Flagship OnePlus smartphone', 'ONEP11', 0.6, NOW(), NOW(), 799.99, 'url_oneplus_11.jpg'),
('Samsung Galaxy A52', 'Mid-range Samsung smartphone', 'SG_A52', 0.5, NOW(), NOW(), 399.99, 'url_galaxy_a52.jpg'),
('JBL Flip 6', 'Portable waterproof Bluetooth speaker', 'JBL_FLIP6', 0.55, NOW(), NOW(), 99.99, 'url_jbl_flip6.jpg'),
('Sony SRS-XB43', 'Extra Bass wireless speaker', 'SRS_XB43', 2.95, NOW(), NOW(), 249.99, 'url_sony_xb43.jpg'),
('Bose SoundLink Revolve', '360-degree Bluetooth speaker', 'BOSE_REVOLVE', 0.66, NOW(), NOW(), 199.99, 'url_bose_revolve.jpg');

-- Insert product categories (Match products with specific brands)
INSERT INTO `Product_Category_Match` (`product_id`, `category_id`) 
VALUES 
(1, 4),  -- MacBook Air under Apple
(1, 1),  -- MacBook Air under Apple
(2, 6),  -- ThinkPad X1 under Lenovo
(2, 1),  -- ThinkPad X1 under Lenovo
(3, 7),  -- HP Pavilion under HP
(3, 1),  -- HP Pavilion under HP
(4, 4),  -- iPhone 14 Pro under Apple
(4, 2),  -- iPhone 14 Pro under Apple
(5, 8),  -- OnePlus 11 under OnePlus
(5, 2),  -- OnePlus 11 under OnePlus
(6, 5),  -- Galaxy A52 under Samsung
(6, 2),  -- Galaxy A52 under Samsung
(7, 9),  -- JBL Flip 6 under JBL
(7, 3),  -- JBL Flip 6 under JBL
(8, 10), -- Sony SRS-XB43 under Sony
(8, 3), -- Sony SRS-XB43 under Sony
(9, 11), -- Bose SoundLink Revolve under Bose
(9, 3); -- Bose SoundLink Revolve under Bose

-- Insert product variants with multiple options
INSERT INTO `Variant` (`product_id`, `name`, `image_url`, `price`, `created_at`, `updated_at`) 
VALUES 
-- Apple MacBook Air M2
(1, 'MacBook Air M2 - 256GB SSD', 'url_macbook_air_256gb.jpg', 1099.99, NOW(), NOW()),
(1, 'MacBook Air M2 - 512GB SSD', 'url_macbook_air_512gb.jpg', 1399.99, NOW(), NOW()),

-- Lenovo ThinkPad X1 Carbon
(2, 'ThinkPad X1 Carbon - 16GB RAM', 'url_thinkpad_x1_16gb.jpg', 1399.99, NOW(), NOW()),
(2, 'ThinkPad X1 Carbon - 32GB RAM', 'url_thinkpad_x1_32gb.jpg', 1699.99, NOW(), NOW()),

-- HP Pavilion Desktop
(3, 'HP Pavilion Desktop - 512GB SSD', 'url_hp_pavilion_512gb.jpg', 799.99, NOW(), NOW()),
(3, 'HP Pavilion Desktop - 1TB HDD', 'url_hp_pavilion_1tb.jpg', 899.99, NOW(), NOW()),

-- Apple iPhone 14 Pro
(4, 'iPhone 14 Pro - 512GB', 'url_iphone_14_pro_512gb.jpg', 1299.99, NOW(), NOW()),
(4, 'iPhone 14 Pro - 1TB', 'url_iphone_14_pro_1tb.jpg', 1499.99, NOW(), NOW()),

-- OnePlus 11
(5, 'OnePlus 11 - 256GB', 'url_oneplus_11_256gb.jpg', 699.99, NOW(), NOW()),
(5, 'OnePlus 11 - 512GB', 'url_oneplus_11_512gb.jpg', 799.99, NOW(), NOW()),

-- Samsung Galaxy A52
(6, 'Samsung Galaxy A52 - 128GB', 'url_galaxy_a52_128gb.jpg', 349.99, NOW(), NOW()),
(6, 'Samsung Galaxy A52 - 256GB', 'url_galaxy_a52_256gb.jpg', 399.99, NOW(), NOW()),

-- JBL Flip 6
(7, 'JBL Flip 6 - Black', 'url_jbl_flip6_black.jpg', 129.99, NOW(), NOW()),
(7, 'JBL Flip 6 - Blue', 'url_jbl_flip6_blue.jpg', 129.99, NOW(), NOW()),

-- Sony SRS-XB43
(8, 'Sony SRS-XB43 - Black', 'url_sony_srsxb43_black.jpg', 249.99, NOW(), NOW()),
(8, 'Sony SRS-XB43 - Blue', 'url_sony_srsxb43_blue.jpg', 249.99, NOW(), NOW()),

-- Bose SoundLink Revolve
(9, 'Bose SoundLink Revolve - Silver', 'url_bose_revolve_silver.jpg', 199.99, NOW(), NOW()),
(9, 'Bose SoundLink Revolve - Black', 'url_bose_revolve_black.jpg', 199.99, NOW(), NOW());

-- Insert inventory with updated variants
INSERT INTO `Inventory` (`warehouse_id`, `variant_id`, `quantity_available`, `last_updated`) 
VALUES 
-- MacBook Air M2
(1, 1, 100, NOW()),
(1, 2, 75, NOW()),

-- ThinkPad X1 Carbon
(1, 3, 50, NOW()),
(1, 4, 30, NOW()),

-- HP Pavilion Desktop
(2, 5, 20, NOW()),
(2, 6, 15, NOW()),

-- iPhone 14 Pro
(1, 7, 150, NOW()),
(1, 8, 100, NOW()),

-- OnePlus 11
(2, 9, 75, NOW()),
(2, 10, 50, NOW()),

-- Samsung Galaxy A52
(1, 11, 200, NOW()),
(1, 12, 100, NOW()),

-- JBL Flip 6
(2, 13, 300, NOW()),
(2, 14, 200, NOW()),

-- Sony SRS-XB43
(1, 15, 100, NOW()),
(1, 16, 75, NOW()),

-- Bose SoundLink Revolve
(2, 17, 50, NOW()),
(2, 18, 40, NOW());

-- Insert product attributes (Attributes that apply to products)
INSERT INTO `Custom_Attribute` (`product_id`, `attribute_name`) 
VALUES 
-- MacBook Air M2
(1, 'Storage'),
(1, 'Color'),

-- ThinkPad X1 Carbon
(2, 'RAM'),
(2, 'Storage'),

-- HP Pavilion Desktop
(3, 'Storage'),

-- iPhone 14 Pro
(4, 'Storage'),
(4, 'Color'),

-- OnePlus 11
(5, 'Storage'),
(5, 'Color'),

-- Samsung Galaxy A52
(6, 'Storage'),
(6, 'Color'),

-- JBL Flip 6
(7, 'Color'),

-- Sony SRS-XB43
(8, 'Color'),

-- Bose SoundLink Revolve
(9, 'Color');

-- Insert custom attribute values (Assigning specific values to each variant)
INSERT INTO `Custom_Attribute_Value` (`variant_id`, `attribute_id`, `attribute_value`) 
VALUES 
-- MacBook Air M2 Variants
(1, 1, '256GB'),  -- MacBook Air M2 - 256GB SSD
(1, 2, 'Silver'), -- MacBook Air M2 - Color Silver
(2, 1, '512GB'),  -- MacBook Air M2 - 512GB SSD
(2, 2, 'Silver'), -- MacBook Air M2 - Color Silver

-- ThinkPad X1 Carbon Variants
(3, 3, '16GB'),   -- ThinkPad X1 Carbon - 16GB RAM
(3, 4, '512GB'),  -- ThinkPad X1 Carbon - 512GB Storage
(4, 3, '32GB'),   -- ThinkPad X1 Carbon - 32GB RAM
(4, 4, '1TB'),    -- ThinkPad X1 Carbon - 1TB Storage

-- HP Pavilion Desktop Variants
(5, 5, '512GB SSD'),  -- HP Pavilion - 512GB SSD
(6, 5, '1TB HDD'),    -- HP Pavilion - 1TB HDD

-- iPhone 14 Pro Variants
(7, 6, '512GB'),  -- iPhone 14 Pro - 512GB Storage
(7, 7, 'Gold'),   -- iPhone 14 Pro - Gold Color
(8, 6, '1TB'),    -- iPhone 14 Pro - 1TB Storage
(8, 7, 'Silver'), -- iPhone 14 Pro - Silver Color

-- OnePlus 11 Variants
(9, 8, '256GB'),  -- OnePlus 11 - 256GB Storage
(9, 9, 'Green'),  -- OnePlus 11 - Green Color
(10, 8, '512GB'), -- OnePlus 11 - 512GB Storage
(10, 9, 'Black'), -- OnePlus 11 - Black Color

-- Samsung Galaxy A52 Variants
(11, 10, '128GB'),  -- Samsung Galaxy A52 - 128GB Storage
(11, 11, 'White'),  -- Samsung Galaxy A52 - White Color
(12, 10, '256GB'),  -- Samsung Galaxy A52 - 256GB Storage
(12, 11, 'Black'),  -- Samsung Galaxy A52 - Black Color

-- JBL Flip 6 Variants
(13, 12, 'Black'),  -- JBL Flip 6 - Black Color
(14, 12, 'Blue'),   -- JBL Flip 6 - Blue Color

-- Sony SRS-XB43 Variants
(15, 13, 'Black'),  -- Sony SRS-XB43 - Black Color
(16, 13, 'Blue'),   -- Sony SRS-XB43 - Blue Color

-- Bose SoundLink Revolve Variants
(17, 14, 'Silver'),  -- Bose SoundLink Revolve - Silver Color
(18, 14, 'Black');   -- Bose SoundLink Revolve - Black Color


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
('Admin', 'C', 'admin@c.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '1234567890', 1, 0, 1, NOW()),
('Jane', 'Smith', 'jane@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('John', 'Doe', 'john@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('Nick', 'Noah', 'nick@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW()),
('Pilip', 'Man', 'pilip@example.com', '$2a$10$j/DeFvwmLpBjAbJjFRJo6uwQb8/0UnejZOqWKmXTwASwwm.m5DDxq', '0987654321', 2, 0, 2, NOW());

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
