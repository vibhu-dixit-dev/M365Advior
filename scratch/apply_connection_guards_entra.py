import os
import re

iso27001_dir = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27001"
iso27002_dir = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27002"

# 1. Update Entra ID Tests
entra_path = os.path.join(iso27001_dir, "Test-MtIso-Entra.Tests.ps1")
if os.path.exists(entra_path):
    with open(entra_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Define BeforeAll changes
    old_before_all = """    BeforeAll {
        $script:gaRoleTemplateId ="""
        
    new_before_all = """    BeforeAll {
        $script:graphConnected = $false
        try {
            $context = Get-MgContext -ErrorAction Stop
            if ($context -and $context.TenantId) {
                $script:graphConnected = $true
            }
        } catch {}

        $script:gaRoleTemplateId ="""

    if old_before_all in content:
        content = content.replace(old_before_all, new_before_all)

    # Insert guards in each It block
    guard_entra = """        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }
"""
    def replace_it_entra(m):
        it_start = m.group(0)
        return it_start + "\n" + guard_entra

    content = re.sub(r'(^\s*It\s+"[^"]+"\s*{)', replace_it_entra, content, flags=re.MULTILINE)

    # Also replace -NotBeNull with -Not -Be $null
    content = content.replace("-NotBeNull", "-Not -Be $null")

    with open(entra_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Entra ID tests updated.")

# 2. Fix -NotBeNull in Defender tests
def_path = os.path.join(iso27001_dir, "Test-MtIso-Defender.Tests.ps1")
if os.path.exists(def_path):
    with open(def_path, "r", encoding="utf-8") as f:
        content = f.read()
    content = content.replace("-NotBeNull", "-Not -Be $null")
    with open(def_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Defender tests updated.")

# 3. Synchronize ISO 27001 files to ISO 27002
print("Synchronizing ISO 27001 tests to ISO 27002...")
for filename in os.listdir(iso27001_dir):
    if not filename.endswith(".Tests.ps1"):
        continue
    
    src_file = os.path.join(iso27001_dir, filename)
    dest_filename = filename.replace("Test-MtIso-", "Test-MtIso27002-")
    dest_file = os.path.join(iso27002_dir, dest_filename)
    
    with open(src_file, "r", encoding="utf-8") as f:
        content = f.read()
        
    # Replace references
    content = content.replace("ISO 27001", "ISO 27002")
    content = content.replace("ISO27001:", "ISO27002:")
    
    with open(dest_file, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Copied & adapted: {filename} -> {dest_filename}")

print("All tests processed.")
