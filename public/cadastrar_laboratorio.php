<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem cadastrar laboratórios.");
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Cadastrar Laboratório - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Cadastrar laboratório</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Laboratório cadastrado com sucesso.</p>
    <?php endif; ?>

    <form action="salvar_laboratorio.php" method="POST">
        <?= csrf_input() ?>

        <label>Bloco</label>
        <input type="text" name="bloco" maxlength="50" required>

        <label>Andar</label>
        <input type="number" name="andar" required>

        <label>Capacidade</label>
        <input type="number" name="capacidade" min="1" required>

        <button type="submit">Cadastrar</button>
    </form>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
