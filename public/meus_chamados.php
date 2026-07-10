<?php
session_start();
require_once "conexao.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] == 'tecnico') {
    die("Acesso negado.");
}

$sql = "
    SELECT
        s.id_solicitacao,
        s.data_abertura,
        s.descricao,
        s.tipo_solicitacao,
        s.status,
        e.patrimonio,
        e.nome AS equipamento,
        l.bloco,
        l.andar
    FROM solicitacao s
    INNER JOIN equipamentos e
        ON s.id_equipamento = e.id_equipamento
    INNER JOIN laboratorio l
        ON e.id_laboratorio = l.id_laboratorio
    WHERE s.id_usuario_solicitante = :id_usuario
    ORDER BY s.id_solicitacao DESC
";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':id_usuario' => $_SESSION['id_usuario']
]);

$chamados = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Meus Chamados</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Meus chamados</h1>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Equipamento</th>
                <th>Patrimônio</th>
                <th>Laboratório</th>
                <th>Problema</th>
                <th>Status</th>
                <th>Data</th>
                <th>Ação</th>
            </tr>
        </thead>

        <tbody>
            <?php foreach ($chamados as $chamado): ?>
                <tr>
                    <td><?= htmlspecialchars($chamado['id_solicitacao']) ?></td>
                    <td><?= htmlspecialchars($chamado['equipamento']) ?></td>
                    <td><?= htmlspecialchars($chamado['patrimonio']) ?></td>
                    <td><?= htmlspecialchars($chamado['bloco']) ?> - Andar <?= htmlspecialchars($chamado['andar']) ?></td>
                    <td><?= htmlspecialchars($chamado['descricao']) ?></td>
                    <td><?= htmlspecialchars($chamado['status']) ?></td>
                    <td><?= htmlspecialchars($chamado['data_abertura']) ?></td>

                    <td>
                        <?php if ($chamado['status'] == 'aberto'): ?>
                            <a class="btn-remover"
                               href="remover_chamado.php?id=<?= $chamado['id_solicitacao'] ?>"
                               onclick="return confirm('Deseja apagar este chamado?')">
                               Apagar
                            </a>
                        <?php else: ?>
                            -
                        <?php endif; ?>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <br>
    <a href="painel.php">Voltar</a>
</div>

</body>
</html>