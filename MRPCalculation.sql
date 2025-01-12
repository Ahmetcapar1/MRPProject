WITH RECURSIVE MRP_CTE AS (

    SELECT 
        GR.RequirementID,
        GR.ItemID,
        GR.Quantity AS RemainingQuantity,
        GR.Planned_Period
    FROM 
        GROSS_REQUIREMENT GR
    JOIN 
        SYSTEM S ON GR.RequirementID = S.RequirementID

    UNION ALL

   
    SELECT 
        NULL AS RequirementID,  
        B.ChildID AS ItemID,
        (B.Quantity * MRP_CTE.RemainingQuantity) AS Quantity,
        (MRP_CTE.Planned_Period - I.LeadTime) AS Planned_Period
    FROM 
        BOM B
    JOIN 
        MRP_CTE ON B.ParentID = MRP_CTE.ItemID
    JOIN 
        ITEM I ON B.ChildID = I.ItemID
    WHERE 
        MRP_CTE.RemainingQuantity > 0  
),


INSERT INTO GROSS_REQUIREMENT (ItemID, Quantity, Planned_Period)
SELECT 
    MRP_CTE.ItemID, 
    MRP_CTE.Quantity, 
    MRP_CTE.Planned_Period
FROM 
    MRP_CTE
WHERE 
    MRP_CTE.RequirementID IS NULL;  


UPDATE INVENTORY
SET Quantity = Quantity - GR.Quantity
FROM 
    INVENTORY I
JOIN 
    GROSS_REQUIREMENT GR ON GR.ItemID = I.ItemID
JOIN 
    SYSTEM S ON GR.RequirementID = S.RequirementID
WHERE 
    S.RequirementID IN (SELECT RequirementID FROM SYSTEM)
    AND GR.Quantity <= I.Quantity;  


UPDATE GROSS_REQUIREMENT
SET Quantity = Quantity - (SELECT Quantity FROM INVENTORY WHERE ItemID = GROSS_REQUIREMENT.ItemID)
WHERE EXISTS (SELECT 1 FROM INVENTORY WHERE ItemID = GROSS_REQUIREMENT.ItemID);


INSERT INTO ORDERS (ItemID, PeriodID)
SELECT 
    GR.ItemID,
    GR.Planned_Period - I.LeadTime AS PeriodID
FROM 
    GROSS_REQUIREMENT GR
JOIN 
    ITEM I ON GR.ItemID = I.ItemID
LEFT JOIN 
    BOM B ON I.ItemID = B.ParentID
WHERE 
    B.ParentID IS NULL  
    AND GR.Quantity > 0;  

