-- =====================================================
-- INVENTORY MANAGEMENT SYSTEM
-- Company: Maun Smart Pack East Africa
-- Purpose: Manage ziplock bag inventory and sales
-- =====================================================


CREATE DATABASE IF NOT EXISTS maun_inventory_db;
USE maun_inventory_db;

-- =====================================================
-- TABLE 1: Product Categories
-- =====================================================
CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- =====================================================
-- TABLE 2: Products (Main product table)
-- =====================================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    size_capacity VARCHAR(50),
    dimensions VARCHAR(50),
    color VARCHAR(50),
    has_window BOOLEAN DEFAULT FALSE,
    has_valve BOOLEAN DEFAULT FALSE,
    material_type VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

-- =====================================================
-- TABLE 3: Price Tiers (Different pricing based on quantity)
-- =====================================================
CREATE TABLE price_tiers (
    tier_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    min_quantity INT NOT NULL,
    max_quantity INT,
    price_per_unit DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_product_tier (product_id, min_quantity)
);

-- =====================================================
-- TABLE 4: Suppliers
-- =====================================================
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50) DEFAULT 'Nairobi',
    country VARCHAR(50) DEFAULT 'Kenya'
);

-- =====================================================
-- TABLE 5: Customers
-- =====================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    business_name VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    customer_type ENUM('Retail', 'Wholesale', 'Corporate') DEFAULT 'Retail',
    registration_date DATE DEFAULT (CURRENT_DATE)
);

-- =====================================================
-- TABLE 6: Inventory (Current stock levels)
-- =====================================================
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 100,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    location VARCHAR(100) DEFAULT 'Main Warehouse',
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- TABLE 7: Purchase Orders (From suppliers)
-- =====================================================
CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery DATE,
    total_amount DECIMAL(12,2),
    status ENUM('Pending', 'Confirmed', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- =====================================================
-- TABLE 8: Purchase Order Details
-- =====================================================
CREATE TABLE po_details (
    po_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) AS (quantity * unit_price) STORED,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- TABLE 9: Sales Orders (To customers)
-- =====================================================
CREATE TABLE sales_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATE,
    total_amount DECIMAL(12,2),
    payment_status ENUM('Pending', 'Partial', 'Paid') DEFAULT 'Pending',
    order_status ENUM('Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Processing',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- =====================================================
-- TABLE 10: Sales Order Details
-- =====================================================
CREATE TABLE order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    subtotal DECIMAL(12,2) AS (quantity * unit_price * (1 - discount_percent/100)) STORED,
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- TABLE 11: Stock Movements 
-- =====================================================
CREATE TABLE stock_movements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    movement_type ENUM('IN', 'OUT', 'ADJUSTMENT') NOT NULL,
    quantity INT NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- INSERT  DATA
-- =====================================================

-- Insert Product Categories
INSERT INTO product_categories (category_name, description) VALUES
('Kraft Ziplock Stand Up Pouch', 'Brown and white kraft bags with window and ziplock'),
('Kraft Flat Bottom Ziplock', 'Flat bottom design kraft bags with window'),
('Ziplock Coffee Pouch', 'Specialized coffee pouches with optional valve'),
('Aluminium Stand Up Ziplock', 'Silver and gold aluminum ziplock bags'),
('Clear Flat Bottom Ziplock', 'Fully transparent flat bottom bags'),
('Colored Aluminium Ziplock', 'Various colored aluminum resealable bags');

-- Insert  Products
INSERT INTO products (product_name, category_id, size_capacity, dimensions, color, has_window, material_type) VALUES
('Brown Kraft Stand Up - 50g', 1, '50g', '9*14 cm', 'Brown', TRUE, 'Kraft'),
('Brown Kraft Stand Up - 100-150g', 1, '100-150g', '12*20 cm', 'Brown', TRUE, 'Kraft'),
('Brown Kraft Stand Up - 200-300g', 1, '200-300g', '14*20 cm', 'Brown', TRUE, 'Kraft'),
('Brown Kraft Stand Up - 1-1.5kg', 1, '1-1.5kg', '20*30 cm', 'Brown', TRUE, 'Kraft'),
('Kraft Flat Bottom - 100-150g', 2, '100-150g', '10*20+6', 'Brown', TRUE, 'Kraft'),
('Kraft Flat Bottom - 400-500g', 2, '400-500g', '14*24+6', 'Brown', TRUE, 'Kraft'),
('Coffee Pouch with Valve - 250g', 3, '250g', 'Standard', 'Brown', FALSE, 'Kraft'),
('Coffee Pouch with Valve - 500g', 3, '500g', 'Standard', 'Brown', FALSE, 'Kraft'),
('Silver Aluminium - 50g', 4, '50g', '9*14 cm', 'Silver', FALSE, 'Aluminium'),
('Gold Aluminium - 200-300g', 4, '200-300g', '14*20 cm', 'Gold', FALSE, 'Aluminium'),
('Clear Flat Bottom - 100-150g', 5, '100-150g', '10*20+6', 'Clear', FALSE, 'Plastic'),
('Black Aluminium Ziplock - 100-150g', 6, '100-150g', '12*20 cm', 'Black', FALSE, 'Aluminium'),
('Purple Aluminium Ziplock - 200-300g', 6, '200-300g', '14*20 cm', 'Purple', FALSE, 'Aluminium');

-- Insert Price Tiers for products
INSERT INTO price_tiers (product_id, min_quantity, max_quantity, price_per_unit) VALUES
-- Brown Kraft Stand Up - 50g
(1, 10, 99, 10.00),
(1, 100, 499, 9.50),
(1, 500, 999, 9.00),
(1, 1000, NULL, 8.50),
-- Brown Kraft Stand Up - 100-150g
(2, 10, 99, 15.00),
(2, 100, 499, 14.50),
(2, 500, 999, 14.00),
(2, 1000, NULL, 13.50),
-- Brown Kraft Stand Up - 200-300g
(3, 10, 99, 18.00),
(3, 100, 499, 17.50),
(3, 500, 999, 17.00),
(3, 1000, NULL, 16.50),
-- Coffee Pouch with Valve - 250g
(7, 10, 99, 35.00),
(7, 100, 499, 33.00),
(7, 500, 999, 31.00),
(7, 1000, NULL, 30.00);

-- Insert Sample Suppliers
INSERT INTO suppliers (supplier_name, contact_person, phone, email, address) VALUES
('Kenya Packaging Solutions', 'John Kamau', '+254722123456', 'john@kps.co.ke', 'Industrial Area, Nairobi'),
('East Africa Materials Ltd', 'Sarah Wanjiru', '+254733987654', 'sarah@eaml.co.ke', 'Mombasa Road, Nairobi'),
('Import Direct China', 'Li Wei', '+8613800138000', 'liwei@importdirect.cn', 'Guangzhou, China');

-- Insert  Customers
INSERT INTO customers (customer_name, business_name, phone, email, customer_type) VALUES
('Grace Muthoni', 'Grace Coffee Shop', '+254720111222', 'grace@coffeeshop.co.ke', 'Retail'),
('Peter Ochieng', 'Bulk Buyers Ltd', '+254721333444', 'peter@bulkbuyers.co.ke', 'Wholesale'),
('Mary Njeri', 'Njeri Spices & Herbs', '+254722555666', 'mary@njerispices.co.ke', 'Retail'),
('Corporate Foods Kenya', 'Corporate Foods', '+254723777888', 'info@corporatefoods.co.ke', 'Corporate');

-- Insert Inventory Records
INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(1, 500, 100),
(2, 350, 100),
(3, 200, 50),
(4, 150, 50),
(5, 300, 75),
(6, 250, 75),
(7, 100, 50),
(8, 80, 50),
(9, 400, 100),
(10, 300, 75);

-- Insert  Purchase Order
INSERT INTO purchase_orders (supplier_id, order_date, expected_delivery, total_amount, status) VALUES
(1, '2024-01-15', '2024-01-25', 15000.00, 'Delivered'),
(2, '2024-01-20', '2024-01-30', 25000.00, 'Confirmed');

-- Insert Purchase Order Details
INSERT INTO po_details (po_id, product_id, quantity, unit_price) VALUES
(1, 1, 1000, 8.00),
(1, 2, 500, 14.00),
(2, 7, 500, 30.00),
(2, 8, 300, 33.33);

-- Insert Sales Orders
INSERT INTO sales_orders (customer_id, order_date, delivery_date, total_amount, payment_status, order_status) VALUES
(1, '2024-01-22 10:30:00', '2024-01-23', 450.00, 'Paid', 'Delivered'),
(2, '2024-01-23 14:15:00', '2024-01-25', 8500.00, 'Paid', 'Processing'),
(3, '2024-01-24 09:00:00', '2024-01-26', 1750.00, 'Pending', 'Processing');

-- Insert Sales Order Details
INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(1, 7, 10, 35.00, 0),
(1, 1, 10, 10.00, 0),
(2, 1, 1000, 8.50, 0),
(3, 2, 100, 14.50, 0),
(3, 3, 50, 18.00, 10);

-- Insert Stock Movements
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes) VALUES
(1, 'IN', 1000, 'PO', 1, 'Purchase order delivery'),
(2, 'IN', 500, 'PO', 1, 'Purchase order delivery'),
(1, 'OUT', 10, 'SO', 1, 'Sales order fulfillment'),
(1, 'OUT', 1000, 'SO', 2, 'Sales order fulfillment'),
(2, 'OUT', 100, 'SO', 3, 'Sales order fulfillment'),
(3, 'OUT', 50, 'SO', 3, 'Sales order fulfillment');

-- =====================================================
-- CREATED INDEXES 
-- =====================================================
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_price_tiers_product ON price_tiers(product_id);
CREATE INDEX idx_order_details_order ON order_details(order_id);
CREATE INDEX idx_po_details_po ON po_details(po_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_sales_orders_customer ON sales_orders(customer_id);
CREATE INDEX idx_purchase_orders_supplier ON purchase_orders(supplier_id);



-- View: Current Stock Status with Product Details
CREATE VIEW stock_status AS
SELECT 
    p.product_id,
    p.product_name,
    pc.category_name,
    p.size_capacity,
    p.color,
    i.quantity_in_stock,
    i.reorder_level,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'Reorder Needed'
        WHEN i.quantity_in_stock <= i.reorder_level * 1.5 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
LEFT JOIN inventory i ON p.product_id = i.product_id
ORDER BY p.product_id;

-- View: Customer Order Summary
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(DISTINCT so.order_id) AS total_orders,
    SUM(so.total_amount) AS total_spent,
    MAX(so.order_date) AS last_order_date
FROM customers c
LEFT JOIN sales_orders so ON c.customer_id = so.customer_id
GROUP BY c.customer_id;

-- View: Product Price List (showing all tiers)
CREATE VIEW product_price_list AS
SELECT 
    p.product_name,
    pc.category_name,
    p.size_capacity,
    pt.min_quantity,
    pt.max_quantity,
    pt.price_per_unit,
    CONCAT(pt.min_quantity, '-', IFNULL(pt.max_quantity, 'above'), ' pcs') AS quantity_range
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN price_tiers pt ON p.product_id = pt.product_id
ORDER BY p.product_id, pt.min_quantity;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure: Process a sale and update inventory
DELIMITER //
CREATE PROCEDURE process_sale(
    IN p_order_id INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE cur CURSOR FOR 
        SELECT product_id, quantity 
        FROM order_details 
        WHERE order_id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    START TRANSACTION;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Update inventory
        UPDATE inventory 
        SET quantity_in_stock = quantity_in_stock - v_quantity
        WHERE product_id = v_product_id;
        
        -- Record stock movement
        INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id)
        VALUES (v_product_id, 'OUT', v_quantity, 'SO', p_order_id);
    END LOOP;
    
    CLOSE cur;
    
    -- Update order status
    UPDATE sales_orders 
    SET order_status = 'Shipped'
    WHERE order_id = p_order_id;
    
    COMMIT;
END//
DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger: Update inventory timestamp when stock changes
DELIMITER //
CREATE TRIGGER update_inventory_timestamp
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    SET NEW.last_updated = CURRENT_TIMESTAMP;
END//
DELIMITER ;



show tables;

DESCRIBE products;
DESCRIBE sales_orders;
DESCRIBE order_details;

SELECT * FROM product_categories;
