<?php
$sessDir = ini_get('session.save_path') ?: (dirname(PHP_BINARY) . '\\..\\sessions');
if (!is_dir($sessDir)) {
    mkdir($sessDir, 0777, true);
}

$sidFile = rtrim($sessDir, '\\/') . DIRECTORY_SEPARATOR . 'cybord.sid';
if (file_exists($sidFile) && filesize($sidFile) > 0) {
    $sid = trim(file_get_contents($sidFile));
} else {
    $sid = bin2hex(random_bytes(16));
    file_put_contents($sidFile, $sid);
}

session_id($sid);
session_start();
