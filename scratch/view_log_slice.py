import json
import os

log_path = r"C:\Users\DurgeshBahadurSingh\.gemini\antigravity\brain\4cec0b14-7f93-4b75-824b-b3697f084fd5\.system_generated\logs\overview.txt"
with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '"step_index":1057' in line or '"step_index": 1057' in line:
        print(f"--- MATCH AT LINE {i} ---")
        for j in range(max(0, i-2), min(len(lines), i+6)):
            # Print a snippet, since it might be very long
            content = lines[j]
            if len(content) > 1000:
                print(content[:500] + " ... [TRUNCATED] ... " + content[-500:])
            else:
                print(content.strip())
