function Change-Text($filename, $originalText, $newText)
{
 (Get-Content $filename -Raw).replace($originalText, $newText) | Set-Content $filename
}
