<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem associar turmas a laboratórios.");
}

$turmas = db_execute($pdo, "
    SELECT id_turma, curso, disciplina, semestre, ano
    FROM turma
    ORDER BY ano DESC, semestre, disciplina
")->fetchAll(PDO::FETCH_ASSOC);

$laboratorios = db_execute($pdo, "
    SELECT id_laboratorio, bloco, andar
    FROM laboratorio
    ORDER BY id_laboratorio
")->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Associar Turma a Laboratório - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Associar turma a laboratório</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Turma associada ao laboratório com sucesso.</p>
    <?php endif; ?>

    <?php if (count($turmas) == 0 || count($laboratorios) == 0): ?>
        <p class="erro">É preciso ter ao menos uma turma e um laboratório cadastrados.</p>
    <?php else: ?>

        <form action="salvar_associacao_lab.php" method="POST">
            <?= csrf_input() ?>

            <label>Turma</label>
            <select name="id_turma" required>
                <option value="">Selecione</option>
                <?php foreach ($turmas as $turma): ?>
                    <option value="<?= htmlspecialchars($turma['id_turma']) ?>">
                        <?= htmlspecialchars($turma['disciplina']) ?> -
                        <?= htmlspecialchars($turma['curso']) ?> -
                        <?= htmlspecialchars($turma['semestre']) ?>º sem/<?= htmlspecialchars($turma['ano']) ?>
                    </option>
                <?php endforeach; ?>
            </select>

            <label>Laboratório</label>
            <select name="id_laboratorio" required>
                <option value="">Selecione</option>
                <?php foreach ($laboratorios as $lab): ?>
                    <option value="<?= htmlspecialchars($lab['id_laboratorio']) ?>">
                        Laboratório <?= htmlspecialchars($lab['id_laboratorio']) ?> -
                        <?= htmlspecialchars($lab['bloco']) ?> -
                        Andar <?= htmlspecialchars($lab['andar']) ?>
                    </option>
                <?php endforeach; ?>
            </select>

            <button type="submit">Associar</button>
        </form>

    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
