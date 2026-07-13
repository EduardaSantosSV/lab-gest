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

    <?php if ($tipo == 'tecnico'): ?>
        <h2 class="section-title">Cadastros</h2>

        <div class="cards">
            <a href="cadastrar_laboratorio.php" class="card">
                <h3>Laboratório</h3>
                <p>Cadastrar novo laboratório.</p>
            </a>

            <a href="cadastrar_equipamento.php" class="card">
                <h3>Equipamento</h3>
                <p>Cadastrar equipamento e associar a um laboratório.</p>
            </a>

            <a href="cadastrar_turma.php" class="card">
                <h3>Turma</h3>
                <p>Cadastrar nova turma.</p>
            </a>

            <a href="cadastrar_usuario.php" class="card">
                <h3>Usuário</h3>
                <p>Cadastrar aluno, professor ou técnico.</p>
            </a>

            <a href="associar_turma.php" class="card">
                <h3>Associar aluno à turma</h3>
                <p>Vincular um aluno a uma turma existente.</p>
            </a>

            <a href="associar_lab_turma.php" class="card">
                <h3>Associar turma a laboratório</h3>
                <p>Registrar laboratórios utilizados por uma turma.</p>
            </a>
        </div>

        <h2 class="section-title">Consultas</h2>

        <div class="cards">
            <a href="consultar_equipamentos.php" class="card">
                <h3>Equipamentos por laboratório</h3>
                <p>Listar equipamentos agrupados por laboratório.</p>
            </a>

            <a href="consultar_turmas.php" class="card">
                <h3>Turmas, alunos e labs</h3>
                <p>Ver alunos e laboratórios de cada turma.</p>
            </a>

            <a href="consultar_manutencao.php" class="card">
                <h3>Histórico de manutenção</h3>
                <p>Consultar manutenções de um equipamento.</p>
            </a>

            <a href="consultar_chamados.php" class="card">
                <h3>Todos os chamados</h3>
                <p>Visão geral das solicitações registradas.</p>
            </a>

            <a href="consultar_chaves.php" class="card">
                <h3>Status das chaves</h3>
                <p>Ver todas as retiradas e devoluções.</p>
            </a>
        </div>
    <?php endif; ?>

    <a href="logout.php" class="logout">Sair</a>

</div>

</body>
</html>