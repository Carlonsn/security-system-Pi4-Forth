( main.f )
: ALARM_MSG LCD CLEAR 'A 'L 'A 'R 'M 'SPACE 'A 'C 'T 'I 'V 'A 'T 'E 'D ;
: STANDBY_MSG 'S 'T 'A 'N 'D 'SPACE 'B 'Y ;
: STANDBY LCD CLEAR STANDBY_MSG BEGIN 1 SEC DELAY BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;
: TIME_OVER_MSG LCD CLEAR 'T 'I 'M 'E 'SPACE 'O 'V 'E 'R ;

: MAIN
    INIT_LED
    INIT_BUTTON
    INIT_I2C
    INIT_LCD
    INIT_PIN_BUTTONS
    INIT_PIR
    INIT_SONAR

    BEGIN
        STANDBY
        INIT_ATTEMPS
        INIT_COUNTDOWN
        PIN_CHECK CASE
            TRUE OF
                DROP
                ALARM_MSG
                SECURITY_SYSTEM
                ALARM_OFF
            ENDOF
            FALSE OF  
                DROP
                ALERT
            ENDOF
            2 OF  
                DROP
                TIME_OVER_MSG
            ENDOF
        ENDCASE
        1 SEC DELAY
    AGAIN
;
