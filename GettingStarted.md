# Introduction #

My goal is to provide a FPGA based computing environment that can easily be changed on all levels and allows for interactive hardware exploration (i.e. no compile-upload-debug cycle).

# Prerequisites #

If you just want to play with Forth on the FPGA and you have a board that is supported, all you need to do is upload the bitstream file to your FPGA, connect your PC's serial port to the FPGA board using a null modem cable and play around.  Here is a sample session:

```

MaisForth an601
Copyright (c) 2005 HCC Forth-gg
System09 port by Hans Huebner
       16 kB RAM
words
 MS  SEE  DUMP  ;CODE  CODE  DOES>  UNUSED  MARKER  FORGET  WORDLIST 
 ONLY  ;  +LOOP  LOOP  ?DO  DO  REPEAT  ELSE  AGAIN  UNTIL  BEGIN 
 THEN  WHILE  AHEAD  IF  TO  VALUE  VARIABLE  CONSTANT  :NONAME 
 :  POSTPONE  [COMPILE]  [']  IMMEDIATE  RECURSE  CREATE  \  ( 
 [CHAR]  CHAR  '  EVALUATE  THROW  QUIT  >NUMBER  2LITERAL  LITERAL 
 SEARCH-WORDLIST  FIND  REFILL  QUERY  .S  DEPTH  ."  S"  ABORT" 
 .(  ]  [  COMPILE,  PARSE  WORD  MOVE  COMPARE  ABORT  CATCH 
 /STRING  SOURCE  HEX  DECIMAL  ?  .R  U.R  D.R  .  U.  D.  SIGN 
 #>  #S  #  <#  HOLD  ACCEPT  PAGE  TYPE  SPACES  SPACE  CR  EMIT 
 */  */MOD  MOD  /  /MOD  *  FM/MOD  SM/REM  M*  S>D  CS-ROLL 
 CS-PICK  WITHIN  C,  ,  ALLOT  PAD  ROLL  CHARS  CELLS  >BODY 
 CHAR+  CELL+  CMOVE>  CMOVE  FILL  UM/MOD  UM*  M+  D-  D+  DABS 
 DNEGATE  ABS  NEGATE  D2/  D2*  -  +  2/  2*  1-  1+  RSHIFT 
 LSHIFT  INVERT  XOR  OR  AND  <  >  U<  U>  0<>  <>  =  0>  0= 
 0<  MAX  MIN  PICK  NIP  -ROT  ROT  TUCK  SWAP  OVER  DUP  DROP 
 ?DUP  2ROT  2TUCK  2SWAP  2OVER  2NIP  2DUP  2DROP  2R@  R@ 
 2R>  2>R  R>  >R  COUNT  2@  @  C@  +!  2!  !  C!  BL  FALSE 
 TRUE  ORIGIN  STATE  BASE  >IN  HERE  J  I  UNLOOP  LEAVE  KEY 
 KEY?  EMIT?  EXIT  EXECUTE 
 (200)  OK
 ( ) hex  OK
 ( ) B030 constant leds  OK
 ( ) 55 leds c!  OK
 ( ) \ four leds are now lit  OK
 ( ) 0 leds c!  OK
 ( ) \ all leds are off now  OK
 ( ) : up ( -- )  ok
 ( )     1  ok
 ( )     8 0 do  ok
 ( )         dup leds c!  ok
 ( )         2 *  ok
 ( )         1000 ms  ok
 ( )     loop  ok
 ( )     drop ;  OK
 ( )   OK
 ( ) : down ( -- )  ok
 ( )     128  ok
 ( )     8 0 do  ok
 ( )         dup leds c!  ok
 ( )         2 /  ok
 ( )         1000 ms  ok
 ( )     loop  ok
 ( )     drop ;  OK
 ( )   OK
 ( ) : updown ( -- )  ok
 ( )     begin  ok
 ( )         up  ok
 ( )         down  ok
 ( )         key?  ok
 ( )     until  ok
 ( )     key drop ;  OK
 ( ) updown  OK
 ( ) \ what you'll see is a funky light show that does not look quite right because i forgot to type DECIMAL above :)  OK
```
See my [Scratchpad of words](http://code.google.com/p/rekonstrukt/source/browse/trunk/forth/s3esk.f) for the Spartan-3E starter kit for more stuff like this.

# Resynthesizing the hardware #

In order to modify the rekonstrukt hardware, the top level VHDL file must be edited to connect the hardware to System09 and the outside world.  Then, a new bitstream must be generated.  When you checkout rekonstrukt from the Subversion repository, you'll find a ise/ subdirectory that contains the projects files for Xilinx ISE Webpack 10.1.

# Changing Maisforth #

If you want to change the Maisforth ROM, for example to include hardware specific words in the ROM code, you'll have to cross compile Maisforth for System09.  [GForth](http://www.jwdt.com/~paysan/gforth.html) works as cross compiler.  I also had some success with WinForth, but some words did not get compiled with it.  GForth runs fine on Windows as well as Unix/Linux, so I recommend using that.

The maisforth/ subdirectory of the rekonstrukt tree contains a Makefile thatcross compiles Maisforth.  It also contains targets to recreate the ROM VHDL files as well as .MEM files that can be used to update the ROM image without resynthesizing the hardware.

# Compiling the usim 6809 simulator #

In order to test out Forth code on a PC, the usim mc6809 simulator written by Ray Bellis can be used.  The source to the simulator is included in the rekonstrukt/usim/ directory.  It has been tested on FreeBSD/x86, Windows using cygwin and MacOS X.  The virtual hardware that is simulated by usim currently includes only the UART.  usim is written in C++ und rather easy to extend, so it is easy to extend for other hardware connected to the FPGA if required.