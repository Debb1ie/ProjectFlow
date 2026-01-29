-- ================================================
-- PROJECT MILESTONE TRACKER & INVOICE SYSTEM
-- Professional Client Management Database
-- ================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS milestones;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS admin_users;

-- ================================================
-- ADMIN USERS TABLE
-- ================================================
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    role ENUM('super_admin', 'project_manager', 'finance') DEFAULT 'project_manager',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- ================================================
-- CLIENTS TABLE
-- ================================================
CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    industry VARCHAR(100),
    client_portal_password VARCHAR(255) NOT NULL,
    logo_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT
);

-- ================================================
-- PROJECTS TABLE
-- ================================================
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    project_type ENUM('web_development', 'mobile_app', 'design', 'consulting', 'marketing', 'other') NOT NULL,
    status ENUM('planning', 'in_progress', 'review', 'completed', 'on_hold', 'cancelled') DEFAULT 'planning',
    start_date DATE NOT NULL,
    deadline DATE,
    budget DECIMAL(12, 2),
    assigned_manager INT,
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    completion_percentage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_manager) REFERENCES admin_users(admin_id) ON DELETE SET NULL
);

-- ================================================
-- MILESTONES TABLE
-- ================================================
CREATE TABLE milestones (
    milestone_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    milestone_name VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'delayed') DEFAULT 'pending',
    completion_date TIMESTAMP NULL,
    payment_amount DECIMAL(10, 2) DEFAULT 0.00,
    is_billable BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

-- ================================================
-- INVOICES TABLE
-- ================================================
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    project_id INT NOT NULL,
    client_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    status ENUM('draft', 'sent', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    payment_date TIMESTAMP NULL,
    payment_method VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

-- ================================================
-- INVOICE ITEMS TABLE
-- ================================================
CREATE TABLE invoice_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    milestone_id INT,
    description TEXT NOT NULL,
    quantity DECIMAL(10, 2) DEFAULT 1.00,
    unit_price DECIMAL(10, 2) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (milestone_id) REFERENCES milestones(milestone_id) ON DELETE SET NULL
);

-- ================================================
-- INDEXES FOR PERFORMANCE
-- ================================================
CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_milestones_project ON milestones(project_id);
CREATE INDEX idx_milestones_status ON milestones(status);
CREATE INDEX idx_invoices_project ON invoices(project_id);
CREATE INDEX idx_invoices_client ON invoices(client_id);
CREATE INDEX idx_invoices_status ON invoices(status);

-- ================================================
-- SAMPLE DATA FOR DEMONSTRATION
-- ================================================

-- Insert Admin Users
INSERT INTO admin_users (username, email, password_hash, full_name, role) VALUES
('admin', 'admin@company.com', '$2y$10$example_hash_here', 'John Administrator', 'super_admin'),
('sarah.pm', 'sarah@company.com', '$2y$10$example_hash_here', 'Sarah Project Manager', 'project_manager'),
('mike.finance', 'mike@company.com', '$2y$10$example_hash_here', 'Mike Finance', 'finance');

-- Insert Clients
INSERT INTO clients (company_name, contact_person, email, phone, industry, client_portal_password, address) VALUES
('TechVision Inc', 'Robert Chen', 'robert@techvision.com', '+1-555-0101', 'Technology', '$2y$10$client_hash', '123 Innovation Drive, San Francisco, CA 94105'),
('GreenLeaf Organics', 'Maria Rodriguez', 'maria@greenleaf.com', '+1-555-0102', 'Retail', '$2y$10$client_hash', '456 Eco Street, Portland, OR 97201'),
('FinanceHub Solutions', 'David Kim', 'david@financehub.com', '+1-555-0103', 'Finance', '$2y$10$client_hash', '789 Wall Street, New York, NY 10005'),
('CreativeMinds Studio', 'Emma Thompson', 'emma@creativeminds.com', '+1-555-0104', 'Design', '$2y$10$client_hash', '321 Art Avenue, Austin, TX 78701');

-- Insert Projects
INSERT INTO projects (client_id, project_name, description, project_type, status, start_date, deadline, budget, assigned_manager, priority, completion_percentage) VALUES
(1, 'E-Commerce Platform Redesign', 'Complete overhaul of online shopping experience with modern UI/UX', 'web_development', 'in_progress', '2025-01-15', '2025-04-30', 125000.00, 2, 'high', 45),
(1, 'Mobile App Development', 'iOS and Android native apps for customer engagement', 'mobile_app', 'planning', '2025-02-01', '2025-07-31', 180000.00, 2, 'high', 10),
(2, 'Brand Identity Refresh', 'Logo redesign and brand guidelines development', 'design', 'in_progress', '2025-01-10', '2025-03-15', 45000.00, 2, 'medium', 65),
(3, 'Financial Dashboard System', 'Real-time analytics and reporting platform', 'web_development', 'in_progress', '2024-12-01', '2025-03-31', 95000.00, 2, 'critical', 70),
(4, 'Marketing Campaign Platform', 'Automated email and social media management', 'marketing', 'review', '2024-11-15', '2025-02-28', 67000.00, 2, 'medium', 90);

-- Insert Milestones
INSERT INTO milestones (project_id, milestone_name, description, due_date, status, payment_amount, completion_date, sort_order) VALUES
-- Project 1 Milestones
(1, 'Discovery & Research', 'User research, competitor analysis, requirements gathering', '2025-01-31', 'completed', 15000.00, '2025-01-28 14:30:00', 1),
(1, 'Design Phase', 'Wireframes, mockups, and design system creation', '2025-02-28', 'completed', 25000.00, '2025-02-26 16:45:00', 2),
(1, 'Development - Phase 1', 'Homepage, product catalog, and search functionality', '2025-03-31', 'in_progress', 35000.00, NULL, 3),
(1, 'Development - Phase 2', 'Shopping cart, checkout, and payment integration', '2025-04-20', 'pending', 30000.00, NULL, 4),
(1, 'Testing & Launch', 'QA testing, bug fixes, and production deployment', '2025-04-30', 'pending', 20000.00, NULL, 5),

-- Project 2 Milestones
(2, 'Requirements & Planning', 'App specifications and technical architecture', '2025-02-15', 'in_progress', 20000.00, NULL, 1),
(2, 'UI/UX Design', 'Mobile interface design and prototyping', '2025-03-15', 'pending', 30000.00, NULL, 2),
(2, 'iOS Development', 'Native iOS app development', '2025-05-31', 'pending', 50000.00, NULL, 3),
(2, 'Android Development', 'Native Android app development', '2025-06-30', 'pending', 50000.00, NULL, 4),
(2, 'App Store Submission', 'Testing and submission to app stores', '2025-07-31', 'pending', 30000.00, NULL, 5),

-- Project 3 Milestones
(3, 'Brand Strategy Session', 'Workshops and brand positioning', '2025-01-20', 'completed', 8000.00, '2025-01-18 11:00:00', 1),
(3, 'Logo Concepts', 'Initial logo design concepts and iterations', '2025-02-05', 'completed', 12000.00, '2025-02-04 15:20:00', 2),
(3, 'Brand Guidelines', 'Complete brand book and asset library', '2025-02-28', 'in_progress', 15000.00, NULL, 3),
(3, 'Marketing Collateral', 'Business cards, letterhead, and templates', '2025-03-15', 'pending', 10000.00, NULL, 4),

-- Project 4 Milestones
(4, 'System Architecture', 'Database design and API planning', '2024-12-20', 'completed', 15000.00, '2024-12-18 10:30:00', 1),
(4, 'Backend Development', 'API and data processing systems', '2025-01-31', 'completed', 30000.00, '2025-01-29 16:00:00', 2),
(4, 'Dashboard UI', 'Interactive charts and visualization', '2025-02-28', 'in_progress', 25000.00, NULL, 3),
(4, 'Integration & Testing', 'Third-party integrations and QA', '2025-03-31', 'pending', 25000.00, NULL, 4),

-- Project 5 Milestones
(5, 'Platform Setup', 'Email service and social media API integration', '2024-12-01', 'completed', 12000.00, '2024-11-28 09:15:00', 1),
(5, 'Campaign Builder', 'Drag-and-drop campaign creation tool', '2024-12-31', 'completed', 20000.00, '2024-12-29 14:40:00', 2),
(5, 'Analytics Dashboard', 'Performance tracking and reporting', '2025-01-31', 'completed', 18000.00, '2025-01-30 11:20:00', 3),
(5, 'User Acceptance Testing', 'Client testing and feedback incorporation', '2025-02-15', 'completed', 10000.00, '2025-02-14 13:50:00', 4),
(5, 'Training & Handover', 'Documentation and team training', '2025-02-28', 'in_progress', 7000.00, NULL, 5);

-- Insert Invoices
INSERT INTO invoices (invoice_number, project_id, client_id, issue_date, due_date, subtotal, tax_rate, tax_amount, total_amount, status, payment_date) VALUES
('INV-2025-001', 1, 1, '2025-02-01', '2025-02-15', 15000.00, 8.50, 1275.00, 16275.00, 'paid', '2025-02-10 10:30:00'),
('INV-2025-002', 1, 1, '2025-03-01', '2025-03-15', 25000.00, 8.50, 2125.00, 27125.00, 'paid', '2025-03-12 14:20:00'),
('INV-2025-003', 3, 2, '2025-01-25', '2025-02-08', 8000.00, 7.00, 560.00, 8560.00, 'paid', '2025-02-05 09:15:00'),
('INV-2025-004', 3, 2, '2025-02-10', '2025-02-24', 12000.00, 7.00, 840.00, 12840.00, 'paid', '2025-02-20 16:45:00'),
('INV-2025-005', 4, 3, '2024-12-22', '2025-01-05', 15000.00, 8.00, 1200.00, 16200.00, 'paid', '2025-01-03 11:00:00'),
('INV-2025-006', 4, 3, '2025-02-01', '2025-02-15', 30000.00, 8.00, 2400.00, 32400.00, 'sent', NULL),
('INV-2025-007', 5, 4, '2024-12-05', '2024-12-19', 12000.00, 7.50, 900.00, 12900.00, 'paid', '2024-12-18 08:30:00'),
('INV-2025-008', 5, 4, '2025-01-05', '2025-01-19', 38000.00, 7.50, 2850.00, 40850.00, 'paid', '2025-01-17 15:10:00');

-- Insert Invoice Items
INSERT INTO invoice_items (invoice_id, milestone_id, description, quantity, unit_price, amount) VALUES
-- Invoice 1 Items
(1, 1, 'Discovery & Research Phase - User research, competitor analysis, requirements gathering', 1.00, 15000.00, 15000.00),

-- Invoice 2 Items
(2, 2, 'Design Phase - Wireframes, mockups, and design system creation', 1.00, 25000.00, 25000.00),

-- Invoice 3 Items
(3, 11, 'Brand Strategy Session - Workshops and brand positioning', 1.00, 8000.00, 8000.00),

-- Invoice 4 Items
(4, 12, 'Logo Concepts - Initial logo design concepts and iterations', 1.00, 12000.00, 12000.00),

-- Invoice 5 Items
(5, 15, 'System Architecture - Database design and API planning', 1.00, 15000.00, 15000.00),

-- Invoice 6 Items
(6, 16, 'Backend Development - API and data processing systems', 1.00, 30000.00, 30000.00),

-- Invoice 7 Items
(7, 19, 'Platform Setup - Email service and social media API integration', 1.00, 12000.00, 12000.00),

-- Invoice 8 Items
(8, 20, 'Campaign Builder - Drag-and-drop campaign creation tool', 1.00, 20000.00, 20000.00),
(8, 21, 'Analytics Dashboard - Performance tracking and reporting', 1.00, 18000.00, 18000.00);

-- ================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================

-- Project Overview with Client Info
CREATE VIEW project_overview AS
SELECT 
    p.project_id,
    p.project_name,
    p.status,
    p.completion_percentage,
    p.budget,
    p.start_date,
    p.deadline,
    c.company_name,
    c.contact_person,
    c.email,
    a.full_name as manager_name,
    COUNT(DISTINCT m.milestone_id) as total_milestones,
    SUM(CASE WHEN m.status = 'completed' THEN 1 ELSE 0 END) as completed_milestones
FROM projects p
JOIN clients c ON p.client_id = c.client_id
LEFT JOIN admin_users a ON p.assigned_manager = a.admin_id
LEFT JOIN milestones m ON p.project_id = m.project_id
GROUP BY p.project_id;

-- Invoice Summary View
CREATE VIEW invoice_summary AS
SELECT 
    i.invoice_id,
    i.invoice_number,
    i.issue_date,
    i.due_date,
    i.total_amount,
    i.status,
    c.company_name,
    p.project_name
FROM invoices i
JOIN clients c ON i.client_id = c.client_id
JOIN projects p ON i.project_id = p.project_id;

-- ================================================
-- END OF DATABASE SCHEMA
-- ================================================
