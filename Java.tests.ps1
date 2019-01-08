# ----- Get the module name
if ( -Not $PSScriptRoot ) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$ModulePath = $PSScriptRoot

$Global:ModuleName = $ModulePath | Split-Path -Leaf

# ----- Remove and then import the module.  This is so any new changes are imported.
Get-Module -Name $ModuleName -All | Remove-Module -Force

Import-Module "$ModulePath\$ModuleName.PSD1" -Force -ErrorAction Stop  

InModuleScope $ModuleName {

    #-------------------------------------------------------------------------------------
    # ----- Check if all fucntions in the module have a unit tests

    Describe "$ModuleName : Module Tests" {

        $Module = Get-module -Name $ModuleName -Verbose

        $testFile = Get-ChildItem $module.ModuleBase -Filter '*.Tests.ps1' -File -verbose
    
        $testNames = Select-String -Path $testFile.FullName -Pattern 'Describe "\$ModuleName : (.*)"' | ForEach-Object {
              $_.matches.groups[1].value
        }

        $moduleCommandNames = (Get-Command -Module $ModuleName | where CommandType -ne Alias)

        it 'should have a test for each function' {
            Compare-Object $moduleCommandNames $testNames | where { $_.SideIndicator -eq '<=' } | select inputobject | should beNullOrEmpty
        }
    }

 
#-------------------------------------------------------------------------------------
    Write-Output "`n`n"

    Describe "$ModuleName : Get-JavaExceptionList" {

        Mock -CommandName Get-Content -MockWith {
            return "Sitename"
        }

        Context Output {

            It "Should return an array of Sites" {
                Get-JavaExceptionList | Should beoftype String
            }
        }
    }

    Describe "$ModuleName : Set-JavaExceptionList" {

        Mock -CommandName Get-Content -MockWith {
            return "Sitename"
        }

        Mock -CommandName Set-Content -MockWith {
            New-Item -Path "TestDrive:\list.txt" -ItemType File
        }

        Context Output {

            It "Should Save to a file" {

                $List = Get-JavaExceptionList 
                Set-JavaExceptionList -ExceptionList $List -Site "Http:/hello.com"

                "TestDrive:\list.txt" | Should Exist
            }
        }
    }

}
