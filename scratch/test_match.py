import json
import os
import re

registry_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Assess-main\src\M365-Assess\controls\registry.json"
registry = json.load(open(registry_path, encoding='utf-8'))
checks = registry.get("checks", [])

# Parse all checks into a dictionary keyed by checkId
checks_dict = {c["checkId"]: c for c in checks}

def get_iso_controls(check, framework_key):
    fw = check.get("frameworks", {}).get(framework_key, {})
    if not fw:
        return []
    cid = fw.get("controlId", "")
    if not cid:
        return []
    # Split on semicolon
    return [c.strip() for c in cid.split(";")]

# Parse Pester tests
def parse_pester_tests(dir_path):
    tests = []
    for filename in os.listdir(dir_path):
        if not filename.endswith(".Tests.ps1"):
            continue
        filepath = os.path.join(dir_path, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Find all It blocks
        matches = re.finditer(r'It\s+"([^"]+)"\s*\{', content)
        for m in matches:
            full_desc = m.group(1)
            # e.g. "ISO27001.A.8.20.1: Modern Authentication must be enabled"
            if ":" in full_desc:
                test_id, test_title = full_desc.split(":", 1)
                test_id = test_id.strip()
                test_title = test_title.strip()
            else:
                test_id = ""
                test_title = full_desc.strip()
            
            # Extract control number from test_id
            # e.g., ISO27001.A.8.20.1 -> A.8.20 or 8.20
            ctrl_match = re.search(r'ISO2700[12]\.(?:A\.)?(\d+\.\d+(?:\.\d+)?)', test_id)
            ctrl = ctrl_match.group(1) if ctrl_match else ""
            
            tests.append({
                "file": filename,
                "id": test_id,
                "title": test_title,
                "control": ctrl
            })
    return tests

tests_iso1 = parse_pester_tests(r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27001")
print(f"Loaded {len(tests_iso1)} ISO 27001 tests.")

# Match each test
for t in tests_iso1[:20]:
    ctrl = t["control"]
    candidates = []
    for c in checks:
        controls_1 = get_iso_controls(c, "iso-27001")
        controls_2 = get_iso_controls(c, "iso-27002")
        # Check if control matches (either exactly or as substring/parent)
        match_ctrl = False
        for c1 in controls_1 + controls_2:
            if ctrl in c1 or c1 in ctrl:
                match_ctrl = True
                break
        if match_ctrl:
            candidates.append(c)
            
    # Find best candidate based on keyword overlap with check name or description
    best_candidate = None
    best_score = -1
    t_words = set(re.findall(r'\w+', t["title"].lower()))
    
    for cand in candidates:
        cand_text = (cand.get("name", "") + " " + cand.get("description", "") + " " + cand.get("rationale", "")).lower()
        cand_words = set(re.findall(r'\w+', cand_text))
        overlap = len(t_words.intersection(cand_words))
        if overlap > best_score:
            best_score = overlap
            best_candidate = cand
            
    if best_candidate:
        print(f"Test: {t['id']} - {t['title']}")
        print(f"  -> Best Match: {best_candidate['checkId']} - {best_candidate['name']} (Score: {best_score})")
    else:
        print(f"Test: {t['id']} - {t['title']} -> NO MATCH!")
