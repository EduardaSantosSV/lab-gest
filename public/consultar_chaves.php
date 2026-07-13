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

$status_filtros = ['retirada', 'devolvida', 'atrasada'];
$filtro = $_GET['status'] ?? '';

$sql = "
    SELECT
        a.id_agenda,
        a.data_retirada,
        a.hora_retirada,
        a.data_devolucao,
        a.hora_devolucao,
        a.status_chave,
        l.id_laboratorio,
        l.bloco,
        l.andar,
        u.nome AS professor
    FROM agenda_labs_chave a
    INNER JOIN laboratorio l ON a.id_laboratorio = l.id_laboratorio
    INNER JOIN professor p ON a.siape_professor = p.siape
    LEFT JOIN usuario u ON p.id_usuario = u.id_usuario
";

if ($filtro !== '' && in_array($filtro, $status_filtros, true)) {
    $sql .= " WHERE a.status_chave = :status ORDER BY a.id_agenda DESC";
    $chaves = db_execute($pdo, $sql, [':status' => $filtro])->fetchAll(PDO::FETCH_ASSOC);
} else {
    $filtro = '';
    $sql .= " ORDER BY a.id_agenda DESC";
    $chaves = db_execute($pdo, $sql)->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Status das Chaves - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Status das chaves</h1>

    <form action="consultar_chaves.php" method="GET">
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

    <?php if (count($chaves) == 0): ?>
        <p class="empty-state">Nenhum registro de chave encontrado para este filtro.</p>
    <?php else: ?>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Laboratório</th>
                    <th>Professor</th>
                    <th>Retirada</th>
                    <th>Devolução</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($chaves as $c): ?>
                    <tr>
                        <td><?= htmlspecialchars($c['id_agenda']) ?></td>
                        <td>
                            Lab <?= htmlspecialchars($c['id_laboratorio']) ?> -
                            <?= htmlspecialchars($c['bloco']) ?> -
                            Andar <?= htmlspecialchars($c['andar']) ?>
                        </td>
                        <td><?= htmlspecialchars($c['professor'] ?? '-') ?></td>
                        <td>
                            <?= htmlspecialchars($c['data_retirada']) ?>
                            <?= htmlspecialchars($c['hora_retirada']) ?>
                        </td>
                        <td>
                            <?php if ($c['data_devolucao']): ?>
                                <?= htmlspecialchars($c['data_devolucao']) ?>
                                <?= htmlspecialchars($c['hora_devolucao']) ?>
                            <?php else: ?>
                                -
                            <?php endif; ?>
                        </td>
                        <td><?= htmlspecialchars($c['status_chave']) ?></td>
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
