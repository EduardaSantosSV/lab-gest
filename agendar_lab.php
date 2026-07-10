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

$sqlProfessor = "
    SELECT siape
    FROM professor
    WHERE id_usuario = :id_usuario
";

$stmtProfessor = $pdo->prepare($sqlProfessor);
$stmtProfessor->execute([
    ':id_usuario' => $_SESSION['id_usuario']
]);

$professor = $stmtProfessor->fetch(PDO::FETCH_ASSOC);

if (!$professor) {
    die("Professor não encontrado para este usuário.");
}

$sqlLabs = "
    SELECT id_laboratorio, bloco, andar, capacidade
    FROM laboratorio
    ORDER BY id_laboratorio
";

$stmtLabs = $pdo->query($sqlLabs);
$laboratorios = $stmtLabs->fetchAll(PDO::FETCH_ASSOC);

$horarios = [
    '08:00' => '08:00 até 09:40',
    '10:00' => '10:00 até 11:40',
    '13:30' => '13:30 até 15:10',
    '15:10' => '15:10 até 16:50',
    '17:00' => '17:00 até 18:40',
    '18:40' => '18:40 até 20:20',
    '20:20' => '20:20 até 22:00'
];
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Agendar Laboratório - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Agendar Laboratório</h1>

    <p>
        Professor:
        <strong><?= htmlspecialchars($_SESSION['nome']) ?></strong>
    </p>

    <p>
        SIAPE:
        <strong><?= htmlspecialchars($professor['siape']) ?></strong>
    </p>

    <form action="salvar_agendamento.php" method="POST">

        <label>Laboratório</label>
        <select name="id_laboratorio" required>
            <option value="">Selecione o laboratório</option>

            <?php foreach ($laboratorios as $lab): ?>
                <option value="<?= htmlspecialchars($lab['id_laboratorio']) ?>">
                    Laboratório <?= htmlspecialchars($lab['id_laboratorio']) ?> -
                    <?= htmlspecialchars($lab['bloco']) ?> -
                    Andar <?= htmlspecialchars($lab['andar']) ?> -
                    Capacidade <?= htmlspecialchars($lab['capacidade']) ?>
                </option>
            <?php endforeach; ?>
        </select>

        <label>Data da retirada</label>
        <input type="date" name="data_retirada" required>

        <label>Horário da retirada</label>
        <select name="hora_retirada" required>
            <option value="">Selecione o horário</option>

            <?php foreach ($horarios as $inicio => $descricao): ?>
                <option value="<?= $inicio ?>">
                    <?= $descricao ?>
                </option>
            <?php endforeach; ?>
        </select>

        <button type="submit">Confirmar agendamento</button>
    </form>

    <br>

    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>