<?php
session_start();

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
    <title>Cadastrar Usuário - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Cadastrar usuário</h1>
    <p>Selecione o perfil do novo usuário.</p>

    <div class="cards">
        <a href="cadastrar_aluno.php" class="card">
            <h3>Aluno</h3>
            <p>Matrícula, curso e semestre.</p>
        </a>

        <a href="cadastrar_professor.php" class="card">
            <h3>Professor</h3>
            <p>SIAPE, curso e departamento.</p>
        </a>

        <a href="cadastrar_tecnico.php" class="card">
            <h3>Técnico de TI</h3>
            <p>CPF.</p>
        </a>
    </div>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
