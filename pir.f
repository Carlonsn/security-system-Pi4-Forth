( Includi prima le librerie )
( gpio.f )
( timer.f )
( led.f )
( event.f )
( utility.f )
( pir.f )
GPIO12 OUTPUT
GPIO12 CONSTANT BUZZER
GPIO27 CONSTANT PIR
PIR GPREN0 ENABLE
PIR CLEAR_EVENT

: BLINK_BUZ 2DUP LED ON BUZZER ON DELAY LED OFF BUZZER OFF DELAY ;
: MOTION_DETECTED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ;
: DELAY_COUNTER 0 ;

: PIR_CALIBRATION
BEGIN 
    PIR IS_ON 0 = IF
        1 SEC DELAY
        YELLOW LED OFF ." Nessun movimento" CR
    ELSE
        YELLOW LED ON ." Pir High" CR
        DELAY_COUNTER
        BEGIN
            PIR IS_ON WHILE
            1 SEC DELAY 1+ DUP . ." sec "
        REPEAT
		CR
    THEN 
        1 SEC DELAY
        YELLOW LED OFF ." Pir Low" CR
        DEPTH 0> IF
            ." Durata totale: " . ." secondi" CR 5 SEC DELAY
        THEN
BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;

: MOTION_DETECTION
BEGIN 
    PIR DUP MOTION_DETECTED IF
         CLEAR_EVENT ." Movimento rilevato" CR
         BEGIN PIR IS_ON WHILE 0.5SEC RED BLINK_BUZ REPEAT
    ELSE 
        RED LED OFF CLEAR_EVENT ." Nessun movimento" CR 5 SEC DELAY 
    THEN
BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;
