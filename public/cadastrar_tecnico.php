<?php
session_start();
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem cadastrar usuários.");
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Cadastrar Técnico - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Cadastrar técnico de TI</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Técnico cadastrado com sucesso.</p>
    <?php endif; ?>

    <form action="salvar_tecnico.php" method="POST">
        <?= csrf_input() ?>

        <label>Nome</label>
        <input type="text" name="nome" maxlength="100" required>

        <label>E-mail</label>
        <input type="email" name="email" maxlength="100" required>

        <label>Senha</label>
        <input type="password" name="senha" minlength="6" required>

        <label>CPF (11 dígitos)</label>
        <input type="text" name="cpf" pattern="[0-9]{11}" maxlength="11" required>

        <button type="submit">Cadastrar</button>
    </form>

    <br>
    <a href="cadastrar_usuario.php">Voltar</a>
</div>

</body>
</html>
