TOP_DIR = ../..
include $(TOP_DIR)/tools/Makefile.common

SRC_PERL = $(wildcard scripts/*.pl)
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))

DEPLOY_PERL = $(addprefix $(TARGET)/bin/,$(basename $(notdir $(SRC_PERL))))

SERVER_SPEC = IDServer-API.spec
SERVER_MODULE = IDServerAPI
SERVICE = idserver

all: bin server

what:
	@echo $(BIN_PERL)

server: lib/$(SERVER_MODULE)Server.pm

lib/$(SERVER_MODULE)Server.pm: $(SERVER_SPEC)
	compile_typespec $(SERVER_SPEC) lib

bin: $(BIN_PERL)

$(BIN_DIR)/%: scripts/%.pl 
	$(TOOLS_DIR)/wrap_perl '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@

deploy: deploy-scripts deploy-libs deploy-services

deploy-scripts:
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib bash ; \
	for src in $(SRC_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $$src $$base ; \
		cp $$src $(TARGET)/plbin ; \
		bash $(TOOLS_DIR)/wrap_perl.sh "$(TARGET)/plbin/$$basefile" $(TARGET)/bin/$$base ; \
	done 

deploy-libs:
	rsync -arv lib/. $(TARGET)/lib/.

deploy-services:
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib bash ; \
	bash $(TOOLS_DIR)/wrap_starman.sh "$(TARGET)/lib/$(SERVER_MODULE).psgi" $(TARGET)/services/$(SERVICE)
