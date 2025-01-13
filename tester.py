import sqlite3


# Paths to SQL files
TABLES_SQL_FILE = "Tables.sql"
MRP_CALCULATION_SQL_FILE = "MRPCalculation.sql"

# Database connection
conn = sqlite3.connect('test_mrp_database.db')
conn.execute("PRAGMA foreign_keys = ON;")
cursor = conn.cursor()

# Function to initialize the database
def initialize_database(file_path):
    with open(file_path, "r") as f:
        schema_sql = f.read()
    conn.executescript(schema_sql)
    conn.commit()
    print("Database initialized successfully!")

# Function to run MRP calculations
def run_mrp_calculation(file_path):
    with open(file_path, "r") as f:
        calculation_sql = f.read()
    conn.executescript(calculation_sql)
    conn.commit()
    print("MRP Calculation completed successfully!")

# Function to display table contents
def display_table(table_name):
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    print(f"\nContents of {table_name}:")
    for row in rows:
        print(row)

# Initialize the database
initialize_database(TABLES_SQL_FILE)

# Insert test data
print("Inserting test data...")
cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (10, "Pasta", 4))
cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (20, "Süt", 3))
cursor.execute("INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)", (15, "Krema", 3))

# Update column name to match Tables.sql
cursor.execute("INSERT INTO BOM (ParentID, ChildID, ChildQuantity) VALUES (?, ?, ?)", (1, 2, 2))  # Pasta -> 2x Süt
cursor.execute("INSERT INTO BOM (ParentID, ChildID, ChildQuantity) VALUES (?, ?, ?)", (1, 3, 4))  # Pasta -> 4x Krema

cursor.execute("INSERT INTO INVENTORY (ItemID, InventoryQuantity) VALUES (?, ?)", (2, 50))  # Süt inventory
cursor.execute("INSERT INTO INVENTORY (ItemID, InventoryQuantity) VALUES (?, ?)", (3, 30))  # Krema inventory

cursor.execute("INSERT INTO GROSS_REQUIREMENT (ItemID, RequiredQuantity, Planned_Period) VALUES (?, ?, ?)", (1, 40, 25))  # Pasta requirement


conn.commit()
cursor.execute("PRAGMA table_info(BOM)")
print("Schema of BOM:", cursor.fetchall())

cursor.execute("PRAGMA table_info(INVENTORY)")
print("Schema of INVENTORY:", cursor.fetchall())

cursor.execute("PRAGMA table_info(GROSS_REQUIREMENT)")
print("Schema of GROSS_REQUIREMENT:", cursor.fetchall())

cursor.execute("PRAGMA table_info(ORDERS)")
print("Schema of ORDERS:", cursor.fetchall())

# Display initial tables
display_table("ITEM")
display_table("BOM")
display_table("INVENTORY")
display_table("GROSS_REQUIREMENT")

# Run MRP calculations
run_mrp_calculation(MRP_CALCULATION_SQL_FILE)

# Display results
display_table("ORDERS")

# Cleanup: Optional for testing
conn.executescript("""
DELETE FROM GROSS_REQUIREMENT;
DELETE FROM INVENTORY;
DELETE FROM ORDERS;
""")
conn.commit()
print("\nTest database cleared.")

# Close connection
conn.close()
