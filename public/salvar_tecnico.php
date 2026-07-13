<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado.");
}

csrf_verificar();

$nome = trim($_POST['nome'] ?? '');
$email = trim($_POST['email'] ?? '');
$senha = $_POST['senha'] ?? '';
$cpf = $_POST['cpf'] ?? '';

if (
    $nome === '' ||
    !filter_var($email, FILTER_VALIDATE_EMAIL) ||
    strlen($senha) < 6 ||
    !preg_match('/^[0-9]{11}$/', $cpf)
) {
    die("Dados inválidos. <br><br><a href='cadastrar_tecnico.php'>Voltar</a>");
}

$senha_hash = password_hash($senha, PASSWORD_DEFAULT);

try {
    $pdo->beginTransaction();

    $stmt = $pdo->prepare("
        INSERT INTO usuario (nome, email, tipo_usuario, senha)
        VALUES (:nome, :email, 'tecnico', :senha)
        RETURNING id_usuario
    ");
    $stmt->execute([
        ':nome' => $nome,
        ':email' => $email,
        ':senha' => $senha_hash
    ]);
    $id_usuario = $stmt->fetchColumn();

    $stmt2 = $pdo->prepare("
        INSERT INTO tecnico_ti (cpf, id_usuario)
        VALUES (:cpf, :id_usuario)
    ");
    $stmt2->execute([
        ':cpf' => $cpf,
        ':id_usuario' => $id_usuario
    ]);

    $pdo->commit();
} catch (PDOException $e) {
    $pdo->rollBack();
    error_log("Erro ao cadastrar técnico: " . $e->getMessage());
    die("Não foi possível cadastrar. Verifique se o e-mail ou o CPF já estão em uso. <br><br><a href='cadastrar_tecnico.php'>Voltar</a>");
}

header("Location: cadastrar_tecnico.php?sucesso=1");
exit;
