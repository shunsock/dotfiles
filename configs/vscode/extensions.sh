#!/bin/bash
extensions=(
  catppuccin.catppuccin-vsc
  eamodio.gitlens
  github.copilot
  github.copilot-chat
  jeff-tian.markdown-katex
  oderwat.indent-rainbow
  tal7aouy.rainbow-bracket
  vscodevim.vim
)

for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force
done
