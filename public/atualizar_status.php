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

$id_solicitacao = $_POST['id_solicitacao'] ?? null;
$status = $_POST['status'] ?? null;

$status_permitidos = ['aberto', 'em atendimento', 'concluido'];

if (!$id_solicitacao || !in_array($status, $status_permitidos)) {
    die("Dados inválidos.");
}

/*
  Pega o CPF do técnico logado.
*/
$sqlCpf = "
    SELECT cpf
    FROM tecnico_ti
    WHERE id_usuario = :id_usuario
";

$stmtCpf = $pdo->prepare($sqlCpf);
$stmtCpf->execute([
    ':id_usuario' => $_SESSION['id_usuario']
]);

$tecnico = $stmtCpf->fetch(PDO::FETCH_ASSOC);

if (!$tecnico) {
    die("Técnico não encontrado.");
}

$cpf = $tecnico['cpf'];

/*
  Atualiza somente se o chamado pertence ao técnico logado.
*/
$sql = "
    UPDATE solicitacao
    SET status = :status
    WHERE id_solicitacao = :id_solicitacao
      AND cpf_tecnico_responsavel = :cpf
";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':status' => $status,
    ':id_solicitacao' => $id_solicitacao,
    ':cpf' => $cpf
]);

header("Location: chamados_tecnico.php");
exit;
?>