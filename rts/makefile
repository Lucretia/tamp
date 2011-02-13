# TODO: Use this until gnatmake can build a lib.
#BOARD	=	pc

ifeq ($(BOARD),pc)
TARGET	=
else
ifeq ($(BOARD),beagle)
TARGET	=	arm-none-eabi-
endif
endif

FLAGS	=	-c -gnat2005 -gnatg -O2 -ffunction-sections -fdata-sections \
		-nostdinc -nostdlib --RTS=./boards/$(BOARD)
#		-I./src/boards/$(BOARD)

LIBNAME	=	libgnat.a

OBJS	=	obj/ada.o \
		obj/a-unccon.o \
		obj/a-uncdea.o \
		obj/gnat.o \
		obj/g-souinf.o \
		obj/s-stoele.o \
		obj/s-atacco.o \
		obj/s-maccod.o \
		obj/system.o
ALIS	=	$(OBJS:.o=.ali)

all: $(LIBNAME)

$(LIBNAME): $(OBJS) $(ALIS)
	$(TARGET)ar -rcs ./boards/$(BOARD)/adalib/$(LIBNAME) $(OBJS)
	cp ./obj/*.ali ./boards/$(BOARD)/adalib

obj/ada.o obj/ada.ali: src/common/ada.ads
	$(TARGET)gcc $(FLAGS) src/common/ada.ads -o obj/ada.o

obj/a-unccon.o obj/a-unccon.ali: src/common/a-unccon.ads
	$(TARGET)gcc $(FLAGS) src/common/a-unccon.ads -o obj/a-unccon.o

obj/a-uncdea.o obj/a-uncdea.ali: src/common/a-uncdea.ads
	$(TARGET)gcc $(FLAGS) src/common/a-uncdea.ads -o obj/a-uncdea.o

obj/gnat.o obj/gnat.ali: src/common/gnat.ads
	$(TARGET)gcc $(FLAGS) src/common/gnat.ads -o obj/gnat.o

obj/g-souinf.o obj/g-souinf.ali: src/common/g-souinf.ads
	$(TARGET)gcc $(FLAGS) src/common/g-souinf.ads -o obj/g-souinf.o

obj/s-stoele.o obj/s-stoele.ali: src/common/s-stoele.ads src/common/s-stoele.adb
	$(TARGET)gcc $(FLAGS) src/common/s-stoele.adb -o obj/s-stoele.o

obj/s-atacco.o obj/s-atacco.ali: src/common/s-atacco.ads src/common/s-atacco.adb
	$(TARGET)gcc $(FLAGS) src/common/s-atacco.adb -o obj/s-atacco.o

obj/s-maccod.o obj/s-maccod.ali: src/common/s-maccod.ads
	$(TARGET)gcc $(FLAGS) src/common/s-maccod.ads -o obj/s-maccod.o

obj/system.o obj/system.ali: src/boards/$(BOARD)/system.ads
	$(TARGET)gcc $(FLAGS) src/boards/$(BOARD)/system.ads -o obj/system.o


.PHONY: clean

clean:
	-rm obj/*
	-rm ./boards/$(BOARD)/adainclude/*
	-rm ./boards/$(BOARD)/adainclude/.symlinks
	-rm ./boards/$(BOARD)/adalib/*
