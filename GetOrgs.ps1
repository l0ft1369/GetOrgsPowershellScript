function ProcessOrgs
{
    param(
        $orgs
    )

    $Limit = 300

    foreach ($org in $orgs) 
    {
        $newObjOrg = $org | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100

                foreach ($field in $org.organization_fields.PSObject.Properties)
                {
                
                    if ($null -eq $field.value)
                    {
                         Add-Member -NotePropertyName $field.Name -NotePropertyValue 0 -InputObject $newObjOrg
                         
                    }
                    else
                    {
                        Add-Member -NotePropertyName $field.Name -NotePropertyValue $field.Value -InputObject $newObjOrg
                        
                    } 
                }
            $GlobalList.Add($newObjOrg)
        
    }
}

$username = Read-Host -Prompt 'Username: '
$password = Read-Host -Prompt 'Password: '
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$GlobalList = [System.Collections.ArrayList]@()
#$GlobalList = [System.Collections.Hashtable]::new()

Write-Output $base64AuthInfo

$headers = @{
    Authorization=("Basic {0}" -f $base64AuthInfo)
    Accept="application/json"
}

$Orgs = Invoke-RestMethod -Method GET -Uri "https://logpointsupport.zendesk.com/api/v2/organizations" -Headers $headers
$Page = 1

ProcessOrgs -orgs $Orgs.organizations

while ($Orgs.next_page -ne $null) {
    
    $Page += 1
    $Orgs = Invoke-RestMethod -Method GET -Uri "https://logpointsupport.zendesk.com/api/v2/organizations?page=$Page" -Headers $headers
    ProcessOrgs -orgs $Orgs.organizations

    Write-Output "Page : $Page"
}


#$GlobalList | out-file "ZendeskOrgs.json"
$GlobalList | Export-Csv -Path "./ZendeskOrgs.csv"