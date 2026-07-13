<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem acessar as consultas.");
}

$equipamentos = db_execute($pdo, "
    SELECT id_equipamento, patrimonio, nome
    FROM equipamentos
    ORDER BY nome
")->fetchAll(PDO::FETCH_ASSOC);

$id_equipamento = filter_var($_GET['id_equipamento'] ?? '', FILTER_VALIDATE_INT);
$historico = [];
$equip_selecionado = null;

if ($id_equipamento !== false) {
    $historico = db_execute($pdo, "
        SELECT
            s.id_solicitacao,
            s.data_abertura,
            s.data_fechamento,
            s.tipo_solicitacao,
            s.descricao,
            s.status,
            u.nome AS solicitante,
            ut.nome AS tecnico
        FROM solicitacao s
        INNER JOIN usuario u ON s.id_usuario_solicitante = u.id_usuario
        LEFT JOIN tecnico_ti t ON s.cpf_tecnico_responsavel = t.cpf
        LEFT JOIN usuario ut ON t.id_usuario = ut.id_usuario
        WHERE s.id_equipamento = :id_equipamento
        ORDER BY s.id_solicitacao DESC
    ", [
        ':id_equipamento' => $id_equipamento
    ])->fetchAll(PDO::FETCH_ASSOC);

    foreach ($equipamentos as $eq) {
        if ((int) $eq['id_equipamento'] === $id_equipamento) {
            $equip_selecionado = $eq;
            break;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Histórico de Manutenção - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Histórico de manutenção por equipamento</h1>

    <form action="consultar_manutencao.php" method="GET">
        <label>Equipamento</label>
        <select name="id_equipamento" required onchange="this.form.submit()">
            <option value="">Selecione</option>
            <?php foreach ($equipamentos as $eq): ?>
                <option value="<?= htmlspecialchars($eq['id_equipamento']) ?>"
                    <?= ($equip_selecionado && $equip_selecionado['id_equipamento'] == $eq['id_equipamento']) ? 'selected' : '' ?>>
                    <?= htmlspecialchars(($eq['patrimonio'] ?? 's/ patrimônio') . " - " . $eq['nome']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <noscript><button type="submit">Consultar</button></noscript>
    </form>

    <?php if ($equip_selecionado): ?>
        <h2 class="section-title">
            <?= htmlspecialchars($equip_selecionado['nome']) ?>
            (<?= htmlspecialchars($equip_selecionado['patrimonio'] ?? 's/ patrimônio') ?>)
        </h2>

        <?php if (count($historico) == 0): ?>
            <p>Nenhuma solicitação de manutenção registrada para este equipamento.</p>
        <?php else: ?>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Abertura</th>
                        <th>Fechamento</th>
                        <th>Tipo</th>
                        <th>Problema</th>
                        <th>Solicitante</th>
                        <th>Técnico</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($historico as $h): ?>
                        <tr>
                            <td><?= htmlspecialchars($h['id_solicitacao']) ?></td>
                            <td><?= htmlspecialchars($h['data_abertura']) ?></td>
                            <td><?= htmlspecialchars($h['data_fechamento'] ?? '-') ?></td>
                            <td><?= htmlspecialchars($h['tipo_solicitacao']) ?></td>
                            <td><?= htmlspecialchars($h['descricao']) ?></td>
                            <td><?= htmlspecialchars($h['solicitante']) ?></td>
                            <td><?= htmlspecialchars($h['tecnico'] ?? '-') ?></td>
                            <td><?= htmlspecialchars($h['status']) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
