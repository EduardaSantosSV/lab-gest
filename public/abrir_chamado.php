<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";


if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] == 'tecnico') {
    die("Acesso negado. Técnico não abre chamado, apenas atende chamados atribuídos.");
}

$equipamentos = $pdo->query("SELECT id_equipamento, patrimonio, nome FROM equipamentos ORDER BY nome")
                   ->fetchAll(PDO::FETCH_ASSOC);

$tecnicos = $pdo->query("
    SELECT t.cpf, u.nome
    FROM tecnico_ti t
    INNER JOIN usuario u ON t.id_usuario = u.id_usuario
    ORDER BY u.nome
")->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Abrir Chamado</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="form-box">
    <h1>Abrir chamado</h1>

    <form action="salvar_chamado.php" method="POST">
        <?= csrf_input() ?>

        <label>Equipamento</label>
        <select name="id_equipamento" required>
            <option value="">Selecione</option>
            <?php foreach ($equipamentos as $equip): ?>
                <option value="<?= $equip['id_equipamento'] ?>">
                    <?= htmlspecialchars($equip['patrimonio'] . " - " . $equip['nome']) ?>
                </option>
            <?php endforeach; ?>
        </select>

        <label>Técnico responsável</label>
        <select name="cpf_tecnico_responsavel" required>
            <option value="">Selecione</option>
            <?php foreach ($tecnicos as $tec): ?>
                <option value="<?= $tec['cpf'] ?>">
                    <?= htmlspecialchars($tec['nome']) ?>
                </option>
            <?php endforeach; ?>
        </select>

        <label>Tipo da solicitação</label>
        <select name="tipo_solicitacao" required>
            <option value="hardware">Hardware</option>
            <option value="rede">Rede</option>
            <option value="periferico">Periférico</option>
            <option value="software">Software</option>
        </select>

        <label>Descrição do problema</label>
        <textarea name="descricao" required></textarea>

        <button type="submit">Salvar chamado</button>
    </form>

    <a href="painel.php">Voltar</a>
</div>

</body>
</html>