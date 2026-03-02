# Claude Code Observability Stack
.PHONY: help up down logs restart clean validate-config

help: ## Show this help message
	@echo "Claude Code Observability Stack"
	@echo "================================"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start the observability stack
	@echo "🚀 Starting Claude Code observability stack..."
	docker-compose up -d
	@echo "✅ Stack started!"
	@echo "📊 Grafana: https://grafana.$${DOMAIN:-<your-domain>} (Google SSO)"


down: ## Stop the observability stack
	@echo "🛑 Stopping Claude Code observability stack..."
	docker-compose down
	@echo "✅ Stack stopped!"

restart: ## Restart the observability stack
	@echo "🔄 Restarting Claude Code observability stack..."
	docker-compose restart
	@echo "✅ Stack restarted!"

logs: ## Show logs from all services
	docker-compose logs -f

logs-collector: ## Show OpenTelemetry collector logs
	docker-compose logs -f otel-collector

logs-prometheus: ## Show Prometheus logs
	docker-compose logs -f prometheus

logs-grafana: ## Show Grafana logs
	docker-compose logs -f grafana

clean: ## Clean up containers and volumes
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f
	@echo "✅ Cleanup complete!"





validate-config: ## Validate all configuration files
	@echo "✅ Validating configurations..."
	@echo "📋 Checking docker-compose.yml..."
	docker-compose config > /dev/null && echo "✅ docker-compose.yml is valid"
	@echo "📋 Checking collector-config.yaml..."
	@if command -v otelcol-contrib >/dev/null 2>&1; then \
		otelcol-contrib --config-validate --config=collector-config.yaml; \
	else \
		echo "ℹ️  Install otelcol-contrib to validate collector config"; \
	fi


status: ## Show stack status
	@echo "📊 Claude Code Observability Stack Status"
	@echo "==========================================="
	@docker-compose ps
	@echo ""
	@echo "🌐 Service URLs:"
	@echo "  Grafana:    https://grafana.$${DOMAIN:-<your-domain>}"
	@echo "  OTLP gRPC:  https://otel.$${DOMAIN:-<your-domain>}:4317"
	@echo "  OTLP HTTP:  https://otel.$${DOMAIN:-<your-domain>}:4318"

setup-claude: ## Display Claude Code telemetry setup instructions
	@echo "🤖 Claude Code Telemetry Setup"
	@echo "==============================="
	@echo ""
	@echo "To enable telemetry in Claude Code, set these environment variables:"
	@echo ""
	@echo "export CLAUDE_CODE_ENABLE_TELEMETRY=1"
	@echo "export OTEL_METRICS_EXPORTER=otlp"
	@echo "export OTEL_LOGS_EXPORTER=otlp"
	@echo "export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf"
	@echo "export OTEL_EXPORTER_OTLP_ENDPOINT=https://otel.$${DOMAIN:-<your-domain>}:4318"
	@echo 'export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic $$(echo -n otel:<your-password> | base64)"'
	@echo ""
	@echo "Then run: claude"

demo-metrics: ## Generate demo metrics for testing
	@echo "🎯 This would generate demo metrics if Claude Code was running"
	@echo "💡 To see real metrics, ensure Claude Code is configured with telemetry enabled"
	@echo "📖 Run 'make setup-claude' for setup instructions" 