#!/bin/bash

# Color Definitions for SketchyBar
# These colors are used by various plugins

export BLACK=0xff181926
export WHITE=0xffffffff
export RED=0xffed8796
export GREEN=0xffa6da95
export BLUE=0xff8aadf4
export YELLOW=0xffeed49f
export ORANGE=0xfff5a97f
export MAGENTA=0xffc6a0f6
export GREY=0xff939ab7
export TRANSPARENT=0x00000000

# Bar and Item Colors (Updated for island style with 90% opacity)
export BAR_COLOR=0xe6363a4f           # 90% opacity bar (0xe6 = ~230/255 ≈ 90%)
export ITEM_BG_COLOR=0x00000000       # Transparent (items use group background)
export ACCENT_COLOR=$BLUE

# Group backgrounds (lighter since bar is now opaque)
export GROUP_BG_COLOR=0x33363a4f      # 20% opacity for grouped items
export GROUP_BORDER_COLOR=0x99ced4da  # 60% opacity border for better definition
export ACTIVE_ITEM_BG=0xaa8aadf4      # ~67% opacity blue for active items
