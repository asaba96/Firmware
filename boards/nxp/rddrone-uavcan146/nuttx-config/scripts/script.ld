/****************************************************************************
 * boards/arm/s32k1xx/rddrone-uavcan146/scripts/flash.ld
 *
 *   Copyright (C) 2019 Gregory Nutt. All rights reserved.
 *   Author: Gregory Nutt <gnutt@nuttx.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name NuttX nor the names of its contributors may be
 *    used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

/* The S32K146 has 1Mb of FLASH beginning at address 0x0000:0000 and
 * 124Kb of SRAM beginning at address 0x1fff:0000 (plus 4Kb of FlexRAM)
 *
 * The on-chip RAM is split in two regions: SRAM_L and SRAM_U. The RAM is
 * implemented such that the SRAM_L and SRAM_U ranges form a contiguous
 * block in the memory map
 *
 *   SRAM_L 1fff0000 - 1fffffff 64Kb
 *   SRAM_U 20000000 - 2000efff 60Kb
 */

MEMORY
{
  vflash (rx) : ORIGIN = 0x00000000, LENGTH = 1K
  pflash (rx) : ORIGIN = 0x00000400, LENGTH = 16
  dflash (rx) : ORIGIN = 0x00000410, LENGTH = 1023K-16
  sram  (rwx) : ORIGIN = 0x1fff0000, LENGTH = 124K
}

OUTPUT_ARCH(arm)
EXTERN(_vectors)
EXTERN(g_flashcfg)
ENTRY(_stext)

SECTIONS
{
  .vectors :
  {
    _stext = ABSOLUTE(.);
    *(.vectors)
  } > vflash

  .flashcfg :
  {
    *(.flashcfg)
  } > pflash

  .text :
  {
    *(.text .text.*)
    *(.fixup)
    *(.gnu.warning)
    *(.rodata .rodata.*)
    *(.gnu.linkonce.t.*)
    *(.glue_7)
    *(.glue_7t)
    *(.got)
    *(.gcc_except_table)
    *(.gnu.linkonce.r.*)
    _etext = ABSOLUTE(.);

    /*
     * This is a hack to make the newlib libm __errno() call
     * use the NuttX get_errno_ptr() function.
     */
    __errno = get_errno_ptr;
  } > dflash

  .init_section :
  {
    _sinit = ABSOLUTE(.);
    *(.init_array .init_array.*)
    _einit = ABSOLUTE(.);
  } > dflash

  /*
   * Construction data for parameters.
   */
  __param ALIGN(4): {
    __param_start = ABSOLUTE(.);
    KEEP(*(__param*))
    __param_end = ABSOLUTE(.);
  } > dflash

  .ARM.extab :
  {
    *(.ARM.extab*)
  } >dflash

  .ARM.exidx :
  {
    __exidx_start = ABSOLUTE(.);
    *(.ARM.exidx*)
    __exidx_end = ABSOLUTE(.);
  } >dflash

  .data :
  {
    _sdata = ABSOLUTE(.);
    *(.data .data.*)
    *(.gnu.linkonce.d.*)
    CONSTRUCTORS
    . = ALIGN(4);
    _edata = ABSOLUTE(.);
  } > sram AT > dflash

  _eronly = LOADADDR(.data);

  .ramfunc ALIGN(4):
  {
    _sramfuncs = ABSOLUTE(.);
    *(.ramfunc  .ramfunc.*)
    _eramfuncs = ABSOLUTE(.);
  } > sram AT > dflash

  _framfuncs = LOADADDR(.ramfunc);

  .bss :
  {
    _sbss = ABSOLUTE(.);
    *(.bss .bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = ABSOLUTE(.);
  } > sram

  /* Stabs debugging sections. */

  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .stab.excl 0 : { *(.stab.excl) }
  .stab.exclstr 0 : { *(.stab.exclstr) }
  .stab.index 0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment 0 : { *(.comment) }
  .debug_abbrev 0 : { *(.debug_abbrev) }
  .debug_info 0 : { *(.debug_info) }
  .debug_line 0 : { *(.debug_line) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  .debug_aranges 0 : { *(.debug_aranges) }
}
