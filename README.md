# Smart Irrigation System

A microcontroller-based smart irrigation system using LPC1768 that automatically controls plant watering based on soil moisture and humidity levels.

## Features

- **Soil Moisture Sensing**: Uses ADC to read analog soil moisture sensor on P0.25
- **Humidity Monitoring**: DHT11 sensor on P0.22 for ambient humidity detection
- **Smart Decision Logic**: Hysteresis-based watering control to prevent over/under watering
- **Visual Feedback**: LED indicator (P1.18) shows watering status
- **Low-level Hardware Control**: Direct register manipulation for optimal performance

## Hardware Requirements

### Microcontroller
- LPC1768 (ARM Cortex-M3)
- mbed development board

### Sensors
- **Soil Moisture Sensor**: Analog output connected to P0.25 (AD0.2)
- **DHT11**: Digital humidity/temperature sensor on P0.22

### Connections
```
LPC1768 Pin Assignments:
- P0.25 (AD0.2)  → Soil Moisture Sensor (Analog)
- P0.22          → DHT11 Data Pin
- P1.18          → LED (Active Low)
- 3.3V           → Sensor Power
- GND            → Common Ground
```

## System Logic

### Watering Decision Algorithm
The system uses a hysteresis-based approach to prevent rapid on/off cycling:

1. **Soil Moisture Thresholds**:
   - Turn ON watering: < 35% moisture
   - Turn OFF watering: > 45% moisture

2. **Humidity Limits**:
   - Allow watering: < 80% humidity
   - Block watering: > 85% humidity

3. **Decision Matrix**:
   - If humidity sensor fails: Use soil moisture only
   - If humidity available: Consider both moisture and humidity
   - LED ON = Water the plant
   - LED OFF = Do not water

### Timing
- Main loop runs every 1000ms (1 second)
- DHT11 communication uses precise timing for data integrity
- ADC conversion completes in microseconds

## Code Structure

### Key Components

1. **Hardware Abstraction**:
   - Direct register access for GPIO, ADC, and system control
   - Pin configuration for analog and digital I/O
   - Clock configuration for peripherals

2. **Sensor Drivers**:
   - `adc0_init_ad02()`: Configure ADC for soil moisture reading
   - `adc0_read_ch2_once()`: Read 12-bit soil moisture value
   - `dht11_read_rh_uint()`: Read humidity from DHT11 sensor

3. **Control Logic**:
   - Hysteresis state machine for watering decisions
   - Error handling for sensor failures
   - Percentage calculations with bounds checking

### Configuration Constants
```cpp
static const int MOIST_ON_TH  = 35;   // Turn ON below this moisture %
static const int MOIST_OFF_TH = 45;  // Turn OFF above this moisture %
static const int RH_ON_LIMIT  = 80;   // Allow watering below this humidity %
static const int RH_OFF_LIMIT = 85;   // Block watering above this humidity %
```

## Compilation and Deployment

### Prerequisites
- mbed CLI or mbed Studio
- LPC1768 target support
- ARM GCC toolchain

### Build Commands
```bash
# Using mbed CLI
mbed compile -m LPC1768 -t GCC_ARM

# Using mbed Studio
# Import project and build for LPC1768 target
```

### Flashing
```bash
# Flash to target
mbed flash -m LPC1768
```

## Usage

1. **Hardware Setup**:
   - Connect soil moisture sensor to P0.25
   - Connect DHT11 to P0.22
   - Ensure proper power and ground connections

2. **Calibration**:
   - Adjust `MOIST_ON_TH` and `MOIST_OFF_TH` based on your soil type
   - Modify humidity limits based on plant requirements

3. **Operation**:
   - System starts with LED OFF (no watering)
   - Monitor LED status for watering decisions
   - Check sensor readings for system health

## Troubleshooting

### Common Issues

1. **DHT11 Communication Errors**:
   - Check wiring and pull-up resistor
   - Verify timing delays are accurate
   - Ensure stable power supply

2. **ADC Reading Issues**:
   - Verify analog sensor connections
   - Check reference voltage stability
   - Calibrate sensor readings

3. **LED Not Responding**:
   - Check P1.18 connection
   - Verify LED polarity (active-low)
   - Test GPIO configuration

### Error Codes
- DHT11 returns negative values for communication errors
- ADC returns 0-4095 range (12-bit)
- System continues operation even with sensor failures

## Customization

### Adjusting Thresholds
Modify the constants at the top of the main function:
```cpp
static const int MOIST_ON_TH  = 35;   // Your soil moisture threshold
static const int MOIST_OFF_TH = 45;   // Hysteresis offset
static const int RH_ON_LIMIT  = 80;   // Humidity limit for watering
static const int RH_OFF_LIMIT = 85;   // Humidity limit to stop watering
```

### Adding Features
- Temperature monitoring from DHT11
- Multiple soil moisture sensors
- Water pump control relay
- Data logging capabilities
- Wireless communication module

## Technical Specifications

- **Microcontroller**: LPC1768 (ARM Cortex-M3 @ 100MHz)
- **ADC Resolution**: 12-bit (0-4095)
- **Sensor Accuracy**: DHT11 ±2% RH, ±1°C
- **Response Time**: 1-second sampling rate
- **Power Consumption**: Low power operation with sleep modes possible

## License

This project is open source. Feel free to modify and distribute according to your needs.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:
- Bug fixes
- Feature enhancements
- Documentation improvements
- Hardware compatibility updates
