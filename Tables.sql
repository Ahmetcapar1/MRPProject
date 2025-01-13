CREATE TABLE IF NOT EXISTS ITEM (
    ItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    LotSize INT,
    ItemName VARCHAR(30),
    LeadTime INT
);

CREATE TABLE IF NOT EXISTS BOM (
    ParentID INT,
    ChildID INT,
    ChildQuantity INT, -- Ensure this column exists
    FOREIGN KEY (ParentID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (ChildID) REFERENCES ITEM(ItemID)
);

CREATE TABLE IF NOT EXISTS INVENTORY (
    InventoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID INT,
    InventoryQuantity INT, -- Ensure this column exists
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID)
);

CREATE TABLE IF NOT EXISTS GROSS_REQUIREMENT (
    RequirementID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID INT,
    RequiredQuantity INT, -- Ensure this column exists
    Planned_Period INT,
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (Planned_Period) REFERENCES PERIODS(PeriodID)
);

CREATE TABLE IF NOT EXISTS PERIODS (
    PeriodID INT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS MODEL (
    RequirementID INT,
    InventoryID INT,
    PeriodID INT,
    OrderID INT,
    FOREIGN KEY (RequirementID) REFERENCES GROSS_REQUIREMENT(RequirementID),
    FOREIGN KEY (InventoryID) REFERENCES INVENTORY(InventoryID),
    FOREIGN KEY (PeriodID) REFERENCES PERIODS(PeriodID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);

CREATE TABLE IF NOT EXISTS ORDERS (
    OrderID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID INT,
    PeriodID INT,
    OrderQuantity INT, -- Ensure this column exists
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (PeriodID) REFERENCES PERIODS(PeriodID)
);

INSERT OR IGNORE INTO PERIODS (PeriodID)
VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);


