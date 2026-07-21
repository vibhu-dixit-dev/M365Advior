import json
import os
import re

base_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit"
registry_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Assess-main\src\M365-Assess\controls\registry.json"
registry = json.load(open(registry_path, encoding='utf-8-sig'))
checks = registry.get("checks", [])

def get_iso_controls(check, framework_key):
    fw = check.get("frameworks", {}).get(framework_key, {})
    if not fw:
        return []
    cid = fw.get("controlId", "")
    if not cid:
        return []
    return [c.strip() for c in cid.split(";")]

def parse_pester_tests(dir_path):
    tests = []
    if not os.path.exists(dir_path):
        return tests
    for filename in os.listdir(dir_path):
        if not filename.endswith(".Tests.ps1"):
            continue
        filepath = os.path.join(dir_path, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        matches = re.finditer(r'It\s+"([^"]+)"\s*\{', content)
        for m in matches:
            full_desc = m.group(1)
            if ":" in full_desc:
                test_id, test_title = full_desc.split(":", 1)
                test_id = test_id.strip()
                test_title = test_title.strip()
            else:
                test_id = ""
                test_title = full_desc.strip()
            
            ctrl_match = re.search(r'ISO2700[12]\.(?:A\.)?(\d+\.\d+(?:\.\d+)?)', test_id)
            ctrl = ctrl_match.group(1) if ctrl_match else ""
            
            tests.append({
                "file": filename,
                "id": test_id,
                "title": test_title,
                "control": ctrl
            })
    return tests

for folder in ["tests/iso27001", "tests/iso27002"]:
    t_list = parse_pester_tests(os.path.join(base_path, folder))
    print(f"\n--- {folder} ({len(t_list)} tests) ---")
    no_match_count = 0
    low_score_count = 0
    for t in t_list:
        ctrl = t["control"]
        candidates = []
        for c in checks:
            controls_1 = get_iso_controls(c, "iso-27001")
            controls_2 = get_iso_controls(c, "iso-27002")
            match_ctrl = False
            for c1 in controls_1 + controls_2:
                if ctrl in c1 or c1 in ctrl:
                    match_ctrl = True
                    break
            if match_ctrl:
                candidates.append(c)
                
        best_candidate = None
        best_score = -1
        t_words = set(re.findall(r'\w+', t["title"].lower()))
        
        # If no candidates based on control match, try all checks
        search_set = candidates if candidates else checks
        
        for cand in search_set:
            cand_text = (cand.get("name", "") + " " + cand.get("description", "") + " " + cand.get("rationale", "")).lower()
            cand_words = set(re.findall(r'\w+', cand_text))
            overlap = len(t_words.intersection(cand_words))
            if overlap > best_score:
                best_score = overlap
                best_candidate = cand
                
        if not best_candidate or best_score < 2:
            no_match_count += 1
            print(f"LOW/NO MATCH: {t['id']} - {t['title']}")
            if best_candidate:
                print(f"  -> Best candidate: {best_candidate['checkId']} - {best_candidate['name']} (Score: {best_score})")
        else:
            if best_score < 4:
                low_score_count += 1
                
    print(f"Total Low/No Matches: {no_match_count}")
