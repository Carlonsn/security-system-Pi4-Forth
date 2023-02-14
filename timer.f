RPI4 3000 + CONSTANT TIMER 
TIMER       CONSTANT TIMER_CONTROL_STATUS
TIMER  04 + CONSTANT TIMER_COUNTER_LOW

: NOW TIMER_COUNTER_LOW @ ;
: DELAY NOW + BEGIN DUP NOW - THEN 0 <= UNTIL DROP ;
: MSEC 3E8 * ; ( 1000 * conversione da milli a micro )
: 0.5SEC 1F4 MSEC ;
: SEC 3E8 MSEC * ; ( 1000 * conversione da secondi a milli )
