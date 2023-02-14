( ECHO INPUT E PULL_DOWN - TRIGGER OUTPUT)
( # add rising and falling edge detection on echo_pin )
(
\ #### Define program constants
\ trigger_pin=4    # the GPIO pin that is set to high to send an ultrasonic wave out. (output)
\ echo_pin=17      # the GPIO pin that indicates a returning ultrasonic wave when it is set to high (input)
\ number_of_samples=5 # this is the number of times the sensor tests the distance and then picks the middle value to return
\ sample_sleep = .01  # amount of time in seconds that the system sleeps before sending another sample request to the sensor.
\ You can try this at .05 if your measurements aren't good, or try it at 005 if you want faster sampling.
\ calibration1 = 30   # the distance the sensor was calibrated at
\ calibration2 = 1750 # the median value reported back from the sensor at 30 cm
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

: DISTANCE_CHECK
    BEGIN
    DEPTH 2 < WHILE
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
    DEPTH 2 = IF
        SWAP - 154 * 2 / 1 MSEC / .
    ELSE
        STACK_CLEAR
    THEN
;

: DISTANCE_DETECTION
    BEGIN
    DEPTH 2 < WHILE 
		ECHO_PIN IS_ON IF TIME_OUT DELAY THEN TRIGGER
        BEGIN ECHO_PIN IS_ON 0 = WHILE REPEAT NOW
        BEGIN ECHO_PIN IS_ON WHILE REPEAT NOW
    REPEAT
    DEPTH 2 = IF SWAP - 154 * 2 / 1 MSEC / . ELSE STACK_CLEAR THEN ;

: ECHO_HIGH ECHO_PIN IS_ON IF ." HIGH " ELSE ." LOW" THEN ;
: SONAR_CHECK BEGIN 1 SEC DELAY DISTANCE_CHECK BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;