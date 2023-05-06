CREATE EXTERNAL TABLE `ticker_hudi_json`(
  `event_id` string , 
  `price` double, 
  `event_time` string, 
  `processing_time` string)
PARTITIONED BY ( 
  `ticker` string)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES ('ignore.malformed.json' = 'true')
LOCATION
  's3://flink-app-practica-json/table_json';

MSCK REPAIR TABLE `ticker_hudi_json`;

