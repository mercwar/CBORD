<?php
$hex = next($argv) ?: '';

// Start persistent session (save_path and use_cookies=0 are already set in bin\php.ini)
if (session_status() !== PHP_SESSION_ACTIVE) {
    $sessDir = ini_get('session.save_path') ?: (dirname(PHP_BINARY) . '\\..\\sessions');
    if (!is_dir($sessDir)) {
        mkdir($sessDir, 0777, true);
    }
    $sidFile = rtrim($sessDir, '\\/') . '\\cybord.sid';
    $sid = (file_exists($sidFile) && filesize($sidFile) > 0)
        ? trim(file_get_contents($sidFile))
        : bin2hex(random_bytes(16));
    file_put_contents($sidFile, $sid);
    session_id($sid);
    session_start();
}

// Track persistent session runs & last hex payload
$_SESSION['run_count'] = ($_SESSION['run_count'] ?? 0) + 1;
if ($hex !== '') {
    $_SESSION['last_hex'] = $hex;
}

echo "  [1/6] PHP Engine  : " . PHP_VERSION . PHP_EOL;
echo "  [2/6] Session     : ACTIVE (ID: " . substr(session_id(), 0, 12) . "... | Run #" . $_SESSION['run_count'] . ")" . PHP_EOL;
echo "  [3/6] FFI Module  : " . (extension_loaded('ffi') ? 'ACTIVE' : 'MISSING (ext_dir=' . ini_get('extension_dir') . ')') . PHP_EOL;

if (!extension_loaded('ffi')) {
    exit(2);
}

// Load cbord.dll directly from the same bin\ directory
$binDir  = __DIR__;
$dllPath = $binDir . '\\cbord.dll';

$k32 = FFI::cdef("
    void* LoadLibraryA(const char* lpLibFileName);
    unsigned int GetLastError(void);
", "kernel32.dll");

$hMod = $k32->LoadLibraryA($dllPath);

if ($hMod === null) {
    echo "  [4/6] Target DLL  : FAILED (Win32 Err " . $k32->GetLastError() . " -> " . $dllPath . ")" . PHP_EOL;
    exit(3);
}

echo "  [4/6] Target DLL  : LOADED (" . $dllPath . ")" . PHP_EOL;

// Decode Cyborg Hex String payload
$bin     = @hex2bin($hex);
$byteLen = ($bin !== false) ? strlen($bin) : 0;
echo "  [5/6] Hex Payload : " . $hex . " (" . $byteLen . " bytes)" . PHP_EOL;

// Call native Win32 MessageBoxA from user32.dll
$u32 = FFI::cdef("
    int MessageBoxA(void* hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
", "user32.dll");

$msg = "CYBORD PHP CLI Host is LIVE!\n\n"
     . "PHP Version : " . PHP_VERSION . "\n"
     . "Session Run : #" . $_SESSION['run_count'] . " (ID: " . substr(session_id(), 0, 8) . "...)\n"
     . "Loaded DLL  : cbord.dll\n"
     . "Hex Payload : " . $hex . " (" . $byteLen . " bytes)";

// 0x00000040 = MB_ICONINFORMATION | 0x00000000 = MB_OK
$u32->MessageBoxA(null, $msg, "CYBORD + Win32 API Bridge", 0x00000040);

echo "  [6/6] Win32 API   : MessageBoxA executed successfully" . PHP_EOL;
