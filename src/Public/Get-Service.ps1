Function Get-Service {
    [CmdletBinding()]

    Param(
        [Parameter( Position = 0, ValueFromPipeline = $True )]
        [String] $Name
    )

    Begin {
        # Stop Function if Not Linux
        If ( -Not $IsLinux ) {
            Throw "This function should only be run on Linux systems"
        }
    }

    Process {

        if ( (Get-Process -Id 1).ProcessName -eq 'systemd') {

            if ( $PSBoundParameters.ContainsKey('Name') ) {
                $services = & systemctl list-units "$Name.service" --type=service --no-legend --all --no-pager
            }
            else {
                $services = & systemctl list-units --type=service --no-legend --all --no-pager
            }

            $services | ForEach-Object {
                $service = $_ -Split '\s+'

                $servicename, $load, $active, $sub, $desc = $service

                [PSCustomObject]@{
                    PSTypeName = 'linuxservicemodule.systemdservice'
                    Name        = $servicename.Split('.') | Select-Object -First 1
                    Load        = $load
                    Active      = $active
                    State       = $sub
                    Description = $desc -join " "
                }
            }
        }
        else {

            $services = & service --status-all *>&1

            $services | ForEach-Object {
                $service = $_.ToString()

                $status = switch ($service[3]) {
                    '-' { "Stopped" }
                    '+' { "Running" }
                    '?' { "Unavailable" }
                    default { "Unavailable" }
                }

                $servicename = ($service -split " ")[5]


                $object = [PSCustomObject]@{
                    PSTypeName = 'linuxservicemodule.simpleservice'
                    Name  = $servicename
                    State = $status
                }

                if ($PSBoundParameters.ContainsKey('Name') ) {

                    if ( $object.Name -eq $Name ) {
                        $object
                    }
                }
                else {

                    $object

                }
            }
        }
    }
}