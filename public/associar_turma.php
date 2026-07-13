<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem associar alunos a turmas.");
}

$alunos = db_execute($pdo, "
    SELECT a.matricula, u.nome
    FROM aluno a
    INNER JOIN usuario u ON a.id_usuario = u.id_usuario
    ORDER BY u.nome
")->fetchAll(PDO::FETCH_ASSOC);

$turmas = db_execute($pdo, "
    SELECT id_turma, curso, disciplina, semestre, ano
    FROM turma
    ORDER BY ano DESC, semestre, disciplina
")->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Associar Aluno à Turma - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Associar aluno à turma</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Aluno associado à turma com sucesso.</p>
    <?php endif; ?>

    <?php if (count($alunos) == 0 || count($turmas) == 0): ?>
        <p class="erro">É preciso ter ao menos um aluno e uma turma cadastrados.</p>
    <?php else: ?>

        <form action="salvar_associacao_turma.php" method="POST">
            <?= csrf_input() ?>

            <label>Aluno</label>
            <select name="matricula" required>
                <option value="">Selecione</option>
                <?php foreach ($alunos as $aluno): ?>
                    <option value="<?= htmlspecialchars($aluno['matricula']) ?>">
                        <?= htmlspecialchars($aluno['nome']) ?> - <?= htmlspecialchars($aluno['matricula']) ?>
                    </option>
                <?php endforeach; ?>
            </select>

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

            <button type="submit">Associar</button>
        </form>

    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
