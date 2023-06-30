import os
import json
from pyflink.table import StreamTableEnvironment


def set_local_environment(table_env: StreamTableEnvironment) -> None:
    CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
    table_env.get_config().get_configuration().set_string(
        "pipeline.jars", f"file:///{CURRENT_DIR}/../lib/combined.jar"
    )

    table_env.get_config().get_configuration().set_string(
        "execution.checkpointing.mode", "EXACTLY_ONCE"
    )
    table_env.get_config().get_configuration().set_string(
        "execution.checkpointing.interval", "5000"
    )


def get_application_properties(is_local: bool = False) -> dict:
    if is_local:
        APPLICATION_PROPERTIES_FILE_PATH = "flink_app/local_application_properties.json"
    else:
        APPLICATION_PROPERTIES_FILE_PATH = "/etc/flink/application_properties.json"

    if os.path.isfile(APPLICATION_PROPERTIES_FILE_PATH):
        with open(APPLICATION_PROPERTIES_FILE_PATH, "r") as file:
            contents = file.read()
            properties_json = json.loads(contents)

            properties = {}
            for group in properties_json:
                group_id = group["PropertyGroupId"]
                group_map = group["PropertyMap"]
                properties[group_id] = group_map
            return properties
    else:
        print(f'A file at "{APPLICATION_PROPERTIES_FILE_PATH}" was not found')
