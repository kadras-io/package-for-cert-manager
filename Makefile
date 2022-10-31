# Use ytt to generate an OpenAPI specification
schema:
	ytt -f package/config/values-schema.yml --data-values-schema-inspect -o openapi-v3 > package/config/schema-openapi.yml

# Check the ytt-annotated Kubernetes configuration
test-config:
	ytt --file package/config

# Run package tests
test-integration: test/test.sh
	chmod +x test/test.sh
	./test/test.sh
