Write-Host "Updating Profit-Times"

# Ensure git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
	Write-Error "git not found in PATH. Install Git or add it to PATH."
	exit 1
}

# Optional: check for Quarto
$quartoPresent = $true
if (-not (Get-Command quarto -ErrorAction SilentlyContinue)) {
	Write-Warning "Quarto CLI not found. The publish step will be skipped unless Quarto is installed."
	$quartoPresent = $false
}

# Show status and only commit if there are changes
$changes = git status --porcelain 2>$null
if ([string]::IsNullOrWhiteSpace($changes)) {
	Write-Host "No changes to commit."
} else {
	# Prompt for a commit message, use a timestamped default if left blank
	$commitMsg = Read-Host "Enter commit message (leave empty to use default)"
	if ([string]::IsNullOrWhiteSpace($commitMsg)) {
		$commitMsg = "Site update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
	}

	git add .
	if ($LASTEXITCODE -ne 0) { Write-Error "git add failed"; exit $LASTEXITCODE }

	git commit -m "$commitMsg"
	if ($LASTEXITCODE -ne 0) { Write-Error "git commit failed (no changes staged or commit blocked)"; exit $LASTEXITCODE }

	git push origin main
	if ($LASTEXITCODE -ne 0) { Write-Error "git push failed"; exit $LASTEXITCODE }
}

if ($quartoPresent) {
	Write-Host "Publishing to GitHub Pages via Quarto..."
	quarto publish gh-pages
	if ($LASTEXITCODE -ne 0) { Write-Error "quarto publish failed"; exit $LASTEXITCODE }
} else {
	Write-Host "Skipping Quarto publish (Quarto CLI not found)."
}

Write-Host "Finished Updating Profit-Times"