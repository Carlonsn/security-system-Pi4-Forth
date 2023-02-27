# security-system-Pi4-Forth

# Descrizione libreria implementata per la gestione dei GPIO di Raspberry Pi 4 Model B

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
Il codice seguente è stack-oriented, cioè si utilizzeranno diverse word per la manipolazione dello stack in modo da definire word utili per la realizzazione di un livello di astrazione superiore.
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

N.B. L'utente ha la possibilità di entendere la libreria aggiungendo le restanti function definendo le mask corrispondenti

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

Per sapere se un GPIO in quel istante è in HIGH cioè è percorso dalla corrente si definisce la seguente word:

: IS_ON GPLEV0 @ AND 0 = IF 0 ELSE 1 THEN ;


