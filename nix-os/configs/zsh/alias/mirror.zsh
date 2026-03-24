# Screen Mirroring for Sway (Wayland)
alias mirror='wl-mirror "$(swaymsg -t get_outputs --raw | jq -r ".[0].name")" & sleep 0.5 && swaymsg "[app_id=at.yrlf.wl_mirror] move to output $(swaymsg -t get_outputs --raw | jq -r ".[1].name"), fullscreen enable"'
