<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'professor') {
    die("Acesso negado. Apenas professores podem devolver chaves.");
}

csrf_verificar();

$id_agenda = filter_var($_POST['id_agenda'] ?? '', FILTER_VALIDATE_INT);

if ($id_agenda === false) {
    die("Dados inválidos.");
}

/*
    Pega o SIAPE do professor logado.
*/
$stmtSiape = db_execute($pdo, "
    SELECT siape
    FROM professor
    WHERE id_usuario = :id_usuario
", [
    ':id_usuario' => $_SESSION['id_usuario']
]);

$professor = $stmtSiape->fetch(PDO::FETCH_ASSOC);

if (!$professor) {
    die("Professor não encontrado para este usuário.");
}

$siape = $professor['siape'];

/*
    Marca a devolução somente se a chave é do professor logado
    e ainda não foi devolvida. O gatilho do banco exige data e hora
    de devolução quando o status vira 'devolvida'.
*/
db_execute($pdo, "
    UPDATE agenda_labs_chave
    SET status_chave = 'devolvida',
        data_devolucao = CURRENT_DATE,
        hora_devolucao = CURRENT_TIME
    WHERE id_agenda = :id_agenda
      AND siape_professor = :siape
      AND status_chave IN ('retirada', 'atrasada')
", [
    ':id_agenda' => $id_agenda,
    ':siape' => $siape
]);

header("Location: minhas_chaves.php?devolvida=1");
exit;
