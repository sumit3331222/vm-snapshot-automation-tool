# VMware Snapshot Manager - Simple Version with Delete Option
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$VMRUN = "$BasePath\vmrun.exe"
$VM_DIR = "$BasePath\VMs"

function List-VMs {
    Write-Host "`n===== Available VMs in $VM_DIR =====" -ForegroundColor Cyan
    $vmList = Get-ChildItem -Path $VM_DIR -Filter *.vmx -Recurse
    if ($vmList.Count -eq 0) {
        Write-Host "No VMX files found!"
        return @()
    }
    $i = 1
    foreach ($vm in $vmList) {
        Write-Host "$i. $($vm.FullName)"
        $i++
    }
    return $vmList
}

function Create-Snapshot {
    $vms = List-VMs
    if ($vms.Count -eq 0) { return }
    $choice = Read-Host "Select VM number"
    $vm = $vms[[int]$choice - 1].FullName
    $snapName = Read-Host "Enter snapshot name"
    Write-Host "`nCreating snapshot '$snapName'..." -ForegroundColor Yellow
    $out = & "$VMRUN" snapshot "$vm" "$snapName" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "✔ Snapshot created successfully!" -ForegroundColor Green }
    else { Write-Host "❌ Snapshot creation failed!" -ForegroundColor Red; Write-Host "Error: $out" }
}

function List-Snapshots {
    $vms = List-VMs
    if ($vms.Count -eq 0) { return }
    $choice = Read-Host "Select VM number"
    $vm = $vms[[int]$choice - 1].FullName
    Write-Host "`nSnapshots for VM:"
    $out = & "$VMRUN" listSnapshots "$vm" 2>&1
    Write-Host $out
}

function Restore-Snapshot {
    $vms = List-VMs
    if ($vms.Count -eq 0) { return }
    $choice = Read-Host "Select VM number"
    $vm = $vms[[int]$choice - 1].FullName
    Write-Host "`nRestoring last snapshot..." -ForegroundColor Yellow
    $out = & "$VMRUN" revertToSnapshot "$vm" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "✔ Restored last snapshot successfully!" -ForegroundColor Green }
    else { Write-Host "❌ Failed to restore snapshot." -ForegroundColor Red; Write-Host "Error: $out" }
}

function Backup-VM {
    Write-Host "Backup feature placeholder."
}

function Delete-Snapshot {
    $vms = List-VMs
    if ($vms.Count -eq 0) { return }
    $choice = Read-Host "Select VM number"
    $vm = $vms[[int]$choice - 1].FullName
    Write-Host "`nFetching snapshots..." -ForegroundColor Yellow
    $snapOut = & "$VMRUN" listSnapshots "$vm" 2>&1
    $snaps = ($snapOut -split "`n") | Select-Object -Skip 1 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    if ($snaps.Count -eq 0) { Write-Host "No snapshots available to delete!" -ForegroundColor Red; return }
    Write-Host "`n===== Snapshots ====="
    for ($i = 0; $i -lt $snaps.Count; $i++) { Write-Host "$($i+1). $($snaps[$i])" }
    $snapChoice = Read-Host "Select snapshot number to DELETE"
    $snapName = $snaps[[int]$snapChoice - 1]
    $confirm = Read-Host "Type YES to confirm delete"
    if ($confirm -ne "YES") { Write-Host "Cancelled." -ForegroundColor Yellow; return }
    Write-Host "`nDeleting snapshot '$snapName'..." -ForegroundColor Yellow
    $out = & "$VMRUN" deleteSnapshot "$vm" "$snapName" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "Snapshot deleted successfully!" -ForegroundColor Green }
    else { Write-Host "Failed to delete snapshot!" -ForegroundColor Red; Write-Host "Error: $out" }
}

while ($true) {
    Write-Host "`n===== VMware Snapshot Manager =====" -ForegroundColor Cyan
    Write-Host "1) List VMs"
    Write-Host "2) Create Snapshot"
    Write-Host "3) Restore Last Snapshot"
    Write-Host "4) List Snapshots"
    Write-Host "5) Backup VM (full copy)"
    Write-Host "6) Delete Snapshot"
    Write-Host "7) Exit"
    Write-Host "=================================="
    $op = Read-Host "Enter choice"
    switch ($op) {
        "1" { List-VMs }
        "2" { Create-Snapshot }
        "3" { Restore-Snapshot }
        "4" { List-Snapshots }
        "5" { Backup-VM }
        "6" { Delete-Snapshot }
        "7" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid choice!" -ForegroundColor Red }
    }
}
