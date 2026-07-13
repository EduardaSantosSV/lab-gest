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

$bloco = trim($_POST['bloco'] ?? '');
$andar = filter_var($_POST['andar'] ?? '', FILTER_VALIDATE_INT);
$capacidade = filter_var($_POST['capacidade'] ?? '', FILTER_VALIDATE_INT);

if ($bloco === '' || $andar === false || $capacidade === false || $capacidade < 1) {
    die("Dados inválidos. <br><br><a href='cadastrar_laboratorio.php'>Voltar</a>");
}

$sql = "INSERT INTO laboratorio (bloco, andar, capacidade) VALUES (:bloco, :andar, :capacidade)";

db_execute($pdo, $sql, [
    ':bloco' => $bloco,
    ':andar' => $andar,
    ':capacidade' => $capacidade
]);

header("Location: cadastrar_laboratorio.php?sucesso=1");
exit;
