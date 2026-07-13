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

$tipos_permitidos = [
    'Computador desktop',
    'Computador portátil',
    'Periférico',
    'Equipamento de rede',
    'Servidor',
    'Multimídia',
    'Armazenamento'
];

$nome = trim($_POST['nome'] ?? '');
$tipo = $_POST['tipo'] ?? '';
$patrimonio = trim($_POST['patrimonio'] ?? '');
$id_laboratorio = filter_var($_POST['id_laboratorio'] ?? '', FILTER_VALIDATE_INT);
$descricao = trim($_POST['descricao'] ?? '');

if ($nome === '' || !in_array($tipo, $tipos_permitidos, true) || $id_laboratorio === false) {
    die("Dados inválidos. <br><br><a href='cadastrar_equipamento.php'>Voltar</a>");
}

if ($patrimonio !== '') {
    $stmtExiste = db_execute($pdo, "SELECT 1 FROM equipamentos WHERE patrimonio = :patrimonio", [
        ':patrimonio' => $patrimonio
    ]);

    if ($stmtExiste->fetch()) {
        die("Já existe um equipamento com esse patrimônio. <br><br><a href='cadastrar_equipamento.php'>Voltar</a>");
    }
}

$sql = "
    INSERT INTO equipamentos (nome, tipo, status, descricao, id_laboratorio, patrimonio)
    VALUES (:nome, :tipo, 'ativo', :descricao, :id_laboratorio, :patrimonio)
";

db_execute($pdo, $sql, [
    ':nome' => $nome,
    ':tipo' => $tipo,
    ':descricao' => $descricao !== '' ? $descricao : null,
    ':id_laboratorio' => $id_laboratorio,
    ':patrimonio' => $patrimonio !== '' ? $patrimonio : null
]);

header("Location: cadastrar_equipamento.php?sucesso=1");
exit;
