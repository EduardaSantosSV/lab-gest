<?php
session_start();
require_once "conexao.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'professor') {
    die("Acesso negado. Apenas professores podem agendar laboratório.");
}

if (
    empty($_POST['id_laboratorio']) ||
    empty($_POST['data_retirada']) ||
    empty($_POST['hora_retirada'])
) {
    die("Preencha todos os campos do agendamento.");
}

$id_laboratorio = $_POST['id_laboratorio'];
$data_retirada = $_POST['data_retirada'];
$hora_retirada = $_POST['hora_retirada'];

$horariosPermitidos = [
    '08:00',
    '10:00',
    '13:30',
    '15:10',
    '17:00',
    '18:40',
    '20:20'
];

if (!in_array($hora_retirada, $horariosPermitidos)) {
    die("
        Horário inválido. O agendamento só pode ser feito nos horários definidos.
        <br><br>
        <a href='agendar_lab.php'>Voltar</a>
    ");
}

$sqlSiape = "
    SELECT siape
    FROM professor
    WHERE id_usuario = :id_usuario
";

$stmtSiape = $pdo->prepare($sqlSiape);
$stmtSiape->execute([
    ':id_usuario' => $_SESSION['id_usuario']
]);

$professor = $stmtSiape->fetch(PDO::FETCH_ASSOC);

if (!$professor) {
    die("Professor não encontrado para este usuário.");
}

$siape = $professor['siape'];

/*
    Verifica se o laboratório já está agendado naquele dia e horário.
*/
$sqlConflito = "
    SELECT id_agenda
    FROM agenda_labs_chave
    WHERE id_laboratorio = :id_laboratorio
      AND data_retirada = :data_retirada
      AND hora_retirada = :hora_retirada
      AND status_chave IN ('retirada', 'atrasada')
    LIMIT 1
";

$stmtConflito = $pdo->prepare($sqlConflito);
$stmtConflito->execute([
    ':id_laboratorio' => $id_laboratorio,
    ':data_retirada' => $data_retirada,
    ':hora_retirada' => $hora_retirada
]);

$conflito = $stmtConflito->fetch(PDO::FETCH_ASSOC);

if ($conflito) {
    die("
        Este laboratório já está agendado para esse dia e horário.
        <br>
        Escolha outro horário disponível.
        <br><br>
        <a href='agendar_lab.php'>Voltar</a>
    ");
}

$sql = "
    INSERT INTO agenda_labs_chave (
        data_retirada,
        hora_retirada,
        status_chave,
        siape_professor,
        id_laboratorio
    ) VALUES (
        :data_retirada,
        :hora_retirada,
        'retirada',
        :siape_professor,
        :id_laboratorio
    )
";

$stmt = $pdo->prepare($sql);

$stmt->execute([
    ':data_retirada' => $data_retirada,
    ':hora_retirada' => $hora_retirada,
    ':siape_professor' => $siape,
    ':id_laboratorio' => $id_laboratorio
]);

header("Location: minhas_chaves.php");
exit;
?>