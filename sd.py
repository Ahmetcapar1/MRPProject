    with st.form("Requirement_form"):
        item_name = st.text_input("Item Name")
        quantity_ordered = st.number_input("Quantity Ordered", min_value=1, step=1)
        planned_date = st.number_input("Planned Period")
        submitted = st.form_submit_button("Insert")

        if submitted:
            try:
                cursor.execute("SELECT ItemID FROM ITEM WHERE ItemName = ?", (item_name,))
                item = cursor.fetchone()
                if not item:
                    st.error(f"Item '{item_name}' does not exist in the database.")
                else:
                    cursor.execute(
                        "INSERT INTO GROSS_REQUIREMENTS (ItemID, Quantity, PlannedPeriods) VALUES (?, ?, ?)",
                        (item[0], quantity_ordered,planned_date),
                    )
                conn.commit()
                st.success("Order inserted successfully!")
            except sqlite3.IntegrityError as e:
                st.error(f"Error: {e}")