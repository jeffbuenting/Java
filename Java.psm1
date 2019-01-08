function Get-JavaExceptionList {

<#
    .Synopsis
        Gets a list of URLs in the Java Site Exception List

    .Description
        Retrieves a list of sites from the Java Control Panel Site Exception
List.

    .Example
        Return a list of Sites that are on the Java Exception List

        Get-JavaExceptionList

    .Link
 
https://cl-chang.blogspot.com/2017/02/configure-java-control-panel-settings.
html

    .NOTE
        Author : Jeff Buenting
        Date : 2019 JAN 08
#>

    [CmdletBinding()]
    Param ( 
        [Parameter ( ValueFromPipeline = $True ) ]
        [String[]]$ComputerName = $env:ComputerName

        # ----- Commenting these lines as I haven't figured out how I want to deal with setting remote servers / users

  #      [PSCredential]$Credential,

  #      [String]$UserProfile = $env:USERPROFILE
    )

    Process {
        Foreach ( $C in $ComputerName ) {
            Write-verbose "Getting Java Site Exception List from $C"

            If ( $Credential ) {
  #              Write-verbose "Running with passed Credentials"

  #              $Session = New-PSSession -ComputerName $C -Credential $Credential 

  #              Invoke-Command -Session $Session -ScriptBlock {
  #                  Get-Content -path "$Using:UserProfile\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"
  #              }

  #              Remove-PSSession $Session 
            }
            Else {
                $UserProfile = $env:USERPROFILE
                Get-Content -path "$UserProfile\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"
            }            
        }
    }

}

#-------------------------------------------------------------------------------------

Function Set-JavaExceptionList {

<#
    .Synopsis
        Updates Jave Site Exception List

    .Description
        Adds a site to the Java Control Panel Site Exception List.

    .Example
        Add a site.

        $List = Get-JavaExceptionList
        Set-JaveExceptionList -ExceptionList $List -Site Https://contoso.com

    .Link
 
https://cl-chang.blogspot.com/2017/02/configure-java-control-panel-settings.
html

    .NOTE
        Author : Jeff Buenting
        Date : 2019 JAN 08

#>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory = $True)]
        [String[]]$ExceptionList,

        [Parameter (Mandatory = $True) ]
        [String[]]$Site
    )

    foreach ( $S in $Site ) {
        # ----- Does it already exist in the list?
        if ( $ExceptionList -Notcontains $S ) {
            Write-Verbose "$S does not exist.  Adding."
            $ExceptionList += $S
        }
    }


    # ----- Save ExceptionList
    $UserProfile = $env:USERPROFILE

    Write-verbose "Saving Site Exception List"
    Set-Content -path "$UserProfile\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites" -Value $ExceptionList -Force
     

}
