# Change it for your name of app
APPNAME := submarine.aqx

# Recursive wildcard macros 
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC := $(call rwildcard,src,*.asm *.inc)
INCLUDES := $(call rwildcard,include,*.asm *.inc)
ASSETS := $(call rwildcard,assets,*.*)
MAIN_SOURCE := main.asm

ASM := sjasmplus
ASMFLAGS := --raw=../$(APPNAME)

all: $(APPNAME)

$(APPNAME): $(SRC) $(INCLUDES) $(ASSETS)
		(cd src && $(ASM) $(MAIN_SOURCE) $(ASMFLAGS))


clean:
		rm -rf $(APPNAME) $(ASMOUT_DIR)