<?php
session_start();
require_once __DIR__ . "/../includes/csrf.php";
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>LabGest - Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body class="login-body">

<div class="login-box">
    <h1>LabGest</h1>
    <p>Sistema de Gestão de Laboratórios</p>

    <form action="autenticar.php" method="POST">
        <?= csrf_input() ?>

        <label>E-mail</label>
        <input type="email" name="email" placeholder="seu@email.edu.br" required>

        <label>Senha</label>
        <input type="password" name="senha" placeholder="Digite sua senha" required>

        <button type="submit">Entrar</button>
    </form>
</div>

</body>
</html>