<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";

/*
    Verifica se está logado
*/
if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

/*
    Apenas professor pode acessar esta página
*/
if ($_SESSION['tipo_usuario'] != 'professor') {
    die("Acesso negado. Apenas professores podem ver suas chaves.");
}

/*
    Busca o SIAPE do professor logado
*/
$sqlSiape = "
    SELECT siape
    FROM professor
    WHERE id_usuario = :id_usuario
";

$stmtSiape = $pdo->prepare($sqlSiape);
$stmtSiape->execute([
    ':id_usuario' => $_SESSION['id_usuario']
]);

$professor = $stmtSiape->fetch(PDO::FETCH_ASSOC);

if (!$professor) {
    die("Professor não encontrado para este usuário.");
}

$siape = $professor['siape'];

/*
    Busca as chaves retiradas/agendadas pelo professor
*/
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
        l.capacidade
    FROM agenda_labs_chave a
    INNER JOIN laboratorio l
        ON a.id_laboratorio = l.id_laboratorio
    WHERE a.siape_professor = :siape
    ORDER BY a.id_agenda DESC
";

$stmt = $pdo->prepare($sql);
$stmt->execute([
    ':siape' => $siape
]);

$chaves = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Minhas Chaves - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Minhas chaves retiradas</h1>

    <p>
        Professor:
        <strong><?= htmlspecialchars($_SESSION['nome']) ?></strong>
    </p>

    <p>
        SIAPE:
        <strong><?= htmlspecialchars($siape) ?></strong>
    </p>

    <?php if (count($chaves) == 0): ?>

        <p>Nenhuma chave retirada ou agendada ainda.</p>

    <?php else: ?>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Laboratório</th>
                    <th>Data Retirada</th>
                    <th>Hora Retirada</th>
                    <th>Data Devolução</th>
                    <th>Hora Devolução</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>
                <?php foreach ($chaves as $chave): ?>
                    <tr>
                        <td><?= htmlspecialchars($chave['id_agenda']) ?></td>

                        <td>
                            Lab <?= htmlspecialchars($chave['id_laboratorio']) ?> -
                            <?= htmlspecialchars($chave['bloco']) ?> -
                            Andar <?= htmlspecialchars($chave['andar']) ?> -
                            Capacidade <?= htmlspecialchars($chave['capacidade']) ?>
                        </td>

                        <td><?= htmlspecialchars($chave['data_retirada']) ?></td>
                        <td><?= htmlspecialchars($chave['hora_retirada']) ?></td>

                        <td>
                            <?= htmlspecialchars($chave['data_devolucao'] ?? '-') ?>
                        </td>

                        <td>
                            <?= htmlspecialchars($chave['hora_devolucao'] ?? '-') ?>
                        </td>

                        <td><?= htmlspecialchars($chave['status_chave']) ?></td>
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