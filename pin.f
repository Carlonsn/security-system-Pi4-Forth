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

: BUTTONS_RESET BUTTON5 BUTTON6 OR BUTTON7 OR BUTTON8 OR BREAK_BUTTON OR CLEAR_EVENT ;
: SEQUENCE 8 = -ROT 6 = -ROT 5 = -ROT 2SWAP SWAP 7 = ; ( 7 5 6 8 )
: RESET STACK_CLEAR
        GPEDS0 @ 0<> IF
        BUTTONS_RESET THEN
        LCD CLEAR CURSOR !BLINKS ;

: PIN_MSG DOWN CURSOR 'P 'I 'N ': CURSOR BLINKS ;
: PIN_ERR LCD CLEAR 'W 'R 'O 'N 'G 'SPACE 'P 'I 'N  ;
: PIN_OK LCD CLEAR 'C 'O 'R 'R 'E 'C 'T 'SPACE 'P 'I 'N ;
: ATTEMPS_LEFT_MSG LCD CLEAR 'A 'T 'T 'E 'M 'P 'S 'SPACE 'L 'E 'F 'T ': 'SPACE ;

VARIABLE ATTEMPS
: INIT_ATTEMPS 3 ATTEMPS ! ;
: TERMINATED @ 0 = ;
: DECREMENT DUP @ 1- SWAP ! ;
VARIABLE PIN_COUNTDOWN
: INIT_COUNTDOWN A 3 * SEC NOW + PIN_COUNTDOWN ! ;
: TIME_OVER PIN_COUNTDOWN @ NOW - 0 <= ;
: PIN_CHECK
    BEGIN
        1 SEC DELAY
        RESET  
        ." DIGITA IL PIN E PREMI INVIO "
        ATTEMPS_LEFT_MSG ATTEMPS @ N_PRINT
        PIN_MSG
        BEGIN
            
            BUTTON7 IS_CLICKED IF
            ." 7 " '7 BUTTON7 N_GPIO BUTTON7 CLEAR_EVENT 1 SEC DELAY THEN

            BUTTON5 IS_CLICKED IF
            ." 5 " '5 BUTTON5 N_GPIO BUTTON5 CLEAR_EVENT 1 SEC DELAY THEN 

            BUTTON6 IS_CLICKED IF
            ." 6 " '6 BUTTON6 N_GPIO BUTTON6 CLEAR_EVENT 1 SEC DELAY THEN

            BUTTON8 IS_CLICKED IF
            ." 8 " '8 BUTTON8 N_GPIO BUTTON8 CLEAR_EVENT 1 SEC DELAY THEN

        BREAK_BUTTON IS_CLICKED ATTEMPS TERMINATED OR TIME_OVER OR 
        UNTIL
        BREAK_BUTTON IS_CLICKED IF
            
            0.5SEC YELLOW BLINK
            DEPTH 4 <> 
            IF STACK_CLEAR FALSE
                ." ERRATA " CR PIN_ERR 0.5SEC RED BLINK ATTEMPS DECREMENT BREAK_BUTTON CLEAR_EVENT
            ELSE
                SEQUENCE AND AND AND
                DUP FALSE = IF 
                ." ERRATA " CR PIN_ERR 0.5SEC RED BLINK ATTEMPS DECREMENT BREAK_BUTTON CLEAR_EVENT
                THEN 
            THEN
        THEN
    TRUE = ATTEMPS TERMINATED OR TIME_OVER OR
    UNTIL
    BREAK_BUTTON IS_CLICKED IF    
    ." CORRETTA " CR PIN_OK 1 SEC GREEN BLINK RESET
    TRUE 
    ELSE
        ATTEMPS TERMINATED IF FALSE BREAK_BUTTON CLEAR_EVENT
        ELSE
            TIME_OVER IF
                ." TEMPO SCADUTO "
                BREAK_BUTTON CLEAR_EVENT
                2
            THEN
        THEN
    THEN
;

