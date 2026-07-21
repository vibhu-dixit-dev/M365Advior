import json

registry_path = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Assess-main\src\M365-Assess\controls\registry.json"
checks = json.load(open(registry_path, encoding='utf-8-sig'))['checks']
for c in checks:
    if c["checkId"].startswith("TEAMS-EXTACCESS"):
        print(f'{c["checkId"]}: {c["name"]}')
