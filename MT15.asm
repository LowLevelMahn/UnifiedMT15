; ---------------------------------------------------------------------------

Sysex_address_t struc ; (sizeof=0x3)
  byte_0 db ?
  byte_1 db ?
  byte_2 db ?
Sysex_address_t ends

PatchTemporaryArea_BenderRange_msg_t struc ; (sizeof=0x4)
  address Sysex_address_t <?,?,?>
    ; byte_0 - always 0x03
    ; byte_1 - always 0x00
    ; byte_2 - sizeof(PatchTemporaryArea)*PartIndex + 0x04
  Bender_Range  db ? ; allowed range: 0-24 (0x00-0x18)
PatchTemporaryArea_BenderRange_msg_t ends

; ---------------------------------------------------------------------------

struct1_t struc ; (sizeof=0x36)
  unknown1  db 18 dup(?)
  byte_12   db ?
  unknown2  db 2 dup(?)
  byte_15   db ?
  unknown3  db 3 dup(?)
  byte_19   db ?
  unknown4  db 14 dup(?)
  byte_28   db ?
  unknown5  db 12 dup(?)
  byte_35   db ?
  unknown6  db 14 dup(?)
  byte_44   db ?
  byte_45   db ?
  byte_46   db ?
struct1_t ends

; ---------------------------------------------------------------------------

struct2_t struc ; (sizeof=0x23)
  unknown1  db 3 dup(?)
  byte_3    db ?
  byte_4    db ?
  unknown2  db ?
  byte_6    db ?
  unknown3  db 13 dup(?)
  word_14   dw ?
  unknown4  db 6 dup(?)
  word_1C   dw ?
  unknown5  db 4 dup(?)
  byte_22   db ?
struct2_t ends

; ---------------------------------------------------------------------------

struct3_t struc ; (sizeof=0x47)
  unknown1  db 18 dup(?)
  byte_12   db ?
  unknown2  db 49 dup(?)
  byte_44   db ?
  byte_45   db ?
  byte_46   db ?
struct3_t ends

; ---------------------------------------------------------------------------

; ===========================================================================

;isubs call count
;              write_midi_cmd isub1 write_midi_data isub3 send_midi_sysex_msg pit_based_delay
;MT15.DRV 1.0    2     0     73    1     4     -
;MT15.DRV 1.1    2     0     73    0     5     2

IFNDEF VERSION
  .ERR <you need to choose driver version option!!!>
ENDIF

%OUT ====================================
%OUT Unified_MT15 driver version
IF VERSION EQ 10
  %OUT 4D Sports Driving 1.0
ELSEIF VERSION EQ 11
  %OUT 4D Sports Driving 1.1
ELSE
  .ERR <"!!!unknown driver version!!!">
ENDIF
%OUT "===================================="

;-----------------------------
IFNDEF EQUAL_BINARY
  .ERR <you need to set binary compatiblity option!!!>
ENDIF

;UASM generates functional identical but different opcodes for some mnemonics
;
; can happen with every other assembler/compiler - except the very original one
; there are several functional identical opcodes - the assembler is free to decide which one to use
;
; example: "and ax,0xf"
; ORG : 25 0F 00
; UASM: 83 E0 0F

;-----------------------------

IFNDEF REMOVE_DEAD_CODE
  .ERR <you need to set dead code removal option!!!>
ENDIF

;-----------------------------

IFNDEF REPLACE_WITH_C_CODE
  .ERR <you need to set replace with c-code option!!!>
ENDIF
 
;-----------------------------

IF EQUAL_BINARY EQ 1
   IF REMOVE_DEAD_CODE EQ 1
     .ERR <"EQUAL_BINARY and REMOVE_DEAD_CODE are not compatible">
   ENDIF
   IF REPLACE_WITH_C_CODE EQ 1
     .ERR <"EQUAL_BINARY and REPLACE_WITH_C_CODE are not compatible">
   ENDIF
ENDIF

; -------------------------

IF EQUAL_BINARY EQ 1
  %OUT Equal binary result
ENDIF

IF REMOVE_DEAD_CODE EQ 1
  %OUT Remove dead code
ENDIF

PPI_PORT_B = 61h

PIT_CHAN2_DATA = 42h ; Channel 2 data port (read/write)
PIT_MODE_CMD = 43h ; write only, a read is ignored

; MIDI

; https://github.com/torvalds/linux/blob/master/include/sound/mpu401.h
; http://midi.teragonaudio.com/tech/mpu.htm
; http://www.piclist.com/techref/io/serial/midi/mpu.html
; http://www.gweep.net/~prefect/eng/reference/protocol/midispec.html
; http://cd.textfiles.com/audio11000/MSDOS/MIDI/MPPDEMO/MPUDEMO.C
; https://android.googlesource.com/kernel/msm/+/android-6.0.1_r0.121/sound/oss/mpu401.c
; http://manuals.opensound.com/sources/oss_uart401.c.html
; https://www.vogons.org/viewtopic.php?t=61245
MPU_401_BASE = 330h
MPU_401_DATA = (MPU_401_BASE+0)
MPU_401_STATUS_CMD = (MPU_401_BASE+1) ; write => COMMAND-Port, read => STATUS-Port

; status bit mask
MPU_401_OUTPUT_READY = 40h ; bit 6
MPU_401_INPUT_AVAIL = 80h ; bit 7

; how to display message on MPU 401
; http://www.youngmonkey.ca/nose/audio_tech/synth/Roland-MT32.html
; http://www.vcfed.org/forum/showthread.php?27856-output-to-MT-32-display

SYSEX_START = 0F0h
SYSEX_END = 0F7h
CHECKSUM_MASK = 7Fh

SYSEX_ROLAND_ID = 41h
SYSEX_DEVICE_ID = 10h
SYSEX_MODEL_ID_MT32 = 16h
SYSEX_SEND_CMD = 12h

; Segment type: Pure code
seg000    segment byte public 'CODE'
    assume cs:seg000
    assume es:nothing, ss:nothing, ds:nothing

jump_table: ; 3 bytes per jump

; interface function + offset in the drv binary
;tsub00: 0x00
;tsub01: 0x03
;tsub02: 0x06
;tsub03: 0x09
;tsub04: 0x0C
;tsub05: 0x0F
;tsub06: 0x12
;tsub07: 0x15
;tsub08: 0x18
;tsub09: 0x1B
;tsub10: 0x1E
;tsub11: 0x21
;tsub12: 0x24
;tsub13: 0x27
;tsub14: 0x2A
;tsub15: 0x2D
;tsub16: 0x30
;tsub17: 0x33
;tsub18: 0x36
;tsub19: 0x39
;tsub20: 0x3C
;tsub21: 0x3F
;tsub22: 0x42

; all isubs ported

    jmp near ptr tsub0 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub1 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub2 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub3 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub4 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub5 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub6 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub7 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub8 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub9 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub10 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub11 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub12 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub13 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub14 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub15 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub16 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub17 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub18 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub19 ; ported
; ---------------------------------------------------------------------------
    jmp near ptr tsub20 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub21 ; ported 
; ---------------------------------------------------------------------------
    jmp near ptr tsub22 ; ported
; ---------------------------------------------------------------------------

; LOCAL-DATA

public C msg_buffer
public C byte_14A_buffer
public C word_172_buffer_index1
public C word_174_buffer_index2
public C display_start_adress
public C display_text
public C patch_memory_address_byte1
public C patch_memory_address_byte2
public C timbre_memory_address_byte1
public C timbre_memory_address_byte2
public C sounds_left

patch_memory_address_byte1   db 0
patch_memory_address_byte2   db 0

timbre_memory_address_byte1   db 0
timbre_memory_address_byte2   db 0

sounds_left   db 0

MSG_BUFFER_CONTENT_SIZE = (256 - size Sysex_address_t)

Msg_buffer_t struc
  address Sysex_address_t <?,?,?>
  content db MSG_BUFFER_CONTENT_SIZE dup(?)
Msg_buffer_t ends

msg_buffer Msg_buffer_t <<0,0,0>,<MSG_BUFFER_CONTENT_SIZE dup(0)>> ; 256 bytes ; general sysex msg content buffer

byte_14A_buffer db 28h dup(0) ; 40 bytes
word_172_buffer_index1  dw 0
word_174_buffer_index2  dw 0

display_start_adress db 20h, 0, 0

; 20 byte string
IF VERSION EQ 10
  display_text  db '    (C) 1990 DSI    '
ELSEIF VERSION EQ 11
  display_text  db '  (C)1990,1991 DSI  '
ENDIF

IF ((EQUAL_BINARY EQ 1) AND (REMOVE_DEAD_CODE EQ 0))
; complete unknown 4 bytes - from display_text end?
  db 7Fh
  db 0
  db 0
  db 0
ENDIF

IF VERSION EQ 11

public C bender_range_msg
; MT32 sysex msg content
bender_range_msg  PatchTemporaryArea_BenderRange_msg_t <<3, 0, 4>, 0>

;   03 00 (0x10*(Part-1)) -> Base Adress of "Patch Temporary Area Part (Part)"
; +    00    04           -> Address Offset of "Bender range"
;                  xx     -> Value in range 0-24
; Address = PatchTemporaryArea.BaseAdresss(Part) + BenderRange.AddressOffset
; Part = 1-8
; Value = 0-24

; 03 00 04 18 <- get_msg_PatchTemporaryArea_BenderRange(1, 24, msg);
; 03 00 44 00 <- get_msg_PatchTemporaryArea_BenderRange(5, 0, msg);

;                                                 0  1  2  3
; only [2] and [3] getting changed
; Sysex message size 8,   data: F0 41 10 16 12   03                                 00   F7 <-- invalid msg, checksum error
; Sysex message size 11,  data: F0 41 10 16 12   03 00 04 18                        61   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 14 00                        69   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 24 00                        59   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 34 00                        49   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 44 00                        39   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 44 02                        37   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 54 00                        29   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 54 70                        39   F7 <-- invalid range, gets clampt to 0x18
; Sysex message size 11,  data: F0 41 10 16 12   03 00 64 00                        19   F7
; Sysex message size 11,  data: F0 41 10 16 12   03 00 74 02                        07   F7
ENDIF

MT32_Patch_memory_address_byte0 = 5
MT32_Timbre_memory_address_byte0 = 8

mt32_patch_memory_timbre_group_Memory = 2

mt32_patch_memory_t struc ; (sizeof=0x08)
  timbre_group db ? ; 0:group A, 1:group B, 2:Memory, 3:Rhythm
  timbre_number db ? ; 0-63
  key_shift db ? ; 0-48 [-24...+24]
  fine_tune db ? ; 0-100 [-50...+50]
  bender_range db ? ; 0-24
  assign_mode db ? ; 0:POLY1, 1:POLY2, 2:POLY3, 3:POLY4
  reverb_switch db ? ; 0-1 (OFF,ON)
  dummy db ?
mt32_patch_memory_t ends

mt32_timbre_memory_t struc
  data db 246 dup (?) 
mt32_timbre_memory_t ends

mt32_plb_sound_t struc
  patch_memory_data mt32_patch_memory_t <?>
  ;--
  ;[ only exists if mt32_patch_memory_t::timbre_group == mt32_patch_memory_timbre_group_Memory ]
    timbre_memory_data mt32_timbre_memory_t <?>
  ;] --
mt32_plb_sound_t ends

MT32_plb_t struc
  sound_count db ?
  content mt32_plb_sound_t 5 dup(<?>)
MT32_plb_t ends

; CODE

; =============== S U B R O U T I N E =======================================


IF VERSION EQ 11

IF REPLACE_WITH_C_CODE EQ 1

pit_based_delay proc near
  extrn _c_pit_based_delay:near
  
  push ax
  push cx
  push dx
  
  push ax
  call _c_pit_based_delay
  add sp,2
  
  pop dx
  pop cx
  pop ax
  retn  
  
pit_based_delay endp

ELSE

; void __usercall pit_based_delay(__int16 ax_@<ax>)
; void pit_delay(uint16_t ticks_to_wait_)
pit_based_delay   proc near
    push  ax
    push  cx
    
    neg ax
    IF EQUAL_BINARY
    db 05, 0ffh, 0ffh
    ELSE
    add ax, 0FFFFh
    ENDIF
    mov cx, ax
    mov al, 0B6h
    out PIT_MODE_CMD, al
    mov al, 0FFh
    out PIT_CHAN2_DATA, al
    out PIT_CHAN2_DATA, al
    in  al, PPI_PORT_B
    or  al, 1
    out PPI_PORT_B, al

pit_based_delay_0:
    mov al, 80h
    out PIT_MODE_CMD, al
    in  al, PIT_CHAN2_DATA
    xchg  al, ah
    in  al, PIT_CHAN2_DATA
    xchg  al, ah
    cmp ax, cx
    jnb short pit_based_delay_0
    in  al, PPI_PORT_B
    and al, 0FEh
    out PPI_PORT_B, al
    
    pop cx
    pop ax
    retn
pit_based_delay   endp

ENDIF

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

write_midi_cmd proc near
  extrn _c_write_midi_cmd:near
  
  push si
  push bx
  push cx
  push dx

  push ax ; can't push byte - only words
  call _c_write_midi_cmd
  add sp,2
  
  pop dx
  pop cx 
  pop bx 
  pop si  
  
  retn
  
write_midi_cmd endp

ELSE

; __int16 __usercall write_midi_cmd<ax>(__int8 mpu_command_value_@<al>)
write_midi_cmd   proc near
    push  cx
    push  dx
    push  ax
    mov dx, MPU_401_STATUS_CMD
    mov cx, 0FFFFh

write_midi_cmd_0:
    in  al, dx
    test  al, 40h
    jz  short write_midi_cmd_1
    dec cx
    cmp cx, 1
    jge short write_midi_cmd_0
    pop ax
    mov ax, 0FFFFh
    jmp short write_midi_cmd_5
; ---------------------------------------------------------------------------
    nop

write_midi_cmd_1:
    cli
    pop ax
    out dx, al
    mov cx, 0FFFFh

write_midi_cmd_2:
    in  al, dx
    rol al, 1
    jnb short write_midi_cmd_3
    dec cx
    cmp cx, 1
    jge short write_midi_cmd_2
    mov ax, 0FFFFh
    jmp short write_midi_cmd_5
; ---------------------------------------------------------------------------
    nop

write_midi_cmd_3:
    mov dx, MPU_401_DATA
    in  al, dx
    cmp al, 0FEh
    jz  short write_midi_cmd_4
    mov ax, 0FFFFh
    jmp short write_midi_cmd_5
; ---------------------------------------------------------------------------
    nop

write_midi_cmd_4:
    mov ax, 0

write_midi_cmd_5:
    sti
    pop dx
    pop cx
    retn
write_midi_cmd   endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REMOVE_DEAD_CODE EQ 0

isub1   proc near
    push  cx
    push  dx
    mov dx, MPU_401_STATUS_CMD
    mov cx, 65535

isub1_0:
    in  al, dx
    rol al, 1
    jnb short isub1_1
    dec cx
    cmp cx, 1
    jge short isub1_0
    mov ax, 0FFFFh
    jmp short isub1_2
; ---------------------------------------------------------------------------
    nop

isub1_1:
    mov dx, MPU_401_DATA
    mov ah, 0
    in  al, dx
    mov ax, 0

isub1_2:
    pop dx
    pop cx
    retn
isub1   endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

write_midi_data proc near
  extrn _c_write_midi_data:near
  
  push bx
  push cx
  push dx

  push ax ; can't push byte - only words
  call _c_write_midi_data
  add sp,2
  
  pop dx
  pop cx  
  pop bx
  
  retn
  
write_midi_data endp

else

; __int16 __usercall write_midi_data<ax>(__int8 mpu_command_@<al>)
write_midi_data   proc near
    push  cx
    push  dx
    push  ax

write_midi_data_0:
    mov dx, MPU_401_STATUS_CMD
    mov cx, 0FFFFh

write_midi_data_1:
    in  al, dx

    test  al, MPU_401_OUTPUT_READY
    jz  short write_midi_data_2

    rol al, 1
    jnb short write_midi_data_4

    jmp short write_midi_data_0

IF REMOVE_DEAD_CODE EQ 0

; ---------------------------------------------------------------------------
    dec cx
    cmp cx, 1
    jge short write_midi_data_1

    pop ax
    mov ax, 0FFFFh
    jmp short write_midi_data_3
; ---------------------------------------------------------------------------
    nop

ENDIF

write_midi_data_2:
    mov dx, MPU_401_DATA
    pop ax
    out dx, al
    mov ax, 0

IF REMOVE_DEAD_CODE EQ 0
write_midi_data_3:
ENDIF
    pop dx
    pop cx
    retn
; ---------------------------------------------------------------------------

write_midi_data_4:
    push  si
    mov si, cs:word_172_buffer_index1 ; initial = 0, or?
    mov dx, MPU_401_DATA
    in  al, dx
    mov cs:byte_14A_buffer[si], al
    inc si
    cmp si, lengthof byte_14A_buffer
    jnz short write_midi_data_5
    xor si, si

write_midi_data_5:
    mov cs:word_172_buffer_index1, si
    pop si
    jmp short write_midi_data_0
write_midi_data   endp

endif

; =============== S U B R O U T I N E =======================================

; only used by version 1.0
IF ( VERSION EQ 10 ) OR ( (VERSION EQ 11 ) AND ( ( REMOVE_DEAD_CODE EQ 0 ) AND (REPLACE_WITH_C_CODE EQ 0) ) )

IF REPLACE_WITH_C_CODE EQ 1

isub3 proc near
  extrn _c_isub3:near
  
  push ax ; al
  push cx ; cl
  xor bh,bh
  mov bl,dl 
  push bx ; dl
  xchg dh,dl
  push dx ; dh
  
  call _c_isub3
  add sp,8
  
  retn
isub3 endp


ELSE

; __int16 __usercall isub3<ax>(__int8 al_@<al>, __int8 cl_@<cl>, __int8 dl_@<dl>, __int8 dh_@<dh>)
isub3   proc near
    push  ax
    mov al, cl
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 64h  ; mpu_command_@
    call  write_midi_data
    mov al, dl    ; mpu_command_@
    call  write_midi_data
    mov al, cl
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 65h  ; mpu_command_@
    call  write_midi_data
    mov al, dh    ; mpu_command_@
    call  write_midi_data
    mov al, cl
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 6   ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data
    retn
isub3   endp

ENDIF

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

send_midi_sysex_msg proc near
  extrn _c_send_midi_sysex_msg:near
  
  push si
  
  push cx
  push es
  push bx
  call _c_send_midi_sysex_msg
  add sp,6
  
  pop si
  
  retn
send_midi_sysex_msg endp

ELSE

; void __usercall send_midi_sysex_msg(__int16 segment_@<es>, __int16 offset_@<bx>, __int16 size_@<cx>)
send_midi_sysex_msg   proc near
    push  si
    mov si, bx

    ; [F0 41 10 16 12]
    mov al, SYSEX_START ; mpu_command_@
    call  write_midi_data
    mov al, SYSEX_ROLAND_ID  ; mpu_command_@
    call  write_midi_data
    mov al, SYSEX_DEVICE_ID   ; mpu_command_@
    call  write_midi_data
    mov al, SYSEX_MODEL_ID_MT32   ; mpu_command_@
    call  write_midi_data
    mov al, SYSEX_SEND_CMD   ; mpu_command_@
    call  write_midi_data
    mov dx, 0

send_midi_sysex_msg_0:
    mov al, es:[si] ; mpu_command_@
    xor ah, ah
    add dx, ax
    call  write_midi_data

IF VERSION EQ 10
    push  cx
    mov cx, 100

send_midi_sysex_msg_1:
    in  al, PPI_PORT_B
    loop  send_midi_sysex_msg_1
    pop cx
ELSEIF VERSION EQ 11
    mov ax, 400   ; ax_@
    call  pit_based_delay
ENDIF

    inc si
    loop  send_midi_sysex_msg_0
    mov al, dl
    neg al
    and al, CHECKSUM_MASK
    call  write_midi_data

    mov al, SYSEX_END ; mpu_command_@
    call  write_midi_data
    pop si
IF VERSION EQ 11
    mov ax, 65000 ; ax_@
    call  pit_based_delay
ENDIF
    retn
send_midi_sysex_msg   endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub20 proc far
  extrn _c_tsub20:far
  
  push si
  
  call _c_tsub20
  
  pop si
  
  retf
tsub20 endp

ELSE

; int __cdecl __far tsub20()
tsub20    proc far
    push  si
    mov ax, 0FFFFh
    mov si, cs:word_174_buffer_index2
    cmp si, cs:word_172_buffer_index1
    jz  short tsub20_1
    mov ah, 0
    mov al, cs:byte_14A_buffer[si]
    inc si
    cmp si, lengthof byte_14A_buffer
    jnz short tsub20_0
    mov si, 0

tsub20_0:
    mov cs:word_174_buffer_index2, si

tsub20_1:
    pop si
    retf
tsub20    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame


IF REPLACE_WITH_C_CODE EQ 1

tsub21 proc far
  extrn _c_tsub21:far

; this sub-call is needed because calls change the stack - but the only real call is in stunts

size_   = word ptr  6
buffer_   = dword ptr  8  

  push  bp
  mov bp, sp
  les bx, [bp+buffer_] ; segment_@ + offset_@
  mov cx, [bp+size_]  ; size_@
  pop bp
  
  push es
  push bx
  push cx
  call _c_tsub21
  add sp,6
  
  retf
tsub21 endp

ELSE

; int __cdecl __far tsub21(__int16 size_, __int8 far *buffer_)
tsub21    proc far

size_   = word ptr  6
buffer_   = dword ptr  8

    push  bp
    mov bp, sp
    les bx, [bp+buffer_] ; segment_@ + offset_@
    mov cx, [bp+size_]  ; size_@
    call  send_midi_sysex_msg
    pop bp
    retf
tsub21    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub22 proc far
  extrn _c_tsub22:far

  mt32_plb   = dword ptr  6

  push  bp
  mov bp, sp

  pushf
  push  si
  push  di
  push  ds
  push  es
 
  lds si, [bp+mt32_plb]
  push ds
  push si
  
  call _c_tsub22
  add sp,4
  
  pop es
  pop ds
  pop di
  pop si
  popf

  pop bp

  retf 
tsub22 endp

ELSE

; tsub22 sends the 05(Patch Memory) and 08(Timbre Memory) sysex messages - based on MT32.PLB content

; void __cdecl tsub22(mt32_plb_t far* mt32_plb_)
tsub22 proc far

mt32_plb = dword ptr  6

    push  bp
    mov bp, sp
    pushf
    push si
    push di
    push ds
    push es
    
    xor al, al
    mov cs:patch_memory_address_byte1, al
    mov cs:patch_memory_address_byte2, al
    mov cs:timbre_memory_address_byte1, al
    mov cs:timbre_memory_address_byte2, al
    
    lds si, [bp+mt32_plb] ; ds=seg, si=ofs
    
    push cs
    pop es    ; segment_@
    
    mov al, [si]  ; ds:[si] ; => 5 => 5 sounds
    inc si
    mov cs:sounds_left, al ; sound-count ==> 5 sounds
    ; sounds_left = mt32_plb->sound_count;
    
    ;----
    or al, al
    jnz short tsub22_0
    ; if( sounds_left != 0 ) // could not happen with stunts MT32.PLB
    ; {
    ;   goto tsub22_0;
    ; }
    ;----
    
    jmp tsub22_3
; ---------------------------------------------------------------------------

tsub22_0:
; -----
    mov di, offset msg_buffer
    mov byte ptr es:[di], MT32_Patch_memory_address_byte0
    inc di
    mov al, cs:patch_memory_address_byte1
    mov es:[di], al
    inc di
    mov al, cs:patch_memory_address_byte2
    mov es:[di], al
    inc di
    
;msg_buffer -> filled with 0 at start
;
;  msg_buffer.address.byte_0 = MT32_Patch_memory_address_byte0;
;  msg_buffer.address.byte_1 = patch_memory_address_byte1;
;  msg_buffer.address.byte_2 = patch_memory_address_byte2;
  
; ----
    
    mov al, [si] ; -> 02 - mt32_plb_sound_t.patch_memory_data.timbre_group = 02 == mt32_patch_memory_timbre_group_Memory ---> 5 times hit
    push ax

; ----
    mov cx, sizeof mt32_patch_memory_t
    cld
    rep movsb ; Move byte at address DS:SI to address ES:DI

;   memcpy(msg_buffer[3], mt32_plb[1], sizeof(mt32_patch_memory_t));
; ----   
    
    mov bx, offset msg_buffer ; offset_@
    mov cx, sizeof Sysex_address_t + sizeof mt32_patch_memory_t ; size_@ = 11
    call send_midi_sysex_msg
    ; send_midi_sysex_msg(&msg_buffer, sizeof(Sysex_address_t) + sizeof(mt32_patch_memory_t));
; Sysex message size 18,  data: F0 41 10 16 12   05 00 00  02 00 18 32 18 00 00 00   17 F7 
; Sysex message size 18,  data: F0 41 10 16 12   05 00 08  02 01 18 32 0C 00 01 00   19 F7 
; Sysex message size 18,  data: F0 41 10 16 12   05 00 10  02 02 18 32 0C 00 01 00   10 F7 
; Sysex message size 18,  data: F0 41 10 16 12   05 00 18  02 03 18 32 0C 00 01 00   07 F7 
; Sysex message size 18,  data: F0 41 10 16 12   05 00 20  02 04 18 32 0C 00 01 00   7E F7 
    
    mov al, cs:patch_memory_address_byte2
    add al, sizeof mt32_patch_memory_t ; address.byte_2 to next address
    mov cs:patch_memory_address_byte2, al
    ; patch_memory_address_byte2 += sizeof(mt32_patch_memory_t);
    
    ;---
    and al, 80h ; 5 times hit
    jz  short tsub22_1
    ;if( (patch_memory_address_byte2 & 0x80) == 0) // does byte2 overflows (exceeds 7 bits) at next iteration...
    ;{
    ;  goto tsub22_1;
    ;}
    ;---
    
    ; only if there are > 9 sounds (stunts is currently fixed to 5) - maybe other games using that lib need that check
    ; ... then reset byte2 to 0 and increment byte1
    xor al, al
    mov cs:patch_memory_address_byte2, al
    inc cs:patch_memory_address_byte1
    ; patch_memory_address_byte2 = 0;
    ; patch_memory_address_byte1 += 1;

tsub22_1:
    ; ---
    pop ax ; first patch memory data byte, 5 times hit
    cmp al, mt32_patch_memory_timbre_group_Memory
    jnz short tsub22_2
    ; if( al != mt32_patch_memory_timbre_group_Memory )
    ; {
    ;   goto tsub22_2;
    ; }
    ; ---

    ; this block gets skipped if timbre_group is not 'Memory'

; -----
    mov di, offset msg_buffer
    mov byte ptr es:[di], MT32_Timbre_memory_address_byte0
    inc di
    mov al, cs:timbre_memory_address_byte1
    mov es:[di], al
    inc di
    mov al, cs:timbre_memory_address_byte2
    mov es:[di], al
    inc di
    
;uint8_t msg_buffer[256] -> filled with previous msg - gets overwritten
;
;  msg_buffer.address.byte_0 = MT32_Timbre_memory_address_byte0;
;  msg_buffer.address.byte_1 = timbre_memory_address_byte1;
;  msg_buffer.address.byte_2 = timbre_memory_address_byte2;

; -----
    
    mov cx, sizeof mt32_timbre_memory_t
    cld
    rep movsb
;   memcpy(msg_buffer[3], mt32_plb[9], sizeof(mt32_timbre_memory_t));
; -----    
    
    mov bx, offset msg_buffer ; offset_@
    mov cx, size Sysex_address_t + sizeof mt32_timbre_memory_t
    call send_midi_sysex_msg
; Sysex message size 256, data: F0 41 10 16 12   08 00 00  45 6E 67 69 6E 65 20 31 20 20 07 05 0F 00 17 15 0B 01 01 00 35 07 00 00 00 37 28 32 23 0A 32 46 46 14 0D 10 10 23 14 09 69 07 37 00 00 00 00 2A 2E 64 32 64 64 64 64 64 32 5B 0C 1B 0C 00 00 05 00 00 00 19 64 64 64 64 17 4C 0B 01 01 00 35 07 00 00 00 37 28 32 23 0A 32 46 46 14 0D 10 10 23 14 09 69 07 37 00 00 00 00 2A 2E 64 32 64 64 64 64 64 32 5B 0C 1B 0C 00 00 05 00 00 00 19 64 64 64 64 18 32 0B 01 01 35 25 07 00 00 00 37 2D 2D 23 0A 32 46 46 14 0C 00 10 39 14 09 69 07 37 00 00 00 00 2A 2C 64 32 64 64 64 64 64 32 5B 0C 1B 0C 00 00 05 00 00 00 1D 64 64 63 64 00 00 0B 01 01 2B 35 07 00 00 00 37 28 32 23 0A 32 46 46 14 0D 10 10 23 14 09 69 07 37 00 00 00 00 2A 2E 64 32 64 64 64 64 64 32 5B 0C 1B 0C 00 00 05 00 00 00 19 64 64 64 64   53 F7 
; Sysex message size 256, data: F0 41 10 16 12   08 02 00  53 71 75 65 65 6C 20 20 20 20 00 08 0F 00 24 19 0B 01 00 25 64 07 00 00 00 00 06 00 00 00 64 64 64 00 48 64 00 03 1E 09 69 07 64 00 00 00 00 00 00 00 00 64 64 64 64 32 64 5B 0C 1B 0C 00 00 05 00 00 00 00 64 63 00 63 24 56 0B 01 00 25 58 07 00 00 00 00 06 00 00 00 64 64 64 00 48 64 00 03 1E 09 69 07 64 00 00 00 00 00 00 00 00 64 64 64 64 32 64 5B 0C 1B 0C 00 00 05 00 00 00 00 64 63 00 63 13 0B 0B 01 01 35 25 07 00 00 00 00 00 00 00 00 4E 4E 4E 00 32 64 10 39 14 09 69 07 37 00 00 00 00 2A 2C 64 32 64 64 64 64 46 64 5B 0C 1B 0C 00 00 05 02 00 00 00 64 63 00 64 07 5E 0B 01 00 35 64 07 00 00 00 00 00 00 00 00 50 50 51 00 21 64 00 1C 1E 09 69 07 37 00 00 00 00 2A 2C 64 32 64 64 64 64 46 64 5B 0C 1B 0C 00 00 05 00 00 00 00 64 63 00 63   3C F7 
; Sysex message size 256, data: F0 41 10 16 12   08 04 00  44 61 6D 61 67 65 20 20 20 20 05 05 0F 00 15 00 0F 00 00 12 42 00 04 00 00 14 1E 00 00 00 14 28 00 00 05 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 0E 00 46 00 0A 00 61 00 00 09 00 0F 00 00 13 41 00 04 00 00 14 14 00 00 64 50 00 00 00 0A 1E 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 13 11 3B 37 00 00 63 2D 04 12 00 0F 00 00 18 41 04 08 00 00 4C 17 13 0A 34 00 00 00 11 05 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 00 41 1D 0E 00 5E 17 03 14 00 0F 00 00 53 41 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 32 33 50 0C 53 64 2D 00   44 F7 
; Sysex message size 256, data: F0 41 10 16 12   08 06 00  4D 65 74 61 6C 43 6C 61 6E 6B 08 09 03 00 05 00 0F 00 00 45 41 00 03 00 00 14 1E 00 00 31 14 28 00 00 05 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 3F 3D 00 0A 62 00 00 00 0D 00 0F 00 01 58 41 00 04 00 00 3D 00 00 00 31 2F 00 00 00 18 0D 05 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 39 0C 04 2A 64 00 00 00 24 00 0F 00 00 18 41 04 05 00 00 4C 17 13 0A 34 00 00 00 11 05 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 40 06 17 1D 64 00 00 00 36 00 0F 00 00 53 41 00 02 00 00 0A 0A 00 00 64 50 32 00 00 00 00 00 64 00 0B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 4C 00 00 00 00 00 00 00 39 00 26 2C 64 00 00 00   04 F7 
; Sysex message size 256, data: F0 41 10 16 12   08 08 00  45 6E 67 69 6E 65 20 31 20 20 02 02 0F 00 24 32 0B 01 00 53 64 0E 00 00 00 37 2D 2D 23 0A 32 46 46 14 13 64 10 22 00 09 69 07 37 00 00 00 00 2A 2C 64 32 64 64 64 64 0D 32 40 0C 00 0C 00 00 05 00 00 00 13 64 64 64 64 18 4C 0B 01 01 00 35 07 00 00 00 37 28 32 23 0A 32 46 46 14 0D 10 10 23 14 09 69 07 37 00 00 00 00 2A 2E 64 32 64 64 64 64 64 32 5B 0C 1B 0C 00 00 05 00 00 00 19 64 64 64 64 16 32 0B 01 01 58 25 07 00 00 00 37 2D 2D 23 0A 32 46 46 14 0C 00 10 39 14 09 69 07 37 00 00 00 00 2A 2C 64 32 64 64 64 64 0E 32 5B 0C 1B 0C 00 00 05 00 00 00 1D 64 64 63 64 0C 36 0B 01 00 00 32 07 02 00 00 37 28 32 23 32 32 37 40 14 0D 10 10 38 12 0B 69 07 37 00 00 00 00 2A 2E 64 32 64 64 64 64 23 32 5B 0C 1B 0C 00 00 05 00 00 00 19 64 64 64 64   29 F7 
    ; send_midi_sysex_msg(&msg_buffer, sizeof(Sysex_address_t) + sizeof(mt32_timbre_memory_t));

; -----

    mov al, cs:timbre_memory_address_byte1
    add al, 2 ; full_address += sizeof(mt32_timbre_memory_t), or only address.byte_1 += 2
    mov cs:timbre_memory_address_byte1, al
    ; timbre_memory_address_byte1 += 2;

tsub22_2:

IF VERSION EQ 10
    ; port_read_based_delay(60000);

    push cx

    mov cx, 60000
    ; just read the port 60000 times?
wait_loop:
    in al, PPI_PORT_B
    loop wait_loop

    pop cx
ENDIF

; ----
    mov al, cs:sounds_left ; sound_count
    dec al
    mov cs:sounds_left, al
    or al, al
    jz short tsub22_3 ; exit if all sounds processed
    jmp tsub22_0
    ; if((--sounds_left) > 0){ goto tsub22_0; }
    ; return;
; ----

; ---------------------------------------------------------------------------

tsub22_3:
    pop es
    pop ds
    pop di
    pop si
    popf
    pop bp
    retf
tsub22    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1 ; TODO - not ported

tsub19 proc far
  extrn _c_tsub19:far
  
  push bx
  push ax
  
  pop bx ; size
  pop ax ; offset
  
  push ds ; set correct ds as buffer.segment
  push ax
  push bx
  
  call _c_tsub19
  
  add sp, 6
  
  pop ax
  pop bx

  retf 
  
tsub19 endp

ELSE

tsub19    proc far

arg_0   = word ptr  6
arg_2   = word ptr  8

    push  bp
    mov bp, sp
    mov cx, [bp+arg_0] ; command buffer size
    mov bx, [bp+arg_2] ; command buffer ptr

tsub19_0:
    mov al, [bx]  ; mpu_command_@ ; where does DS come from?
    call  write_midi_data
    inc bx ; +1 byte
    loop  tsub19_0 ; as long as cx is not 0
    pop bp
    retf
tsub19    endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1 ; TODO: test

tsub0 proc far
  extrn _c_tsub0:far
  
  push si
  
  call _c_tsub0
  
  pop si
  
  retf
tsub0 endp

ELSE

tsub0   proc far
    mov al, 0FFh  ; mpu_command_value_@
    call  write_midi_cmd
    mov dx, 0

tsub0_0:
    dec dx
    jnz short tsub0_0
    mov al, 3Fh  ; mpu_command_value_@
    call  write_midi_cmd
    push  cs    ; push cs to get a far call on stack
    call  near ptr tsub2  ; push cs that this gets "magical" a far call on stack

    mov cx, lengthof display_start_adress + lengthof display_text
    mov bx, offset display_start_adress ; offset_@
    push  cs
    pop es    ; segment_@
    call  send_midi_sysex_msg

    mov ax, 0FFF6h
    retf
tsub0   endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1 ; TODO: test

tsub1 proc far
  extrn _c_tsub1:far
  
  call _c_tsub1
  
  retf
tsub1 endp

ELSE  
  
; void __cdecl __far tsub1()
tsub1		proc far
    push  cs
    call  near ptr tsub2  ; push cs, make the next near call a real far-call seen from stack
    retf
tsub1   endp

ENDIF


; =============== S U B R O U T I N E =======================================


IF REPLACE_WITH_C_CODE EQ 1

tsub2 proc far
  extrn _c_tsub2:far
  
  call _c_tsub2
  retf  
  
tsub2 endp

ELSE

; void __cdecl __far tsub2()
tsub2		proc far
    mov dh, 0Fh

tsub2_0:
    mov al, 0B0h
    or  al, dh    ; mpu_command_@
    call  write_midi_data
    mov al, 7Bh  ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    mov al, 0B0h
    or  al, dh    ; mpu_command_@
    call  write_midi_data
    mov al, 79h   ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    dec dh
    jg  short tsub2_0
    retf
tsub2   endp

ENDIF

IF REPLACE_WITH_C_CODE EQ 1

tsub3 proc far
  extrn _c_tsub3:far
  
mpu_command1_ = word ptr  6
struct1_  = dword ptr  8
mpu_command2_ = word ptr  0Ch
mpu_command3_ = word ptr  0Eh
struct2_  = dword ptr  10h

  push bp
  mov bp, sp
  
  mov ax,[bp+mpu_command1_]
  mov bx,word ptr [bp+struct1_] ; ptr.segment is wrong
  mov cx,[bp+mpu_command2_]
  mov dx,[bp+mpu_command3_]
  les si,[bp+struct2_]
    
  push es
  push si
  push dx
  push cx
  push ds
  push bx
  push ax
  call _c_tsub3
  
  add sp,14
  
  pop bp
  
  retf  
  
tsub3 endp

ELSE

; =============== S U B R O U T I N E =======================================

; maybe: void __cdecl tsub3(__int16 mpu_command1_, struct2_t far *struct1_, __int16 mpu_command2_, __int16 mpu_command3_, struct1_t far* struct2_)
;
; mpu_command1_ is high byte 0 set on call
; mpu_command2_ is value = byte + byte
; mpu_command3_ is high byte 0 set on call
;
; struct1_ could be of type struct2_t
; Attributes: bp-based frame

tsub3   proc far

mpu_command1_ = word ptr  6
struct1_  = dword ptr  8
mpu_command2_ = word ptr  0Ch
mpu_command3_ = word ptr  0Eh
struct2_  = dword ptr  10h

    push  bp
    mov bp, sp
    
    ; struct1_ is a far ptr but the segment is not used (and wrongly set), access is manually done by ds:struct1_.offset
    ; ds != word ptr [bp+struct1_+2] and ds != es
    ; also in stunts at the caller place right before the tsub3 call [bx+2Ch] is also accessed using the ds register
    ; so i need to set the pointer segment correct in the asm stub for my C/C++ call
    mov bx, word ptr [bp+struct1_] ; 0xA2B6
    
    mov al, byte ptr [bp+mpu_command2_]
    mov [bx+struct2_t.byte_3], al ; ds:[A2B6+3]=0x24
    mov [bx+struct2_t.byte_6], al ; ds:[A2B6+6]=0x24
    les bx, [bp+struct2_]
    cmp byte ptr es:[bx+struct1_t.byte_15], 0
    jnz short tsub3_0
    mov al, 7Fh
    jmp short tsub3_1
; ---------------------------------------------------------------------------

tsub3_0:
    mov al, byte ptr [bp+mpu_command3_]

tsub3_1:
    mov bx, word ptr [bp+struct1_]
    mov [bx+struct2_t.byte_4], al  ; DS access?
    push  ax
    mov ax, [bp+mpu_command1_]
    or  al, 90h   ; mpu_command_@
    call  write_midi_data
    mov al, byte ptr [bp+mpu_command2_] ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub3   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub4 proc far
  extrn _c_tsub4:far

unknown1_	= word ptr  6
unknown2_	= word ptr  8

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown1_]
  mov bx,[bp+unknown2_]
  
  push ds ; get ds segment
  push bx
  push ax
  call _c_tsub4
  add sp,6
  
  pop bp
  
  retf  
  
tsub4 endp

ELSE

; int __cdecl __far tsub4(__int16 unknown1_, struct struct2_t far* unknown2_)
tsub4   proc far

unknown1_	= word ptr  6
unknown2_	= word ptr  8

    push  bp
    mov bp, sp
    mov ax, [bp+unknown1_]
    or  al, 80h   ; mpu_command_@
    call  write_midi_data
    mov	bx, [bp+unknown2_]
    mov al, [bx+struct2_t.byte_6]  ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub4   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub5 proc far
  extrn _c_tsub5:far

unknown1_	= word ptr  6
unknown2_	= word ptr  8

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown1_]
  mov bx,[bp+unknown2_]
  
  push bx
  push ax
  call _c_tsub5
  add sp,4
  
  pop bp
  
  retf  
  
tsub5 endp

ELSE

; int __cdecl __far tsub5(__int16 unknown1_, __int16 unknown2_)
tsub5   proc far

unknown1_	= word ptr  6
unknown2_	= word ptr  8

    push  bp
    mov bp, sp
    pop bp
    retf
tsub5   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; arg_2	unused?
; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub6 proc far
  extrn _c_tsub6:far

unknown1_	= word ptr  6
unknown2_	= word ptr  8
mpu_command_	= word ptr  0Ah

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown1_]
  mov bx,[bp+unknown2_]
  mov cx,[bp+mpu_command_]
  
  push cx
  push bx
  push ax
  call _c_tsub6
  add sp,6
  
  pop bp
  
  retf  
  
tsub6 endp

ELSE

; int __cdecl __far tsub6(__int16 unknown1_, __int16 unknown2_,	__int16 mpu_command_@)
tsub6   proc far

unknown1_	= word ptr  6
unknown2_	= word ptr  8
mpu_command_@	= word ptr  0Ah

    push  bp
    mov bp, sp
    mov ax, [bp+unknown1_]
    IF EQUAL_BINARY
    db 25h, 0fh, 00h
    ELSE
    and ax, 0Fh
    ENDIF
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 7   ; mpu_command_@
    call  write_midi_data
    mov	al, byte ptr [bp+mpu_command_@]	; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub6   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub7 proc far
  extrn _c_tsub7:far

unknown1_	= word ptr  6
unknown2_	= word ptr  8
unknown3_	= word ptr  0Ah
unknown4_	= word ptr  0Ch

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown1_]
  mov bx,[bp+unknown2_]
  mov cx,[bp+unknown3_]
  mov dx,[bp+unknown4_]
  
  push dx
  push cx
  push bx
  push ax
  call _c_tsub7
  add sp,8
  
  pop bp
  
  retf  
  
tsub7 endp

ELSE

; void __cdecl __far tsub7(__int16 unknown1_, __int16 unknown2_, __int16 unknown3_, __int16 unknown4_)
tsub7   proc far

unknown1_	= word ptr  6
unknown2_	= word ptr  8
unknown3_	= word ptr  0Ah
unknown4_	= word ptr  0Ch

    push  bp
    mov bp, sp
    mov ax, [bp+unknown1_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, byte ptr [bp+unknown3_]	; mpu_command_@
    call  write_midi_data
    mov al, byte ptr [bp+unknown4_] ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub7   endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub8 proc far
  extrn _c_tsub8:far
  
  call _c_tsub8
  retf  
  
tsub8 endp

ELSE

tsub8   proc far
    mov dh, 0Fh

tsub8_0:
    mov al, 0B0h
    or  al, dh    ; mpu_command_@
    call  write_midi_data
    mov al, 79h   ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    dec dh
    cmp dh, 0FFh
    jnz short tsub8_0
    retf
tsub8   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub9 proc far
  extrn _c_tsub9:far

  unknown1_	= word ptr  6
  unknown2_ = word ptr  8
  unknown3_ = word ptr  0Ah

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown1_]
  mov bx,[bp+unknown2_]
  mov cx,[bp+unknown3_]
  
  push cx
  push bx
  push ax
  call _c_tsub9
  add sp,6
  
  pop bp
  
  retf  
  
tsub9 endp

ELSE

tsub9   proc far

arg_0		= word ptr  6
arg_2   = word ptr  8
arg_4   = word ptr  0Ah

    push  bp
    mov bp, sp
    mov ax, [bp+arg_4]
    or  al, 0E0h  ; mpu_command_@
    call  write_midi_data
    mov ax, [bp+arg_2]
    add ax, 2000h
    push  ax
    and al, 7Fh   ; mpu_command_@
    call  write_midi_data
    pop ax
    shl ax, 1
    mov al, ah
    and al, 7Fh   ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub9   endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub12 proc far
  extrn _c_tsub12:far

mpu_command_	= word ptr 6
unknown2_	= word ptr 8
unknown3_	= word ptr 0Ah

  push bp
  mov bp, sp
  
  mov ax,[bp+unknown3_]
  mov bx,[bp+unknown2_]
  mov cx,[bp+mpu_command_]
  
  push ax
  push bx
  push cx
  call _c_tsub12
  add sp,6
  
  pop bp
  
  retf  
  
tsub12 endp

ELSE

; void __cdecl far c_tsub12(uint16_t mpu_command_, uint16_t unknown2_, uint16_t unknown3_)
tsub12    proc far

mpu_command_	= word ptr  6
unknown2_	= word ptr  8
unknown3_	= word ptr  0Ah

    push  bp
    mov bp, sp
    mov ax, [bp+mpu_command_]
    or  al, 0E0h  ; mpu_command_@
    call  write_midi_data
    mov ax, [bp+unknown3_]
    mov bx, 3Ch
    mul bx
    push  ax
    and al, 7Fh   ; mpu_command_@
    call  write_midi_data
    pop ax
    shl ax, 1
    mov al, ah
    and al, 7Fh   ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub12    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub10 proc far
  extrn _c_tsub10:far

; we need to push onto the stack because the sub-call changes the stack and we get the wrong parameters

mpu_command_	= word ptr  6

  push  bp
  mov bp, sp
  mov ax, [bp+mpu_command_]
  pop bp
  
  push ax
  call _c_tsub10
  add sp,2

  retf  
  
tsub10 endp

ELSE

; void __cdecl __far tsub10(__int16 mpu_command_)
tsub10    proc far

mpu_command_	= word ptr  6

    push  bp
    mov bp, sp
    mov ax, [bp+mpu_command_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 7Bh   ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub10    endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub11 proc far
  extrn _c_tsub11:far

; we need to push onto the stack because the sub-call changes the stack and we get the wrong parameters

mpu_command_  = word ptr  6
unknown1		= word ptr  8
unknown2		= word ptr  0Ah
buffer_   = dword ptr  0Ch

  push  bp
  mov bp, sp
  mov ax, [bp+mpu_command_]
  mov bx, [bp+unknown1]
  mov cx, [bp+unknown2]
  les si, [bp+buffer_]
  
  push es
  push si
  push cx
  push bx
  push ax
  call _c_tsub11
  add sp,10

  pop bp

  retf  
  
tsub11 endp

ELSE

; Attributes: bp-based frame

; void __cdecl tsub11(uint16_t mpu_command_, uint16_t unknown1_, uint16_t unknown2_, struct1_t far *buffer_)
tsub11    proc far

mpu_command_  = word ptr  6
arg_2		= word ptr  8
arg_4		= word ptr  0Ah
buffer_   = dword ptr  0Ch

    push  bp
    mov bp, sp
    mov ax, [bp+mpu_command_] ; 9
    or  al, 0C0h  ; mpu_command_@
    call  write_midi_data
    les bx, [bp+buffer_] ; es:bx = 45CA:0118
    mov al, es:[bx+struct1_t.byte_44] ; mpu_command_@
    call  write_midi_data

IF VERSION EQ 10

    ; VERSION 1.0
    mov cx, [bp+mpu_command_]
    mov dx, 0   ; dl_@ + dh_@
    mov al, es:[bx+struct1_t.byte_12] ; al_@
    call  isub3

ELSEIF VERSION EQ 11

    ; VERSION 1.1
    mov al, es:[bx+struct1_t.byte_12]
    mov cs:bender_range_msg.Bender_Range, al
    mov ax, [bp+mpu_command_]
    and al, 0Fh
    IF EQUAL_BINARY
    db 3dh, 0ah, 00h
    ELSE
    cmp ax, 0Ah
    ENDIF
    jz  short tsub11_0
    dec ax

tsub11_0:
    mov cl, 4
    shl al, cl
    mov cl, al
    mov al, cs:bender_range_msg.address.byte_2
    and al, 0Fh
    or  al, cl
    mov cs:bender_range_msg.address.byte_2, al
    mov cx, size PatchTemporaryArea_BenderRange_msg_t ; size_@
    mov bx, offset bender_range_msg ; offset_@
    push  cs
    pop es    ; segment_@
    call  send_midi_sysex_msg

ENDIF

    mov al, es:[bx+struct1_t.byte_45]
    cmp al, 0
    jz  short tsub11_1
    mov ax, [bp+mpu_command_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 7   ; mpu_command_@
    call  write_midi_data
    les bx, [bp+buffer_]
    mov al, es:[bx+struct1_t.byte_45] ; mpu_command_@
    call  write_midi_data

tsub11_1:
    mov ax, [bp+mpu_command_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 0Ah   ; mpu_command_@
    call  write_midi_data
    les bx, [bp+buffer_]
    mov al, es:[bx+struct1_t.byte_46] ; mpu_command_@
    call  write_midi_data
    pop bp
    retf
tsub11    endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub13 proc far
  extrn _c_tsub13:far

; we need to push onto the stack because the sub-call changes the stack and we get the wrong parameters

mpu_command_  = word ptr  6
buffer1_  = dword ptr  8
buffer2_  = dword ptr  0Ch

  push  bp
  mov bp, sp
  
  mov ax, [bp+mpu_command_]
  mov bx, word ptr [bp+buffer1_] ; the segment is wrongly set - we will use DS
  les si, [bp+buffer2_]

;--
  push es
  push si
  
  push ds ; we use the correct ds segment here, the buffer1_.segment is just wrong
  push bx
  
  push ax
;--  
  call _c_tsub13
  add sp,10

  pop bp

  retf  
  
tsub13 endp

ELSE

; Attributes: bp-based frame

; void __cdecl tsub13(__int16 mpu_command_, struct2_t far *buffer1_, struct1_t far *buffer2_)
tsub13    proc far

mpu_command_  = word ptr  6
buffer1_  = dword ptr  8
buffer2_  = dword ptr  0Ch

    push  bp
    mov bp, sp
    les bx, [bp+buffer2_]
    cmp es:[bx+struct1_t.byte_35], 1
    jnz short tsub13_0

    ; RECHECK
    ; buffer1_ is a far ptr but the segment is not used (and wrongly set), access is manually done by ds:struct1_.offset
    ; ds != word ptr [bp+struct1_+2] and ds != es
    ; also in stunts at the caller place right before the tsub3 call [bx+2Ch] is also accessed using the ds register
    ; so i need to set the pointer segment correct in the asm stub for my C/C++ call
    mov bx, word ptr [bp+buffer1_]
    mov al, [bx+struct2_t.byte_22]
    add al, [bx+struct2_t.byte_3]
    cmp al, [bx+struct2_t.byte_6]
    jz  short tsub13_0

    mov bx, word ptr [bp+buffer1_]
    mov al, [bx+struct2_t.byte_6]
    mov dl, al
    mov ax, [bp+mpu_command_]
    or  al, 80h   ; mpu_command_@
    call  write_midi_data
    mov al, dl    ; mpu_command_@
    call  write_midi_data
    xor al, al    ; mpu_command_@
    call  write_midi_data
    mov bx, word ptr [bp+buffer1_]
    mov al, [bx+struct2_t.byte_22]
    add al, [bx+struct2_t.byte_3]
    mov [bx+struct2_t.byte_6], al
    mov dl, al
    mov ax, [bp+mpu_command_]
    or  al, 90h   ; mpu_command_@
    call  write_midi_data
    mov al, dl    ; mpu_command_@
    call  write_midi_data
    mov bx, word ptr [bp+buffer1_]
    mov al, [bx+struct2_t.byte_4] ; mpu_command_@
    call  write_midi_data

tsub13_0:
    les bx, [bp+buffer2_]
    cmp es:[bx+struct1_t.byte_28], 4
    jnz short tsub13_1
    mov bx, word ptr [bp+buffer1_]
    mov ax, [bx+struct2_t.word_1C]
    push  ax
    mov ax, [bp+mpu_command_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 1   ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data
    jmp short tsub13_2
; ---------------------------------------------------------------------------
    nop

tsub13_1:
    cmp es:[bx+struct1_t.byte_28], 2
    jnz short tsub13_2
    mov bx, word ptr [bp+buffer1_]
    mov ax, [bx+struct2_t.word_1C]
    push  ax
    mov ax, [bp+mpu_command_]
    or  al, 0E0h  ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data

tsub13_2:
    les bx, [bp+buffer2_]
    cmp es:[bx+struct1_t.byte_19], 4
    jnz short tsub13_3
    mov bx, word ptr [bp+buffer1_]
    mov ax, [bx+struct2_t.word_14]
    push  ax
    mov ax, [bp+mpu_command_]
    or  al, 0B0h  ; mpu_command_@
    call  write_midi_data
    mov al, 1   ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data
    jmp short tsub13_4
; ---------------------------------------------------------------------------
    nop

tsub13_3:
    cmp byte ptr es:[bx+struct1_t.byte_19], 2
    jnz short tsub13_4
    mov bx, word ptr [bp+buffer1_]
    mov ax, [bx+struct2_t.word_14]
    push  ax
    mov ax, [bp+mpu_command_]
    or  al, 0E0h  ; mpu_command_@
    call  write_midi_data
    mov al, 0   ; mpu_command_@
    call  write_midi_data
    pop ax    ; mpu_command_@
    call  write_midi_data

tsub13_4:
    pop bp
    retf
tsub13    endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub14 proc far
  extrn _c_tsub14:far

  call _c_tsub14
  retf  
  
tsub14 endp

ELSE

; Attributes: bp-based frame

; TODO:	find call in stunts
; void __cdecl __far tsub14()
tsub14    proc far
    push  bp
    mov bp, sp
    pop bp
    retf
tsub14    endp

ENDIF

; =============== S U B R O U T I N E =======================================

IF REPLACE_WITH_C_CODE EQ 1

tsub15 proc far
  extrn _c_tsub15:far

  call _c_tsub15
  retf  
  
tsub15 endp

ELSE

; TODO:	find call in stunts
; Attributes: bp-based frame

; void __cdecl __far tsub15()
tsub15    proc far
    push  bp
    mov bp, sp
    pop bp
    retf
tsub15    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub16 proc far
  extrn _c_tsub16:far

  call _c_tsub16
  retf  
  
tsub16 endp

ELSE

; __int16 __cdecl __far	tsub16(__int16 unknown_)
; void __cdecl __far tsub16()
tsub16    proc far

unknown_	= word ptr  6

    push  bp
    mov bp, sp
    pop bp
    retf
tsub16    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; TODO:	find call in stunts
; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub17 proc far
  extrn _c_tsub17:far

  call _c_tsub17
  retf  
  
tsub17 endp

ELSE

; void __cdecl __far tsub17()
tsub17    proc far
    push  bp
    mov bp, sp
    pop bp
    retf
tsub17    endp

ENDIF

; =============== S U B R O U T I N E =======================================

; TODO:	find call in stunts
; Attributes: bp-based frame

IF REPLACE_WITH_C_CODE EQ 1

tsub18 proc far
  extrn _c_tsub18:far

  call _c_tsub18
  retf  
  
tsub18 endp

ELSE

; __int16 __cdecl __far tsub18()
tsub18    proc far
    push  bp
    mov bp, sp
    mov ax, 0FFh
    pop bp
    retf
tsub18    endp

ENDIF

seg000    ends

end jump_table ; not a real entry point, just to silence the linker
