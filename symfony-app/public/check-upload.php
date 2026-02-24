<?php
// public/check-upload.php

echo "<h2>Configuration PHP</h2>";
echo "upload_max_filesize: " . ini_get('upload_max_filesize') . "<br>";
echo "post_max_size: " . ini_get('post_max_size') . "<br>";
echo "max_execution_time: " . ini_get('max_execution_time') . "s<br>";
echo "max_input_time: " . ini_get('max_input_time') . "s<br>";
echo "memory_limit: " . ini_get('memory_limit') . "<br>";

echo "<h2>Test d'upload</h2>";
echo '<form action="" method="post" enctype="multipart/form-data">';
echo '<input type="file" name="test_file">';
echo '<input type="submit" value="Upload">';
echo '</form>';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['test_file'])) {
    echo "<h3>Résultat:</h3>";
    echo "Fichier: " . $_FILES['test_file']['name'] . "<br>";
    echo "Taille: " . $_FILES['test_file']['size'] . " bytes<br>";
    echo "Erreur: " . $_FILES['test_file']['error'] . "<br>";

    if ($_FILES['test_file']['error'] === UPLOAD_ERR_OK) {
        echo "<span style='color:green'>✅ Upload réussi !</span>";
    } else {
        echo "<span style='color:red'>❌ Échec de l'upload</span>";
    }
}
