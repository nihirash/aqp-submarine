# Change it for your name of app
APPNAME := submarine.aqx

# Recursive wildcard macros 
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC := $(call rwildcard,src,*.asm *.inc)
INCLUDES := $(call rwildcard,include,*.asm *.inc)
MAIN_SOURCE := src/main.asm

ASM := zmac
ASMFLAGS := --zmac --oo cim,lst -I include/ -n
ASMOUT_DIR := zout/
ASMOUT := $(ASMOUT_DIR)main.cim

all: $(APPNAME)

$(ASMOUT): $(SRC) $(INCLUDES)
		$(ASM) $(ASMFLAGS) $(MAIN_SOURCE)

$(APPNAME): $(ASMOUT)
		cp $(ASMOUT) $(APPNAME)

clean:
		rm -rf $(APPNAME) $(ASMOUT_DIR)