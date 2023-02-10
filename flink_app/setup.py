import os
from setuptools import setup, find_packages


with open(
    os.path.join(os.path.dirname(__file__), "requirements.txt"), "r"
) as requirements:
    setup(
        name="flink_app",
        author="",
        author_email="",
        description="KDA Flink application",
        packages=find_packages(),
        python_requires=">=3.8,<3.9",
        install_requires=requirements.readlines(),
        extras_require={
            "dev": [
                "black==21.7b0",
                "boto3>=1.26.86,<1.27.0",
                "python-dotenv==1.0.0",
            ],
        },
    )
