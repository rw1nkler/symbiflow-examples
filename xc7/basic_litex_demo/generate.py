#!/usr/bin/env python3

import os
import argparse

from migen import *
from litex.soc.cores.clock import *
from liteeth.phy.mii import LiteEthPHYMII
from litex.soc.cores.led import LedChaser

from litex.boards.platforms import arty
from litex.boards.targets.arty import _CRG
from litex.soc.integration.soc_core import SoCCore
from litex.soc.integration.builder import Builder
from litex.soc.integration.soc_core import soc_core_args, soc_core_argdict
from litex.build.xilinx.vivado import vivado_build_args, vivado_build_argdict

from litedram.modules import MT41K128M16
from litedram.phy import s7ddrphy


class BaseSoC(SoCCore):
    def __init__(self, toolchain="symbiflow", sys_clk_freq=int(100e6),
                 with_ethernet=False, board_variant="a7-35", **kwargs):

        platform = arty.Platform(variant=board_variant, toolchain=toolchain)
        SoCCore.__init__(self, platform, sys_clk_freq,
            ident          = "LiteX SoC on Arty A7",
            ident_version  = True,
            **kwargs)

        self.submodules.crg = _CRG(platform, sys_clk_freq)

        if not self.integrated_main_ram_size:
            self.submodules.ddrphy = s7ddrphy.A7DDRPHY(platform.request("ddram"),
                memtype        = "DDR3",
                nphases        = 4,
                sys_clk_freq   = sys_clk_freq)
            self.add_csr("ddrphy")
            self.add_sdram("sdram",
                phy                     = self.ddrphy,
                module                  = MT41K128M16(sys_clk_freq, "1:4"),
                origin                  = self.mem_map["main_ram"],
                size                    = kwargs.get("max_sdram_size", 0x40000000),
                l2_cache_size           = kwargs.get("l2_size", 8192),
                l2_cache_min_data_width = kwargs.get("min_l2_data_width", 128),
                l2_cache_reverse        = True
            )

        # FIXME: Ethernet addition cause SDRAM to fail
        # if with_ethernet:
        #    self.submodules.ethphy = LiteEthPHYMII(
        #    clock_pads = self.platform.request("eth_clocks"),
        #        pads       = self.platform.request("eth"))
        #    self.add_csr("ethphy")
        #    self.add_ethernet(phy=self.ethphy)

        self.submodules.leds = LedChaser(
            pads         = platform.request_all("user_led"),
            sys_clk_freq = sys_clk_freq)
        self.add_csr("leds")


def main():
    parser = argparse.ArgumentParser(description="LiteX SoC on Arty A7")
    parser.add_argument("--load", action="store_true", help="Load bitstream")
    parser.add_argument("--build", action="store_true", help="Build bitstream")
    parser.add_argument("--toolchain", default="symbiflow", help="Gateware toolchain to use, vivado or symbiflow (default)")
    parser.add_argument("--with-ethernet", action="store_true", help="Enable ethernet support")
    parser.add_argument("--board", default="a7-35", help="Specifies Arty Board version")
    parser.add_argument("--builddir", help="Build directory")

    soc_core_args(parser)
    vivado_build_args(parser)
    args = parser.parse_args()

    if args.board not in ["a7-35", "a7-100"]:
        raise ValueError("Unsupported device variant!")

    soc = BaseSoC(
        toolchain=args.toolchain,
        sys_clk_freq=int(80e6),
        board_variant=args.board,
        **soc_core_argdict(args)
    )

    builder = Builder(soc, output_dir=args.builddir)
    builder_kwargs = vivado_build_argdict(args) if args.toolchain == "vivado" else {}
    builder.build(**builder_kwargs, run=args.build)


if __name__ == "__main__":
    main()
