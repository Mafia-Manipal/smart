#!/bin/bash

# Smart Irrigation System Build Script
# This script provides easy compilation options for the project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="smart_irrigation"
TARGET_MCU="LPC1768"
BUILD_DIR="build"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command_exists arm-none-eabi-gcc; then
        missing_tools+=("arm-none-eabi-gcc")
    fi
    
    if ! command_exists arm-none-eabi-g++; then
        missing_tools+=("arm-none-eabi-g++")
    fi
    
    if ! command_exists make; then
        missing_tools+=("make")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Please install ARM GCC toolchain:"
        print_status "  Ubuntu/Debian: sudo apt-get install gcc-arm-none-eabi"
        print_status "  macOS: brew install arm-none-eabi-gcc"
        print_status "  Or download from: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain"
        exit 1
    fi
    
    print_success "All prerequisites found"
}

# Function to clean build directory
clean_build() {
    print_status "Cleaning build directory..."
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        print_success "Build directory cleaned"
    else
        print_status "No build directory to clean"
    fi
}

# Function to create build directory
create_build_dir() {
    if [ ! -d "$BUILD_DIR" ]; then
        mkdir -p "$BUILD_DIR"
        print_success "Created build directory: $BUILD_DIR"
    fi
}

# Function to compile the project
compile_project() {
    print_status "Compiling $PROJECT_NAME for $TARGET_MCU..."
    
    create_build_dir
    
    # Run make
    if make -j$(nproc 2>/dev/null || echo 4); then
        print_success "Compilation completed successfully"
        
        # Show build results
        if [ -f "$BUILD_DIR/$PROJECT_NAME.elf" ]; then
            print_status "Build artifacts:"
            ls -la "$BUILD_DIR/"
            
            # Show size information
            if command_exists arm-none-eabi-size; then
                print_status "Memory usage:"
                arm-none-eabi-size "$BUILD_DIR/$PROJECT_NAME.elf"
            fi
        fi
    else
        print_error "Compilation failed"
        exit 1
    fi
}

# Function to compile test program
compile_test() {
    print_status "Compiling test program..."
    
    if command_exists gcc; then
        gcc -o test_system test_system.cpp -lm
        print_success "Test program compiled successfully"
    else
        print_warning "GCC not found, skipping test compilation"
    fi
}

# Function to run tests
run_tests() {
    if [ -f "test_system" ]; then
        print_status "Running system tests..."
        ./test_system
        print_success "Tests completed"
    else
        print_warning "Test program not found, run 'compile_test' first"
    fi
}

# Function to show help
show_help() {
    echo "Smart Irrigation System Build Script"
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  build       Compile the main project (default)"
    echo "  clean       Clean build directory"
    echo "  test        Compile and run test program"
    echo "  compile_test Compile test program only"
    echo "  run_tests   Run test program"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build        # Compile the project"
    echo "  $0 clean        # Clean build files"
    echo "  $0 test         # Compile and run tests"
}

# Main script logic
main() {
    local action="${1:-build}"
    
    case "$action" in
        "build")
            check_prerequisites
            compile_project
            ;;
        "clean")
            clean_build
            ;;
        "test")
            compile_test
            run_tests
            ;;
        "compile_test")
            compile_test
            ;;
        "run_tests")
            run_tests
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown option: $action"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
