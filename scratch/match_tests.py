import os
import re
import json

registry_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Assess-main\src\M365-Assess\controls\registry.json"
with open(registry_path, "r", encoding="utf-8-sig") as f:
    registry = json.load(f)
    
checks = registry["checks"]

directories = [
    r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27001"
]

all_tests = []
for directory in directories:
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
                    "file": filename,
                    "id": tid.strip(),
                    "desc": desc.strip()
                })

def clean_text(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    return set(text.split())

for test in all_tests:
    test_words = clean_text(test["desc"])
    best_match = None
    best_score = 0
    
    for check in checks:
        check_words = clean_text(check["name"])
        overlap = len(test_words.intersection(check_words))
        
        # Add some score if the category/collector matches the file
        collector_score = 0
        collector = check.get("collector", "").lower()
        file_lower = test["file"].lower()
        if "entra" in file_lower and collector in ["aad", "entra", "identity"]:
            collector_score = 1
        elif "exchange" in file_lower and collector in ["exo", "exchange"]:
            collector_score = 1
        elif "defender" in file_lower and collector in ["defender", "sec"]:
            collector_score = 1
        elif "sharepoint" in file_lower and collector in ["spo", "sharepoint"]:
            collector_score = 1
        elif "teams" in file_lower and collector in ["teams", "skype"]:
            collector_score = 1
            
        score = overlap + collector_score
        if score > best_score:
            best_score = score
            best_match = check
            
    print(f"Test: {test['id']} - {test['desc']}")
    if best_match:
        print(f"  -> Match: {best_match['checkId']} - {best_match['name']} (Score: {best_score})")
    else:
        print("  -> No match found!")
