import boto3
import os
from dotenv import load_dotenv


def set_aws_credentials():
    session = boto3.Session(profile_name=os.environ["AWS_PROFILE"])
    sts = session.client("sts")
    session_credentials = sts.get_session_token()

    os.environ["AWS_ACCESS_KEY_ID"] = session_credentials["Credentials"]["AccessKeyId"]
    os.environ["AWS_SECRET_ACCESS_KEY"] = session_credentials["Credentials"][
        "SecretAccessKey"
    ]
    os.environ["AWS_SESSION_TOKEN"] = session_credentials["Credentials"]["SessionToken"]


def load_environment_variables():
    load_dotenv()
