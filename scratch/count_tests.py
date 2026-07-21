import os
import re

base_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit"
for folder in ["tests/iso27001", "tests/iso27002"]:
    p = os.path.join(base_path, folder)
    if os.path.exists(p):
        for f in os.listdir(p):
            if f.endswith(".Tests.ps1"):
                filepath = os.path.join(p, f)
                with open(filepath, "r", encoding="utf-8") as file:
                    content = file.read()
                    matches = re.findall(r'It\s+"([^"]+)"', content)
                    print(f"{folder}/{f}: {len(matches)} tests")
