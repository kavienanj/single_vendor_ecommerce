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

CREATE TABLE `Order` (
  `order_id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `contact_email` VARCHAR(255),
  `contact_phone` VARCHAR(255),
  `delivery_method` ENUM("store_pickup", "delivery"),
  `payment_method` ENUM("Cash_on_delivery", "card"),
  `total_amount` FLOAT,
  `order_status` ENUM("Processing", "Shipped", "Completed"),
  `purchased_time` DATETIME,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`customer_id`) REFERENCES `User`(`user_id`) 
  on update restrict
  ON delete restrict
  
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

-- creating a custom attribute for a product and initiating the attribute values of the variants to be 'Not specified' 
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

-- change the custom attribute value of a variant
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

-- add variant
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

-- increase stock of a variant
CREATE PROCEDURE ADD_STOCK_VARIANT (variant_id INT, adding_quantity INT)
begin
  SET @current_stock = (
    select quantity_available
    from Inventory i
    where i.variant_id = variant_id
  );
  set @current_stock = @current_stock + adding_quantity;
  update Inventory i
  set quantity_available = @current_stock
  where i.variant_id = varinat_id;
END$$

CREATE PROCEDURE SET_CATEGORY (IN product_id INT, IN category_id INT)
BEGIN
  INSERT INTO Product_Category_Match values (product_id, category_id);
END$$

-- CREATE PROCEDURE GetSubCategories(
--     IN input_category_id INT
-- )
-- BEGIN
--     -- Use a recursive Common Table Expression (CTE)
--     WITH RECURSIVE SubCategoryCTE AS (
--         -- Anchor member: Select all immediate subcategories of the given category
--         SELECT 
--             pc.category_id,
--             pc.parent_category_id
--         FROM 
--             ParentCategory_Match pc
--         WHERE 
--             pc.parent_category_id = input_category_id

--         UNION ALL

--         -- Recursive member: Find the subcategories of the current subcategory
--         SELECT 
--             pcm.category_id,
--             pcm.parent_category_id
--         FROM 
--             ParentCategory_Match pcm
--         INNER JOIN 
--             SubCategoryCTE sc ON pcm.parent_category_id = sc.category_id
--     )
--     -- Select all subcategory IDs and their parent category IDs
--     SELECT c.category_id -- , c.category_name
--     FROM SubCategoryCTE sc
--     JOIN Category c ON sc.category_id = c.category_id;
--     
-- END $$


CREATE FUNCTION GetSubCategories(
    input_category_id INT
) 
RETURNS VARCHAR(100000) -- Adjust the length as per your needs
DETERMINISTIC
BEGIN
    -- Variable to hold the concatenated result
    DECLARE subcategories_list VARCHAR(10000) DEFAULT '';

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



-- CREATE function GetProductsInSubCategories(
--      input_category_id INT
-- )
-- RETURNS VARCHAR(100000) -- Adjust the length as per your needs
-- DETERMINISTIC
-- BEGIN
--     -- Temporary table to store the results of GetSubCategories
--     DROP TEMPORARY TABLE IF EXISTS TempSubCategories;
--     CREATE TEMPORARY TABLE TempSubCategories (
--         category_id INT
--     );
--     
--     DECLARE product_list VARCHAR(10000) DEFAULT '';
--     -- Insert the results of the GetSubCategories procedure into the temporary table
--     INSERT INTO TempSubCategories (category_id)
--     values (
--          GetSubCategories(input_category_id)
--     );
--     
--     -- Now, select all products belonging to these subcategories
--     SELECT p.product_id  -- , p.title, p.category_id
--     FROM Product p
--     WHERE p.category_id IN (SELECT category_id FROM TempSubCategories);

--     -- Clean up the temporary table
--     -- DROP TEMPORARY TABLE IF EXISTS TempSubCategories;
-- END$$



DELIMITER $$

CREATE FUNCTION GetProductsInSubCategories(
    input_category_id INT
)
RETURNS VARCHAR(100000) -- Adjust the length as needed
DETERMINISTIC
BEGIN
    -- Declare a variable to store the concatenated product IDs
    DECLARE product_list VARCHAR(100000) DEFAULT '';

    -- Retrieve subcategories using the GetSubCategories function
    DECLARE subcategories_list VARCHAR(100000);
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




-- CREATE PROCEDURE GetVariantsForSubCategories(
--     IN category_id INT
-- )
-- BEGIN
--     -- Create a temporary table to hold the product IDs returned by GetProductsInSubCategories
--     CREATE TEMPORARY TABLE IF NOT EXISTS TempProductIDs (
--         product_id INT
--     );
--     
--     -- Step 1: Insert product IDs returned by GetProductsInSubCategories
--     INSERT INTO TempProductIDs (product_id)
--     SELECT product_id
--     FROM (
--         CALL GetProductsInSubCategories(category_id)
--     ) AS SubProducts;
--     
--     -- Step 2: Select all variants for the products in TempProductIDs
--     SELECT v.variant_id --, v.product_id, v.name, v.price
--     FROM Variant v
--     WHERE v.product_id IN (SELECT product_id FROM TempProductIDs);

--     -- Step 3: Clean up by dropping the temporary table
--     DROP TEMPORARY TABLE IF EXISTS TempProductIDs;
-- END$$

-- DELIMITER ;
DELIMITER $$

CREATE FUNCTION GetVariantsForSubCategories(
    category_id INT
)
RETURNS VARCHAR(100000) -- Adjust the length as necessary
DETERMINISTIC
BEGIN
    -- Variable to hold the concatenated result of variant IDs
    DECLARE variant_list VARCHAR(100000) DEFAULT '';

    -- Temporary variable to hold product IDs
    DECLARE product_ids VARCHAR(100000);
    
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

DELIMITER ;
