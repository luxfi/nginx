#!/bin/bash

# Nginx configuration management script for blockchain services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to print colored output
print_status() {
    case $1 in
        "success") echo -e "${GREEN}✓${NC} $2" ;;
        "warning") echo -e "${YELLOW}!${NC} $2" ;;
        "error") echo -e "${RED}✗${NC} $2" ;;
        *) echo "$2" ;;
    esac
}

# Function to install all configs
install_configs() {
    echo "Installing nginx configurations..."
    
    # Copy all .conf files to sites-available
    for conf in "$SCRIPT_DIR"/*.conf; do
        if [ -f "$conf" ]; then
            filename=$(basename "$conf")
            sudo cp "$conf" "$NGINX_AVAILABLE/"
            print_status "success" "Copied $filename to sites-available"
        fi
    done
}

# Function to enable a specific config
enable_config() {
    local config=$1
    if [ -f "$NGINX_AVAILABLE/$config" ]; then
        sudo ln -sf "$NGINX_AVAILABLE/$config" "$NGINX_ENABLED/"
        print_status "success" "Enabled $config"
    else
        print_status "error" "Config $config not found in sites-available"
    fi
}

# Function to disable a specific config
disable_config() {
    local config=$1
    if [ -L "$NGINX_ENABLED/$config" ]; then
        sudo rm "$NGINX_ENABLED/$config"
        print_status "success" "Disabled $config"
    else
        print_status "warning" "Config $config not found in sites-enabled"
    fi
}

# Function to enable all configs
enable_all() {
    echo "Enabling all blockchain service configurations..."
    for conf in "$SCRIPT_DIR"/*.conf; do
        if [ -f "$conf" ]; then
            filename=$(basename "$conf")
            enable_config "$filename"
        fi
    done
}

# Function to list status
list_status() {
    echo -e "\n${GREEN}Available configurations:${NC}"
    ls -1 "$NGINX_AVAILABLE"/*.conf 2>/dev/null | xargs -n1 basename | sort
    
    echo -e "\n${YELLOW}Enabled configurations:${NC}"
    ls -1 "$NGINX_ENABLED"/*.conf 2>/dev/null | xargs -n1 basename | sort
}

# Function to test nginx configuration
test_config() {
    echo "Testing nginx configuration..."
    if sudo nginx -t; then
        print_status "success" "Nginx configuration is valid"
        return 0
    else
        print_status "error" "Nginx configuration has errors"
        return 1
    fi
}

# Function to reload nginx
reload_nginx() {
    if test_config; then
        echo "Reloading nginx..."
        if sudo systemctl reload nginx; then
            print_status "success" "Nginx reloaded successfully"
        else
            print_status "error" "Failed to reload nginx"
        fi
    else
        print_status "error" "Cannot reload nginx due to configuration errors"
    fi
}

# Main script logic
case "$1" in
    install)
        install_configs
        ;;
    enable)
        if [ -z "$2" ]; then
            enable_all
        else
            enable_config "$2"
        fi
        ;;
    disable)
        if [ -z "$2" ]; then
            print_status "error" "Please specify a config to disable"
            exit 1
        fi
        disable_config "$2"
        ;;
    list|status)
        list_status
        ;;
    test)
        test_config
        ;;
    reload)
        reload_nginx
        ;;
    setup)
        # Full setup process
        install_configs
        enable_all
        reload_nginx
        ;;
    help|*)
        echo "Usage: $0 {install|enable|disable|list|test|reload|setup|help}"
        echo ""
        echo "Commands:"
        echo "  install              - Copy all configs to sites-available"
        echo "  enable [config]      - Enable specific config or all if none specified"
        echo "  disable <config>     - Disable specific config"
        echo "  list/status         - Show available and enabled configs"
        echo "  test                - Test nginx configuration"
        echo "  reload              - Test and reload nginx"
        echo "  setup               - Full setup (install, enable all, reload)"
        echo "  help                - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 setup                     # Full setup"
        echo "  $0 enable api.lux.network.conf   # Enable specific config"
        echo "  $0 disable explore.zoo.network.conf  # Disable specific config"
        ;;
esac