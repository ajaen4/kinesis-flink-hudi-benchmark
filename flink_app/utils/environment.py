from pyflink.table import EnvironmentSettings, StreamTableEnvironment
from pyflink.datastream import StreamExecutionEnvironment
from .config import IS_LOCAL
from .utils import set_local_environment


ENV_SETTINGS = EnvironmentSettings.in_streaming_mode()
ENV_STREAM = StreamExecutionEnvironment.get_execution_environment()
ENV_TABLE = StreamTableEnvironment.create(
    stream_execution_environment=ENV_STREAM,
    environment_settings=ENV_SETTINGS,
)
ENV_TABLE.get_config().get_configuration().set_string("table.local-time-zone", "UTC")


if IS_LOCAL:
    set_local_environment(ENV_TABLE)
