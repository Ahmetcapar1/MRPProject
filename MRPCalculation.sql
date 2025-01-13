WITH RECURSIVE MRP_CTE AS (
    SELECT 
        GR.RequirementID,
        GR.ItemID,
        GR.Quantity AS RemainingQuantity,
        GR.Planned_Period
    FROM 
        GROSS_REQUIREMENT GR
    UNION ALL
    SELECT 
        NULL,
        BOM.ChildID,
        BOM.Quantity * MRP_CTE.RemainingQuantity,
        MRP_CTE.Planned_Period - ITEM.LeadTime
    FROM 
        BOM
    JOIN MRP_CTE ON BOM.ParentID = MRP_CTE.ItemID
    JOIN ITEM ON BOM.ChildID = ITEM.ItemID
    WHERE 
        MRP_CTE.RemainingQuantity > 0
)
INSERT INTO GROSS_REQUIREMENT (ItemID, Quantity, Planned_Period)
SELECT ItemID, Quantity, Planned_Period
FROM MRP_CTE
WHERE RequirementID IS NULL;


INSERT INTO ORDERS (ItemID, PeriodID)
SELECT 
    GR.ItemID,
    GR.Planned_Period - ITEM.LeadTime
FROM 
    GROSS_REQUIREMENT GR
JOIN ITEM ON GR.ItemID = ITEM.ItemID
LEFT JOIN BOM ON ITEM.ItemID = BOM.ParentID
WHERE BOM.ParentID IS NULL AND GR.Quantity > 0;
