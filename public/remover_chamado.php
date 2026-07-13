<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] == 'tecnico') {
    die("Acesso negado.");
}

csrf_verificar();

$id_solicitacao = $_POST['id'] ?? null;

if (!$id_solicitacao) {
    die("ID do chamado não informado.");
}

/*
  Remove a solicitação somente se:
  - foi aberta pelo usuário logado
  - ainda está aberta
*/
$sql = "
    DELETE FROM solicitacao
    WHERE id_solicitacao = :id_solicitacao
      AND id_usuario_solicitante = :id_usuario
      AND status = 'aberto'
";

db_execute($pdo, $sql, [
    ':id_solicitacao' => $id_solicitacao,
    ':id_usuario' => $_SESSION['id_usuario']
]);

header("Location: meus_chamados.php");
exit;
?>