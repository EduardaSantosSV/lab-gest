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

$curso = trim($_POST['curso'] ?? '');
$disciplina = trim($_POST['disciplina'] ?? '');
$semestre = filter_var($_POST['semestre'] ?? '', FILTER_VALIDATE_INT);
$ano = filter_var($_POST['ano'] ?? '', FILTER_VALIDATE_INT);

if ($curso === '' || $disciplina === '' || $semestre === false || $semestre < 1 || $ano === false) {
    die("Dados inválidos. <br><br><a href='cadastrar_turma.php'>Voltar</a>");
}

$sql = "INSERT INTO turma (curso, disciplina, semestre, ano) VALUES (:curso, :disciplina, :semestre, :ano)";

db_execute($pdo, $sql, [
    ':curso' => $curso,
    ':disciplina' => $disciplina,
    ':semestre' => $semestre,
    ':ano' => $ano
]);

header("Location: cadastrar_turma.php?sucesso=1");
exit;
