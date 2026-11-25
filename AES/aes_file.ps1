$Iterations = 100000   # how many times the password is mixed (slows down guessing)

# Turn a password + salt into a 256-bit (32 byte) AES key
function Get-AesKey($password, $salt) {
    $kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
        $password, $salt, $Iterations,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256)
    return $kdf.GetBytes(32)
}

# Read a password without showing it on screen
function Read-Password {
    $secure = Read-Host "Enter password" -AsSecureString
    return [System.Net.NetworkCredential]::new('', $secure).Password
}

# Turn a typed file name into a full path (works for names AND full paths)
function Get-FullPath($path) {
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Encrypt-File($inPath, $outPath, $password) {
    # Random salt, so the same password gives a different key every time
    $salt = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($salt)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.Mode = 'CBC'
    $aes.Padding = 'PKCS7'
    $aes.Key = Get-AesKey $password $salt
    $aes.GenerateIV()   # random 16 byte IV

    $plain = [System.IO.File]::ReadAllBytes($inPath)
    $cipher = $aes.CreateEncryptor().TransformFinalBlock($plain, 0, $plain.Length)

    # Save salt + IV + scrambled data together
    [System.IO.File]::WriteAllBytes($outPath, [byte[]]($salt + $aes.IV + $cipher))
}

function Decrypt-File($inPath, $outPath, $password) {
    $data = [System.IO.File]::ReadAllBytes($inPath)
    if ($data.Length -lt 33) { throw "This file is too small to be an encrypted file." }

    $salt = [byte[]]$data[0..15]                    # first 16 bytes
    $iv = [byte[]]$data[16..31]                   # next 16 bytes
    $cipher = [byte[]]$data[32..($data.Length - 1)]   # the rest

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.Mode = 'CBC'
    $aes.Padding = 'PKCS7'
    $aes.Key = Get-AesKey $password $salt
    $aes.IV = $iv

    $plain = $aes.CreateDecryptor().TransformFinalBlock($cipher, 0, $cipher.Length)
    [System.IO.File]::WriteAllBytes($outPath, $plain)
}

# ==========================================
# USER INTERACTION
# ==========================================
Write-Host "=== AES-256 FILE ENCRYPTION ==="

while ($true) {
    $choice = (Read-Host "`nEncrypt or Decrypt? (e/d, or q to quit)").ToLower()

    if ($choice -eq 'q') { Write-Host "Goodbye!"; break }
    if ($choice -notin @('e', 'd')) { Write-Host "Please enter e, d, or q."; continue }

    $inPath = Get-FullPath (Read-Host "Enter the input file path")
    if (-not (Test-Path $inPath)) { Write-Host "File not found: $inPath"; continue }

    $outPath = Get-FullPath (Read-Host "Enter the output file path")
    $password = Read-Password

    try {
        if ($choice -eq 'e') {
            Encrypt-File $inPath $outPath $password
            Write-Host "Encrypted -> $outPath"
        }
        else {
            Decrypt-File $inPath $outPath $password
            Write-Host "Decrypted -> $outPath"
        }
    }
    catch {
        Write-Host "Failed: $($_.Exception.Message)"
    }
}