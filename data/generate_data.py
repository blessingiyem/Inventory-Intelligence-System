import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

connection = psycopg2.connect(
    database="meridian_inventory_db",
    user="blessingiyem",
    host="localhost",
    port="5432"
)

cursor = connection.cursor()

print("Connected successfully!")


# =========================
# LOAD EXISTING DATA
# =========================

cursor.execute("SELECT category_id FROM categories")
categories = [row[0] for row in cursor.fetchall()]

cursor.execute("SELECT supplier_id FROM suppliers")
suppliers = [row[0] for row in cursor.fetchall()]

cursor.execute("SELECT product_id FROM products")
products = [row[0] for row in cursor.fetchall()]


print("Loaded existing data")


# =========================
# INVENTORY TRANSACTIONS
# =========================

transactions = []

for i in range(500):

    product_id = random.choice(products)

    transaction_type = random.choice(
        ["IN", "OUT"]
    )

    quantity = random.randint(1, 50)

    transaction_date = datetime.today() - timedelta(
        days=random.randint(1,365)
    )

    transactions.append(
        (
            product_id,
            transaction_type,
            quantity,
            transaction_date.date()
        )
    )


cursor.executemany(
    """
    INSERT INTO inventory_transactions
    (product_id, transaction_type, quantity, transaction_date)
    VALUES (%s,%s,%s,%s)
    """,
    transactions
)

print("Inventory transactions inserted!")


# =========================
# PURCHASE ORDERS
# =========================

orders = []

for i in range(100):

    product_id = random.choice(products)

    quantity_ordered = random.randint(5,100)

    order_date = datetime.today() - timedelta(
        days=random.randint(1,365)
    )

    status = random.choice(
        [
            "Pending",
            "Completed",
            "Cancelled"
        ]
    )


    orders.append(
        (
            product_id,
            quantity_ordered,
            order_date.date(),
            status
        )
    )


cursor.executemany(
    """
    INSERT INTO purchase_orders
    (product_id, quantity_ordered, order_date, status)
    VALUES (%s,%s,%s,%s)
    """,
    orders
)


connection.commit()

print("Purchase orders inserted!")


# =========================
# CLOSE CONNECTION
# =========================

cursor.close()
connection.close()

print("Database connection closed!")