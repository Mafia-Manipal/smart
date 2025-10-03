#include "config.h"
#include <stdio.h>
#include <stdint.h>

// Simple test program for Smart Irrigation System
// This can be used to verify sensor readings and system logic

// Mock functions for testing (replace with actual hardware calls in real implementation)
static uint16_t mock_adc_reading = 2000;  // Mock ADC reading (middle range)
static uint8_t mock_humidity = 60;        // Mock humidity reading
static int mock_dht11_error = 0;          // Mock DHT11 error code

// Mock ADC function
uint16_t mock_adc_read(void) {
    return mock_adc_reading;
}

// Mock DHT11 function
int mock_dht11_read(uint8_t* humidity) {
    if (mock_dht11_error != 0) {
        return mock_dht11_error;
    }
    *humidity = mock_humidity;
    return 0;
}

// Test soil moisture calculation
void test_soil_moisture_calculation(void) {
    printf("=== Testing Soil Moisture Calculation ===\n");
    
    // Test different ADC readings
    uint16_t test_readings[] = {0, 1000, 2000, 3000, 4095};
    int num_tests = sizeof(test_readings) / sizeof(test_readings[0]);
    
    for (int i = 0; i < num_tests; i++) {
        uint16_t raw = test_readings[i];
        int moist_pct = (int)((raw / 4095.0f) * 100.0f);
        printf("ADC: %4d -> Moisture: %3d%%\n", raw, moist_pct);
    }
    printf("\n");
}

// Test watering decision logic
void test_watering_logic(void) {
    printf("=== Testing Watering Decision Logic ===\n");
    
    // Test cases: {moisture, humidity, expected_decision}
    struct test_case {
        int moisture;
        int humidity;
        int expected_water;
        const char* description;
    };
    
    struct test_case tests[] = {
        {30, 70, 1, "Low moisture, normal humidity - should water"},
        {50, 70, 0, "High moisture, normal humidity - should not water"},
        {30, 90, 0, "Low moisture, high humidity - should not water"},
        {40, 75, 1, "Medium moisture, normal humidity - should water"},
        {45, 85, 0, "High moisture, high humidity - should not water"},
        {25, -1, 1, "Low moisture, sensor error - should water"},
        {50, -1, 0, "High moisture, sensor error - should not water"}
    };
    
    int num_tests = sizeof(tests) / sizeof(tests[0]);
    
    for (int i = 0; i < num_tests; i++) {
        struct test_case* test = &tests[i];
        
        // Simulate watering decision logic
        int water_decision = 0;
        
        if (test->humidity >= 0) {
            // Humidity sensor working
            if (test->moisture < MOISTURE_ON_THRESHOLD && 
                test->humidity < HUMIDITY_ON_LIMIT) {
                water_decision = 1;
            }
        } else {
            // Humidity sensor failed, use moisture only
            if (test->moisture < MOISTURE_ON_THRESHOLD) {
                water_decision = 1;
            }
        }
        
        printf("Test %d: %s\n", i + 1, test->description);
        printf("  Moisture: %d%%, Humidity: %s\n", 
               test->moisture, 
               test->humidity >= 0 ? (char[]){(test->humidity + '0'), '\0'} : "ERROR");
        printf("  Expected: %s, Got: %s - %s\n\n",
               test->expected_water ? "WATER" : "NO WATER",
               water_decision ? "WATER" : "NO WATER",
               (water_decision == test->expected_water) ? "PASS" : "FAIL");
    }
}

// Test hysteresis behavior
void test_hysteresis_behavior(void) {
    printf("=== Testing Hysteresis Behavior ===\n");
    
    int water_state = 0;
    int moisture_values[] = {30, 35, 40, 45, 50, 45, 40, 35, 30};
    int num_values = sizeof(moisture_values) / sizeof(moisture_values[0]);
    
    printf("Simulating moisture changes with hysteresis:\n");
    printf("ON threshold: %d%%, OFF threshold: %d%%\n\n", 
           MOISTURE_ON_THRESHOLD, MOISTURE_OFF_THRESHOLD);
    
    for (int i = 0; i < num_values; i++) {
        int moisture = moisture_values[i];
        
        // Apply hysteresis logic
        if (!water_state) {
            if (moisture < MOISTURE_ON_THRESHOLD) {
                water_state = 1;
            }
        } else {
            if (moisture > MOISTURE_OFF_THRESHOLD) {
                water_state = 0;
            }
        }
        
        printf("Moisture: %2d%% -> %s\n", 
               moisture, 
               water_state ? "WATERING" : "NOT WATERING");
    }
    printf("\n");
}

// Test error handling
void test_error_handling(void) {
    printf("=== Testing Error Handling ===\n");
    
    // Test DHT11 error codes
    int error_codes[] = {
        DHT11_ERROR_TIMEOUT_1,
        DHT11_ERROR_TIMEOUT_2,
        DHT11_ERROR_TIMEOUT_3,
        DHT11_ERROR_TIMEOUT_4,
        DHT11_ERROR_TIMEOUT_5,
        DHT11_ERROR_CHECKSUM
    };
    
    int num_errors = sizeof(error_codes) / sizeof(error_codes[0]);
    
    for (int i = 0; i < num_errors; i++) {
        int error = error_codes[i];
        printf("DHT11 Error %d: %s\n", error, 
               error == DHT11_ERROR_CHECKSUM ? "Checksum failed" : "Timeout");
    }
    printf("\n");
}

// Test system parameters
void test_system_parameters(void) {
    printf("=== System Parameters ===\n");
    printf("Soil Moisture ON Threshold:  %d%%\n", MOISTURE_ON_THRESHOLD);
    printf("Soil Moisture OFF Threshold: %d%%\n", MOISTURE_OFF_THRESHOLD);
    printf("Humidity ON Limit:           %d%%\n", HUMIDITY_ON_LIMIT);
    printf("Humidity OFF Limit:          %d%%\n", HUMIDITY_OFF_LIMIT);
    printf("Main Loop Delay:             %d ms\n", MAIN_LOOP_DELAY_MS);
    printf("ADC Resolution:              %d bits\n", ADC_RESOLUTION_BITS);
    printf("ADC Max Value:               %d\n", ADC_MAX_VALUE);
    printf("System Clock:                %d MHz\n", SYSTEM_CLOCK_MHZ);
    printf("\n");
}

int main(void) {
    printf("Smart Irrigation System - Test Suite\n");
    printf("====================================\n\n");
    
    test_system_parameters();
    test_soil_moisture_calculation();
    test_watering_logic();
    test_hysteresis_behavior();
    test_error_handling();
    
    printf("All tests completed!\n");
    return 0;
}
