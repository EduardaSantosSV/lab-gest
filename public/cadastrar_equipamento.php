<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem cadastrar equipamentos.");
}

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
    <title>Cadastrar Equipamento - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Cadastrar equipamento</h1>

    <?php if (isset($_GET['sucesso'])): ?>
        <p class="sucesso">Equipamento cadastrado com sucesso.</p>
    <?php endif; ?>

    <?php if (count($laboratorios) == 0): ?>
        <p class="erro">Nenhum laboratório cadastrado ainda. Cadastre um laboratório antes.</p>
    <?php else: ?>

        <form action="salvar_equipamento.php" method="POST">
            <?= csrf_input() ?>

            <label>Nome</label>
            <input type="text" name="nome" maxlength="100" required>

            <label>Tipo</label>
            <select name="tipo" required>
                <option value="">Selecione</option>
                <option value="Computador desktop">Computador desktop</option>
                <option value="Computador portátil">Computador portátil</option>
                <option value="Periférico">Periférico</option>
                <option value="Equipamento de rede">Equipamento de rede</option>
                <option value="Servidor">Servidor</option>
                <option value="Multimídia">Multimídia</option>
                <option value="Armazenamento">Armazenamento</option>
            </select>

            <label>Patrimônio (opcional)</label>
            <input type="text" name="patrimonio" maxlength="30">

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

            <label>Descrição (opcional)</label>
            <textarea name="descricao" maxlength="500"></textarea>

            <button type="submit">Cadastrar</button>
        </form>

    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
