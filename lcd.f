( lcd.f )
: 4BIT_CLEAR F SWAP LSHIFT INVERT AND ;

: SEND_4BIT_MORE   
  0 4BIT_CLEAR DUP
  D OR >I2C 
  9 OR >I2C
;

: SEND_4BIT_LESS  
  4 4BIT_CLEAR 4 LSHIFT DUP
  D OR >I2C 
  9 OR >I2C
;

: >LCD DUP SEND_4BIT_MORE SEND_4BIT_LESS ;

: 4BIT-CONFIG 
  ( FUNCTION SET )
  3C 38 SEND
  3C 38 SEND
  3C 38 SEND

  ( SET INTERFACE TO 4-BIT )
  2C 28 SEND


  ( SET 2 LINE, 5X8 FONT)
  2C 28 SEND
  8C 88 SEND

  ( THE NUMBER OF DISPLAY LINE AND CHARACTER FONT CANNOT BE CHANGED AFTERWARES )
  0C 08 SEND
  8C 88 SEND
  0C 08 SEND
  1C 18 SEND

  ( LCD OFF )
  0C 08 SEND

  ( ENTRY SET MODE: INCREMENT, DISPLAY SHIFT )
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
