<#
Generate a json formated list like below based on filters specified:

"UbuntuServer 12.04.3-LTS": {
  "imagePublisher": "Canonical",
  "imageOffer": "UbuntuServer", 
  "imageSku": "12.04.3-LTS"     
},
"UbuntuServer 12.04.4-LTS": {
  "imagePublisher": "Canonical",
  "imageOffer": "UbuntuServer", 
  "imageSku": "12.04.4-LTS"     
},
"UbuntuServer 12.04.5-LTS": {
  "imagePublisher": "Canonical",
  "imageOffer": "UbuntuServer",
  "imageSku": "12.04.5-LTS"
},
...

#>

$location = 'westeurope'
$all = Get-AzVMImagePublisher -Location $location |
        where { ('MicrosoftWindowsServer', 'Canonical', 'RedHat', 'OpenLogic').Contains($_.PublisherName) } |
        Get-AzVMImageOffer -Location $location |
        where { ('WindowsServer', 'UbuntuServer', 'CentOS', 'RHEL').Contains($_.Offer) } |
        Get-AzVMImageSku -Location $location
$filtered = $all |
    where { ($_.Offer -eq 'UbuntuServer' -and $_.Skus -match '(?=.*LTS)^(?!.*DAILY)') -or
            ($_.Offer -eq 'WindowsServer' -and $_.Skus -match '(?=2016|2019)(?!.*zhcn)') -or
            ($_.Offer -eq 'CentOS' -and $_.Skus -match '^(?!.*DAILY)') -or
            ($_.Offer -eq 'RHEL' -and $_.Skus -match '^(?!.*DAILY)^(?!.*BETA)') }
$filtered | foreach {
'"{0}": {{
  "imagePublisher": "{1}",
  "imageOffer": "{2}",
  "imageSku": "{3}"
}},' -f ($_.Offer + ' ' + $_.Skus), $_.PublisherName, $_.Offer, $_.Skus}

$filtered | foreach {'"' + $_.Offer + ' ' + $_.Skus + '",'}