#undef __ARM_FP
#include "mbed.h"
#include <stdint.h>
#include <math.h>

// Base addresses (LPC1768)
#ifndef LPC_SC_BASE
  #define LPC_SC_BASE       0x400FC000UL  //system control block
#endif
#ifndef LPC_PINCON_BASE                   //Pin control block
  #define LPC_PINCON_BASE   0x4002C000UL
#endif
#ifndef LPC_GPIO_BASE                     //GPIO Registers
  #define LPC_GPIO_BASE     0x2009C000UL
#endif
#ifndef LPC_ADC_BASE                       //Analog to Digital Converter
  #define LPC_ADC_BASE      0x40034000UL
#endif

#define REG32(a) (*(volatile uint32_t*)(a))

/* ===== System control ===== */
#define PCONP              REG32(LPC_SC_BASE + 0x0C4)  //enable or disable clk for a specific peripheral
#define PCLKSEL0           REG32(LPC_SC_BASE + 0x1A8)  //clock divider

/* ===== Pin connect ===== */
#define PINSEL0            REG32(LPC_PINCON_BASE + 0x000)
#define PINSEL1            REG32(LPC_PINCON_BASE + 0x004)
#define PINMODE0           REG32(LPC_PINCON_BASE + 0x040)   //configure analog inputs for no pull op
#define PINMODE1           REG32(LPC_PINCON_BASE + 0x044)   //configure analog inputs for no pull op

/* ===== Fast GPIO P0/P1 ===== */
#define FIO0DIR            REG32(LPC_GPIO_BASE + 0x000)  //Direction- Input/Ouput
#define FIO0PIN            REG32(LPC_GPIO_BASE + 0x014)  //Read Value
#define FIO0SET            REG32(LPC_GPIO_BASE + 0x018)  //Writing 1 sets pin to HIGH
#define FIO0CLR            REG32(LPC_GPIO_BASE + 0x01C)  //Writing 1 sets pin to LOW

#define FIO1DIR            REG32(LPC_GPIO_BASE + 0x020)
#define FIO1PIN            REG32(LPC_GPIO_BASE + 0x034)
#define FIO1SET            REG32(LPC_GPIO_BASE + 0x038)        
#define FIO1CLR            REG32(LPC_GPIO_BASE + 0x03C)

/* ===== ADC0 ===== */
#define AD0CR              REG32(LPC_ADC_BASE + 0x000)  //Controls ADC Peripherals
#define AD0GDR             REG32(LPC_ADC_BASE + 0x004)  //Global Data register- stores value of Latest ADC Conversion with flag

/* ===== PCONP bits ===== */
#define PCONP_PCADC        (1U << 12)  //sets bit 12 of PCONP as HIGH(ADC), MAKING its registers accessible

/* ===== PCLKSEL0 fields ===== */
#define PCLKSEL0_PCLK_ADC_SHIFT   24

/* ===== ADC fields ===== */
#define ADCR_SEL_SHIFT     0 //Select which ADC Channel
#define ADCR_CLKDIV_SHIFT  8 //Clock Divider
#define ADCR_PDN           (1U << 21)  //Power Down
#define ADCR_START_SHIFT   24  //start in ADOCR
#define ADGDR_DONE         (1U << 31)  //done flag
#define ADGDR_RESULT_MASK  (0xFFFU << 4) //12 bit ADC result stored in 15:4 of AD0GR

/* ===== Delays ===== */
static void delay_cycles(volatile uint32_t n){ while(n--){ __asm volatile("nop"); } }
static void delay_us(uint32_t us){ while(us--){ delay_cycles(100); } }   // ~1 µs @100 MHz
static void delay_ms(uint32_t ms){ while(ms--){ delay_cycles(100000); } } // ~1 ms @100 MHz

/* ===== LED: use P1.18 (mbed LED1, active-low) ===== */
#define LED_BIT   18u
static inline void led_init(void){ FIO1DIR |= (1u<<LED_BIT); }
static inline void led_on(void){  FIO1CLR  = (1u<<LED_BIT); } // active-low ON[web:622]
static inline void led_off(void){ FIO1SET  = (1u<<LED_BIT); } // OFF[web:622]

/* ===== ADC0.2 (Soil moisture AO on P0.25) ===== */
static void adc0_init_ad02(void){
  PCONP |= PCONP_PCADC;  //Set bit 12 in PCONP register field
  PCLKSEL0 &= ~(3U << PCLKSEL0_PCLK_ADC_SHIFT); //Clear bit 24 tthen set PCLKSEL0 as 01
  PCLKSEL0 |=  (3U << PCLKSEL0_PCLK_ADC_SHIFT);    // PCLK_ADC = CCLK/8
  // P0.25 -> AD0.2
  PINSEL1  &= ~(3U << 18);  //clear bit 18-19
  PINSEL1  |=  (1U << 18);  //set bit 18-19 as 01 (ADC input)
  PINMODE1 &= ~(3U << 18);  
  PINMODE1 |=  (2U << 18);  //set bit as 10                       // no pulls
  AD0CR = (1U << (ADCR_SEL_SHIFT + 2)) | ADCR_PDN | (0U << ADCR_CLKDIV_SHIFT);
} // AD0.2 routing and AD0GDR usage per UM10360[attached_file:698].

static uint16_t adc0_read_ch2_once(void){
  AD0CR &= ~(7U << ADCR_START_SHIFT); //clear the start field  (26:24) of AD0CR
  AD0CR |=  (1U << ADCR_START_SHIFT);  //write 001 to fields 26:24 signalling start conversion
    while(!(AD0GDR & ADGDR_DONE)){} //carry out the conversion till bit 31 of AD0CR becomes 1
  uint32_t gdr = AD0GDR; //put 12 bit value of AD0GDR in a variable gdr (15:4)
  AD0CR &= ~(7U << ADCR_START_SHIFT);  //clear the start field again
  return (uint16_t)((gdr & ADGDR_RESULT_MASK) >> 4);  //mask the GDR result with FFFU to expose only 15:4, then right shift by 4 bits to bring it to 11:0 (valid 12 bit useful for math)
} // 12-bit result in bits [15:4] per UM10360[attached_file:698].

/* ===== DHT11 on P0.22 (DATA, one-wire) ===== */
#define DHT_BIT 22u
static inline void dht_out(void){ FIO0DIR |=  (1u<<DHT_BIT); }
static inline void dht_in(void) { FIO0DIR &= ~(1u<<DHT_BIT); }
static inline void dht_lo(void){  FIO0CLR =  (1u<<DHT_BIT); }
static inline uint32_t dht_rd(void){ return (FIO0PIN >> DHT_BIT) & 1u; }

static void dht_pin_init(void){
  // P0.22 as GPIO with internal pull-up (PINSEL1[13:12]=00, PINMODE1[13:12]=00)
  PINSEL1  &= ~(3u<<12);
  PINMODE1 &= ~(3u<<12);
  dht_in();
} // DHT11 needs a pull-up on DATA[web:680][web:676].

static int dht11_read_rh_uint(uint8_t* rh){
  uint8_t b[5]={0};
  // Start: drive low >=18 ms then release
  dht_out(); dht_lo(); delay_ms(20);
  dht_in();  delay_us(30);
  // Presence: ~80 µs low, ~80 µs high
  uint32_t t=0;
  while(dht_rd()==1){ if(++t>200) return -1; delay_us(1); }
  t=0; while(dht_rd()==0){ if(++t>120) return -2; delay_us(1); }
  t=0; while(dht_rd()==1){ if(++t>120) return -3; delay_us(1); }
  // Read 40 bits
  for(int i=0;i<5;i++){
    for(int bit=7; bit>=0; bit--){
      t=0; while(dht_rd()==0){ if(++t>120) return -4; delay_us(1); } // wait 50 µs low
      delay_us(40);                          // sample during high
      if (dht_rd()) b[i] |= (1u<<bit);       // ~70 µs => 1, ~26–28 µs => 0
      t=0; while(dht_rd()==1){ if(++t>150) return -5; delay_us(1); }
    }
  }
  uint8_t sum = (uint8_t)(b[0]+b[1]+b[2]+b[3]);
  if (sum != b[4]) return -6;
  *rh = b[0];                                  // integer RH
  return 0;
} // DHT11 timing per datasheet: 18 ms start, 80/80 presence, 40-bit frame[web:680][web:676].

/* ===== Decision policy with hysteresis =====
   LED ON  -> WATER THE PLANT
   LED OFF -> DO NOT WATER
*/
static const int MOIST_ON_TH  = 35;   // turn ON below this
static const int MOIST_OFF_TH = 45;   // turn OFF above this
static const int RH_ON_LIMIT  = 80;   // allow watering below this
static const int RH_OFF_LIMIT = 85;   // block watering above this

static uint8_t clamp_u8(int v){ if(v<0) v=0; if(v>100) v=100; return (uint8_t)v; }  //calculated percentage is always between 0 to 100!

int main(void){
  adc0_init_ad02();        // Soil AO on P0.25
  dht_pin_init();          // DHT11 on P0.22 with pull-up
  led_init(); led_off();   // start OFF (DO NOT WATER)

  int water_state = 0;
  while(1){
    // Soil moisture in %
    uint16_t raw = adc0_read_ch2_once();
    int moist_pct = (int)lroundf((raw / 4095.0f) * 100.0f);
    moist_pct = clamp_u8(moist_pct);           // 0..100[web:553]

    // Humidity %
    uint8_t rh_b=0; int drc = dht11_read_rh_uint(&rh_b);
    int hum_pct = (drc==0) ? (int)rh_b : -1;   // -1 if invalid[web:680]

    // Hysteresis decision
    if (hum_pct >= 0){
      if (!water_state){
        if (moist_pct < MOIST_ON_TH && hum_pct < RH_ON_LIMIT) water_state = 1;
      } else {
        if (moist_pct > MOIST_OFF_TH || hum_pct > RH_OFF_LIMIT) water_state = 0;
      }
    } else {
      if (!water_state){ if (moist_pct < MOIST_ON_TH) water_state = 1; }
      else { if (moist_pct > MOIST_OFF_TH) water_state = 0; }
    }

    if (water_state) led_on(); else led_off(); // LED1 indicates WATER/NO[web:622]
    delay_ms(1000);
  }
}
