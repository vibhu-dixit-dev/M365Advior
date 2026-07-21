import json
import os
import re

base_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit"
registry_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Assess-main\src\M365-Assess\controls\registry.json"
registry = json.load(open(registry_path, encoding='utf-8-sig'))
checks = registry.get("checks", [])
checks_dict = {c["checkId"]: c for c in checks}

def get_iso_controls(check, framework_key):
    fw = check.get("frameworks", {}).get(framework_key, {})
    if not fw:
        return []
    cid = fw.get("controlId", "")
    if not cid:
        return []
    return [c.strip() for c in cid.split(";")]

# Manual overrides for specific test IDs or titles
manual_mappings = {
    "Email OTP authentication must be disabled": "ENTRA-AUTHMETHOD-002",
    "Communication with unmanaged Teams users (personal accounts) must be disabled": "TEAMS-EXTACCESS-001",
    "External unmanaged Teams users must not be able to initiate conversations": "TEAMS-EXTACCESS-002",
    "Skype for Business / consumer interop must be disabled": "TEAMS-EXTACCESS-004"
}

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

# Create the output directories if they don't exist
out_dir = os.path.join(base_path, "powershell", "public", "iso")
os.makedirs(out_dir, exist_ok=True)

# Process all ISO tests
folders = ["tests/iso27001", "tests/iso27002"]
all_mappings = {}
test_titles = {}

for folder in folders:
    framework_key = "iso-27001" if "27001" in folder else "iso-27002"
    t_list = parse_pester_tests(os.path.join(base_path, folder))
    for t in t_list:
        test_id = t["id"]
        title = t["title"]
        test_titles[test_id] = title
        ctrl = t["control"]
        
        # Check manual overrides first
        matched_check_id = None
        for pattern, cid in manual_mappings.items():
            if pattern.lower() in title.lower():
                matched_check_id = cid
                break
        
        if not matched_check_id:
            # Filter checks by matching controls
            candidates = []
            for c in checks:
                controls = get_iso_controls(c, framework_key)
                # Check both ISO-27001 and ISO-27002 tags
                controls_1 = get_iso_controls(c, "iso-27001")
                controls_2 = get_iso_controls(c, "iso-27002")
                match_ctrl = False
                for c1 in controls_1 + controls_2:
                    if ctrl in c1 or c1 in ctrl:
                        match_ctrl = True
                        break
                if match_ctrl:
                    candidates.append(c)
            
            # Match by keyword overlap
            best_candidate = None
            best_score = -1
            t_words = set(re.findall(r'\w+', title.lower()))
            
            search_set = candidates if candidates else checks
            for cand in search_set:
                cand_text = (cand.get("name", "") + " " + cand.get("description", "") + " " + cand.get("rationale", "")).lower()
                cand_words = set(re.findall(r'\w+', cand_text))
                overlap = len(t_words.intersection(cand_words))
                if overlap > best_score:
                    best_score = overlap
                    best_candidate = cand
            
            if best_candidate:
                matched_check_id = best_candidate["checkId"]
        
        if matched_check_id:
            all_mappings[test_id] = matched_check_id
        else:
            print(f"Failed to match: {test_id} - {title}")

# Write markdown files
metadata_dict = {}
for test_id, check_id in all_mappings.items():
    check = checks_dict.get(check_id)
    if not check:
        continue
    
    title = test_titles.get(test_id, test_id)
    
    # Extract details
    desc = check.get("description") or check.get("rationale") or check.get("name")
    rationale = check.get("rationale")
    remediation = check.get("remediation", {})
    rem_notes = remediation.get("notes") or ""
    portal_path = remediation.get("portal", {}).get("path") or ""
    severity = check.get("impactRating", {}).get("severity") or "Medium"
    
    # Formulate markdown content
    md_lines = []
    md_lines.append(f"{desc}\n")
    
    if rationale and rationale != desc:
        md_lines.append(f"#### Rationale:\n\n{rationale}\n")
        
    md_lines.append("#### Remediation action:\n")
    if rem_notes:
        md_lines.append(f"{rem_notes}\n")
    if portal_path:
        md_lines.append(f"Configure via: {portal_path}\n")
    if not rem_notes and not portal_path:
        md_lines.append("Refer to vendor recommendations for correcting this setting.\n")
        
    references = check.get("references", [])
    ref_list = []
    if references:
        md_lines.append("#### Related links\n")
        for ref in references:
            title_str = ref.get("title") or ref.get("url")
            url_str = ref.get("url")
            ref_list.append({"title": title_str, "url": url_str})
            if url_str:
                md_lines.append(f"- [{title_str}]({url_str})\n")
            else:
                md_lines.append(f"- {title_str}\n")
                
    md_lines.append("\n<!--- Results --->\n%TestResult%\n")
    
    md_content = "\n".join(md_lines)
    
    # Save file
    md_path = os.path.join(out_dir, f"{test_id}.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md_content)
        
    # Add to metadata dict
    metadata_dict[test_id] = {
        "severity": severity,
        "title": title,
        "description": desc,
        "rationale": rationale,
        "remediation": rem_notes,
        "portal_path": portal_path,
        "references": ref_list
    }

# Save metadata.json
metadata_json_path = os.path.join(out_dir, "metadata.json")
with open(metadata_json_path, "w", encoding="utf-8") as f:
    json.dump(metadata_dict, f, indent=2)

print(f"Successfully generated {len(all_mappings)} markdown files and metadata.json in {out_dir}")

