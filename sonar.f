( ECHO INPUT E PULL_DOWN - TRIGGER OUTPUT)
( # add rising and falling edge detection on echo_pin )
(
\ trigger_pin=4    # the GPIO pin that is set to high to send an ultrasonic wave out. (output)
\ echo_pin=17      # the GPIO pin that indicates a returning ultrasonic wave when it is set to high (input)
\ time_out = .05 # measured in seconds in case the program gets stuck in a loop
)
( sonar.f )
: INIT_SONAR
    GPIO4 OUTPUT
    GPIO17 INPUT
    GPIO17 GPAREN0 ENABLE
    GPIO17 GPAFEN0 ENABLE 
    GPIO17 CLEAR_EVENT
;

GPIO4 CONSTANT TRIGGER_PIN
GPIO17 CONSTANT ECHO_PIN

: TIME_OUT 5 A * MSEC DELAY ;
: SEND_TIME A MSEC DELAY ;
: TRIGGER TRIGGER_PIN HIGH SEND_TIME TRIGGER_PIN LOW ;
: ECHO_HIGH ECHO_PIN IS_ON IF ." HIGH " ELSE ." LOW" THEN ;

: TRIGGER_ECHO_CHECK
    BEGIN
    DEPTH 2 < WHILE
        ECHO_PIN IS_HIGH IF 
            TIME_OUT
        THEN TRIGGER
        BEGIN 
            ECHO_PIN IS_HIGH 0 = WHILE 
            ." ." 
        REPEAT NOW
        BEGIN 
            ECHO_PIN IS_HIGH WHILE 
            ." -" 
        REPEAT NOW
    REPEAT
    DEPTH 2 = IF SWAP - . CR
            ELSE STACK_CLEAR THEN ;

: SONAR_CHECK BEGIN 1 SEC DELAY TRIGGER_ECHO_CHECK BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: DISTANCE_DETECTION
    BEGIN
    DEPTH 4 < WHILE
        ECHO_PIN IS_ON IF TIME_OUT THEN
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
: SONAR_DISTANCE BEGIN 1 SEC DELAY DISTANCE_DETECTION BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;
