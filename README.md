# process-lithold

## Purpose
The idea for this script came from Michael Lustfield.  Michael requested:
> When a "Litigation Hold" process is initiated, files within specific parameters (file extentions & regex checks) need to be archived with tar (preserving meta data) and uploaded to a collection server using SSH. The uploaded tarball must have the computer name and collection date in the file name. These collections are performed on a Windows server. This script is deployed to systems utilizing a compiled package.



## Summary 

This script will take a path and recursively look through it for files that end in specified extensions or match specified regular expressions.  As it comes across files that match, it will add them to a tar file.  Once the file search is finished the tar file will be scp'ed to a remote server.

## Dependencies
- Powershell
- [PoSH-SSH Module](https://www.powershellgallery.com/packages/Posh-SSH/1.7.6)
- [7-zip](http://www.7-zip.org/)

## Usage
```

NAME
    process-lithold.ps1

SYNOPSIS
    A powershell script to search for files by extension and/or regular expression, archive those files, and scp them to a remote server.


SYNTAX
    C:\users\Administrator\Documents\process-lithold.ps1 [[-Path] <String>] [[-Regexes] <String[]>] [[-Extensions] <String[]>] [[-Archive_Path] <String>] [-SSH_Host] <String> [-Remote_Path] <String> [[-7zPath] <String>] [[-Credential] <PSCredential>]
    [<CommonParameters>]


DESCRIPTION
    This script will take a path and recursively look through it for files that end in specified extensions or match specified regular expressions.  As it comes across files that match, it will add them to a tar file.  Once the file search is finished the tar file will
    be scp'ed to a remote server.


PARAMETERS
    -Path <String>
        The starting path of where to search for files.

        Required?                    false
        Position?                    1
        Default value                C:\
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Regexes <String[]>
        An array of regular expressions to search for in file names.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Extensions <String[]>
        An array of extensions to search for in file names.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Archive_Path <String>
        The path of where the tar archieve will be stored locally.

        Required?                    false
        Position?                    4
        Default value                $(Get-Location)
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -SSH_Host <String>
        The hostname or IP address of a remote host to send the archieve file.

        Required?                    true
        Position?                    5
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Remote_Path <String>
        The path to store the archieve file on the SSH_Host.

        Required?                    true
        Position?                    6
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -7zPath <String>
        The path to 7z.exe.  By default the script will look for it in your environment's $PATH.

        Required?                    false
        Position?                    7
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Credential <PSCredential>
        Credentials used to log onto the SSH_Host.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>process-lithold.ps1 -Regexes ^finance, ^account -SSH_Host host_or_ip -Remote_Path /data






    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>process-lithold.ps1 -Path C:\Users -Extensions .docx, .xlsx  -SSH_Host host_or_ip -Remote_Path /data






    -------------------------- EXAMPLE 3 --------------------------

    PS C:\>process-lithold.ps1 -Extensions .docx, .xlsx -Regexes '^New' -SSH_Host host_or_ip -Remote_Path /data







RELATED LINKS
    https://github.com/canance/process-lithold


```


## Future Development
- Create a report containing metadata for each file
- Add support for other archive types
- Add support for SSH private keys

## Video Demonstration
http://www.youtube.com/watch?v=cLe5BwcVXS4



