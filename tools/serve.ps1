param([string]$Root, [int]$Port = 8765)
# Minimal static server that mimics GitHub Pages (dir -> index.html, 404.html fallback)
$types = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css'; '.js'='text/javascript'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.svg'='image/svg+xml'; '.ico'='image/x-icon'; '.mp4'='video/mp4'; '.xml'='application/xml'; '.txt'='text/plain'; '.json'='application/json'; '.webp'='image/webp' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Serving $Root on http://localhost:$Port/"
while ($l.IsListening) {
  $ctx = $l.GetContext()
  try {
    $p = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    $f = Join-Path $Root ($p.TrimStart('/') -replace '/', '\')
    $status = 200
    if (Test-Path $f -PathType Container) {
      if (-not $p.EndsWith('/')) { $ctx.Response.Redirect("$p/"); $ctx.Response.Close(); continue }
      $f = Join-Path $f 'index.html'
    }
    if (-not (Test-Path $f -PathType Leaf)) { $f = Join-Path $Root '404.html'; $status = 404 }
    $bytes = [IO.File]::ReadAllBytes($f)
    $ext = [IO.Path]::GetExtension($f).ToLower()
    $ctx.Response.StatusCode = $status
    $ctx.Response.ContentType = $(if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' })
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    Write-Host "$status $p"
  } catch { Write-Host "ERR $_" } finally { $ctx.Response.Close() }
}
