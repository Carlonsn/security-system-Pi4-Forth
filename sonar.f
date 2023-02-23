( Includi prima le librerie )
( utility.f )
( gpio.f )
( timer.f )
( led.f )
( event.f )
( ECHO INPUT E PULL_DOWN - TRIGGER OUTPUT)
( # add rising and falling edge detection on echo_pin )
(
\ trigger_pin=4    # the GPIO pin that is set to high to send an ultrasonic wave out. (output)
\ echo_pin=17      # the GPIO pin that indicates a returning ultrasonic wave when it is set to high (input)
\ time_out = .05 # measured in seconds in case the program gets stuck in a loop
)

GPIO4 OUTPUT
GPIO17 INPUT
GPIO4 CONSTANT TRIGGER_PIN
GPIO17 CONSTANT ECHO_PIN
ECHO_PIN GPREN0 ENABLE
ECHO_PIN GPFEN0 ENABLE

: TIME_OUT 5 A * MSEC DELAY ;
: SEND_TIME A MSEC DELAY ;
: TRIGGER TRIGGER_PIN HIGH SEND_TIME TRIGGER_PIN LOW ;
: ECHO_HIGH ECHO_PIN IS_ON IF ." HIGH " ELSE ." LOW" THEN ;

: DISTANCE_CHECK
    BEGIN
    DEPTH 4 < WHILE
        ECHO_PIN IS_ON IF
            ." waiting for timeout"
            TIME_OUT DELAY
        THEN
        TRIGGER
        BEGIN
            ECHO_PIN IS_ON 0 = WHILE
            ." ."
        REPEAT
        NOW
        BEGIN
            ECHO_PIN IS_ON WHILE
            ." -"
        REPEAT
        NOW
    REPEAT
    DEPTH 4 = IF
        SWAP - 154 * 2 / 1 MSEC / -ROT
        SWAP - 154 * 2 / 1 MSEC /
        2DUP < IF DROP ELSE NIP THEN . CR
    ELSE
        STACK_CLEAR
    THEN
;

: SONAR_CHECK BEGIN 1 SEC DELAY DISTANCE_CHECK BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: DISTANCE_DETECTION
    BEGIN
    DEPTH 4 < WHILE
        ECHO_PIN IS_ON IF TIME_OUT DELAY THEN
        TRIGGER
        BEGIN ECHO_PIN IS_ON 0 = WHILE REPEAT
        NOW
        BEGIN ECHO_PIN IS_ON WHILE REPEAT
        NOW
    REPEAT
    DEPTH 4 = IF
        SWAP - 154 * 2 / 1 MSEC / -ROT
        SWAP - 154 * 2 / 1 MSEC /
        2DUP < IF DROP ELSE NIP THEN . CR
    ELSE STACK_CLEAR THEN
;
: SONAR_DETECTION BEGIN 1 SEC DELAY DISTANCE_DETECTION BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;