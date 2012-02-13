TOP_DIR = ../..
include $(TOP_DIR)/tools/Makefile.common

SRC_PERL = $(wildcard scripts/*.pl)
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))

SERVER_SPEC = IDServer-API.spec
SERVER_MODULE = IDServerAPI

all: bin server

what:
	@echo $(BIN_PERL)

server: lib/$(SERVER_MODULE)Server.pm

lib/$(SERVER_MODULE)Server.pm: $(SERVER_SPEC)
	compile_typespec $(SERVER_SPEC) lib

bin: $(BIN_PERL)

$(BIN_DIR)/%: scripts/%.pl 
	$(TOOLS_DIR)/wrap_perl '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@
