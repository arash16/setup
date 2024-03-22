source ~/.gdb/pwndbg/gdbinit.py
source ~/.gdb/splitmind/gdbinit.py

python
import splitmind
(splitmind.Mind()
  .tell_splitter(show_titles=True)
  .tell_splitter(set_title="Main")
  .right(display="legend")
  .show("regs", on="legend")
  .below(display="stack", size="60%")
  .below(display="backtrace", size="35%")
  .above(of="main", display="disasm", size="70%", banner="top")
  .show("code", on="disasm", banner="none")
).build(nobanner=True)
end

set context-code-lines 25
set context-source-code-lines 20
set context-sections  "regs args code disasm stack backtrace"
set context-stack-lines 15
set context-clear-screen on
set follow-fork-mode parent
