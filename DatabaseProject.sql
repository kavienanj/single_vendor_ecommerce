
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

CREATE TABLE `Variant` (
  `variant_id` INT AUTO_INCREMENT,
  `product_id` INT not null,
  `name` VARCHAR(255) not null,
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
  `quantity_available` INT not null,
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
create procedure ADD_PRODUCT (title VARCHAR(255) , description varchar(255) , sku varchar(255), weight float, warehause_id INT)
begin
	insert into Product values (default,title,description,sku,weight,warehouse_id,now(),now());
END$$

CREATE PROCEDURE ADD_VARIANT( product_id INT , name varchar(255), price float,quantity INT)
begin
	insert into Variant values (default,product_id,name,price,now(),now());
    
    set @warehouse_id = (
		select warehouse_id 
        from Product p
        where p.product_id = product_id
        );
	set @variant_id = LAST_INSERT_ID();
    
    insert into Inventory values (default,@warehouse_id,@varinat_id,quantity,now());
end$$

CREATE PROCEDURE SET_CATEGORY (IN product_id INT, IN category_id INT)
BEGIN
  INSERT INTO Product_Category_Match values (product_id, category_id);
END$$

CREATE PROCEDURE GetSubCategories(
    IN input_category_id INT
)
BEGIN
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
    -- Select all subcategory IDs and their parent category IDs
    SELECT c.category_id -- , c.category_name
    FROM SubCategoryCTE sc
    JOIN Category c ON sc.category_id = c.category_id;
    
END $$

CREATE PROCEDURE GetProductsInSubCategories(
    IN input_category_id INT
)
BEGIN
    -- Temporary table to store the results of GetSubCategories
    DROP TEMPORARY TABLE IF EXISTS TempSubCategories;
    CREATE TEMPORARY TABLE TempSubCategories (
        category_id INT
    );
    
    -- Insert the results of the GetSubCategories procedure into the temporary table
    INSERT INTO TempSubCategories (category_id)
    SELECT sc.category_id
    FROM (
        -- This is where we call the GetSubCategories procedure
        CALL GetSubCategories(input_category_id)
    ) AS sc;
    
    -- Now, select all products belonging to these subcategories
    SELECT p.product_id  -- , p.title, p.category_id
    FROM Product p
    WHERE p.category_id IN (SELECT category_id FROM TempSubCategories);

    -- Clean up the temporary table
    DROP TEMPORARY TABLE IF EXISTS TempSubCategories;
END$$


CREATE PROCEDURE GetVariantsForSubCategories(
    IN category_id INT
)
BEGIN
    -- Create a temporary table to hold the product IDs returned by GetProductsInSubCategories
    CREATE TEMPORARY TABLE IF NOT EXISTS TempProductIDs (
        product_id INT
    );
    
    -- Step 1: Insert product IDs returned by GetProductsInSubCategories
    INSERT INTO TempProductIDs (product_id)
    SELECT product_id
    FROM (
        CALL GetProductsInSubCategories(category_id)
    ) AS SubProducts;
    
    -- Step 2: Select all variants for the products in TempProductIDs
    SELECT v.variant_id --, v.product_id, v.name, v.price
    FROM Variant v
    WHERE v.product_id IN (SELECT product_id FROM TempProductIDs);

    -- Step 3: Clean up by dropping the temporary table
    DROP TEMPORARY TABLE IF EXISTS TempProductIDs;
END$$

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

-- Get cart items

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
INSERT INTO `Order` (`customer_id`, `contact_email`, `contact_phone`, `delivery_method`, `payment_method`, `total_amount`, `order_status`, `purchased_time`)
VALUES 
    (1, 'john.doe@example.com', '1234567890', 'delivery', 'card', 199.99, 'Completed', '2024-03-02'),
    (2, 'jane.smith@example.com', '0987654321', 'store_pickup', 'Cash_on_delivery', 59.99, 'Shipped', '2024-09-04'),
    (3, 'guest.user@example.com', '1122334455', 'delivery', 'Cash_on_delivery', 120.00, 'Processing', '2024-09-05');
use DataBaseProject;
CALL Get_Quarterly_Sales_By_Year(2024);
