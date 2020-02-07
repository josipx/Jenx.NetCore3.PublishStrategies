$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

function Get-FolderSize($Path) {    
    $FolderSizeInMb = ((Get-ChildItem $Path -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB) 
    $FolderSizeInMbFormatted = [math]::Round($FolderSizeInMb, 2)
    "{0} MB" -f $FolderSizeInMbFormatted
}

function Get-FilesCount($Path) {
    ( Get-ChildItem $Path -Recurse -File | Measure-Object ).Count;
}

function Remove-BinariesDirs {
    if (Test-Path "$PSScriptRoot\src\bin") {
        Write-Host "Deleting bin folder"
        Remove-Item -Path "$PSScriptRoot\src\bin" -Recurse -Force
    } 

    if (Test-Path "$PSScriptRoot\src\obj") {
        Write-Host "Deleting obj folder"
        Remove-Item -Path "$PSScriptRoot\src\obj" -Recurse -Force
    }
}

function Remove-PublishDir {
    if (Test-Path "$PSScriptRoot\src\Publish") {
        Write-Host "Deleting Publish folder"
        Remove-Item -Path "$PSScriptRoot\src\Publish" -Recurse -Force
    }
}

function Start-BuildWithStatistics($BuildDescription, $Command, $OutputPath) {
    Write-Host "Starting build: " $BuildDescription

    Write-Host $Command

    $DeployOutputSize = Get-FolderSize $PSScriptRoot"\src\"$OutputPath"publish"
    $DeployOutputFilesNo = Get-FilesCount $PSScriptRoot"\src\"$OutputPath"publish"    
    
    $BuildStatistics = New-Object System.Object
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Build Description" -Value $BuildDescription
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Output size" -Value $DeployOutputSize
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "No of files in output" -Value $DeployOutputFilesNo
    
    return $BuildStatistics
}

function Run-DeployAnalysis {
    Remove-BinariesDirs
    Remove-PublishDir
    
    $BuildStatisticList = New-Object System.Collections.ArrayList

    $Stopwatch = [system.diagnostics.stopwatch]::StartNew()
 
    $OutputPath = "Publish/AnyCpu"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:'Restore,Build,Publish' /p:Configuration=Release /p:Platform='Any Cpu' /p:PublishProfile=AnyCpu-Profile /p:OutputPath=$OutputPath
    $BuildStatistics = Start-BuildWithStatistics "Runtime dependent build- default" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs
    
    $Stopwatch.Restart(); 
    $OutputPath = "Publish/AnyCpu-SelfContained"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:'Restore,Build,Publish' /p:Configuration=Release /p:Platform='Any Cpu' /p:PublishProfile=AnyCpu-SelfContained-Profile /p:SelfContained=true /p:RuntimeIdentifier=win-x64 /p:OutputPath=$OutputPath
    $BuildStatistics = Start-BuildWithStatistics "Self-contained build" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs

    $Stopwatch.Restart();
    $OutputPath = "Publish/AnyCpu-SelfContained-SingleFile"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:"Restore,Build,Publish" /p:Configuration=Release /p:Platform="Any Cpu" /p:PublishProfile=AnyCpu-SelfContained-SingleFile-Profile /p:SelfContained=true /p:RuntimeIdentifier=win-x64 /p:PublishSingleFile=true /p:OutputPath=$OutputPath
    $BuildStatistics = Start-BuildWithStatistics "Self-contained, single file build" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs
 
    $Stopwatch.Restart();
    $OutputPath = "Publish/AnyCpu-SelfContained-SingleFile-ReadyToRun"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:"Restore,Build,Publish" /p:Configuration=Release /p:Platform="Any Cpu" /p:PublishProfile=AnyCpu-SelfContained-SingleFile-ReadyToRun-Profile /p:SelfContained=true /p:RuntimeIdentifier=win-x64 /p:PublishSingleFile=true /p:PublishReadyToRun=true /p:OutputPath=$OutputPath
    $BuildStatistics = Start-BuildWithStatistics "Self-contained, single file, ready-to-run build" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs

    $Stopwatch.Restart();
    $OutputPath = "Publish/AnyCpu-SelfContained-SingleFile-Trimmed"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:"Restore,Build,Publish" /p:Configuration=Release /p:Platform="Any Cpu" /p:PublishProfile=AnyCpu-SelfContained-SingleFile-Trimmed-Profile /p:SelfContained=true /p:RuntimeIdentifier=win-x64 /p:PublishSingleFile=true /p:PublishReadyToRun=false /p:PublishTrimmed=true /p:OutputPath=$OutputPath  
    $BuildStatistics = Start-BuildWithStatistics "Self-contained, single file, trimmed build" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs

    $Stopwatch.Restart();
    $OutputPath = "Publish/AnyCpu-SelfContained-SingleFile-ReadyToRun-Trimmed"
    $Command = msbuild Jenx.NetCore3.PublishStrategies.sln /t:"Restore,Build,Publish" /p:Configuration=Release /p:Platform="Any Cpu" /p:PublishProfile=AnyCpu-SelfContained-SingleFile-ReadyToRun-Trimmed-Profile /p:SelfContained=true /p:RuntimeIdentifier=win-x64 /p:PublishSingleFile=true /p:PublishReadyToRun=true /p:PublishTrimmed=true /p:OutputPath=$OutputPath  
    $BuildStatistics = Start-BuildWithStatistics "Self-contained, single file, ready-to-run, trimmed build" $Command $OutputPath
    $Stopwatch.Stop()
    $BuildStatistics | Add-Member -MemberType NoteProperty -Name "Execution time" -Value $Stopwatch.Elapsed
    $BuildStatisticList.Add($BuildStatistics) | Out-Null

    Remove-BinariesDirs

    $BuildStatisticList | Format-Table -AutoSize
}

Run-DeployAnalysis