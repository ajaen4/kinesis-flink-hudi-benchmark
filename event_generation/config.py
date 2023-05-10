import os
from dotenv import load_dotenv

load_dotenv()

STREAM_NAME = os.environ["STREAM_NAME"]
REGION_NAME = os.environ["REGION_NAME"]
