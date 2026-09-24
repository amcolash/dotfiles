from typing import List
from kittens.tui.handler import result_handler
from kitty.boss import Boss

def main(args: List[str]) -> str:
    return ""

@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss: Boss) -> None:
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    # Inspect the foreground processes running in the window
    fg_procs = window.child.foreground_processes
    is_shell = False
    if fg_procs:
        proc = fg_procs[-1]
        cmdline = proc.get("cmdline", [])
        if cmdline:
            exe = cmdline[0].split("/")[-1].lstrip("-")
            if exe in ("bash", "zsh", "fish", "sh"):
                is_shell = True
    else:
        is_shell = True

    # If at the shell prompt, resume with `fg`; otherwise suspend with Ctrl-Z
    if is_shell:
        window.write_to_child(b"fg\r")
    else:
        window.write_to_child(b"\x1a")
