<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

csrf_verificar();

$tipos_permitidos = ['hardware', 'rede', 'periferico', 'software'];

if (!in_array($_POST['tipo_solicitacao'] ?? '', $tipos_permitidos, true)) {
    die("Tipo de solicitação inválido.");
}

$sql = "INSERT INTO solicitacao (
            descricao,
            tipo_solicitacao,
            status,
            id_usuario_solicitante,
            cpf_tecnico_responsavel,
            id_equipamento
        ) VALUES (
            :descricao,
            :tipo_solicitacao,
            'aberto',
            :id_usuario_solicitante,
            :cpf_tecnico_responsavel,
            :id_equipamento
        )";

db_execute($pdo, $sql, [
    ':descricao' => $_POST['descricao'],
    ':tipo_solicitacao' => $_POST['tipo_solicitacao'],
    ':id_usuario_solicitante' => $_SESSION['id_usuario'],
    ':cpf_tecnico_responsavel' => $_POST['cpf_tecnico_responsavel'],
    ':id_equipamento' => $_POST['id_equipamento']
]);

header("Location: painel.php");
exit;
?>