from pyflink.table import EnvironmentSettings, StreamTableEnvironment
from pyflink.datastream import StreamExecutionEnvironment
from .config import IS_LOCAL, PROPS
from .utils import set_local_environment


ENV_SETTINGS = EnvironmentSettings.in_streaming_mode()
ENV_STREAM = StreamExecutionEnvironment.get_execution_environment()
ENV_TABLE = StreamTableEnvironment.create(
    stream_execution_environment=ENV_STREAM,
    environment_settings=ENV_SETTINGS,
)
ENV_TABLE.get_config().get_configuration().set_string("table.local-time-zone", "UTC")
PARALLELISM = ENV_STREAM.get_parallelism()
PARALLELISM_PER_KPU = int(
    PROPS["parallelism.config.0"]["parallelism_kpu"]
)
BASE_PARALLELISM = int(PARALLELISM / PARALLELISM_PER_KPU)
ENV_TABLE.get_config().get_configuration().set_string(
    "table.exec.resource.default-parallelism", f"{BASE_PARALLELISM}"
)

if IS_LOCAL:
    set_local_environment(ENV_TABLE)
