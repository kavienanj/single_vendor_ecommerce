
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

CREATE TABLE `Transaction` (
  `transaction_id` INT AUTO_INCREMENT,
  `order_id` INT,
  `status` ENUM("Completed", "Failed"),
  `transaction_date` DATETIME,
  `amount` FLOAT,
  PRIMARY KEY (`transaction_id`),
  FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`)
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

DELIMITER $$

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

DELIMITER ;
DELIMITER $$

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
DELIMITER $$
CREATE PROCEDURE GetTopSellingProducts(IN start_date DATETIME, IN end_date DATETIME)
BEGIN
    SELECT p.title, v.name, SUM(o.quantity) AS total_sales
    FROM OrderItem o
    JOIN Variant v ON v.variant_id = o.variant_id
    JOIN Product p ON v.product_id = p.product_id
    JOIN `Order` t ON t.order_id = o.order_id
    WHERE t.purchased_time BETWEEN start_date AND end_date
    GROUP BY p.title, v.name
    ORDER BY total_sales DESC;
END $$

DELIMITER ;
SELECT -- 3rd report
    c.category_name,
    COUNT(oi.order_item_id) AS total_orders
FROM 
    OrderItem oi
JOIN 
    Variant v ON oi.variant_id = v.variant_id
JOIN 
    Product p ON v.product_id = p.product_id
JOIN 
    Product_Category_Match pcm ON p.product_id = pcm.product_id
JOIN 
    Category c ON pcm.category_id = c.category_id
GROUP BY 
    c.category_id
ORDER BY 
    total_orders DESC
LIMIT 1;
DELIMITER //

CREATE PROCEDURE GetTimePeriodWithMostInterest(
    IN p_product_id INT,
    IN p_period ENUM('daily', 'weekly', 'monthly')
)
BEGIN
    -- Declare variable to hold the formatted date component
    DECLARE period_format VARCHAR(10);

    -- Set the format based on the input period
    SET period_format = CASE
        WHEN p_period = 'daily' THEN '%Y-%m-%d'
        WHEN p_period = 'weekly' THEN '%Y-%u' -- Week of year
        WHEN p_period = 'monthly' THEN '%Y-%m'
        ELSE '%Y-%m-%d' -- Default to daily if input is invalid
    END;

    -- Select the time period with the most interest for the given product
    SELECT
        DATE_FORMAT(v.created_at, period_format) AS time_period,
        SUM(v.interested) AS total_interest
    FROM
        Variant v
    WHERE
        v.product_id = p_product_id
    GROUP BY
        time_period
    ORDER BY
        total_interest DESC
    LIMIT 1;  -- Return only the time period with the highest interest
END //

DELIMITER ;

CALL GetTimePeriodWithMostInterest(1, 'monthly');  -- Example: for product_id 1, find the month with the most interest
SELECT --customer order report
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    u.email,
    o.order_id,
    o.purchased_time,
    o.order_status,
    o.total_amount,
    v.name AS variant_name,
    oi.quantity,
    oi.price AS item_price,
    (oi.quantity * oi.price) AS total_price
FROM 
    User u
JOIN 
    `Order` o ON u.user_id = o.customer_id
JOIN 
    OrderItem oi ON o.order_id = oi.order_id
JOIN 
    Variant v ON oi.variant_id = v.variant_id
ORDER BY 
    o.purchased_time DESC;




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
