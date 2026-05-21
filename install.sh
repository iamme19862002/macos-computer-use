#!/bin/bash
set -e

INSTALL_DIR="/usr/local/bin"
BINARY_NAME="macos-computer-use"
BINARY_PATH=".build/release/${BINARY_NAME}"

echo "🔧 Installing ${BINARY_NAME}..."

# Check if binary exists
if [ ! -f "${BINARY_PATH}" ]; then
    echo "❌ Release binary not found. Building..."
    swift build -c release
fi

# Install binary
if [ -w "${INSTALL_DIR}" ]; then
    cp "${BINARY_PATH}" "${INSTALL_DIR}/${BINARY_NAME}"
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
else
    echo "🔐 Administrator privileges required to install to ${INSTALL_DIR}"
    sudo cp "${BINARY_PATH}" "${INSTALL_DIR}/${BINARY_NAME}"
    sudo chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
fi

echo "✅ ${BINARY_NAME} installed to ${INSTALL_DIR}/${BINARY_NAME}"
echo ""
echo "📋 Verify installation:"
echo "   ${BINARY_NAME} --help"
