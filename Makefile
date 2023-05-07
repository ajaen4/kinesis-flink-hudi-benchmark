install:
	pip install -r requirements.txt
	pre-commit install

uber-jar:
	cd flink_app && mvn clean package

send-records:
	cd event_generation && locust --tags send

run-app:
	python local/run_flink_app.py
