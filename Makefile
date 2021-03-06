REBAR = $(shell which rebar3)

EPMD_PROC_NUM = $(shell ps -ef | grep epmd | grep -v "grep")

.PHONY: all check_rebar compile clean distclean dialyzer tests shell edoc

all: check_rebar compile

check_rebar:
ifeq ($(REBAR),)
ifeq ($(wildcard rebar3),)
	curl -O https://s3.amazonaws.com/rebar3/rebar3
	chmod a+x rebar3
	$(eval REBAR=./rebar3)
else
	$(eval REBAR=./rebar3)
endif
endif

compile: check_rebar
	$(REBAR) compile

clean: check_rebar
	rm -rf ebin/* test/*.beam logs log
	$(REBAR) clean

distclean: clean
	$(REBAR) clean --all
	rm -rf _build logs log doc *.dump c_src/*.o priv/*.so *_plt *.crashdump

dialyzer: check_rebar
	$(REBAR) dialyzer

check_epmd:
ifeq ($(EPMD_PROC_NUM),)
	epmd&
	@echo " ---> Started epmd!"
endif

tests: check_rebar check_epmd
	$(REBAR) ct --name ct@127.0.0.1
	$(REBAR) cover
	rm -rf test/*.beam

local_tests: check_rebar check_epmd
	$(REBAR) ct --name ct@127.0.0.1 --suite=test/local_SUITE
	rm -rf test/*.beam

dist_tests: check_rebar check_epmd
	$(REBAR) ct --name ct@127.0.0.1 --suite=test/dist_SUITE
	rm -rf test/*.beam

shell: check_rebar
	$(REBAR) shell

edoc: check_rebar
	$(REBAR) edoc
