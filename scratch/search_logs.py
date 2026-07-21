import json

log_path = r"C:\Users\DurgeshBahadurSingh\.gemini\antigravity\brain\bb695bfd-212f-4d0d-b26b-75db145e4eb4\.system_generated\logs\overview.txt"

def deep_search(obj, target_words):
    if isinstance(obj, str):
        if any(w in obj for w in target_words):
            return True
    elif isinstance(obj, dict):
        for k, v in obj.items():
            if deep_search(k, target_words) or deep_search(v, target_words):
                return True
    elif isinstance(obj, list):
        for item in obj:
            if deep_search(item, target_words):
                return True
    return False

with open(log_path, 'r', encoding='utf-8') as f:
    # Print the first line to see structure
    first_line = f.readline()
    try:
        print("First line sample:", json.dumps(json.loads(first_line), indent=2)[:500])
    except:
        print("First line (raw):", first_line[:500])

    f.seek(0)
    for i, line in enumerate(f):
        try:
            data = json.loads(line)
            if deep_search(data, ["Build-M365AdvisorModule", "Publish-PSModule", "Publish-Module"]):
                print(f"Line {i} matches:")
                # print a condensed version of the line
                # Look for 'command' or 'toolCall' or similar fields
                if "toolCall" in str(data) or "tool" in str(data) or "CommandLine" in str(data):
                    print(json.dumps(data, indent=2)[:2000])
                    print("-" * 50)
        except Exception as e:
            pass
