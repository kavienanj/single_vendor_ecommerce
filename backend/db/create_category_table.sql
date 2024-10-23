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