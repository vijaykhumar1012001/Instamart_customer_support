import pandas as pd

orders = pd.read_csv("data/raw/orders.csv")
customers = pd.read_csv("data/raw/customers.csv")
products = pd.read_csv("data/raw/products.csv")

print(orders.shape)
print(orders.dtypes)
print(orders.isnull().sum())

missing_percentage = (
    orders.isnull().sum() / len(orders) * 100
)

print(missing_percentage)

# Exact duplicate rows
print(orders.duplicated().sum())

# Pending orders
print((orders["status"] == "pending").sum())

# Distinct order IDs
print(orders["order_id"].nunique())

# Amounts that cannot be converted to numbers
amounts = pd.to_numeric(
    orders["order_amount"], errors="coerce"
)
print((amounts.isna() & orders["order_amount"].notna()).sum())

print(orders)

print(customers.shape)
print(customers.dtypes)
print("duplicate rows:",customers.duplicated().sum())


customers["city"] = (
    customers["city"].str.strip().str.lower()
)

clean_map = {
    'chennai': 'Chennai',
    'CHENNAI': 'Chennai',
    'bengaluru': 'Bengaluru',
    'BENGALURU': 'Bengalure',
    'delhi': 'Delhi',
    'DELHI': 'Delhi',
    'pune': 'Pune',
    'PUNE': 'Pune',
    'mumbai': 'Mumbai',
    'MUMBAI': 'Mumbai'
}

customers['city'] = customers['city'].replace(clean_map)
print(customers)