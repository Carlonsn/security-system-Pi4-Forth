( Includi prima le librerie )
( utility.f )
( gpio.f )
( timer.f )
( led.f )
( event.f )
( pir.f )
: INIT_PIR
    GPIO12 OUTPUT GPIO27 INPUT
    GPIO27 GPREN0 ENABLE
    GPIO27 CLEAR_EVENT ;
GPIO12 CONSTANT BUZZER
GPIO27 CONSTANT PIR

: IS_HIGH IS_ON ;
: BLINK_BUZ 2DUP LED ON BUZZER ON DELAY LED OFF BUZZER OFF DELAY ;
: MOTION_DETECTED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ;
: DELAY_COUNTER 0 ;

: PIR_CALIBRATION
    BEGIN 
        PIR IS_HIGH 0 = IF
            1 SEC DELAY
            YELLOW LED OFF ." Nessun movimento" CR
        ELSE
            YELLOW LED ON ." Pir High" CR
            DELAY_COUNTER
            BEGIN
                PIR IS_HIGH WHILE
                1 SEC DELAY 1+ DUP . ." sec " CR
            REPEAT
            CR
        THEN 
            1 SEC DELAY
            YELLOW LED OFF ." Pir Low" CR
            DEPTH 0> IF
                ." Durata totale: " . ." secondi" CR 1 SEC DELAY
            THEN
    BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: MOTION_DETECTION
    BEGIN 
        PIR DUP MOTION_DETECTED IF
            CLEAR_EVENT ." Movimento rilevato" CR
            BEGIN 
                PIR IS_HIGH WHILE 
                    0.5SEC RED BLINK_BUZ 
            REPEAT
        ELSE 
            RED LED OFF CLEAR_EVENT ." Nessun movimento" CR 1 SEC DELAY
        THEN
    BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;
