require'auto-save'.setup({
  trigger_events = {"InsertLeave", "BufLeave", "FocusLost"},
  --, "ModeChanged" S doesn't work in normal mode
  --{"InsertLeave", "TextChanged"},
})