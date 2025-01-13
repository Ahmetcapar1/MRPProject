import sqlite3


TABLES_SQL_FILE = "Tables.sql"
MRP_CALCULATION_SQL_FILE = "MRPCalculation.sql"

conn = sqlite3.connect('test_mrp_database.db')
conn.execute("PRAGMA foreign_keys = ON;")
cursor = conn.cursor()


def initialize_database(file_path):
    with open(file_path, "r") as f:
        schema_sql = f.read()
    conn.executescript(schema_sql)
    conn.commit()


def run_mrp_calculation(file_path):
    with open(file_path, "r") as f:
        calculation_sql = f.read()
    conn.executescript(calculation_sql)
    conn.commit()


def display_table(table_name):
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    print(f"\nContents of {table_name}:")
    for row in rows:
        print(row)


initialize_database(TABLES_SQL_FILE)



cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (10, "Pasta", 4))
cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (20, "Süt", 3))
cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (15, "Krema", 3))


cursor.execute("INSERT INTO BOM (ParentID, ChildID, ChildQuantity) VALUES (?, ?, ?)", (1, 2, 2))  
cursor.execute("INSERT INTO BOM (ParentID, ChildID, ChildQuantity) VALUES (?, ?, ?)", (1, 3, 4))  

cursor.execute("INSERT INTO INVENTORY (ItemID, InventoryQuantity) VALUES (?, ?)", (2, 50))  
cursor.execute("INSERT INTO INVENTORY (ItemID, InventoryQuantity) VALUES (?, ?)", (3, 30))  

cursor.execute("INSERT INTO GROSS_REQUIREMENT (ItemID, RequiredQuantity, Planned_Period) VALUES (?, ?, ?)", (1, 40, 25))  


conn.commit()
cursor.execute("PRAGMA table_info(BOM)")
print("Schema of BOM:", cursor.fetchall())

cursor.execute("PRAGMA table_info(INVENTORY)")
print("Schema of INVENTORY:", cursor.fetchall())

cursor.execute("PRAGMA table_info(GROSS_REQUIREMENT)")
print("Schema of GROSS_REQUIREMENT:", cursor.fetchall())

cursor.execute("PRAGMA table_info(ORDERS)")
print("Schema of ORDERS:", cursor.fetchall())


display_table("ITEM")
display_table("BOM")
display_table("INVENTORY")
display_table("GROSS_REQUIREMENT")


run_mrp_calculation(MRP_CALCULATION_SQL_FILE)

# Query to retrieve the formatted order details
query = """
SELECT 
    ORDERS.OrderQuantity AS Amount,
    ITEM.ItemName,
    ORDERS.PeriodID
FROM 
    ORDERS
JOIN 
    ITEM ON ORDERS.ItemID = ITEM.ItemID;
"""

# Execute the query
cursor.execute(query)
orders = cursor.fetchall()

# Format and print the output
for order in orders:
    amount, item_name, period_id = order
    print(f'Order "{amount}" "{item_name}" at "{period_id}"')


conn.close()
