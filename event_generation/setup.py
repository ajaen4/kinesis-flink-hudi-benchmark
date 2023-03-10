from setuptools import setup, find_packages

setup(
    name="event_generation",
    author="Alberto Jaen",
    description="Locust code to send events to AWS Kinesis",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        "boto3>=1.26.86,<1.27.0",
        "locust>=2.15.0,<2.16.0",
        "python-dotenv==1.0.0",
    ],
    extras_require={
        "dev": ["black==21.7b0", "wheel"],
    },
)
