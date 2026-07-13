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

$status_filtros = ['aberto', 'em atendimento', 'concluido', 'cancelado'];
$filtro = $_GET['status'] ?? '';

if ($filtro !== '' && in_array($filtro, $status_filtros, true)) {
    $chamados = db_execute($pdo, "
        SELECT
            s.id_solicitacao,
            s.data_abertura,
            s.tipo_solicitacao,
            s.descricao,
            s.status,
            us.nome AS solicitante,
            ut.nome AS tecnico,
            e.nome AS equipamento,
            e.patrimonio
        FROM solicitacao s
        INNER JOIN usuario us ON s.id_usuario_solicitante = us.id_usuario
        INNER JOIN equipamentos e ON s.id_equipamento = e.id_equipamento
        LEFT JOIN tecnico_ti t ON s.cpf_tecnico_responsavel = t.cpf
        LEFT JOIN usuario ut ON t.id_usuario = ut.id_usuario
        WHERE s.status = :status
        ORDER BY s.id_solicitacao DESC
    ", [':status' => $filtro])->fetchAll(PDO::FETCH_ASSOC);
} else {
    $filtro = '';
    $chamados = db_execute($pdo, "
        SELECT
            s.id_solicitacao,
            s.data_abertura,
            s.tipo_solicitacao,
            s.descricao,
            s.status,
            us.nome AS solicitante,
            ut.nome AS tecnico,
            e.nome AS equipamento,
            e.patrimonio
        FROM solicitacao s
        INNER JOIN usuario us ON s.id_usuario_solicitante = us.id_usuario
        INNER JOIN equipamentos e ON s.id_equipamento = e.id_equipamento
        LEFT JOIN tecnico_ti t ON s.cpf_tecnico_responsavel = t.cpf
        LEFT JOIN usuario ut ON t.id_usuario = ut.id_usuario
        ORDER BY s.id_solicitacao DESC
    ")->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Todos os Chamados - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Todos os chamados</h1>

    <form action="consultar_chamados.php" method="GET">
        <label>Filtrar por status</label>
        <select name="status" onchange="this.form.submit()">
            <option value="">Todos</option>
            <?php foreach ($status_filtros as $s): ?>
                <option value="<?= htmlspecialchars($s) ?>" <?= $filtro === $s ? 'selected' : '' ?>>
                    <?= htmlspecialchars(ucfirst($s)) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <noscript><button type="submit">Filtrar</button></noscript>
    </form>

    <br>

    <?php if (count($chamados) == 0): ?>
        <p>Nenhum chamado encontrado.</p>
    <?php else: ?>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Abertura</th>
                    <th>Equipamento</th>
                    <th>Tipo</th>
                    <th>Solicitante</th>
                    <th>Técnico</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($chamados as $c): ?>
                    <tr>
                        <td><?= htmlspecialchars($c['id_solicitacao']) ?></td>
                        <td><?= htmlspecialchars($c['data_abertura']) ?></td>
                        <td>
                            <?= htmlspecialchars($c['equipamento']) ?>
                            (<?= htmlspecialchars($c['patrimonio'] ?? 's/ patrimônio') ?>)
                        </td>
                        <td><?= htmlspecialchars($c['tipo_solicitacao']) ?></td>
                        <td><?= htmlspecialchars($c['solicitante']) ?></td>
                        <td><?= htmlspecialchars($c['tecnico'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($c['status']) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
