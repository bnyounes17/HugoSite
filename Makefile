.PHONY: help build serve deploy clean invalidate all

# Configuration - UPDATE THESE VALUES
BUCKET_NAME := hugowebsite-ybn
REGION := us-east-2
DISTRIBUTION_ID := E1DW2OL6VZDW60

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help:
	@echo -e "$(GREEN)Available commands:$(NC)"
	@echo -e "  make build       - Build Hugo site with minification"
	@echo -e "  make serve       - Run local development server"
	@echo -e "  make deploy      - Deploy to S3 and invalidate CloudFront"
	@echo -e "  make clean       - Remove build artifacts"
	@echo -e "  make all         - Clean, build, and deploy"

build:
	@echo -e "$(GREEN)Building Hugo site...$(NC)"
	hugo --minify
	@echo -e "$(GREEN)✓ Build complete!$(NC)"

serve:
	@echo -e "$(GREEN)Starting Hugo development server...$(NC)"
	hugo server -D --bind 0.0.0.0

upload: build
	@echo -e "$(GREEN)Uploading to S3...$(NC)"
	aws s3 sync public/ s3://$(BUCKET_NAME)/ \
	--region $(REGION) \
	--delete \
	--cache-control "public, max-age=3600"
	@echo -e "$(GREEN)✓ Upload complete!$(NC)"

invalidate:
	@echo -e "$(GREEN)Invalidating CloudFront cache...$(NC)"
	aws cloudfront create-invalidation \
	--distribution-id $(DISTRIBUTION_ID) \
	--paths "/*"
	@echo -e "$(GREEN)✓ Cache invalidated!$(NC)"

deploy: upload invalidate
	@echo -e "$(GREEN)✓ Deployment complete!$(NC)"
	@echo -e "$(YELLOW)Site URL: https://$(DISTRIBUTION_ID).cloudfront.net$(NC)"

clean:
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf public/ resources/
	@echo -e "$(GREEN)✓ Clean complete!$(NC)"

all: clean deploy
