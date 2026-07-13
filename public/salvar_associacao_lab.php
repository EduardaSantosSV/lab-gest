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

$id_turma = filter_var($_POST['id_turma'] ?? '', FILTER_VALIDATE_INT);
$id_laboratorio = filter_var($_POST['id_laboratorio'] ?? '', FILTER_VALIDATE_INT);

if ($id_turma === false || $id_laboratorio === false) {
    die("Dados inválidos. <br><br><a href='associar_lab_turma.php'>Voltar</a>");
}

$stmtExiste = db_execute($pdo, "
    SELECT 1 FROM utiliza WHERE id_turma = :id_turma AND id_laboratorio = :id_laboratorio
", [
    ':id_turma' => $id_turma,
    ':id_laboratorio' => $id_laboratorio
]);

if ($stmtExiste->fetch()) {
    die("Esta turma já está associada a esse laboratório. <br><br><a href='associar_lab_turma.php'>Voltar</a>");
}

db_execute($pdo, "
    INSERT INTO utiliza (id_turma, id_laboratorio) VALUES (:id_turma, :id_laboratorio)
", [
    ':id_turma' => $id_turma,
    ':id_laboratorio' => $id_laboratorio
]);

header("Location: associar_lab_turma.php?sucesso=1");
exit;
