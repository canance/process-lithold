<#
.SYNOPSIS
A powershell script to search for files by extension and/or regular expression, archive those files, and scp them to a remote server.

.DESCRIPTION
This script will take a path and recursively look through it for files that end in specified extensions or match specified regular expressions.  As it comes across files that match, it will add them to a tar file.  Once the file search is finished the tar file will be scp'ed to a remote server.

.PARAMETER Path
The starting path of where to search for files.

.PARAMETER Regexes
An array of regular expressions to search for in file names.

.PARAMETER Extensions
An array of extensions to search for in file names.

.PARAMETER Archive_Path
The path of where the tar archieve will be stored locally.

.PARAMETER SSH_Host
The hostname or IP address of a remote host to send the archieve file.

.PARAMETER Remote_Path
The path to store the archieve file on the SSH_Host.

.PARAMETER 7zPath
The path to 7z.exe.  By default the script will look for it in your environment's $PATH.

.PARAMETER Credential
Credentials used to log onto the SSH_Host.

.EXAMPLE
process-lithold.ps1 -Regexes ^finance, ^account -SSH_Host host_or_ip -Remote_Path /data

.EXAMPLE
process-lithold.ps1 -Path C:\Users -Extensions .docx, .xlsx  -SSH_Host host_or_ip -Remote_Path /data

.EXAMPLE
process-lithold.ps1 -Extensions .docx, .xlsx -Regexes '^New' -SSH_Host host_or_ip -Remote_Path /data

.LINK
https://github.com/canance/process-lithold

#>

[CmdletBinding()]

param(
    [string]$Path='C:\',
    [string[]]$Regexes,
    [string[]]$Extensions,
    [string]$Archive_Path=$(Get-Location),
    [Parameter(Mandatory=$true)][string]$SSH_Host,
    [Parameter(Mandatory=$true)][string]$Remote_Path,
    [string]$7zPath,
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][System.Management.Automation.PSCredential]$Credential
)

if (!$Credential){
    $Credential = Get-Credential
}

# find 7z
if (!$7zPath){
    $7zPath = Get-Command 7z.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if (!$?){
        Write-Output '7z.exe not found!'
        exit
    }
}

if (!$Regexes -and !$Extensions){
    Write-Output 'You must specify Regexes or Extensions!'
    exit
}

# create the archive file path
$archive_file = $(hostname) + '_' + $(Get-Date).ToString() + '.tar'
$archive_file = $archive_file.replace(' ', '_').replace("/", '_').replace(':', '_')
$Archive_Path = Join-Path $Archive_Path $archive_file

# put all regexes into a large regex
$match_regex = ''
foreach($regex in $Regexes){
    $match_regex += '(' + $regex + ')|'
}

if ($match_regex -eq ''){
    $match_regex = '^$'
}
$match_regex = $match_regex.TrimEnd('|')

# cd to $root of path to preserve directories
$old_cwd = Get-Location | Select-Object -ExpandProperty Path
$root = $Path[0] + ":\"
Set-Location $root

# search for items
Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | where-object {(($_.Name -match $match_regex) -or ($_.Extension -in $Extensions))} |
ForEach-Object{
    $relative_path = $_ | Select-Object -Property PSPath | Resolve-Path -Relative
    $relative_path = $relative_path.TrimStart('.\')
    Write-Output "[*INFO] Found --> $($_.FullName)"
    Start-Process $7zPath -ArgumentList 'a','-ttar', $Archive_Path, $relative_path -Wait -NoNewWindow -WorkingDirectory $root 
}

# restore cwd
Set-Location $old_cwd

# scp log to remote server
Write-Output "SCP'ing $Archive_Path to ${SSH_Host}:${Remote_Path}..."
Set-SCPFile -LocalFile $Archive_Path -RemotePath $Remote_Path -ComputerName $SSH_Host -Credential $Credential
