<?php
session_start();
require_once "conexao.php";

$email = $_POST['email'];
$senha = $_POST['senha'];
$tipo_usuario = $_POST['tipo_usuario'];

$sql = "SELECT * FROM usuario 
        WHERE email = :email 
        AND senha = :senha 
        AND tipo_usuario = :tipo_usuario";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':email' => $email,
    ':senha' => $senha,
    ':tipo_usuario' => $tipo_usuario
]);

$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if ($usuario) {
    $_SESSION['id_usuario'] = $usuario['id_usuario'];
    $_SESSION['nome'] = $usuario['nome'];
    $_SESSION['tipo_usuario'] = $usuario['tipo_usuario'];

    header("Location: painel.php");
    exit;
} else {
    echo "Login inválido.";
}
?>