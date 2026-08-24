# Append something to test log
Add-Content -Path C:\Windows\Temp\usb-inserted-test.txt -Value "$(Get-Date -format 'u'): USB Flash Drive was inserted.";

# check for correct volume
# check for at least one file in the correct format
# 

# Extract QuickTime header fields
$headerSize=64
$header = Get-Content -Path '.\Moonrise Kingdom.mp4' -AsByteStream -TotalCount $headerSize

# first signature must be of type ftyp
$ftyp = $header[4..7]
$mp4Type = $header[8..11]
