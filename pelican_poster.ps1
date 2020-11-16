<#
    .SYNOPSIS
        A script that will handle publishing scheduled posts on pelican
#>


$postsPath = "E:\projetos\sipmann.github.io\content\";
$files = Get-ChildItem $postsPath -File -Filter *.md

<# Get the current datetime so we can compare with the psot date #>
$now = Get-Date

<# Set the current location, with this we can work with the git commands #>
Set-Location $postsPath

foreach($file in $files) {

	<# Get's only posts with draft status #>
    $isDraft = Get-Content ($postsPath + $file) | Where-Object { $_ -ccontains "Status: Draft" }

    if ($isDraft) {

		<# First we find the line with the date, then we get only the datetime and then parse it #>
        $pubDate = [datetime]::parseexact(((Get-Content ($postsPath + $file) | Where-Object { $_ -Match "^Date:*" }) -split '\s+', 2)[1], 'yyyy-MM-dd HH:mm', $null)

		<# TODO: Maybe call google and bing api to submit a new url #>
		$slug = ((Get-Content ($postsPath + $file) | Where-Object { $_ -Match "^Slug:*" }) -split '\s+', 2)[1]
        
        if ($now -ge $pubDate) {

			<# Sets the content without the Draft status #>
            ((Get-Content ($postsPath + $file)) -replace 'Status: Draft', '') | Set-Content ($postsPath + $file)

            git add .
            git commit -m ("New scheduled post: " + $file)
            git push origin master
        }
    }
}