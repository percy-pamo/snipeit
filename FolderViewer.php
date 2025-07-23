<?php
$path = isset($_GET['path']) ? $_GET['path'] : '.';
$realPath = realpath($path);

// Seguridad para evitar acceder fuera del directorio base
$base = realpath('.');
if (strpos($realPath, $base) !== 0) {
    die('Acceso no permitido');
}

$files = scandir($realPath);

echo "<h2>Explorando: $realPath</h2>";
echo "<ul style='list-style-type:none;'>";

if ($realPath !== $base) {
    $parent = dirname($realPath);
    echo "<li><a href='?path=" . urlencode($parent) . "'>⬅️ Subir</a></li>";
}

foreach ($files as $file) {
    if ($file === '.') continue;
    $fullPath = "$realPath/$file";
    $relativePath = urlencode($fullPath);

    $modTime = date("Y-m-d H:i:s", filemtime($fullPath));
    $size = is_dir($fullPath) ? '-' : formatSize(filesize($fullPath));

    if (is_dir($fullPath)) {
        echo "<li>📁 <a href='?path=$relativePath'>$file</a> - $modTime - $size</li>";
    } else {
        echo "<li>📄 $file - $modTime - $size</li>";
    }
}

echo "</ul>";

// Función para formato de tamaño
function formatSize($bytes) {
    if ($bytes >= 1073741824) {
        return number_format($bytes / 1073741824, 2) . ' GB';
    } elseif ($bytes >= 1048576) {
        return number_format($bytes / 1048576, 2) . ' MB';
    } elseif ($bytes >= 1024) {
        return number_format($bytes / 1024, 2) . ' KB';
    } else {
        return $bytes . ' B';
    }
}
?>
