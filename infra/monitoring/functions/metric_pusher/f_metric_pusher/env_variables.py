import os

output_format = os.environ["OUTPUT_FORMAT"]

db_table_names = {
    "json": [os.environ["JSON_DATABASE_NAME"], os.environ["JSON_TABLE_NAME"]],
    "hudi": [os.environ["HUDI_DATABASE_NAME"], os.environ["HUDI_TABLE_NAME"]],
}
