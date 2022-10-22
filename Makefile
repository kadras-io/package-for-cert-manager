# Check the ytt-annotated Kubernetes configuration
check:
	ytt --file package/config

# Use ytt to generate an OpenAPI specification
schema:
	ytt -f package/config/values-schema.yml --data-values-schema-inspect -o openapi-v3 > package/config/schema-openapi.yml
