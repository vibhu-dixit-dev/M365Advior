import json
import os
import re

log_path = r"C:\Users\DurgeshBahadurSingh\.gemini\antigravity\brain\419200de-01a3-4af1-b29b-4c52e78867d6\.system_generated\logs\overview.txt"

if not os.path.exists(log_path):
    print("Log path does not exist!")
    exit(1)

with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        try:
            data = json.loads(line)
        except Exception:
            continue
        
        # Check if this is a model response with write_to_file calls
        tool_calls = data.get("tool_calls", [])
        for tc in tool_calls:
            if tc.get("name") == "write_to_file":
                args = tc.get("args", {})
                # Some args might be double JSON-encoded strings
                if isinstance(args, str):
                    try:
                        args = json.loads(args)
                    except Exception:
                        continue
                
                target = args.get("TargetFile", "").replace('"', '').replace('\\\\', '\\')
                if "tests\\iso27001\\Test-MtIso-" in target or "tests/iso27001/Test-MtIso-" in target:
                    content = args.get("CodeContent", "")
                    filename = os.path.basename(target)
                    print(f"Found file in log: {filename} ({len(content)} chars)")
                    # Save it to a temp file in scratch
                    out_path = os.path.join(r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\scratch", filename + ".orig")
                    with open(out_path, "w", encoding="utf-8") as out_f:
                        out_f.write(content)
