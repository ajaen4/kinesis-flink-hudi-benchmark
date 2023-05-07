FROM amazon/aws-lambda-python:3.10
LABEL maintainer="Bluetab"

# Installs python, removes cache file to make things smaller
RUN yum update -y && \
    yum install -y python3 python3-dev python3-pip gcc && \
    rm -Rf /var/cache/yum

COPY . ./

RUN pip install -r requirements.txt

CMD ["app.lambda_handler"]
