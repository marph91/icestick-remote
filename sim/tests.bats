#!/usr/bin/env bats

# TODO: Use "-T" as soon as it is released.
#       See also https://github.com/bats-core/bats-core/issues/49.

ROOT="$(pwd)/.."
WORKDIR="build"
STD="08"

@test "analyze_sources" {
    rm -rf "$WORKDIR"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"

    ghdl -i --std="$STD" "$ROOT"/submodules/icestick-uart/hdl/*.vhd
    ghdl -i --std="$STD" "$ROOT"/hdl/ir_encoder/*.vhd
    ghdl -i --std="$STD" "$ROOT"/hdl/ir_sampler/*.vhd
    ghdl -i --std="$STD" "$ROOT"/hdl/*.vhd
    ghdl -m --std="$STD" remote
}

@test "analyze_testbenches" {
    ghdl -i --std="$STD" --workdir="$WORKDIR" "$ROOT"/sim/tb_remote.vhd
    ghdl -m --std="$STD" --workdir="$WORKDIR" -o "$WORKDIR/tb_remote" tb_remote
}

# toplevel smoke tests
@test "remote_without_sampler" {
    ./"$WORKDIR"/tb_remote -gC_WITH_SAMPLER=0
}

@test "remote_with_sampler" {
    ./"$WORKDIR"/tb_remote
}
