<?php
session_start();

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

$tipo = $_SESSION['tipo_usuario'];
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Painel - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">

    <h1>Olá, <?= htmlspecialchars($_SESSION['nome']) ?> 👋</h1>
    <p>Perfil: <?= htmlspecialchars($tipo) ?></p>

    <div class="cards">

        <?php if ($tipo == 'aluno' || $tipo == 'professor'): ?>
            <a href="abrir_chamado.php" class="card">
                <h3>Abrir chamado</h3>
                <p>Registrar problema em equipamento de informática.</p>
            </a>

            <a href="meus_chamados.php" class="card">
                <h3>Meus chamados</h3>
                <p>Ver chamados que você abriu.</p>
            </a>
        <?php endif; ?>

        <?php if ($tipo == 'professor'): ?>
            <a href="agendar_lab.php" class="card dark">
                <h3>Agendar laboratório</h3>
                <p>Registrar retirada de chave.</p>
            </a>

            <a href="minhas_chaves.php" class="card">
                <h3>Minhas chaves</h3>
                <p>Ver laboratórios/chaves retiradas.</p>
            </a>
        <?php endif; ?>

        <?php if ($tipo == 'tecnico'): ?>
            <a href="chamados_tecnico.php" class="card dark">
                <h3>Chamados atribuídos</h3>
                <p>Ver e atualizar andamento dos chamados.</p>
            </a>
        <?php endif; ?>

    </div>

    <a href="logout.php" class="logout">Sair</a>

</div>

</body>
</html>