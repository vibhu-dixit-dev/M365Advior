import os
import re

directories = [
    r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27001",
    r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27002"
]

all_tests = []

for directory in directories:
    if not os.path.exists(directory):
        continue
    framework = "ISO27001" if "iso27001" in directory else "ISO27002"
    for filename in sorted(os.listdir(directory)):
        if not filename.endswith(".Tests.ps1"):
            continue
        filepath = os.path.join(directory, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        it_matches = re.findall(r'It\s+"([^"]+)"', content)
        for it in it_matches:
            if ":" in it:
                tid, desc = it.split(":", 1)
                all_tests.append({
                    "framework": framework,
                    "file": filename,
                    "id": tid.strip(),
                    "desc": desc.strip()
                })
            else:
                all_tests.append({
                    "framework": framework,
                    "file": filename,
                    "id": "",
                    "desc": it.strip()
                })

print(f"Total ISO tests found: {len(all_tests)}")
for t in all_tests[:15]:
    print(f"[{t['framework']}] {t['id']} -> {t['desc']}")
