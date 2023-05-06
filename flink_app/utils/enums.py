from enum import Enum


class HudiTableType(Enum):
    mor = "MERGE_ON_READ"
    cow = "COPY_ON_WRITE"
