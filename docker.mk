# Use Docker images
DOCKER=docker
#DOCKER=podman
#
PWD = $(shell pwd)
DOCKERARGS = run --rm -v $(PWD)/..:/src \
	-w /src/$(notdir $(PWD))

GHDL         = $(DOCKER) $(DOCKERARGS) hdlc/ghdl ghdl
YOSYS_PLUGIN = -m ghdl
YOSYS        = $(DOCKER) $(DOCKERARGS) hdlc/ghdl:yosys yosys
NEXTPNR      = $(DOCKER) $(DOCKERARGS) hdlc/nextpnr:ice40 nextpnr-ice40
ICEPACK      = $(DOCKER) $(DOCKERARGS) hdlc/icestorm icepack
