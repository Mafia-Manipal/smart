#ifndef CONFIG_H
#define CONFIG_H

// Smart Irrigation System Configuration
// Adjust these values based on your specific requirements

// ===== Soil Moisture Thresholds =====
// These values determine when to start/stop watering based on soil moisture percentage
#define MOISTURE_ON_THRESHOLD    35    // Start watering when moisture drops below this %
#define MOISTURE_OFF_THRESHOLD   45    // Stop watering when moisture rises above this %

// ===== Humidity Limits =====
// These values prevent watering when humidity is too high
#define HUMIDITY_ON_LIMIT        80    // Allow watering when humidity is below this %
#define HUMIDITY_OFF_LIMIT       85    // Stop watering when humidity rises above this %

// ===== Hardware Configuration =====
// Pin assignments (LPC1768 specific)
#define SOIL_MOISTURE_PIN        25    // P0.25 - ADC0.2 for soil moisture sensor
#define DHT11_DATA_PIN           22    // P0.22 - DHT11 data pin
#define LED_PIN                  18    // P1.18 - Status LED (active low)

// ===== Timing Configuration =====
#define MAIN_LOOP_DELAY_MS       1000  // Main loop delay in milliseconds
#define DHT11_START_DELAY_MS     20    // DHT11 start signal duration
#define DHT11_RESPONSE_DELAY_US  30    // DHT11 response delay
#define ADC_SAMPLE_DELAY_US      1     // ADC sampling delay

// ===== ADC Configuration =====
#define ADC_RESOLUTION_BITS      12    // 12-bit ADC resolution
#define ADC_MAX_VALUE            4095  // Maximum ADC reading (2^12 - 1)
#define ADC_REFERENCE_VOLTAGE    3.3   // Reference voltage in volts

// ===== DHT11 Configuration =====
#define DHT11_TIMEOUT_CYCLES     200   // Timeout for DHT11 communication
#define DHT11_PRESENCE_TIMEOUT   120   // Timeout for presence detection
#define DHT11_BIT_TIMEOUT        150   // Timeout for bit reading

// ===== System Configuration =====
#define SYSTEM_CLOCK_MHZ         100   // System clock frequency in MHz
#define DELAY_CYCLES_PER_US      100   // Delay cycles per microsecond
#define DELAY_CYCLES_PER_MS      100000 // Delay cycles per millisecond

// ===== Error Codes =====
#define DHT11_ERROR_TIMEOUT_1    -1    // Timeout waiting for DHT11 response
#define DHT11_ERROR_TIMEOUT_2    -2    // Timeout during presence detection (low)
#define DHT11_ERROR_TIMEOUT_3    -3    // Timeout during presence detection (high)
#define DHT11_ERROR_TIMEOUT_4    -4    // Timeout waiting for bit start
#define DHT11_ERROR_TIMEOUT_5    -5    // Timeout waiting for bit end
#define DHT11_ERROR_CHECKSUM     -6    // Checksum validation failed

// ===== Debug Configuration =====
#ifdef DEBUG
#define DEBUG_PRINT(x)           printf x
#else
#define DEBUG_PRINT(x)
#endif

// ===== Calibration Values =====
// These can be adjusted based on your specific sensors and soil type
#define SOIL_DRY_VALUE           0     // ADC reading for completely dry soil
#define SOIL_WET_VALUE           4095  // ADC reading for completely wet soil

// ===== Safety Limits =====
#define MAX_WATERING_DURATION_MS 300000 // Maximum continuous watering time (5 minutes)
#define MIN_SENSOR_INTERVAL_MS   5000   // Minimum time between sensor readings

#endif // CONFIG_H
