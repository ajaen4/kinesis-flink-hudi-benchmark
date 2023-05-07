import os
from setuptools import setup, find_packages


with open(
    os.path.join(os.path.dirname(__file__), "requirements.txt"), "r"
) as requirements:
    setup(
        name="metric_pusher",
        author="Bluetab",
        description="Python code for lambda function",
        packages=find_packages(),
        python_requires=">=3.8",
        install_requires=requirements.readlines(),
    )
