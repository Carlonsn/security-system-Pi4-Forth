# security-system-Pi4-Forth

# Introduzione
Lo scopo del progetto è di creare un sistema di sicurezza installabile in una residenza domestica per il controllo di eventuali intrusioni.
Tramite l'utilizzo di due sensori, il sistema rileva il movimento dell'intruso e ne calcola la distanza. Un segnalatore acustico avviserà il proprietario non appena l'intruso sarà nelle prossimità del sensore e nel caso si avvicini troppo, farà scattare l'allarme.
Inoltre il sistema è dotato di un pannello di controllo grazie al quale il proprietario può attivare il sistema di sicurezza tramite un pin segreto e disattivare l'allarme in caso di intrusioni rilevate.

# Componenti Hardware 

•	N.1 Raspberry Pi 4 Model B

•	N.1 Breadboard

•	N.1 LCD 16x02

•	N.1 Modulo I2C con chip PCF8574AT

•	N.1 Buzzer attivo

•	N.3 LED (ROSSO, VERDE, GIALLO)

•	N.1 Pulsante piccolo

•	N.4 Pulsanti grandi (2x ROSSO, 2x BLUE)

•	N.3 Resistenze da 220Ω

•	N.1 USB-Serial CH340 (Uart Serial)

•	N.1 HY-SRF05 Sensore di distanza ad ultrasuoni

•	N.1 PIR HC-SR501 Sensore infrarosso passivo

•	Jumper e ponticelli per i collegamenti


# Circuito
![photo_2023-02-27_18-58-20](https://user-images.githubusercontent.com/74939222/221645527-e554197d-b09d-4666-b268-ed47c611ae11.jpg)
![photo_2023-02-27_18-55-48](https://user-images.githubusercontent.com/74939222/221645573-7e1368a9-8908-4797-b3ec-571af9a11c17.jpg)


# Descrizione libreria in FORTH per la gestione di dispositivi input/output 

Ci sono 58 linee GPIO (General-Purpose Input/Output) suddivise in tre banchi. Il banco 0 contiene i GPIO da 0 a 27, il banco 1 contiene GPIO da 28 a 45 e il banco 2 contiene GPIO da 46 a 57. Tutti i pin GPIO hanno almeno due funzioni alternative all'interno di BCM2711.

Per iniziare è necessario settare la base dell'interprete in esadecimale con la word

HEX

Gli indirizzi dei registri del RPI4 sono in esadecimale ed è possibile reperirli nella documentazione BCM2711 ARM Peripheral

Si definisce come costante il valore esadecimale corrispondente all'indirizzo per il RPI4

FE000000 CONSTANT RPI4

da questo momento è possibile definire qualsiasi altro registro aggiungendo a quest'ultimo il valore del registro desiderato.

Si definisce come costante l'indirizzo di base del registro GPIO

RPI4 200000 + CONSTANT GPIO_ADDR

General-Purpose Input/Output (GPIO) ha i seguenti registri. Si presuppone che tutti gli accessi siano a 32 bit.
I primi registri che serviranno per la gestione dei GPIO sono i GPFSEL.

I registri di selezione funzione sono utilizzati per definire il funzionamento dei pin I/O generici.

GPIO_ADDR      CONSTANT GPFSEL0

GPIO_ADDR  4 + CONSTANT GPFSEL1

GPIO_ADDR  8 + CONSTANT GPFSEL2

N.B. In questa libreria verranno gestiti solo i GPIO appartenenti al banco 0, cioè quelli accessibili dall'utente tramite i pin del RPI4 come mostrati nel sito https://pinout.xyz/ . Ciononostante l'utente ha la possibilità di estendere autonomamente la libreria aggiungendo i registri per la gestione dei restanti banchi.


# Funzionalità implementate per la function selection

In questa sezione si farà uso delle word definite nel seguente link
https://github.com/organix/pijFORTHos/blob/master/doc/forth.md#built-in-forth-words 

Il codice seguente è stack-oriented, cioè si utilizzeranno diverse word per la manipolazione dello stack in modo da definire word utili per la realizzazione di un livello di astrazione superiore efficiente dal punto di vista delle prestazioni evitando quindi le allocazioni in memoria.
Nello specifico le word utilizzate sono:

Stack Manipulation
DUP DROP 2DUP SWAP ROT

Logical and Bitwise Operations
AND OR INVERT LSHIFT RSHIFT

Arithmetic Operations MOD + - * / 1+ 2+

: 1BIT_SET 1 SWAP LSHIFT ; ( n -- 1<<n  es. 3 1BIT_SET -- 0bx1000)

<img width="240" alt="image" src="https://user-images.githubusercontent.com/74939222/221558739-e0e59b38-405d-4da9-a840-0c3813faf994.png">

: GPIO 1BIT_SET ; ( per migliorare la leggibilità del codice )

: N_GPIO 0 SWAP BEGIN DUP 2 MOD 0 = IF 1 RSHIFT SWAP 1+ SWAP ELSE THEN DUP 2 = UNTIL DROP 1+ ; ( n -- n calcola n GPIO a partire dal bit significativo )


<img width="273" alt="image" src="https://user-images.githubusercontent.com/74939222/221565364-d26266cd-daec-4b97-9597-6c2a211a8c38.png">

: 2_LSHIFT A MOD 2 * ; ( n -- 2*q dove q = resto della divisione per 10 0xA )

: 3_LSHIFT A MOD 3 * ; ( n -- 3*q dove q = resto della divisione per 10 0xA )

<img width="266" alt="image" src="https://user-images.githubusercontent.com/74939222/221560372-4ac5afdf-8e9b-4531-96fa-67351a46bec7.png">


: MASK2 2_LSHIFT 3 SWAP LSHIFT INVERT ; ( n -- n maschera da 2 bit ottenuta effettuando uno shift a sinistra di n di 3 )

: MASK3 3_LSHIFT 7 SWAP LSHIFT INVERT ; ( n -- n maschera da 3 bit ottenuta effettuando uno shift a sinistra di n di 7 )

<img width="506" alt="image" src="https://user-images.githubusercontent.com/74939222/221561431-f514e089-e8ed-4f95-83ec-96a948236f02.png">

: OUT 3_LSHIFT 1BIT_SET ;         ( GPFSEL in output - 001 )

: ALT0_FUN 3_LSHIFT 2+ 1BIT_SET ; ( GPFSEL in alt0   - 100 )

: ALT5_FUN 3_LSHIFT 1+ 1BIT_SET ; ( GPFSEL in alt5   - 010 )

N.B. L'utente ha la possibilità di estendere la libreria aggiungendo le restanti alternative function definendo le mask corrispondenti.

<img width="285" alt="image" src="https://user-images.githubusercontent.com/74939222/221562811-1422c824-fbd3-4daa-94e4-d816bdda4b21.png">

: FSEL A / 4 * GPFSEL0 + ; ( restituisce il registro GPFSEL corrispondente al n GPIO calcolando l'offset = n/10 * 4)

<img width="334" alt="image" src="https://user-images.githubusercontent.com/74939222/221564363-fbfeac78-6579-444a-a2bb-a5edb388f81d.png">


: FUNCTION FSEL 2DUP SWAP MASK3 SWAP @ AND ROT ; ( per migliorare la leggibilità del codice )

Le seguenti word richiamano le word precedentemente definite e effettuano lo store ( ! ) del valore ottenuto all'interno del registro GPFSELn in modo da settare la function desiderata.

: INPUT N_GPIO FUNCTION DROP SWAP ! ;

: OUTPUT N_GPIO FUNCTION OUT OR SWAP ! ;

: ALT0 N_GPIO FUNCTION ALT0_FUN OR SWAP ! ;

: ALT5 N_GPIO FUNCTION ALT5_FUN OR SWAP ! ;

# Funzionalità implementate per la gestione dei LED

I leds sono tra i più semplici dispositivi di output e grazie ad essi è possibile mettere in pratica la function selection per abilitare il GPIO in uscita.
I registri che permettono di definire il funzionamento in output di un GPIO sono GPSETn e GPCLRn.

GPSETn
I registri di set dell'output vengono utilizzati per impostare un pin GPIO. Il campo SETn definisce il rispettivo pin GPIO da impostare. Se il pin viene definito in output, il bit verrà impostato in base all'ultima operazione di set/clear.

GPIO_ADDR 1C + CONSTANT GPSET0

GPCLRn
I registri di cancellazione dell'output vengono utilizzati per cancellare un pin GPIO. Il campo CLRn definisce il rispettivo pin GPIO da cancellare. Se il pin viene definito in output, il bit verrà impostato in base all'ultima operazione di set/clear.

GPIO_ADDR 28 + CONSTANT GPCLR0

Tramite i registri appena descritti, è possibile ad esempio gestire il funzionamento di un led definendo word e constanti nel seguente modo:
```
GPIO13 OUTPUT ( si setta il GPIO13 in output )

: LED GPSET0 GPCLR0 ; 
: ON DROP ! ;
: OFF NIP ! ;

GPIO13 LED ON
GPIO13 LED OFF
```
per una migliore leggibilità e scalabilità del codice si definisce la costante GPIO13 CONSTANT RED e quindi il comando finale sarà
```
RED LED ON
RED LED OFF
```
in questo modo è possibile aggiungere quanti led si vuole e manipolare il loro funzionamento in base al colore.

GPLEVn
I registri livello restituiscono il valore effettivo (HIGH o LOW) della corrente del pin. Il campo LEVn fornisce il valore del corrispondente GPIO.

GPIO_ADDR 34 + CONSTANT GPLEV0

N.B. Il registro GPLEV0 in RPI4 è di sola lettura quindi è possibile solo prelevare ( @ ) il valore del registro e non modificarlo.
Per sapere se un GPIO in quel istante è in HIGH cioè è percorso da corrente si definisce la seguente word:

: IS_ON GPLEV0 @ AND 0 = IF 0 ELSE 1 THEN ;

# Funzionalità implementate per la gestione degli eventi

I registri di stato di rilevamento degli eventi vengono utilizzati per registrare eventi di livello e di edge sui GPIO. Il bit rilevante nei
Event Detect Status Registers viene impostato ogni volta che: 1) viene rilevato un fronte che corrisponde al tipo di fronte programmato
i registri di abilitazione rilevamento fronte di salita/discesa, oppure 2) viene rilevato un livello che corrisponde al tipo di livello programmato
i registri di abilitazione rilevamento livello alto/basso. Il bit viene azzerato scrivendo un "1" nel bit relativo. I registri di abilitazione del rilevamento 
si suddividono in: Synchronous e Asynchronous.

GPIO_ADDR 40 + CONSTANT GPEDS0

GPIO_ADDR 4C + CONSTANT GPREN0

GPIO_ADDR 58 + CONSTANT GPFEN0

GPIO_ADDR 7C + CONSTANT GPAREN0

GPIO_ADDR 88 + CONSTANT GPAFEN0

Per abilitare o disabilitare un GPIO al rilevamento di eventi si definiscono le seguenti word:

: ENABLE TUCK @ OR SWAP ! ; ( GPIOn REGISTER ENABLE -- abilita il GPIO n al rilevamento descritto dal registro )

: DISABLE SWAP INVERT OVER @ AND SWAP ! ;

Invece per resettare il registro degli eventi per uno specifico GPIO si definisce la word

: CLEAR_EVENT GPEDS0 ENABLE ; ( GPIOn CLEAR_EVENT )

# Applicazione della gestione degli eventi: i Buttons

Tra i più comuni dispotivi di input è presente il pulsante (BUTTON). Per il suo corretto funzionamento bisogna settare il GPIO in input ( impostazione di default ), abilitare il GPIO al rilevamento di fronti di salita /discesa, e abilitare il pull-up.

Per abilitare il pull-up di un GPIO si definiscono il registro e le word seguenti:

GPIO_ADDR E4 + CONSTANT GPIO_PUP_PDN_0

: PULL_UP N_GPIO GPIO_PUP_PDN_0 2DUP SWAP MASK2 SWAP @ AND ROT 1BIT_SET OR SWAP ! ;

: PULL_DOWN N_GPIO GPIO_PUP_PDN_0 2DUP SWAP MASK2 SWAP @ AND ROT 1+ 1BIT_SET OR SWAP ! ;

Tramite le funzionalità finora descritte, è possibile ad esempio gestire il funzionamento di un button nel seguente modo:
```
GPIO9 INPUT
GPIO9 PULL_UP
GPIO9 CONSTANT BUTTON
BUTTON GPREN0 ENABLE
BUTTON CLEAR_EVENT
: IS_CLICKED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ;
: IS_PRESSED GPLEV0 @ AND 0 = IF 1 ELSE 0 THEN ;

BUTTON IS_CLICKED
BUTTON IS_PRESSED
```
# Timer 
Le seguenti word sono state definite per poter utilizzare le funzionalità del timer di sistema. 

RPI4 3000 + CONSTANT TIMER  ( Registro base del timer )

TIMER       CONSTANT TIMER_CONTROL_STATUS ( Registro di controllo / stato del System Timer )

TIMER  04 + CONSTANT TIMER_COUNTER_LOW ( Registro contenente i 32 bit inferiori del System Timer Counter )

: NOW TIMER_COUNTER_LOW @ ; ( restituisce il valore in microsecondi dall’avvio del sistema )

: DELAY NOW + BEGIN DUP NOW - THEN 0 <= UNTIL DROP ; ( delay di un tempo pari ad n microsecondi utilizzando un busy wait )

: MSEC 3E8 * ; ( 1000 * conversione da millisecondi a microsecondi )

: 0.5SEC 1F4 MSEC ; 

: SEC 3E8 MSEC * ; ( 1000 * conversione da secondi a millisecondi )


# Sensori 

In questa sezione saranno descritte le word e le costanti per il funzionamento di due sensori:

PIR ( per maggiori informazioni http://win.adrirobot.it/sensori/pir_sensor/pir_sensor_hc-sr501_arduino.htm )
SONAR ( per maggiori informazioni http://rasathus.blogspot.com/2012/09/ultra-cheap-ultrasonics-with-hy-srf05.html )

# PIR HC-SR501 Sensore infrarosso passivo

Per il funzionamento del sensore PIR, bisogna settare il GPIO in input e abilitare il rilevamento dei fronti di salita 
```
GPIO27 INPUT
GPIO27 GPREN0 ENABLE
GPIO27 CLEAR_EVENT
```
Si definisco le seguenti word per l'utilizzo del sensore

: IS_HIGH IS_ON ; ( restituisce 0 se il segnale è LOW - 1 se il segnale HIGH )

: MOTION_DETECTED GPEDS0 @ AND 0 = IF 0 ELSE 1 THEN ; ( restituisce 0 nessun movimento rilevato - 1 movimento rilevato )

```
GPIO27 CONSTANT PIR
PIR IS_HIGH
PIR MOTION_DETECTED
```
Tramite le word sopra definite si definiscono 
: PIR_CALIBRATION ( permette all'utente di regolare il tempo di stato HIGH del sensore stampando a video i secondi totali )

: MOTION_DETECTION ( appena il sensore individua un movimento, accende il led )

# HY-SRF05 Sensore di distanza ad ultrasuoni
Per il funzionamento del sensore Sonar, bisogna settare un GPIO in output, uno in input e abilitare il rilevamento dei fronti di salita e di discesa
```
GPIO4 OUTPUT
GPIO17 INPUT
GPIO17 GPAREN0 ENABLE
GPIO17 GPAFEN0 ENABLE ;
```
Si definisco le seguenti word e costanti per l'utilizzo del sensore

```
GPIO4 CONSTANT TRIGGER_PIN
GPIO17 CONSTANT ECHO_PIN

: TIME_OUT 5 A * MSEC DELAY ;
: SEND_TIME A MSEC DELAY ;
: TRIGGER TRIGGER_PIN HIGH SEND_TIME TRIGGER_PIN LOW ;
```
Tramite le word sopra definite si definiscono

: TRIGGER_ECHO_CHECK ( stampa a video il passaggio da stato LOW a stato HIGH di ECHO_PIN e il tempo intercorso )

: DISTANCE_DETECTION ( stampa a video la distanza rilevata )

# Pannello di controllo
```
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

```
# Security system

```
: LEDS_OFF RED LED OFF YELLOW LED OFF GREEN LED OFF BUZZER LOW ;
: ALARM_OFF LCD CLEAR 'A 'L 'A 'R 'M 'SPACE 'O 'F 'F ;
: ALERT BEGIN 100 MSEC RED BLINK_BUZ BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT BUZZER LOW RED LED OFF ALARM_OFF QUIT ;

: DISTANCE_LED_DETECTION
 
: MOVE_MSG LCD CLEAR 'M 'O 'V 'E 'SPACE 'D 'E 'T 'E 'C 'T 'E 'D ;
: SECURITY_SYSTEM
	BEGIN 
		PIR DUP MOTION_DETECTED IF CLEAR_EVENT ." Movimento rilevato" CR MOVE_MSG 
			BEGIN PIR IS_HIGH WHILE DISTANCE_LED_DETECTION REPEAT
		ELSE LEDS_OFF CLEAR_EVENT ." Nessun movimento" CR 1 SEC DELAY THEN
	BREAK_BUTTON IS_CLICKED UNTIL BREAK_BUTTON CLEAR_EVENT ;
```
# Main
