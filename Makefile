.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
	 	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## (Re-)Installs the dependencies and builds the docker images.
	docker-compose build

up: ## Starts the images in the background, starts mongo, and seeds with a user.
	docker-compose up -d

down: ## Shuts down all images.
	docker-compose down

status: ## Shows the status of the images.
	docker-compose ps

configure-aws:
	aws configure

sqs-admin: ## Open the SQS admin in a browser.
	xdg-open http://localhost:9325/

send-test-queue-message: ## Sends a test queue message.
	aws sqs send-message \
		--endpoint-url http://localhost:9324 \
		--queue-url http://localhost:9324/queue/default \
		--message-body "Hello, queue!"

read-test-queue-messages: ## Reads a test queue message.
	aws sqs receive-message \
		--endpoint-url http://localhost:9324 \
		--queue-url http://localhost:9324/queue/default \
		--wait-time-seconds 10

create-table:
	aws dynamodb create-table \
		--table-name pagespeedData \
		--attribute-definitions AttributeName=id,AttributeType=S \
		--key-schema AttributeName=id,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
		--endpoint-url http://0.0.0.0:8000

list-tables: ## List the dynamo db tables
	aws dynamodb list-tables \
		--endpoint-url http://0.0.0.0:8000 \
		--output json

bash-s3: ## Enter into the s3 server image with a bash console.
	docker-compose exec local-s3 bash

create-bucket: ## Creates a bucket locally.
	aws s3api create-bucket \
		--endpoint-url http://0.0.0.0:8001 \
		--bucket testing \
		--acl public-read-write

list-buckets: ## Lists the local buckets
	aws s3 ls --endpoint-url http://0.0.0.0:8001
