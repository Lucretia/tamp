RTS_DIR	=	/home/laguest/src/mine/tamp/rts/boards/stm32f4

all: blink

blink: obj/startup_stm32f4xx.o src/blink.adb
	arm-none-eabi-gnatmake --RTS=$(RTS_DIR) -Pblink.gpr

obj/startup_stm32f4xx.o: src/startup_stm32f4xx.s
	arm-none-eabi-as src/startup_stm32f4xx.s -o obj/startup_stm32f4xx.o

.PHONY: clean

clean:
	-rm obj/*.o *~ blink
