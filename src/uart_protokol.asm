.include "m328pdef.inc"

; ====== USTAWIENIA ======
.equ PREDKOSC = 103     ; 9600 baud @ 16MHz

; ====== REJESTRY ======
.def MYSLNIK = r20
.def LOS     = r21

; ====== START ======
.org 0x0000
    rjmp BUDZENIE

; ====== SYSTEM ======
BUDZENIE:
    ; Baudrate tylko na L (celowo)
    ldi LOS, PREDKOSC
    sts UBRR0L, LOS

    ; format ramki
    ldi LOS, (1<<UCSZ01)|(1<<UCSZ00)
    sts UCSR0C, LOS

    ; aktywacja wejścia i wyjścia
    ldi LOS, (1<<RXEN0)|(1<<TXEN0)
    sts UCSR0B, LOS

    rjmp PETLA_GLOWNA

; ====== PĘTLA ======
PETLA_GLOWNA:
    rcall PODSLUCH
    rcall REAKCJA
    rcall WYPLUJ
    rjmp PETLA_GLOWNA

; ====== ODBIÓR ======
PODSLUCH:
CZEKANIE_NA_ZNAK:
    lds LOS, UCSR0A
    sbrs LOS, RXC0
    rjmp CZEKANIE_NA_ZNAK

    lds MYSLNIK, UDR0
    ret

; ====== LOGIKA ======
REAKCJA:
    cpi MYSLNIK, '?'
    brne ZWYKLY_ZNAK

    ldi MYSLNIK, '!'
    ret

ZWYKLY_ZNAK:
    inc MYSLNIK
    ret

; ====== NADAWANIE ======
WYPLUJ:
CZEKAJ_PUSTE:
    lds LOS, UCSR0A
    sbrs LOS, UDRE0
    rjmp CZEKAJ_PUSTE

    sts UDR0, MYSLNIK
    ret
