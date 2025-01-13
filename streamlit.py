import sqlite3
import streamlit as st


conn = sqlite3.connect('sample_database.db')
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


initialize_database("Tables.sql")

st.title("MRP Database Input Tool")


table = st.sidebar.selectbox(
    "Select a Table to Insert Data",
    ["Items", "BillOfMaterials", "Inventory", "GrossRequirement"]
)

if table == "Items":
    with st.form("items_form"):
        lot_size = st.number_input("Lot Size", min_value=1)
        item_name = st.text_input("Item Name")
        lead_time = st.number_input("Lead Time", min_value=0, step=1)
        submitted = st.form_submit_button("Insert")

        if submitted:
            try:
                cursor.execute(
                    "INSERT INTO ITEM (LotSize, ItemName, LeadTime) VALUES (?, ?, ?)",
                    (lot_size, item_name, lead_time),
                )
                conn.commit()
                st.success("Item inserted successfully!")
            except sqlite3.IntegrityError as e:
                st.error(f"Error: {e}")

elif table == "BillOfMaterials":
    with st.form("bom_form"):
        parent_item_name = st.text_input("Parent Item Name")
        child_item_name = st.text_input("Child Item Name")
        quantity_required = st.number_input("Quantity Required", min_value=1, step=1)
        submitted = st.form_submit_button("Insert")

        if submitted:
            try:
                cursor.execute("SELECT ItemID FROM ITEM WHERE ItemName = ?", (parent_item_name,))
                parent_item = cursor.fetchone()

                cursor.execute("SELECT ItemID FROM ITEM WHERE ItemName = ?", (child_item_name,))
                child_item = cursor.fetchone()

                if not parent_item:
                    st.error(f"Parent item '{parent_item_name}' does not exist in the database.")
                elif not child_item:
                    st.error(f"Child item '{child_item_name}' does not exist in the database.")
                else:
                    cursor.execute(
                        "INSERT INTO BOM (ParentID, ChildID, ChildQuantity) VALUES (?, ?, ?)",
                        (parent_item[0], child_item[0], quantity_required),
                    )
                    conn.commit()
                    st.success("BOM entry inserted successfully!")
            except sqlite3.Error as e:
                st.error(f"Error: {e}")

elif table == "Inventory":
    with st.form("inventory_form"):
        item_name = st.text_input("Item Name")
        quantity_available = st.number_input("Quantity Available", min_value=0, step=1)
        submitted = st.form_submit_button("Insert")

        if submitted:
            try:
                cursor.execute("SELECT ItemID FROM ITEM WHERE ItemName = ?", (item_name,))
                item = cursor.fetchone()
                if not item:
                    st.error(f"Item '{item_name}' does not exist in the database.")
                else:
                    cursor.execute(
                        "INSERT INTO INVENTORY (ItemID, InventoryQuantity) VALUES (?, ?)",
                        (item[0], quantity_available),
                    )
                    conn.commit()
                    st.success("Inventory entry inserted successfully!")
            except sqlite3.IntegrityError as e:
                st.error(f"Error: {e}")

elif table == "GrossRequirement":
    with st.form("requirement_form"):
        item_name = st.text_input("Item Name")
        quantity_ordered = st.number_input("Quantity Ordered", min_value=1, step=1)
        planned_date = st.number_input("Planned Period", min_value=1, step=1)
        submitted = st.form_submit_button("Insert")

        if submitted:
            try:
                cursor.execute("SELECT ItemID FROM ITEM WHERE ItemName = ?", (item_name,))
                item = cursor.fetchone()
                if not item:
                    st.error(f"Item '{item_name}' does not exist in the database.")
                else:
                    cursor.execute(
                        "INSERT INTO GROSS_REQUIREMENT (ItemID, RequiredQuantity, Planned_Period) VALUES (?, ?, ?)",
                        (item[0], quantity_ordered, planned_date),
                    )
                    conn.commit()
                    st.success("Gross requirement inserted successfully!")
            except sqlite3.IntegrityError as e:
                st.error(f"Error: {e}")

if st.button("See Results"):
    try:
        run_mrp_calculation("MRPCalculation.sql")

        st.subheader("Orders")
        cursor.execute("SELECT * FROM ORDERS")
        orders = cursor.fetchall()
        st.write(orders)

        cursor.executescript("""
        DELETE FROM ITEM;
        DELETE FROM BOM;
        DELETE FROM GROSS_REQUIREMENT;
        DELETE FROM INVENTORY;
        DELETE FROM ORDERS;
        """)
        conn.commit()
        st.success("Results displayed and database cleared!")
    except sqlite3.Error as e:
        st.error(f"An error occurred: {e}")

conn.close()

