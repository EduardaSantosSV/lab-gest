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
  Primeiro remove registros da tabela realiza_manutencao,
  porque ela depende da solicitação.
*/
$sql1 = "
    DELETE FROM realiza_manutencao
    WHERE id_solicitacao = :id_solicitacao
";

$stmt1 = $pdo->prepare($sql1);
$stmt1->execute([
    ':id_solicitacao' => $id_solicitacao
]);

/*
  Depois remove a solicitação somente se:
  - foi aberta pelo usuário logado
  - ainda está aberta
*/
$sql2 = "
    DELETE FROM solicitacao
    WHERE id_solicitacao = :id_solicitacao
      AND id_usuario_solicitante = :id_usuario
      AND status = 'aberto'
";

$stmt2 = $pdo->prepare($sql2);
$stmt2->execute([
    ':id_solicitacao' => $id_solicitacao,
    ':id_usuario' => $_SESSION['id_usuario']
]);

header("Location: meus_chamados.php");
exit;
?>