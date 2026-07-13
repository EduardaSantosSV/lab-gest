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

$laboratorios = db_execute($pdo, "
    SELECT id_laboratorio, bloco, andar, capacidade
    FROM laboratorio
    ORDER BY id_laboratorio
")->fetchAll(PDO::FETCH_ASSOC);

$equipamentos = db_execute($pdo, "
    SELECT id_laboratorio, id_equipamento, nome, tipo, status, patrimonio
    FROM equipamentos
    ORDER BY id_laboratorio, nome
")->fetchAll(PDO::FETCH_ASSOC);

// Agrupa equipamentos por laboratório
$por_lab = [];
foreach ($equipamentos as $eq) {
    $por_lab[$eq['id_laboratorio']][] = $eq;
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Equipamentos por Laboratório - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Equipamentos por laboratório</h1>

    <?php if (count($laboratorios) == 0): ?>
        <p class="empty-state">Nenhum laboratório cadastrado.</p>
    <?php else: ?>
        <?php foreach ($laboratorios as $lab): ?>
            <h2 class="section-title">
                Laboratório <?= htmlspecialchars($lab['id_laboratorio']) ?> -
                <?= htmlspecialchars($lab['bloco']) ?> -
                Andar <?= htmlspecialchars($lab['andar']) ?>
                (capacidade <?= htmlspecialchars($lab['capacidade']) ?>)
            </h2>

            <?php $lista = $por_lab[$lab['id_laboratorio']] ?? []; ?>

            <?php if (count($lista) == 0): ?>
                <p class="empty-state">Nenhum equipamento neste laboratório.</p>
            <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Patrimônio</th>
                            <th>Nome</th>
                            <th>Tipo</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($lista as $eq): ?>
                            <tr>
                                <td><?= htmlspecialchars($eq['id_equipamento']) ?></td>
                                <td><?= htmlspecialchars($eq['patrimonio'] ?? '-') ?></td>
                                <td><?= htmlspecialchars($eq['nome']) ?></td>
                                <td><?= htmlspecialchars($eq['tipo'] ?? '-') ?></td>
                                <td><?= htmlspecialchars($eq['status'] ?? '-') ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        <?php endforeach; ?>
    <?php endif; ?>

    <br>
    <a href="painel.php">Voltar ao painel</a>
</div>

</body>
</html>
