# This script will read the tests in test-results.json and m365advisor-config.json (if it exists)
# then determine the severity of the test using the Gemini AI API.
# The test-results.json file is a copy of one of the latest runs of Invoke-M365Advisor.

# This script can be reused if we need to do a bulk Severity update or add a similar property in the future.
# E.g Mitre ATT&CK, etc.

function Get-PromptResult($prompt) {
    $apiKey = $Env:GeminiApiKey
    if (-not $apiKey) {
        Write-Host "Gemini API key not found in environment variable. Set with the following command." -ForegroundColor Red
        Write-Host ">`$Env:GeminiApiKey = '<key>'" -ForegroundColor Red
        Write-Host "You can get a new key from https://ai.google.dev/gemini-api/docs/api-key"
        exit 1
    }
    $uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey"


    $Body = @{
        contents = @(
            @{
                parts = @(
                    @{
                        text = $prompt
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 5

    # Write-Host "Calling AI API with question: $question" -ForegroundColor Green
    # Write-Host "Request Body: $Body" -ForegroundColor Green

    $Headers = @{
        "Content-Type" = "application/json"
    }

    $Response = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body

    return $Response.candidates.content.parts.text
}

function Get-MtM365AdvisorConfig($ConfigFilePath) {
    if (-not (Test-Path $ConfigFilePath)) {
        Write-Host "M365Advisor config file not found. Creating a new one." -ForegroundColor Yellow
        $m365advisorConfig = @{
            TestSettings = @()
        }
    } else {
        Write-Host "M365Advisor config file found. Loading existing settings, if you want a refresh all severity, delete TestSettings and run again." -ForegroundColor Green
        $m365advisorConfig = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
    }
    return $m365advisorConfig
}

function Set-MtM365AdvisorConfig($ConfigFilePath, $M365AdvisorConfig) {
    # Always sort TestSettings by Id
    $M365AdvisorConfig.TestSettings = $M365AdvisorConfig.TestSettings | Sort-Object Id
    # Convert the test settings array to JSON
    $m365advisorConfigJson = $M365AdvisorConfig | ConvertTo-Json -Depth 10
    # Save the setting
    Set-Content -Path $ConfigFilePath -Value $m365advisorConfigJson -Force
}

# Read the test-results.json file
$testResultsFilePath = "./test-results.json"
$testResults = Get-Content -Path $testResultsFilePath -Raw | ConvertFrom-Json

$promptFilePath = "./prompt-severity.md"
$promptTemplate = Get-Content -Path $promptFilePath -Raw | Out-String

$m365advisorConfig = Get-MtM365AdvisorConfig './m365advisor-config.json'

# Loop through each test result and create a test setting
foreach ($testResult in $testResults.Tests) {

    # Skip if test already has a severity
    if (![string]::IsNullOrEmpty($testResult.Severity)) {
        Write-Host "Test $($testResult.Id) already has a severity $($testResult.ResultDetail.Severity). Skipping." -ForegroundColor Yellow
        continue
    }

    # Check if the test already exists in the M365Advisor config
    $existingSetting = $m365advisorConfig.TestSettings | Where-Object { $_.Id -eq $testResult.Id }
    if ($existingSetting) {
        Write-Host "Test $($testResult.Id) already exists in M365Advisor config. Skipping." -ForegroundColor Yellow
    } else { # Find out the severity of the test
        $testInfo = [PSCustomObject]@{
            Id          = $testResult.Id
            Title       = $testResult.Title
            Description = $testResult.ResultDetail.Description
        }
        $testInfoJson = $testInfo | ConvertTo-Json -Depth 5

        $prompt = $promptTemplate -replace "%TEST_INFO_JSON%", $testInfoJson

        Write-Host $testResult.Id " - " $testResult.Title -ForegroundColor Green
        Start-Sleep -Seconds 5
        # Call the AI API with the prompt
        $aiResponse = Get-PromptResult -prompt $prompt
        # Remove the \n from the response
        $severity = $aiResponse -replace "\n", ""
        Write-Host "AI Response: $aiResponse" -ForegroundColor Blue

        # Create a new test setting object
        $testSetting = [PSCustomObject]@{
            Id       = $testResult.Id
            Title    = $testResult.Title
            Severity = $severity
        }
        # Add the test setting to the array
        $m365advisorConfig.TestSettings += $testSetting

        # Save the setting so we can resume if the script fails (AI API throttling, etc)
        Set-MtM365AdvisorConfig -ConfigFilePath $m365advisorConfigFilePath -M365AdvisorConfig $m365advisorConfig
    }
}
