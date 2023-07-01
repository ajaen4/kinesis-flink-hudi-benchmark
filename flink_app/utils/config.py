import os
from .utils import get_application_properties


IS_LOCAL = True if os.environ.get("IS_LOCAL") else False
PROPS = get_application_properties(IS_LOCAL)

input_table_name = "input_table"
output_table_name = "output_table"

input_stream = PROPS["consumer.config.0"]["input.stream.name"]
input_region = PROPS["consumer.config.0"]["aws.region"]
stream_initpos = PROPS["consumer.config.0"]["scan.stream.initpos"]

output_bucket_name = PROPS["sink.config.0"]["output.bucket.name"]
output_format = PROPS["sink.config.0"]["output.format"]
output_table_type = PROPS["sink.config.0"].get("output.table.type", output_format)
output_glue_database = PROPS["sink.config.0"]["output.glue.database"]
