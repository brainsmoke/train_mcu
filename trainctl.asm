; toy train firmware

.module trainctl

FORWARD_BUTTON = 6;
STOP_BUTTON = 5;
BACKWARD_BUTTON = 7;

BUTTON_MASK = ( (1<<FORWARD_BUTTON) | (1<<STOP_BUTTON) | (1<<BACKWARD_BUTTON) );
FORWARD_BUTTON_PRESSED_ONLY = ( (1<<STOP_BUTTON) | (1<<BACKWARD_BUTTON) );
BACKWARD_BUTTON_PRESSED_ONLY = ( (1<<STOP_BUTTON) | (1<<FORWARD_BUTTON) );
NO_BUTTON_PRESSED = BUTTON_MASK;

FORWARD_CTL = 4;
BACKWARD_CTL = 0;

OUT_MASK = ((1<<BACKWARD_CTL) | (1<<FORWARD_CTL));

VCC = 3000  ; mV

TIMEOUT=600; seconds

FREQ=3000;
LOOP_CYCLES=11;
COUNT=(FREQ*TIMEOUT/LOOP_CYCLES-1);

COUNT_LOW=(COUNT&0xff);
COUNT_MID=((COUNT>>8)&0xff);
COUNT_HIGH=(COUNT>>16);

.include "pdk.asm"

.area DATA (ABS)
.org 0x00
 
count_low:     .ds 1
count_mid:     .ds 1
count_high:    .ds 1

.area CODE (ABS)
.org 0x00

clock_3khz

easypdk_calibrate_ilrc 3000, VCC

mov a, #0
mov pa, a
mov a, #OUT_MASK
mov pac, a

mov a, #BUTTON_MASK
mov paph, a
mov padier, a

stop:
set0 pa, #FORWARD_CTL
set0 pa, #BACKWARD_CTL

mov a, pa
and a, #BUTTON_MASK
ceqsn a, #NO_BUTTON_PRESSED
goto button_pressed
stopsys
nop
reset

button_pressed:
ceqsn a, #FORWARD_BUTTON_PRESSED_ONLY
goto not_go_forward
goto go_forward
not_go_forward:
ceqsn a, #BACKWARD_BUTTON_PRESSED_ONLY
goto stop

go_backward:
set0 pa, #FORWARD_CTL
nop
set1 pa, #BACKWARD_CTL

go_backward_loop:
ceqsn a, #NO_BUTTON_PRESSED     ; 1
goto go_backward_button_pressed ; 2
dec count_low                   ; 3
subc count_mid                  ; 4
subc count_high                 ; 5
t0sn f, #ACC_CARRY_FLAG         ; 6
goto stop                       ; 7

go_backward_check_button:
mov a, pa                       ; 8
and a, #BUTTON_MASK             ; 9
goto go_backward_loop           ; 11

go_backward_button_pressed:
ceqsn a, #BACKWARD_BUTTON_PRESSED_ONLY
goto stop
go_backward_reset_counter:
; init counter
mov a, #COUNT_LOW
mov count_low, a
mov a, #COUNT_MID
mov count_mid, a
mov a, #COUNT_HIGH
mov count_high, a
goto go_backward_check_button

go_forward:
set0 pa, #BACKWARD_CTL
nop
set1 pa, #FORWARD_CTL

go_forward_loop:
ceqsn a, #NO_BUTTON_PRESSED     ; 1
goto go_forward_button_pressed  ; 2
dec count_low                   ; 3
subc count_mid                  ; 4
subc count_high                 ; 5
t0sn f, #ACC_CARRY_FLAG         ; 6
goto stop                       ; 7

go_forward_check_button:
mov a, pa                       ; 8
and a, #BUTTON_MASK             ; 9
goto go_forward_loop            ; 11

go_forward_button_pressed:
ceqsn a, #FORWARD_BUTTON_PRESSED_ONLY
goto stop
go_forward_reset_counter:
; init counter
mov a, #COUNT_LOW
mov count_low, a
mov a, #COUNT_MID
mov count_mid, a
mov a, #COUNT_HIGH
mov count_high, a
goto go_forward_check_button

