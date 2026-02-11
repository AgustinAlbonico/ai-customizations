param(
    [string]$EventName = "post-task",
    [string]$Context = ""
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "[ai-customizations][$timestamp][$EventName] fin $Context"
