HEX
FE000000 CONSTANT RPI4 
RPI4 200000 + CONSTANT GPIO_ADDR
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;
( utility.f - per inserire i commenti - jonesforth.f )

: C, HERE @ C! 1 HERE +! ;
: ALIGN HERE @ 3 + 3 INVERT AND HERE ! ;
: S" IMMEDIATE STATE @ IF ' LITS , HERE @ 0 ,
	BEGIN KEY DUP '"' <> WHILE C, REPEAT DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE HERE @
	BEGIN KEY DUP '"' <> WHILE OVER C! 1+ REPEAT DROP HERE @ - HERE @ SWAP THEN ;
: ." IMMEDIATE STATE @ 
	IF [COMPILE] S" ' TELL ,
	ELSE BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN THEN ;

: GET @ U. ;
: STACK_CLEAR BEGIN DEPTH 0> WHILE DROP REPEAT ;

( gpio.f )
GPIO_ADDR      CONSTANT GPFSEL0
GPIO_ADDR  4 + CONSTANT GPFSEL1
GPIO_ADDR  8 + CONSTANT GPFSEL2
GPIO_ADDR 10 + CONSTANT GPFSEL4

: 1BIT_SET 1 SWAP LSHIFT ;
: GPIO 1BIT_SET ;
: 2_LSHIFT A MOD 2 * ;
: 3_LSHIFT A MOD 3 * ;
: N_GPIO 0 SWAP BEGIN DUP 2 MOD 0 = IF 1 RSHIFT SWAP 1+ SWAP ELSE THEN DUP 2 = UNTIL DROP 1+ ;
: MASK2 2_LSHIFT 3 SWAP LSHIFT INVERT ;
: MASK3 3_LSHIFT 7 SWAP LSHIFT INVERT ;
: OUT 3_LSHIFT 1BIT_SET ;
: ALT0_FUN 3_LSHIFT 2+ 1BIT_SET ;
: ALT5_FUN 3_LSHIFT 1+ 1BIT_SET ;
: FSEL DUP A / 4 * GPFSEL0 + ;
: FUNCTION FSEL 2DUP SWAP MASK3 SWAP @ AND ROT ;
: INPUT N_GPIO FUNCTION DROP SWAP ! ;
: OUTPUT N_GPIO FUNCTION OUT OR SWAP ! ;
: ALT0 N_GPIO FUNCTION ALT0_FUN OR SWAP ! ;
: ALT5 N_GPIO FUNCTION ALT5_FUN OR SWAP ! ;

DECIMAL
0 GPIO CONSTANT GPIO0 1 GPIO CONSTANT GPIO1 2 GPIO CONSTANT GPIO2 3 GPIO CONSTANT GPIO3
4 GPIO CONSTANT GPIO4 5 GPIO CONSTANT GPIO5 6 GPIO CONSTANT GPIO6 7 GPIO CONSTANT GPIO7
8 GPIO CONSTANT GPIO8 9 GPIO CONSTANT GPIO9 10 GPIO CONSTANT GPIO10 11 GPIO CONSTANT GPIO11
12 GPIO CONSTANT GPIO12 13 GPIO CONSTANT GPIO13 14 GPIO CONSTANT GPIO14 15 GPIO CONSTANT GPIO15
16 GPIO CONSTANT GPIO16 17 GPIO CONSTANT GPIO17 18 GPIO CONSTANT GPIO18 19 GPIO CONSTANT GPIO19
20 GPIO CONSTANT GPIO20 21 GPIO CONSTANT GPIO21 22 GPIO CONSTANT GPIO22 23 GPIO CONSTANT GPIO23
24 GPIO CONSTANT GPIO24 25 GPIO CONSTANT GPIO25 26 GPIO CONSTANT GPIO26 27 GPIO CONSTANT GPIO27
10 GPIO CONSTANT GPIO42
HEX

( timer.f )
RPI4 3000 + CONSTANT TIMER 
TIMER       CONSTANT TIMER_CONTROL_STATUS
TIMER  04 + CONSTANT TIMER_COUNTER_LOW

: NOW TIMER_COUNTER_LOW @ ;
: DELAY NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;
: MSEC 3E8 * ;
: 0.5SEC 1F4 MSEC ;
: SEC 3E8 MSEC * ;

( led.f )
GPIO_ADDR 1C + CONSTANT GPSET0
GPIO_ADDR 20 + CONSTANT GPSET1
GPIO_ADDR 28 + CONSTANT GPCLR0
GPIO_ADDR 2C + CONSTANT GPCLR1
GPIO_ADDR 34 + CONSTANT GPLEV0

: INIT_LED 
    GPIO13 OUTPUT GPIO16 OUTPUT GPIO26 OUTPUT ;
GPIO13 CONSTANT RED
GPIO16 CONSTANT YELLOW
GPIO26 CONSTANT GREEN

: LED GPSET0 GPCLR0 ;
: LED42 GPIO42 GPSET1 GPCLR1 ;
: ON DROP ! ;
: OFF NIP ! ;
: HIGH LED ON ;
: LOW LED OFF ;
: IS_ON GPLEV0 @ AND 0 = IF 0 ELSE 1 THEN ;
: BLINK 2DUP LED ON DELAY LED OFF DELAY ;

( event.f )
GPIO_ADDR 40 + CONSTANT GPEDS0
GPIO_ADDR 4C + CONSTANT GPREN0
GPIO_ADDR 58 + CONSTANT GPFEN0
GPIO_ADDR 7C + CONSTANT GPAREN0
GPIO_ADDR 88 + CONSTANT GPAFEN0

: ENABLE TUCK @ OR SWAP ! ;
: DISABLE SWAP INVERT OVER @ AND SWAP ! ;
: CLEAR_EVENT GPEDS0 ENABLE ;

( button.f )
GPIO_ADDR E4 + CONSTANT GPIO_PUP_PDN_0
: PULL_UP N_GPIO GPIO_PUP_PDN_0 2DUP SWAP MASK2 SWAP @ AND ROT 2_LSHIFT 1BIT_SET OR SWAP ! ;
: PULL_DOWN N_GPIO GPIO_PUP_PDN_0 2DUP SWAP MASK2 SWAP @ AND ROT 2_LSHIFT 1+ 1BIT_SET OR SWAP ! ;
: INIT_BUTTON
    GPIO9 INPUT GPIO10 INPUT
    GPIO9 PULL_UP GPIO10 PULL_UP
    GPIO9 GPREN0 ENABLE GPIO10 GPREN0 ENABLE
    GPIO9 GPIO10 OR CLEAR_EVENT ;
GPIO9 CONSTANT BREAK_BUTTON
GPIO10 CONSTANT EXIT_BUTTON
: IS_PRESSED GPLEV0 @ AND 0 = IF 1 ELSE 0 THEN ;
: IS_CLICKED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ;

( i2c.f )
RPI4 804000 + CONSTANT BSC1 
BSC1 00 + CONSTANT I2C_CONTROL
BSC1 04 + CONSTANT I2C_STATUS
BSC1 08 + CONSTANT I2C_DATA_LENGTH
BSC1 0C + CONSTANT I2C_SLAVE_ADDRESS
BSC1 10 + CONSTANT I2C_DATA_FIFO

: SET TUCK @ OR SWAP ! ;
: CLEAR SWAP INVERT OVER @ AND SWAP ! ;
: INIT_I2C GPIO2 ALT0 GPIO3 ALT0 ;

0 1BIT_SET CONSTANT WRITE
4 1BIT_SET CONSTANT FIFO_CLEAR
7 1BIT_SET CONSTANT START
F 1BIT_SET CONSTANT I2CEN
1 1BIT_SET CONSTANT TRANSFER_DONE
8 1BIT_SET CONSTANT ACK_ERR
9 1BIT_SET CONSTANT CLKT

: RESET_FIFO FIFO_CLEAR I2C_CONTROL SET ;
: RESET_STATUS 
	TRANSFER_DONE   I2C_STATUS SET
	ACK_ERR         I2C_STATUS SET
	CLKT            I2C_STATUS SET ;
: SET_SLAVE 27 I2C_SLAVE_ADDRESS ! ;
: I2C_SETUP
	RESET_STATUS
	RESET_FIFO
	1 I2C_DATA_LENGTH !
	SET_SLAVE ;
: I2C_STORE I2C_DATA_FIFO ! ;
: I2C_SEND
	WRITE I2C_CONTROL CLEAR
	START I2C_CONTROL SET
	I2CEN I2C_CONTROL SET ;
: I2C_DELAY 10 MSEC DELAY ;
: >I2C
	I2C_SETUP
	I2C_STORE
	I2C_SEND
	I2C_DELAY ;
: SEND SWAP >I2C >I2C ;

( lcd.f )
: 4BIT_CLEAR F SWAP LSHIFT INVERT AND ;
: SEND_4BIT_MORE   
  0 4BIT_CLEAR DUP
  D OR >I2C 
  9 OR >I2C ;
: SEND_4BIT_LESS  
  4 4BIT_CLEAR 4 LSHIFT DUP
  D OR >I2C 
  9 OR >I2C ;
: >LCD DUP SEND_4BIT_MORE SEND_4BIT_LESS ;
: 4BIT-CONFIG 
  3C 38 SEND
  3C 38 SEND
  3C 38 SEND
  2C 28 SEND
  2C 28 SEND
  8C 88 SEND
  0C 08 SEND
  8C 88 SEND
  0C 08 SEND
  1C 18 SEND
  0C 08 SEND
  4C 48 SEND
;
: LCD 0C 08 SEND ;
: CLEAR 1C 18 SEND 1F4 MSEC DELAY ;
: SWITCH_ON EC E8 SEND ;
: SWITCH_OFF 84 40 SEND ;
: SHIFT_LEFT 7C 78 SEND ;
: SHIFT_RIGHT 6C 68 SEND ;
: CURSOR LCD ;
: UP 8C 88 SEND ;
: DOWN CC C8 SEND ;
: TURN_ON EC E8 SEND ;
: TURN_OFF CC C8 SEND ;
: BLINKS FC F8 SEND ;
: !BLINKS EC E8 SEND ;
: MOVE 1C 18 SEND ;
: CURSOR_LEFT 0C 08 SEND ;
: CURSOR_RIGHT 4C 48 SEND ;
: DISPLAY_RIGHT CC C8 SEND ;
: DISPLAY_LEFT 8C 88 SEND ;

: INIT_LCD
  4BIT-CONFIG
  LCD SWITCH_ON
  LCD SHIFT_RIGHT ;

( char.f )

: 'SPACE 20 >LCD ;
: '! 21 >LCD ;
: '" 22 >LCD ;
: '# 23 >LCD ;
: '$ 24 >LCD ;
: '% 25 >LCD ;
: '& 26 >LCD ;
: '' 27 >LCD ;
: '( 28 >LCD ;
: '* 2A >LCD ;
: '+ 2B >LCD ;
: ', 2C >LCD ;
: '. 2D >LCD ;
: '. 2E >LCD ;
: '/ 2F >LCD ;
: '0 30 >LCD ;
: '1 31 >LCD ;
: '2 32 >LCD ;
: '3 33 >LCD ;
: '4 34 >LCD ;
: '5 35 >LCD ;
: '6 36 >LCD ;
: '7 37 >LCD ;
: '8 38 >LCD ;
: '9 39 >LCD ;
: ': 3A >LCD ;
: '; 3B >LCD ;
: '< 3C >LCD ;
: '= 3D >LCD ;
: '> 3E >LCD ;
: '? 3F >LCD ;
: '@ 40 >LCD ;
: 'A 41 >LCD ;
: 'B 42 >LCD ;
: 'C 43 >LCD ;
: 'D 44 >LCD ;
: 'E 45 >LCD ;
: 'F 46 >LCD ;
: 'G 47 >LCD ;
: 'H 48 >LCD ;
: 'I 49 >LCD ;
: 'J 4A >LCD ;
: 'K 4B >LCD ;
: 'L 4C >LCD ;
: 'M 4D >LCD ;
: 'N 4E >LCD ;
: 'O 4F >LCD ;
: 'P 50 >LCD ;
: 'Q 51 >LCD ;
: 'R 52 >LCD ;
: 'S 53 >LCD ;
: 'T 54 >LCD ;
: 'U 55 >LCD ;
: 'V 56 >LCD ;
: 'W 57 >LCD ;
: 'X 58 >LCD ;
: 'Y 59 >LCD ;
: 'Z 5A >LCD ;
: '[ 5B >LCD ;
: '\ 5C >LCD ;
: '] 5D >LCD ;
: '^ 5E >LCD ;
: '_ 5F >LCD ;
: '` 60 >LCD ;
: 'mm 6D >LCD 6D >LCD ;
: '{ 7B >LCD ;
: '| 7C >LCD ;
: '} 7D >LCD ;
: '~ 7E >LCD ;
: 'DEL 7F >LCD ;

: N_PRINT 		
CASE
0 OF '0 ENDOF
1 OF '1 ENDOF
2 OF '2 ENDOF
3 OF '3 ENDOF
4 OF '4 ENDOF
5 OF '5 ENDOF
6 OF '6 ENDOF
7 OF '7 ENDOF
8 OF '8 ENDOF
9 OF '9 ENDOF
ENDCASE
;

( pir.f )
: INIT_PIR
    GPIO12 OUTPUT GPIO27 INPUT
    GPIO27 GPREN0 ENABLE
    GPIO27 CLEAR_EVENT ;
GPIO12 CONSTANT BUZZER
GPIO27 CONSTANT PIR

: IS_HIGH IS_ON ;
: BLINK_BUZ 2DUP LED ON BUZZER HIGH DELAY LED OFF BUZZER LOW DELAY ;
: MOTION_DETECTED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ;
: DELAY_COUNTER 0 ;

: PIR_CALIBRATION
	BEGIN 
		PIR IS_HIGH 0 = IF 1 SEC DELAY YELLOW LED OFF ." Nessun movimento" CR
		ELSE YELLOW LED ON ." Pir High" CR DELAY_COUNTER
			BEGIN PIR IS_HIGH WHILE 1 SEC DELAY 1+ DUP . ." sec " CR REPEAT CR
		THEN 1 SEC DELAY YELLOW LED OFF ." Pir Low" CR
        DEPTH 0> IF ." Durata totale: " . ." secondi" CR 1 SEC DELAY THEN
	BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: MOTION_DETECTION
    BEGIN 
        PIR DUP MOTION_DETECTED IF
            CLEAR_EVENT ." Movimento rilevato" CR
            BEGIN PIR IS_HIGH WHILE 0.5SEC RED BLINK_BUZ REPEAT
        ELSE 
            RED LED OFF CLEAR_EVENT ." Nessun movimento" CR 1 SEC DELAY 
        THEN
    BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

( sonar.f )
: INIT_SONAR
GPIO4 OUTPUT GPIO17 INPUT
GPIO17 GPAREN0 ENABLE
GPIO17 GPAFEN0 ENABLE ;

GPIO4 CONSTANT TRIGGER_PIN
GPIO17 CONSTANT ECHO_PIN

: TIME_OUT 5 A * MSEC DELAY ;
: SEND_TIME A MSEC DELAY ;
: TRIGGER TRIGGER_PIN HIGH SEND_TIME TRIGGER_PIN LOW ;

: TRIGGER_ECHO_CHECK
    BEGIN
    DEPTH 2 < WHILE
        ECHO_PIN IS_HIGH IF TIME_OUT DELAY THEN TRIGGER
        BEGIN ECHO_PIN IS_HIGH 0 = WHILE ." ." REPEAT NOW
        BEGIN ECHO_PIN IS_HIGH WHILE ." -" REPEAT NOW
    REPEAT
    DEPTH 2 = IF SWAP - . CR
            ELSE STACK_CLEAR THEN ;

: SONAR_CHECK BEGIN 1 SEC DELAY TRIGGER_ECHO_CHECK BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: DISTANCE_DETECTION
    BEGIN
    DEPTH 4 < WHILE
        ECHO_PIN IS_HIGH IF TIME_OUT DELAY THEN
        TRIGGER
        BEGIN ECHO_PIN IS_HIGH 0 = WHILE REPEAT
        NOW
        BEGIN ECHO_PIN IS_HIGH WHILE REPEAT
        NOW
    REPEAT
    DEPTH 4 = IF
        SWAP - 154 * 2 / 1 MSEC / -ROT
        SWAP - 154 * 2 / 1 MSEC /
        2DUP < IF DROP ELSE NIP THEN . CR
    ELSE STACK_CLEAR THEN
;
: SONAR_DISTANCE BEGIN 1 SEC DELAY DISTANCE_DETECTION BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

( SECURITY SYSTEM )
: LEDS_OFF RED LED OFF YELLOW LED OFF GREEN LED OFF BUZZER LOW ;
: ALARM_OFF LCD CLEAR 'A 'L 'A 'R 'M 'SPACE 'O 'F 'F ;
: ALERT BEGIN 100 MSEC RED BLINK_BUZ BREAK_BUTTON IS_CLICKED UNTIL BUZZER LOW RED LED OFF ;

: DISTANCE_LED_DETECTION
    1 SEC DELAY
    LEDS_OFF
    BEGIN
    DEPTH 4 < WHILE 
		ECHO_PIN IS_HIGH IF TIME_OUT DELAY THEN TRIGGER
        BEGIN ECHO_PIN IS_HIGH 0 = WHILE REPEAT NOW
        BEGIN ECHO_PIN IS_HIGH WHILE REPEAT NOW
    REPEAT
    DEPTH 4 = IF 
        SWAP - 154 * 2 / 1 MSEC / -ROT
        SWAP - 154 * 2 / 1 MSEC /
        2DUP < IF DROP ELSE NIP THEN 

        DOWN CURSOR
        DUP 3E8 / DUP   0 = IF 'SPACE DROP ELSE N_PRINT THEN
        DUP 64 / DUP    0 = IF 'SPACE DROP ELSE N_PRINT THEN
        DUP 64 MOD A DUP 0 = IF 'SPACE DROP ELSE N_PRINT THEN
        DUP A MOD DUP   0 = IF 'SPACE DROP ELSE N_PRINT THEN 'mm

        DUP . ." mm " CR
        DUP 5A < IF ALERT THEN 
        DUP 5A C8 WITHIN IF RED LED ON BUZZER HIGH THEN
        DUP C8 190 WITHIN IF YELLOW LED ON THEN
        DUP 190 > IF GREEN LED ON THEN
     ELSE STACK_CLEAR LEDS_OFF THEN ;


: SONAR_LED BEGIN 2 SEC DELAY DISTANCE_LED_DETECTION BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: MOVE_MSG LCD CLEAR 'M 'O 'V 'E 'SPACE 'D 'E 'T 'E 'C 'T 'E 'D ;
: SECURITY_SYSTEM
	BEGIN 
		PIR DUP MOTION_DETECTED IF CLEAR_EVENT ." Movimento rilevato" CR MOVE_MSG THEN
			BEGIN PIR IS_HIGH BREAK_BUTTON IS_CLICKED OR WHILE DISTANCE_LED_DETECTION REPEAT
		PIR IS_HIGH 0 = IF LEDS_OFF CLEAR_EVENT ." Nessun movimento" CR 1 SEC DELAY THEN
	BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

( pin.f )
: INIT_PIN_BUTTONS
GPIO5 GPREN0 ENABLE
GPIO6 GPREN0 ENABLE
GPIO7 GPREN0 ENABLE
GPIO8 GPREN0 ENABLE ;
GPIO5 CONSTANT BUTTON5
GPIO6 CONSTANT BUTTON6
GPIO7 CONSTANT BUTTON7
GPIO8 CONSTANT BUTTON8

: BUTTONS_RESET BUTTON5 BUTTON6 OR BUTTON7 OR BUTTON8 OR CLEAR_EVENT ;
: SEQUENCE 8 = -ROT 6 = -ROT 5 = -ROT 2SWAP SWAP 7 = ; ( 7 5 6 8 )
: RESET STACK_CLEAR
        GPEDS0 @ 0<> IF
        BUTTONS_RESET THEN
        LCD CLEAR CURSOR !BLINKS ;

: PIN_MSG DOWN CURSOR 'P 'I 'N ': CURSOR BLINKS ;
: PIN_ERR LCD CLEAR 'W 'R 'O 'N 'G 'SPACE 'P 'I 'N  ;
: PIN_OK LCD CLEAR 'C 'O 'R 'R 'E 'C 'T 'SPACE 'P 'I 'N ;
: ATTEMPS_LEFT LCD CLEAR 'A 'T 'T 'E 'M 'P 'S 'SPACE 'L 'E 'F 'T ': 'SPACE ;

VARIABLE ATTEMPS
: INIT_ATTEMPS 3 ATTEMPS ! ;
: TERMINATED @ 0 = ;
: DECREMENT DUP @ 1- SWAP ! ;
: PIN_CHECK
    BEGIN
        1 SEC DELAY
        RESET  
        ." DIGITA IL PIN E PREMI INVIO "
        ATTEMPS_LEFT ATTEMPS @ N_PRINT
        PIN_MSG
        BEGIN
            BREAK_BUTTON IS_CLICKED ATTEMPS TERMINATED OR 0 = WHILE
            BUTTON7 IS_CLICKED IF
            ." 7 " '7 BUTTON7 N_GPIO BUTTON7 CLEAR_EVENT 1 SEC DELAY THEN

            BUTTON5 IS_CLICKED IF
            ." 5 " '5 BUTTON5 N_GPIO BUTTON5 CLEAR_EVENT 1 SEC DELAY THEN 

            BUTTON6 IS_CLICKED IF
            ." 6 " '6 BUTTON6 N_GPIO BUTTON6 CLEAR_EVENT 1 SEC DELAY THEN

            BUTTON8 IS_CLICKED IF
            ." 8 " '8 BUTTON8 N_GPIO BUTTON8 CLEAR_EVENT 1 SEC DELAY THEN
        REPEAT
        BREAK_BUTTON CLEAR_EVENT
        
        ATTEMPS TERMINATED IF
            1 SEC DELAY
        ELSE
            0.5SEC YELLOW BLINK
            DEPTH 4 <> 
            IF STACK_CLEAR FALSE
                ." ERRATA " CR PIN_ERR 0.5SEC RED BLINK ATTEMPS DECREMENT
            ELSE
                SEQUENCE AND AND AND
                DUP FALSE = IF 
                ." ERRATA " CR PIN_ERR 0.5SEC RED BLINK ATTEMPS DECREMENT
                THEN 
            THEN 
        THEN
    TRUE = ATTEMPS TERMINATED OR
    UNTIL
    ATTEMPS TERMINATED IF
        ALERT
        FALSE
    ELSE
        ." CORRETTA " CR PIN_OK 
        1 SEC GREEN BLINK RESET
        TRUE
    THEN
;
: ALARM_MSG LCD CLEAR 'A 'L 'A 'R 'M 'SPACE 'A 'C 'T 'I 'V 'A 'T 'E 'D ;
: STANDBY_MSG 'S 'T 'A 'N 'D 'SPACE 'B 'Y ;
: STANDBY LCD CLEAR STANDBY_MSG BEGIN 1 SEC DELAY BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: MAIN
    INIT_LED
    INIT_BUTTON
    INIT_I2C
    INIT_LCD
    INIT_PIN_BUTTONS
    INIT_PIR
    INIT_SONAR
    INIT_ATTEMPS

    BEGIN
        STANDBY
        PIN_CHECK IF
            ALARM_MSG
            SECURITY_SYSTEM
        THEN
        ALARM_OFF
        1 SEC DELAY
    AGAIN
;
