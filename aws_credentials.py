import configparser
import os
import sys
from os.path import expanduser

def get_aws_credentials():
    credentials_file = '/.aws/credentials'
    profile = "practica-hudi-flink"

    home = expanduser("~")
    credentials_file = home + credentials_file
    config = configparser.RawConfigParser()
    config.read(credentials_file)


    access_key = config.get(profile, 'aws_access_key_id')
    secret_key = config.get(profile, 'aws_secret_access_key')

    # Get the credentials from the file
    access_key = config.get(profile, 'aws_access_key_id')
    secret_key = config.get(profile, 'aws_secret_access_key')
    session_token = config.get(profile, 'session_token')
    return access_key, secret_key, session_token