-- Step 1: Deduct Gross Requirements from Inventory
WITH Inventory_Adjustment AS (
    SELECT 
        INVENTORY.InventoryID,
        INVENTORY.InventoryQuantity - GROSS_REQUIREMENT.RequiredQuantity AS NewInventoryQuantity
    FROM INVENTORY
    JOIN GROSS_REQUIREMENT ON INVENTORY.ItemID = GROSS_REQUIREMENT.ItemID
    WHERE INVENTORY.InventoryQuantity >= GROSS_REQUIREMENT.RequiredQuantity
)
UPDATE INVENTORY
SET InventoryQuantity = (
    SELECT NewInventoryQuantity
    FROM Inventory_Adjustment
    WHERE Inventory_Adjustment.InventoryID = INVENTORY.InventoryID
)
WHERE EXISTS (
    SELECT 1
    FROM Inventory_Adjustment
    WHERE Inventory_Adjustment.InventoryID = INVENTORY.InventoryID
);

-- Step 2: Adjust Remaining Gross Requirements if Inventory is Insufficient
WITH Remaining_Requirements AS (
    SELECT 
        GROSS_REQUIREMENT.RequirementID,
        GROSS_REQUIREMENT.ItemID,
        GROSS_REQUIREMENT.RequiredQuantity - COALESCE(INVENTORY.InventoryQuantity, 0) AS RemainingQuantity
    FROM GROSS_REQUIREMENT
    LEFT JOIN INVENTORY ON GROSS_REQUIREMENT.ItemID = INVENTORY.ItemID
    WHERE COALESCE(INVENTORY.InventoryQuantity, 0) < GROSS_REQUIREMENT.RequiredQuantity
)
UPDATE GROSS_REQUIREMENT
SET RequiredQuantity = (
    SELECT RemainingQuantity
    FROM Remaining_Requirements
    WHERE Remaining_Requirements.RequirementID = GROSS_REQUIREMENT.RequirementID
)
WHERE EXISTS (
    SELECT 1
    FROM Remaining_Requirements
    WHERE Remaining_Requirements.RequirementID = GROSS_REQUIREMENT.RequirementID
);

-- Step 3: Generate New Gross Requirements for Child Items
WITH RECURSIVE Recursive_Requirements(RequirementID, ItemID, RequiredQuantity, Planned_Period) AS (
    -- Anchor Query: Start with existing Gross Requirements
    SELECT 
        GROSS_REQUIREMENT.RequirementID,
        GROSS_REQUIREMENT.ItemID,
        GROSS_REQUIREMENT.RequiredQuantity,
        GROSS_REQUIREMENT.Planned_Period
    FROM GROSS_REQUIREMENT

    UNION ALL

    -- Recursive Query: Generate requirements for child items
    SELECT 
        NULL AS RequirementID, -- New requirements don't have an existing RequirementID
        BOM.ChildID AS ItemID,
        BOM.ChildQuantity * Recursive_Requirements.RequiredQuantity AS RequiredQuantity,
        Recursive_Requirements.Planned_Period - ITEM.LeadTime AS Planned_Period
    FROM BOM
    JOIN Recursive_Requirements ON BOM.ParentID = Recursive_Requirements.ItemID
    JOIN ITEM ON BOM.ChildID = ITEM.ItemID
    WHERE Recursive_Requirements.RequiredQuantity > 0
)
INSERT INTO GROSS_REQUIREMENT (ItemID, RequiredQuantity, Planned_Period)
SELECT 
    Recursive_Requirements.ItemID,
    Recursive_Requirements.RequiredQuantity,
    Recursive_Requirements.Planned_Period
FROM Recursive_Requirements
WHERE Recursive_Requirements.RequirementID IS NULL;



-- Step 4: Create Orders for Items Without Children
INSERT INTO ORDERS (ItemID, PeriodID, OrderQuantity)
SELECT 
    GROSS_REQUIREMENT.ItemID,
    GROSS_REQUIREMENT.Planned_Period - ITEM.LeadTime AS PeriodID,
    CAST((GROSS_REQUIREMENT.RequiredQuantity * 1.0 / ITEM.LotSize + 0.999999) AS INT) * ITEM.LotSize AS OrderQuantity -- Replace CEIL
FROM GROSS_REQUIREMENT
JOIN ITEM ON GROSS_REQUIREMENT.ItemID = ITEM.ItemID
LEFT JOIN BOM ON ITEM.ItemID = BOM.ParentID
WHERE BOM.ParentID IS NULL
  AND GROSS_REQUIREMENT.RequiredQuantity > 0;


-- Step 5: Add Remaining Quantities Back to Inventory
WITH Ordered_Quantities AS (
    SELECT 
        ORDERS.ItemID,
        ORDERS.OrderQuantity - GROSS_REQUIREMENT.RequiredQuantity AS ExcessQuantity
    FROM ORDERS
    JOIN GROSS_REQUIREMENT ON ORDERS.ItemID = GROSS_REQUIREMENT.ItemID
)
INSERT INTO INVENTORY (ItemID, InventoryQuantity)
SELECT 
    Ordered_Quantities.ItemID,
    Ordered_Quantities.ExcessQuantity
FROM Ordered_Quantities
WHERE ExcessQuantity > 0;







