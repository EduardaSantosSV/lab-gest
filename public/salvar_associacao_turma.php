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

$matricula = $_POST['matricula'] ?? '';
$id_turma = filter_var($_POST['id_turma'] ?? '', FILTER_VALIDATE_INT);

if (!preg_match('/^[0-9]{10}$/', $matricula) || $id_turma === false) {
    die("Dados inválidos. <br><br><a href='associar_turma.php'>Voltar</a>");
}

$stmtExiste = db_execute($pdo, "
    SELECT 1 FROM pertence WHERE matricula_aluno = :matricula AND id_turma = :id_turma
", [
    ':matricula' => $matricula,
    ':id_turma' => $id_turma
]);

if ($stmtExiste->fetch()) {
    die("Este aluno já está associado a essa turma. <br><br><a href='associar_turma.php'>Voltar</a>");
}

db_execute($pdo, "
    INSERT INTO pertence (matricula_aluno, id_turma) VALUES (:matricula, :id_turma)
", [
    ':matricula' => $matricula,
    ':id_turma' => $id_turma
]);

header("Location: associar_turma.php?sucesso=1");
exit;
