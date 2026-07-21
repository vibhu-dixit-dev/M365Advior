import os
import re

iso27001_dir = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27001"
iso27002_dir = r"c:\Users\DurgeshBahadurSingh\Desktop\project\M365-Audit\tests\iso27002"

# 1. Update Exchange Online Tests
exo_path = os.path.join(iso27001_dir, "Test-MtIso-ExchangeOnline.Tests.ps1")
if os.path.exists(exo_path):
    with open(exo_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Add BeforeAll in the first Describe block
    before_all_exo = """    BeforeAll {
        $script:exoConnected = $false
        try {
            $null = Get-OrganizationConfig -ErrorAction Stop
            $script:exoConnected = $true
        } catch {}
    }

"""
    # Find the first Describe block open line and insert the BeforeAll
    match = re.search(r'(Describe "ISO 27001 - Exchange Online"[^{]*{)', content)
    if match:
        desc_line = match.group(1)
        content = content.replace(desc_line, desc_line + "\n" + before_all_exo)

    # Insert guards in each It block
    # We find all It lines and replace with It + guard
    # The guard:
    guard_exo = """        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }
"""
    # Replace It blocks safely
    def replace_it_exo(m):
        it_start = m.group(0)
        return it_start + "\n" + guard_exo

    content = re.sub(r'(^\s*It\s+"[^"]+"\s*{)', replace_it_exo, content, flags=re.MULTILINE)

    with open(exo_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Exchange Online tests updated.")

# 2. Update Intune Tests
intune_path = os.path.join(iso27001_dir, "Test-MtIso-Intune.Tests.ps1")
if os.path.exists(intune_path):
    with open(intune_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Add BeforeAll in the first Describe block
    before_all_intune = """    BeforeAll {
        $script:graphConnected = $false
        try {
            $context = Get-MgContext -ErrorAction Stop
            if ($context -and $context.TenantId) {
                $script:graphConnected = $true
            }
        } catch {}
    }

"""
    match = re.search(r'(Describe "ISO 27001 - Intune Device Management"[^{]*{)', content)
    if match:
        desc_line = match.group(1)
        content = content.replace(desc_line, desc_line + "\n" + before_all_intune)

    # Insert guards in each It block
    guard_intune = """        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }
"""
    def replace_it_intune(m):
        it_start = m.group(0)
        return it_start + "\n" + guard_intune

    content = re.sub(r'(^\s*It\s+"[^"]+"\s*{)', replace_it_intune, content, flags=re.MULTILINE)

    with open(intune_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Intune tests updated.")

# 3. Update SharePoint Tests (SPO-SESSION-001)
spo_path = os.path.join(iso27001_dir, "Test-MtIso-SharePoint.Tests.ps1")
if os.path.exists(spo_path):
    with open(spo_path, "r", encoding="utf-8") as f:
        content = f.read()

    old_session_test = """    It "SPO-SESSION-001: Idle session timeout policy must be configured" {
        $idlePolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/activityBasedTimeoutPolicies' -ErrorAction SilentlyContinue
        $hasPolicy = $idlePolicy -and $idlePolicy['value'] -and @($idlePolicy['value']).Count -gt 0
        $hasPolicy | Should -Be $true `
            -Because "ISO A.8.4 requires automatic session termination after inactivity to prevent unauthorized access to unattended sessions"
    }"""

    new_session_test = """    It "SPO-SESSION-001: Idle session timeout policy must be configured" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $idlePolicy = $null
        try {
            $idlePolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/activityBasedTimeoutPolicies' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "ActivityBasedTimeoutPolicies permission not granted"
                return
            }
            throw
        }
        $hasPolicy = $idlePolicy -and $idlePolicy['value'] -and @($idlePolicy['value']).Count -gt 0
        $hasPolicy | Should -Be $true `
            -Because "ISO A.8.4 requires automatic session termination after inactivity to prevent unauthorized access to unattended sessions"
    }"""

    if old_session_test in content:
        content = content.replace(old_session_test, new_session_test)
    else:
        # Fallback to loose match if whitespace differs slightly
        content = re.sub(r'It\s+"SPO-SESSION-001:[^{]*{.*?-Because\s+"ISO\s+A\.8\.4[^\n]*\n\s*}', new_session_test, content, flags=re.DOTALL)

    with open(spo_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("SharePoint tests updated.")

# 4. Synchronize ISO 27001 files to ISO 27002
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
