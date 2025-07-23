<?php
function displayDirectoryTree($directory, $level = 0) {
    // Comprobar si el directorio existe
    if (!is_dir($directory)) {
        echo "El directorio no existe.";
        return;
    }

    // Abrir el directorio
    $files = scandir($directory);
    
    // Mostrar los archivos y carpetas del directorio
    foreach ($files as $file) {
        // Saltarse las entradas '.' y '..'
        if ($file == '.' || $file == '..') continue;
        
        // Indentación para simular un árbol
        $indent = str_repeat('&nbsp;', $level * 4);
        
        // Ruta completa del archivo o carpeta
        $path = $directory . DIRECTORY_SEPARATOR . $file;
        
        // Mostrar archivo o carpeta
        echo $indent . (is_dir($path) ? "📂" : "📄") . " " . $file . "<br>";

        // Si es un directorio, hacer una llamada recursiva
        if (is_dir($path)) {
            displayDirectoryTree($path, $level + 1);
        }
    }
}

// Ruta desde donde quieres empezar el recorrido
$directoryToScan = __DIR__;  // Si está en la raíz del directorio del servidor, usa __DIR__

echo "<h2>Árbol de directorios y archivos:</h2>";
displayDirectoryTree($directoryToScan);
?>
