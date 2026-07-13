<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem cadastrar turmas.");
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Cadastrar Turma - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Cadastrar turma</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Turma cadastrada com sucesso.</p>
    <?php endif; ?>

    <form action="salvar_turma.php" method="POST">
        <?= csrf_input() ?>

        <label>Curso</label>
        <input type="text" name="curso" maxlength="100" required>

        <label>Disciplina</label>
        <input type="text" name="disciplina" maxlength="100" required>

        <label>Semestre</label>
        <input type="number" name="semestre" min="1" required>

        <label>Ano</label>
        <input type="number" name="ano" min="2000" max="2100" required>

        <button type="submit">Cadastrar</button>
    </form>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
