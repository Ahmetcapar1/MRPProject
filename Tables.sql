
CREATE TABLE BOM (
    ParentID int,
    ChildID int,
    Quantity int,
    FOREIGN KEY (ParentID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (ChildID) REFERENCES ITEM(ItemID)
)

CREATE TABLE ITEM (
    ItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    LotSize int,
    ItemName varchar(30)
    
)

CREATE TABLE INVENTORY (
    InventoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    ItemID int,
    Quantity int,
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID)
)

CREATE TABLE GROSS_REQUIREMENT(
    RequirementID INTEGER PRIMARY KEY AUTOINCREMENT
    ItemID int,
    Quantity int,
    Planned_Period int,
    FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    FOREIGN KEY (Planned_Period) REFERENCES PERIODS(PeriodID)
)
CREATE TABLE PERIODS(
    PeriodID int,
    PRIMARY KEY (PeriodID)
)
CREATE TABLE SYSTEM(
    RequirementID int,
    InventoryID int,
    PeriodID int,
    FOREIGN KEY (RequirementID) REFERENCES GROSS_REQUIREMENT(RequirementID)
    FOREIGN KEY (InventoryID) REFERENCES INVENTORY(InventoryID)
    FOREIGN KEY (PeriodID) REFERENCES PERIODS(PeriodID)
)
INSERT INTO PERIODS(PeriodID)
VALUES
('1'),
('2'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9'),
('10'),
('11'),
('12'),
('13'),
('14'),
('15'),
('16'),
('17'),
('18'),
('19'),
('20'),
('21'),
('22'),
('23'),
('24'),
('25'),
('26'),
('27'),
('28'),
('29'),
('30');

