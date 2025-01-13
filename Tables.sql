CREATE TABLE IF NOT EXISTS ITEM (
    ItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    LotSize int,
    ItemName VARCHAR(30),
    LeadTime int
);

CREATE TABLE IF NOT EXISTS BOM (
    ParentID int,
    ChildID int,
    ChildQuantity int, 
    FOREIGN KEY (ParentID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (ChildID) REFERENCES ITEM(ItemID)
);

CREATE TABLE IF NOT EXISTS INVENTORY (
    InventoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID int,
    InventoryQuantity int, 
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID)
);

CREATE TABLE IF NOT EXISTS GROSS_REQUIREMENT (
    RequirementID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID int,
    RequiredQuantity int, 
    Planned_Period int,
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (Planned_Period) REFERENCES PERIODS(PeriodID)
);

CREATE TABLE IF NOT EXISTS PERIODS (
    PeriodID INT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS ORDERS (
    OrderID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID int,
    PeriodID int,
    OrderQuantity int, 
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (PeriodID) REFERENCES PERIODS(PeriodID)
);

INSERT OR IGNORE INTO PERIODS (PeriodID)
VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);