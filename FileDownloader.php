<?php
$path = isset($_GET['path']) ? $_GET['path'] : '.';
$realPath = realpath($path);

// Seguridad: evitar salir del directorio base
$base = realpath('.');
if (strpos($realPath, $base) !== 0) {
    die('Acceso no permitido');
}

// Si es una descarga
if (isset($_GET['download'])) {
    $downloadPath = realpath($_GET['download']);
    if (strpos($downloadPath, $base) === 0 && is_file($downloadPath)) {
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($downloadPath) . '"');
        header('Content-Length: ' . filesize($downloadPath));
        readfile($downloadPath);
        exit;
    } else {
        die('Archivo no permitido para descarga');
    }
}

// Mostrar navegador de archivos
$files = scandir($realPath);
echo "<h2>Explorando: $realPath</h2>";
echo "<ul style='list-style-type:none;'>";

// Enlace para subir
if ($realPath !== $base) {
    $parent = dirname($realPath);
    echo "<li><a href='?path=" . urlencode($parent) . "'>⬅️ Subir</a></li>";
}

// Listar archivos y carpetas
foreach ($files as $file) {
    if ($file === '.' || $file === '..') continue;
    $fullPath = "$realPath/$file";
    $relativePath = urlencode($fullPath);
    $modTime = date("Y-m-d H:i:s", filemtime($fullPath));
    $size = is_dir($fullPath) ? '-' : formatSize(filesize($fullPath));

    if (is_dir($fullPath)) {
        echo "<li>📁 <a href='?path=$relativePath'>$file</a> - $modTime - $size</li>";
    } else {
        echo "<li>📄 $file - $modTime - $size 
              - <a href='?download=$relativePath'>📥 Descargar</a></li>";
    }
}
echo "</ul>";

// Función para formato de tamaño
function formatSize($bytes) {
    if ($bytes >= 1073741824) return number_format($bytes / 1073741824, 2) . ' GB';
    if ($bytes >= 1048576) return number_format($bytes / 1048576, 2) . ' MB';
    if ($bytes >= 1024) return number_format($bytes / 1024, 2) . ' KB';
    return $bytes . ' B';
}
?>
