<?php
session_start();
require_once __DIR__ . "/../includes/conexao.php";
require_once __DIR__ . "/../includes/csrf.php";

if (!isset($_SESSION['id_usuario'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo_usuario'] != 'tecnico') {
    die("Acesso negado. Apenas técnicos podem acessar esta página.");
}

$sqlCpf = "
    SELECT cpf
    FROM tecnico_ti
    WHERE id_usuario = :id_usuario
";

$stmtCpf = db_execute($pdo, $sqlCpf, [
    ':id_usuario' => $_SESSION['id_usuario']
]);

$tecnico = $stmtCpf->fetch(PDO::FETCH_ASSOC);

if (!$tecnico) {
    die("Técnico não encontrado para este usuário.");
}

$cpf = $tecnico['cpf'];

$sql = "
    SELECT
        s.id_solicitacao,
        s.data_abertura,
        s.descricao,
        s.tipo_solicitacao,
        s.status,
        u.nome AS solicitante,
        e.patrimonio,
        e.nome AS equipamento,
        l.bloco,
        l.andar
    FROM solicitacao s
    INNER JOIN usuario u
        ON s.id_usuario_solicitante = u.id_usuario
    INNER JOIN equipamentos e
        ON s.id_equipamento = e.id_equipamento
    INNER JOIN laboratorio l
        ON e.id_laboratorio = l.id_laboratorio
    WHERE s.cpf_tecnico_responsavel = :cpf
    ORDER BY s.id_solicitacao DESC
";

$stmt = db_execute($pdo, $sql, [
    ':cpf' => $cpf
]);

$chamados = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Chamados do Técnico</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Chamados atribuídos a mim</h1>

    <?php if (count($chamados) == 0): ?>
        <p>Nenhum chamado atribuído a você.</p>
    <?php else: ?>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Solicitante</th>
                    <th>Equipamento</th>
                    <th>Patrimônio</th>
                    <th>Laboratório</th>
                    <th>Problema</th>
                    <th>Status</th>
                    <th>Alterar status</th>
                </tr>
            </thead>

            <tbody>
                <?php foreach ($chamados as $chamado): ?>
                    <tr>
                        <td><?= htmlspecialchars($chamado['id_solicitacao']) ?></td>
                        <td><?= htmlspecialchars($chamado['solicitante']) ?></td>
                        <td><?= htmlspecialchars($chamado['equipamento']) ?></td>
                        <td><?= htmlspecialchars($chamado['patrimonio']) ?></td>
                        <td>
                            <?= htmlspecialchars($chamado['bloco']) ?> -
                            Andar <?= htmlspecialchars($chamado['andar']) ?>
                        </td>
                        <td><?= htmlspecialchars($chamado['descricao']) ?></td>
                        <td><?= htmlspecialchars($chamado['status']) ?></td>

                        <td>
                            <form action="atualizar_status.php" method="POST">
                                <?= csrf_input() ?>
                                <input type="hidden" name="id_solicitacao" value="<?= htmlspecialchars($chamado['id_solicitacao']) ?>">

                                <select name="status" required>
                                    <option value="aberto" <?= $chamado['status'] == 'aberto' ? 'selected' : '' ?>>Aberto</option>
                                    <option value="em atendimento" <?= $chamado['status'] == 'em atendimento' ? 'selected' : '' ?>>Em atendimento</option>
                                    <option value="concluido" <?= $chamado['status'] == 'concluido' ? 'selected' : '' ?>>Concluído</option>
                                    <option value="cancelado" <?= $chamado['status'] == 'cancelado' ? 'selected' : '' ?>>Cancelado</option>
                                </select>

                                <button type="submit">Salvar</button>
                            </form>
                        </td>
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