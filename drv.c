#ifdef __clang__ 
// for building with clang - does not produce anything useable for DOS
// but the compiler has much better diagnostics :)

// helper to get it compile with recent clang

#define VERSION 10 // version selected manually

#define far
#define near

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int16_t;
typedef unsigned short uint16_t;

static inline uint8_t inb(uint16_t port_){ (void)port_; return 0; }
static inline void outb(uint16_t port_, uint8_t value_){}
static inline uint16_t inw(uint16_t port_){ (void)port_; return 0; }
static inline void outw(uint16_t port_, uint16_t value_){}
static inline void cli(){}
static inline void sti(){}

#define CODE_SEG_VAR

#else
  
//-----------------------

//https://github.com/open-watcom/open-watcom-v2/issues/703
// uint8_t is internal implemented with plain char aka unsigned char
// so using a int8_t give a comparison warning: W124: Comparison result always 1

// https://stackoverflow.com/questions/19401887/how-to-check-the-size-of-a-structure-at-compile-time
// check size at compile time without static_assert
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int16_t;
typedef unsigned short uint16_t;

//-----------------------
// inline assembler with Watcom
// https://tuttlem.github.io/2015/10/04/inline-assembly-with-watcom.html
// https://users.pja.edu.pl/~jms/qnx/help/watcom/compiler-tools/pragma32.html
// http://www.azillionmonkeys.com/qed/watfaq.shtml
// https://users.pja.edu.pl/~jms/qnx/help/watcom/compiler-tools/cpasm.html

static inline uint8_t inb(uint16_t port_);
#pragma aux inb = "in al, dx" parm[dx] value[al]

static inline void outb(uint16_t port_, uint8_t value_);
#pragma aux outb = "out dx, al" parm[dx][al]

static inline uint16_t inw(uint16_t port_);
#pragma aux inw = "in ax, dx" parm[dx] value[ax]

static inline void outw(uint16_t port_t, uint16_t value_);
#pragma aux outw = "out dx, ax" parm[dx][ax]

static inline void cli();
#pragma aux cli = "cli"

static inline void sti();
#pragma aux sti = "sti"

//-----------------------

#define CODE_SEG_VAR __based( __segname("_CODE") )

#endif

#define LO(VALUE)((uint8_t)(VALUE))
#define HI(VALUE)((uint8_t)((VALUE) >> 8u))

// clamp value to 7 bits
// Midi data bytes can be only 0-127
#define BITS7(VALUE)((VALUE) & 0x7Fu)

// TODO: what is the PIT frequence here? the MT15.DRV 1.1 delay is based on that frequence

//-----------------------

#define MPU_401_BASE 0x330u
#define MPU_401_PORT_DATA (MPU_401_BASE+0u)
#define MPU_401_PORT_STATUS_CMD (MPU_401_BASE+1u) // write => COMMAND-Port, read => STATUS-Port

// http://manuals.opensound.com/sources/oss_uart401.c.html
// status bit mask 
#define MPU_401_OUTPUT_READY 0x40u // bit 6
#define MPU_401_INPUT_AVAIL 0x80u // bit 7

#define MPU_401_CMD_RESET 0xFFu
#define MPU_401_CMD_UART_MODE 0x3Fu
#define MPU_401_STATUS_ACK 0xFEu

// General MIDI programming
//https://www.midi.org/specifications-old/item/table-2-expanded-messages-list-status-bytes
//https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2
//https://logosfoundation.org/kursus/1075.html
//https://stackoverflow.com/questions/29481090/explanation-of-midi-messages
//https://www.cs.cmu.edu/~music/cmsip/readings/MIDI%20tutorial%20for%20programmers.html
//https://www.bome.com/forums/3/12116/send-a-midi-message-to-all-the-ccs-after-pressing-a-keyboard-key/

#define PPI_PORT_B 0x61u

#define PIT_CHAN2_DATA 0x42u // Channel 2 data port (read/write)
#define PIT_MODE_CMD 0x43u // write only, a read is ignored

#define SYSEX_START 0xF0u
#define SYSEX_END 0xF7u

#define SYSEX_ROLAND_ID 0x41u
#define SYSEX_DEVICE_ID 0x10u
#define SYSEX_MODEL_ID_MT32 0x16u
#define SYSEX_SEND_CMD 0x12u

//----------------------

// these are structures that come through parameter 
// TODO: 
// unknown if these structs are all comming from 
// the same place(== same pointer)

#pragma pack ( push, 1 )

struct struct1_t
{
  uint8_t unknown1[18];
  uint8_t bender_range; // 0-24, cropped to 0-24 by MT32
  uint8_t unknown2[2];
  uint8_t byte_15;
  uint8_t unknown3[3];
  uint8_t byte_19;   
  uint8_t unknown4[14];
  uint8_t byte_28;  
  uint8_t unknown5[12];
  uint8_t byte_35;   
  uint8_t unknown6[14];
  uint8_t program;
  uint8_t volume;
  uint8_t pan;
};

struct struct2_t
{
  uint8_t unknown1[3];
  uint8_t key_note_number1;
  uint8_t velocity;
  uint8_t unknown2;
  uint8_t key_note_number2;
  uint8_t unknown3[13];
  uint16_t word_14;
  uint8_t unknown4[6];
  uint16_t word_1C;
  uint8_t unknown5[4];
  uint8_t byte_22;
};

struct sysex_address_t
{
  uint8_t byte_0;
  uint8_t byte_1;
  uint8_t byte_2;
};

/*
Patch Temp

Offset Address      Description
--------------      -----------
00 00H              0000 00aa     TIMBRE GROUP  0-3 
                                  (group A, group B, Memory, Rhythm)
00 01H              0000 00aa     TIMBRE NUMBER 0-63
00 02H              00aa aaaa     KEY SHIFT 0-48 (-24 - +24)
00 03H              00aa aaaa     FINE TUNE 0-100 (-50 - +50)
00 04H              0aaa aaaa     BENDER RANGE 0-24 <=========================== cropped to 0-24 by MT32
00 05H              000a aaaa     ASSIGN MODE 0-3
                                  (POLY1, POLY2, POLY3, POLY4)
00 06H              0000 00aa     REVERB SWITCH 0-1 (OFF,ON)
00 07H              0xxx xxxx     (DUMMY)
00 08H              0aaa aaaa     OUTPUT LEVEL 0-100
00 09H              0000 00aa     PANPOT 0-14 (R-L)
00 0AH              0000 aaaa     (DUMMY)
:
00 0FH              0000 00aa
TOTAL SIZE          00 00 10H
*/

struct patch_temporary_area_bender_range_msg_t // (sizeof=0x4)
{
  struct sysex_address_t address;
    // byte_0 - always 0x03
    // byte_1 - always 0x00
    // byte_2 - sizeof(PatchTemporaryArea)*PartIndex + 0x04
    //          0x10 * PartIndex + 0x04
  uint8_t bender_range; // allowed range: 0-24 (0x00-0x18)
};

struct display_msg_t
{
  struct sysex_address_t address;
  char text[20u];
};

struct msg_buffer_t
{
  struct sysex_address_t address;
  uint8_t content[253];
};

#define MT32_PATCH_MEMORY_ADRESS_BYTE0 5
#define MT32_TIMBRE_MEMORY_ADDRESS_BYTE0 8

#define MT32_PATCH_MEMORY_TIMBRE_GROUP_MEMORY 2

struct mt32_patch_memory_t
{
  uint8_t timbre_group; // 0:group A, 1:group B, 2:Memory, 3:Rhythm
  uint8_t timbre_number; // 0-63
  uint8_t key_shift; // 0-48 [-24...+24]
  uint8_t fine_tune; // 0-100 [-50...+50]
  uint8_t bender_range; // 0-24
  uint8_t assign_mode; // 0:POLY1, 1:POLY2, 2:POLY3, 3:POLY4
  uint8_t reverb_switch; // 0-1 (OFF,ON)
  uint8_t dummy;
};

struct mt32_timbre_memory_t
{
  uint8_t data[246];
};

#if 0
struct mt32_plb_sound_t
{
  struct mt32_patch_memory_t patch_memory_data;
  struct mt32_timbre_memory_t timbre_memory_data;
};

struct mt32_plb_file_t 
{
  uint8_t sound_count;
  struct mt32_plb_sound_t sounds[5];
};
#endif

#pragma  pack ( pop )

#if __clang__

// https://en.wikipedia.org/wiki/Offsetof
#define offsetof(st, m) __builtin_offsetof(st, m)

static_assert(sizeof(struct mt32_timbre_memory_t) == 246u, "wrong size");

static_assert(sizeof(struct struct1_t) == 0x47u, "wrong size");
static_assert(offsetof(struct struct1_t, bender_range) == 0x12u, "wrong offset");
static_assert(offsetof(struct struct1_t, byte_15) == 0x15u, "wrong offset");
static_assert(offsetof(struct struct1_t, byte_19) == 0x19u, "wrong offset");   
static_assert(offsetof(struct struct1_t, byte_28) == 0x28u, "wrong offset");  
static_assert(offsetof(struct struct1_t, byte_35) == 0x35u, "wrong offset");   
static_assert(offsetof(struct struct1_t, program) == 0x44u, "wrong offset");
static_assert(offsetof(struct struct1_t, volume) == 0x45u, "wrong offset");
static_assert(offsetof(struct struct1_t, pan) == 0x46u, "wrong offset");

static_assert(sizeof(struct struct2_t) == 0x23u, "wrong size");
static_assert(sizeof(struct sysex_address_t) == 3u, "wrong size");
#endif

//----------------------

extern struct msg_buffer_t CODE_SEG_VAR msg_buffer;
extern uint8_t CODE_SEG_VAR byte_14A_buffer[0x28u];
extern uint16_t CODE_SEG_VAR word_172_buffer_index1;
extern uint16_t CODE_SEG_VAR word_174_buffer_index2;

extern const uint8_t CODE_SEG_VAR display_start_adress[3u];
extern const uint8_t CODE_SEG_VAR display_text[20u];

extern uint8_t CODE_SEG_VAR patch_memory_address_byte1;
extern uint8_t CODE_SEG_VAR patch_memory_address_byte2;
extern uint8_t CODE_SEG_VAR timbre_memory_address_byte1;
extern uint8_t CODE_SEG_VAR timbre_memory_address_byte2;
extern uint8_t CODE_SEG_VAR sounds_left;

extern struct patch_temporary_area_bender_range_msg_t bender_range_msg;

//----------------------

// https://github.com/open-watcom/open-watcom-v2/issues/698
// Macros generated the correct code, inline function adding a additional, not needed bl move

#define OUTPUT_READY(VALUE)(((VALUE) & MPU_401_OUTPUT_READY ) == 0)
#define INPUT_AVAIL(VALUE)(((VALUE) & MPU_401_INPUT_AVAIL ) == 0)

//------------------------

#define EXTERN_ISUBS

#ifdef EXTERN_ISUBS
#define ISUB_CDECL __cdecl
#define STATIC_INLINE
#else
#define ISUB_CDECL
#define STATIC_INLINE static inline
#endif

STATIC_INLINE uint16_t ISUB_CDECL near c_write_midi_cmd(uint8_t mpu_command_)
{
  const uint16_t COUNT = 65535;
  int i1 = 0;
  int i2 = 0;

  uint16_t result = -1;
  for(i1 = 0; i1 < COUNT; ++i1)
  {
    if( OUTPUT_READY( inb(MPU_401_PORT_STATUS_CMD) ) )
    {
      cli();

      outb(MPU_401_PORT_STATUS_CMD, LO(mpu_command_));
      
      for(i2 = 0; i2 < COUNT; ++i2)
      {
        if( INPUT_AVAIL( inb(MPU_401_PORT_STATUS_CMD) ) )
        {
          if(inb(MPU_401_PORT_DATA) == MPU_401_STATUS_ACK) 
          { 
            result = 0;
          }
          break;
        }
      }

      sti();

      break;
    }
  }

  return result;
}

STATIC_INLINE uint16_t ISUB_CDECL near c_write_midi_data(uint8_t mpu_command_)
{
  for(;;)
  {
    const uint8_t val = inb(MPU_401_PORT_STATUS_CMD);
    
    // is command send allowed?
    if( OUTPUT_READY(val) )
    {
      break;
    }    
    
    // still data waiting?
    if( INPUT_AVAIL( val ) )
    {
      byte_14A_buffer[word_172_buffer_index1++] = inb(MPU_401_PORT_DATA);
      if( word_172_buffer_index1 == sizeof(byte_14A_buffer))
      {
        word_172_buffer_index1 = 0;
      }
    }    
  }
  
  outb( MPU_401_PORT_DATA, LO(mpu_command_ ));
  return 0;
}

// https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message
// https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2
// https://www.zem-college.de/midi/mc_cvm4.htm

static inline void send_midi_msg2(uint8_t status_, uint8_t data1_)
{
  c_write_midi_data(status_);
  c_write_midi_data(data1_);
}

static inline void send_midi_msg3(uint8_t status_, uint8_t data1_, uint8_t data2_)
{
  c_write_midi_data(status_);
  c_write_midi_data(data1_);
  c_write_midi_data(data2_);
}

#define BITS4(VALUE)((VALUE) & 0x0Fu)

static inline void send_pitch_bend_change_midi_msg(uint8_t channel_, uint16_t pitch_bend_value_)
{
  // https://github.com/rkistner/arcore/issues/19#issuecomment-167781675
  // The pitch bend value is a 14-bit number (0-16383). 0x2000 (8192) is the default / middle value.
  
  //assert(channel_ <= 15(=2^4-1));
  //assert(pitch_bend_value_ <= 16384(=2^14));
  uint8_t low_byte = pitch_bend_value_ & 0x7Fu;
  uint8_t high_byte = pitch_bend_value_ >> 7u;  
  send_midi_msg3(0xE0u + BITS4(channel_), low_byte, high_byte);
}

static inline void send_note_off_event_midi_msg(uint8_t channel_, uint8_t key_note_number_, uint8_t velocity_)
{
  /*
  0x80 = 0b1000 0000

  status 1000 channel nnnn	
  data byte 1 0kkkkkkk
  data byte 2 0vvvvvvv	
                      
  Note Off event.
  This message is sent when a note is released (ended).
  (kkkkkkk) is the key (note) number.
  (vvvvvvv) is the velocity.
  */
  //assert(channel_ <= 15(=2^4));
  send_midi_msg3(0x80u + BITS4(channel_), BITS7(key_note_number_), BITS7(velocity_));
}

static inline void send_note_on_event_midi_msg(uint8_t channel_, uint8_t key_note_number_, uint8_t velocity_)
{
  /*
  0x90 = 0b1001 0000

  1001  nnnn	
  0kkkkkkk
  0vvvvvvv	
  Note On event.
  This message is sent when a note is depressed (start). 
  (kkkkkkk) is the key (note) number.
  (vvvvvvv) is the velocity.
  */
  //assert(channel_ <= 15(=2^4-1));
  send_midi_msg3(0x90u + BITS4(channel_), BITS7(key_note_number_), BITS7(velocity_));
}

static inline void send_program_change_midi_msg(uint8_t channel_, uint8_t new_program_number_)
{
  /*
  0xC0 = 0b1100 0000
  1100nnnn	0ppppppp

  Program Change. 
  This message sent when the patch number changes.
  (ppppppp) is the new program number.
  */
  send_midi_msg2(0xC0u + BITS4(channel_), BITS7(new_program_number_));
}

static inline void send_control_or_mode_change_midi_msg(uint8_t channel_, uint8_t controller_nr_, uint8_t controller_value_)
{
  //assert(channel_ <= 15/*2^4-1*/);
  //assert(controller_nr_ <= 119); // Control change
  //assert(controller_nr_ > 119); // Channel mode message
  send_midi_msg3(0xB0u + BITS4(channel_), BITS7(controller_nr_), BITS7(controller_value_)); 
}

// https://www.vogons.org/viewtopic.php?f=40&t=82297

static inline void send_all_notes_off_mode_change_midi_msg(uint8_t channel_)
{
  send_control_or_mode_change_midi_msg(channel_, 0x7B /*123*/, 0);
}

static inline void send_reset_all_controllers_mode_change_midi_msg(uint8_t channel_)
{
  send_control_or_mode_change_midi_msg(channel_, 0x79 /*121*/, 0);
}

static inline void send_volume_control_change_midi_msg(uint8_t channel_, uint8_t velocity_)
{
  send_control_or_mode_change_midi_msg(channel_, 0x07, velocity_);
}

static inline void send_pan_control_change_midi_msg(uint8_t channel_, uint8_t velocity_)
{
  send_control_or_mode_change_midi_msg(channel_, 0x0A, velocity_);
}

static inline void send_modulation_control_change_midi_msg(uint8_t channel_, uint8_t velocity_)
{
  send_control_or_mode_change_midi_msg(channel_, 0x01, velocity_);
}

#if VERSION == 10

// https://www.vogons.org/viewtopic.php?f=40&t=82059
static inline void near set_pitch_bend_range_coarse_adjustment_midi_msg(uint8_t channel_, uint8_t semitones_)
{
  //http://midi.teragonaudio.com/tech/midispec/rpn.htm
  // Pitch Bend Range (ie, Sensitivity)
  send_control_or_mode_change_midi_msg(channel_, 100, 0); // RPN fine (100), Pitch Bend Range
  send_control_or_mode_change_midi_msg(channel_, 101, 0); // RPN coarse (101), Pitch Bend Range

  // The coarse adjustment (usually set via Data Entry 6) sets the range in semitones.
  send_control_or_mode_change_midi_msg(channel_, 6, semitones_); // semitones cropped to 0-24
}

// only one caller
STATIC_INLINE void ISUB_CDECL near c_isub3(uint8_t semitones_, uint8_t midi_channel_, uint8_t dl_, uint8_t dh_)
{
  //assert(dl_ == 0);
  //assert(dhs_ == 0);
  set_pitch_bend_range_coarse_adjustment_midi_msg(midi_channel_, semitones_);
}

#endif

#if VERSION == 11

// PIT counter based delay
STATIC_INLINE void ISUB_CDECL near c_pit_based_delay(uint16_t ticks_to_wait_)
{
  const uint16_t MAX_COUNT = 65535;

  const uint16_t target_counter = MAX_COUNT - ticks_to_wait_;
  uint8_t lo_counter = 0;
  uint8_t hi_counter = 0;
  uint16_t current_counter = 0;
  
  outb(PIT_MODE_CMD, 0xB6);

  outb(PIT_CHAN2_DATA, LO(MAX_COUNT));
  outb(PIT_CHAN2_DATA, HI(MAX_COUNT));

  outb(PPI_PORT_B, inb(PPI_PORT_B) | 1);

  do
  {
    outb(PIT_MODE_CMD, 0x80);
    lo_counter = inb(PIT_CHAN2_DATA);
    hi_counter = inb(PIT_CHAN2_DATA);
    current_counter = (hi_counter << 8u) + lo_counter;
  }
  while( current_counter >= target_counter);
  
  outb(PPI_PORT_B, inb(PPI_PORT_B) & 0xFEu);
}

#endif

#if VERSION == 10
// some sort of pseudo delay - CPU/port reading speed dependent
static inline void port_read_based_delay(uint16_t count_)
{
  uint16_t i = 0;
  for(i = 0; i < count_; ++i)
  {
    /*value = */inb(PPI_PORT_B); // port reading takes some time
  }  
}
#endif

STATIC_INLINE void ISUB_CDECL near c_send_midi_sysex_msg(const uint8_t far* buffer_, uint16_t buffer_size_)
{
  uint8_t value = 0;
  uint16_t value_sum = 0;
  uint8_t checksum = 0;
  
  uint16_t b = 0;

  // [F0 41 10 16 12]
  c_write_midi_data(SYSEX_START);
  c_write_midi_data(SYSEX_ROLAND_ID);
  c_write_midi_data(SYSEX_DEVICE_ID);
  c_write_midi_data(SYSEX_MODEL_ID_MT32);
  c_write_midi_data(SYSEX_SEND_CMD);

  for(b = 0; b < buffer_size_; ++b)
  {
    value = buffer_[b];
    value_sum += value;
    c_write_midi_data(value);

#if VERSION == 10
    port_read_based_delay(100);
#elif VERSION == 11
    c_pit_based_delay(400); // PIT based delay
#else
  #error "unknown version"
#endif
  }
  
#if 0
  checksum = BITS7(-LO(value_sum));
#else 
  // signed warning free
  // https://stackoverflow.com/questions/6719316/can-i-turn-negative-number-to-positive-with-bitwise-operations-in-actionscript-3/6719341
  checksum = BITS7(~LO(value_sum) + 1u);
#endif  
            
  c_write_midi_data(checksum);

  c_write_midi_data(SYSEX_END);
#if VERSION == 11
  c_pit_based_delay(65000);
#endif
}

uint16_t __cdecl far c_tsub20()
{
  uint16_t value = 0;
  
  if( word_174_buffer_index2 == word_172_buffer_index1 )
  {
    return 65535; // -1
  }
  
  value = byte_14A_buffer[word_174_buffer_index2++];
  if( word_174_buffer_index2 == sizeof(byte_14A_buffer))
  {
    word_174_buffer_index2 = 0;
  }

  return value;
}

void __cdecl far c_tsub2()
{
  int16_t channel = 0; // needs to be signed // use int8_t
  for(channel = 15; channel >= 0; --channel) // [15-0]
  {
    send_all_notes_off_mode_change_midi_msg(channel);
    send_reset_all_controllers_mode_change_midi_msg(channel);
  }
}

#ifdef __clang__

static inline void dx_dec_based_delay(){}

#else

// NOTICE: Timing problem: this "delay" is CPU speed dependent
// TODO: replace that with PIT based delay - if the PIT is fast engough

// (underflows on first dec - so its [0,65535,...,0] = 65537 iterations)
static inline void dx_dec_based_delay();
#pragma aux dx_dec_based_delay = \
"  mov dx, 0" \  
"dec_loop:" \
"  dec dx "\
"  jnz dec_loop" \
modify[dx]

#endif

uint16_t __cdecl far c_tsub0()
{
  c_write_midi_cmd(MPU_401_CMD_RESET);

  // how long is this wait on old-days machines, dosbox?
  dx_dec_based_delay(); // like in original
  
  c_write_midi_cmd(MPU_401_CMD_UART_MODE);
  
  // all notes of, reset all controllers
  c_tsub2();
  
  c_send_midi_sysex_msg(&display_start_adress[0], sizeof(display_start_adress)+sizeof(display_text));

  return 0xFFF6; // = -10
}

void __cdecl far c_tsub1()
{
  c_tsub2();
}

void __cdecl far c_tsub10(uint8_t channel_)
{
  send_all_notes_off_mode_change_midi_msg( channel_);
}

void __cdecl far c_tsub8(uint16_t unknown1_)
{
  int16_t channel = 0; // needs to be signed // use int8_t
  for(channel = 15; channel >= 0; --channel) // [15-0]
  {
    send_reset_all_controllers_mode_change_midi_msg(channel);
  }
}

void __cdecl far c_tsub12(uint16_t channel_, uint16_t unknown2_, uint16_t unknown3_)
{
  send_pitch_bend_change_midi_msg(channel_, unknown3_ * 60);
}

void __cdecl far c_tsub9(uint16_t channel_, uint16_t unknown2_, uint16_t unknown3_)
{
  send_pitch_bend_change_midi_msg(LO(channel_), unknown2_ + 8192);
}

void __cdecl far c_tsub4(uint16_t channel_, const struct struct2_t far* struct_)
{
  send_note_off_event_midi_msg(channel_, struct_->key_note_number2, 0);
}

void __cdecl far c_tsub5(uint16_t unknown1_, uint8_t far* struct_)
{
  // nothing
}

// unknown1_ comes from the same var in stunts as the first parameter for tsub11
void __cdecl far c_tsub6(uint16_t midi_channel_, uint16_t unknown2_, uint16_t controller_value_)
{
  send_volume_control_change_midi_msg(midi_channel_, controller_value_);
}

void __cdecl far c_tsub7(uint16_t channel_, uint16_t unknown2_, uint16_t controller_nr_, uint16_t controller_value_)
{
  send_control_or_mode_change_midi_msg(channel_, controller_nr_, controller_value_);
}

void __cdecl far c_tsub21(uint16_t size_, const uint8_t far* buffer_)
{
  c_send_midi_sysex_msg(buffer_, size_);
}

static inline void mem_copy(uint8_t far* dest_, const uint8_t far* src_, uint16_t size_)
{
  uint16_t i = 0;
  for(i = 0; i < size_; ++i)
  { 
    dest_[i] = src_[i];
  }
}

static inline void send_msg_with_address(uint8_t a0, uint8_t a1, uint8_t a2, const uint8_t* far content_, uint16_t size_)
{
  msg_buffer.address.byte_0 = a0;
  msg_buffer.address.byte_1 = a1;
  msg_buffer.address.byte_2 = a2;
  mem_copy(msg_buffer.content, content_, size_);
  c_send_midi_sysex_msg((uint8_t*)&msg_buffer, sizeof(msg_buffer.address)+size_);
}

// prepare sounds like motor, screeching tires, crash,... etc.
void __cdecl far c_tsub22(const uint8_t far* mt32_plb_)
{
  int i = 0;
  const uint8_t far* data = &mt32_plb_[1];
  uint8_t timbre_group = 0;
  const struct mt32_patch_memory_t far* pm = 0;
  const struct mt32_timbre_memory_t far* tm = 0;
  
  const uint8_t sound_count = mt32_plb_[0];
  if( sound_count == 0 )
  {
    return;
  }
  
  patch_memory_address_byte1 = 0;
  patch_memory_address_byte2 = 0;
  timbre_memory_address_byte1 = 0;
  timbre_memory_address_byte2 = 0;
  
  for(i = 0; i < sound_count; ++i)
  {
    pm = (const struct mt32_patch_memory_t far*)data;
    data += sizeof(*pm);

    timbre_group = pm->timbre_group;
    
    send_msg_with_address(
      MT32_PATCH_MEMORY_ADRESS_BYTE0, 
      patch_memory_address_byte1, 
      patch_memory_address_byte2, 
      (uint8_t*)pm, sizeof(*pm)
    );
    
    patch_memory_address_byte2 += sizeof(struct mt32_patch_memory_t);
    // its just a byte2 overflow check - MT32 only uses 7 bits (0-128, 0x00-0x80) of the address bytes
    if( ( patch_memory_address_byte2 & 0x80u ) != 0 )
    {
      // only if there are > 16 sounds (stunts is currently fixed to 5)
      // maybe other games, using also that lib needs that check
      patch_memory_address_byte2 = 0;
      patch_memory_address_byte1 += 1;
    }
    
    // is there timbre group data?
    if( timbre_group == MT32_PATCH_MEMORY_TIMBRE_GROUP_MEMORY )
    {
      tm = (const struct mt32_timbre_memory_t far*)data;
      data += sizeof(*tm);

      send_msg_with_address(
        MT32_TIMBRE_MEMORY_ADDRESS_BYTE0, 
        timbre_memory_address_byte1, 
        timbre_memory_address_byte2, 
        (uint8_t*)tm, sizeof(*tm)
      );

      timbre_memory_address_byte1 += 2;
    }
    
#if VERSION == 10
    port_read_based_delay(60000);
#endif
  }
}

void __cdecl far c_tsub19(uint16_t size_, const uint8_t far* buffer_)
{
  int i = 0;
  for(i = 0; i < size_; ++i)
  {
    c_write_midi_data(buffer_[i]);
  }
}

void __cdecl far c_tsub14()
{
  // nothing
}

void __cdecl far c_tsub15()
{
  // nothing
}

void __cdecl far c_tsub16()
{
  // nothing
}

void __cdecl far c_tsub17()
{
  // nothing
}

uint16_t __cdecl far c_tsub18()
{
  return 0xFF;
}

void __cdecl far c_tsub3(uint16_t midi_channel_, struct struct2_t far *struct1_, uint16_t key_note_number_, uint16_t velocity_, struct struct1_t far* struct2_)
{
  struct1_->key_note_number1 = LO(key_note_number_);
  struct1_->key_note_number2 = LO(key_note_number_);
  struct1_->velocity = ( struct2_->byte_15 == 0) ? 127 : LO(velocity_);

  send_note_on_event_midi_msg(midi_channel_, key_note_number_, struct1_->velocity);
}

static inline uint8_t get_part(uint16_t channel_)
{
    uint8_t low_channel = 0;
    uint8_t part = 0;

    // https://www.vogons.org/viewtopic.php?f=40&t=82277
    // from sergm: "is nothing more than an adjustment for the standard MIDI channel mapping in MT-32"
    // MIDI channel 2-9 -> part 1-8
    
    low_channel = BITS4(LO(channel_));
    
    // channel != 10 seems to be a deprecated condition (that is maybe always true)
    part = ( low_channel != 10 ) ? low_channel - 1 : low_channel;
    
    //assert((part >= 1) && (part <= 8));
    
    return part;
}

static inline void send_bender_range_sysex_msg(uint16_t channel_, uint8_t bender_range_)
{
  bender_range_msg.bender_range = bender_range_; // cropped to 0-24 by MT32
#define BENDER_RANGE_OFFSET 0x04u    
  bender_range_msg.address.byte_2 = (get_part(channel_) << 4u) + BENDER_RANGE_OFFSET;
  c_send_midi_sysex_msg((uint8_t*)&bender_range_msg, sizeof(bender_range_msg));  
}

void __cdecl far c_tsub11(uint16_t channel_, uint16_t unknown1_, uint16_t unknown2_, struct struct1_t far* buffer_)
{
  send_program_change_midi_msg(channel_, buffer_->program);

// https://www.vogons.org/viewtopic.php?p=406966#p406966
//...
// The problem is that the game tries to set the pitch bend range using an RPN midi message, 
// which I don't think was defined by the midi-standard at the time of the MT-32 (old).
// It is supported by the CM-32L and later devices though, and possibly on the MT-32 (new) as well.
// On the MT-32 (old) the pitch bend range will stay on the default 12 semitones,
// instead of the intended 1 semitone, resulting in some weird tones when pitch bend is used.
//...

#if VERSION == 10
  set_pitch_bend_range_coarse_adjustment_midi_msg(channel_, buffer_->bender_range);
#elif VERSION == 11
  send_bender_range_sysex_msg(channel_, buffer_->bender_range);
#else
  #error "unknown version"
#endif

  if( buffer_->volume == 0)
  {
    send_pan_control_change_midi_msg(channel_, buffer_->pan);
  }
  else
  {
    send_volume_control_change_midi_msg(channel_, buffer_->volume);
  }
}

static inline void send_midi_msg_helper(uint8_t some_value_, uint8_t channel_, uint8_t midi_data2_)
{
  if( some_value_ == 4 )
  {
    send_modulation_control_change_midi_msg(channel_, midi_data2_);
  }
  else if( some_value_ == 2 )
  {
    send_pitch_bend_change_midi_msg(channel_, midi_data2_); 
  }
}

void __cdecl far c_tsub13(uint16_t midi_channel_, struct struct2_t far *buffer1_, struct struct1_t far *buffer2_)
{
  if( ( buffer2_->byte_35 == 1 ) && ( ( buffer1_->byte_22 + buffer1_->key_note_number1 ) != buffer1_->key_note_number2 ) )
  {
    send_note_off_event_midi_msg( midi_channel_, buffer1_->key_note_number2, 0 );

    buffer1_->key_note_number2 = buffer1_->byte_22 + buffer1_->key_note_number1;
    
    send_note_on_event_midi_msg(midi_channel_, buffer1_->key_note_number2, buffer1_->velocity );
  }

  send_midi_msg_helper(buffer2_->byte_28, LO(midi_channel_), LO(buffer1_->word_1C));
  send_midi_msg_helper(buffer2_->byte_19, LO(midi_channel_), LO(buffer1_->word_14));
}

