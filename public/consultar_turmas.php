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

$turmas = db_execute($pdo, "
    SELECT id_turma, curso, disciplina, semestre, ano
    FROM turma
    ORDER BY ano DESC, semestre, disciplina
")->fetchAll(PDO::FETCH_ASSOC);

// Alunos por turma
$alunos = db_execute($pdo, "
    SELECT p.id_turma, u.nome, a.matricula, a.curso
    FROM pertence p
    INNER JOIN aluno a ON p.matricula_aluno = a.matricula
    INNER JOIN usuario u ON a.id_usuario = u.id_usuario
    ORDER BY u.nome
")->fetchAll(PDO::FETCH_ASSOC);

// Laboratórios utilizados por turma
$labs = db_execute($pdo, "
    SELECT ut.id_turma, l.id_laboratorio, l.bloco, l.andar
    FROM utiliza ut
    INNER JOIN laboratorio l ON ut.id_laboratorio = l.id_laboratorio
    ORDER BY l.id_laboratorio
")->fetchAll(PDO::FETCH_ASSOC);

$alunos_por_turma = [];
foreach ($alunos as $a) {
    $alunos_por_turma[$a['id_turma']][] = $a;
}

$labs_por_turma = [];
foreach ($labs as $l) {
    $labs_por_turma[$l['id_turma']][] = $l;
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Turmas - LabGest</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div class="container">
    <h1>Turmas, alunos e laboratórios</h1>

    <?php if (count($turmas) == 0): ?>
        <p class="empty-state">Nenhuma turma cadastrada.</p>
    <?php else: ?>
        <?php foreach ($turmas as $turma): ?>
            <h2 class="section-title">
                <?= htmlspecialchars($turma['disciplina']) ?> -
                <?= htmlspecialchars($turma['curso']) ?> -
                <?= htmlspecialchars($turma['semestre']) ?>º sem/<?= htmlspecialchars($turma['ano']) ?>
            </h2>

            <?php $la = $labs_por_turma[$turma['id_turma']] ?? []; ?>
            <p>
                <strong>Laboratórios utilizados:</strong>
                <?php if (count($la) == 0): ?>
                    nenhum
                <?php else: ?>
                    <?php
                    $nomes_labs = array_map(function ($l) {
                        return "Lab " . htmlspecialchars($l['id_laboratorio']) .
                               " (" . htmlspecialchars($l['bloco']) . ")";
                    }, $la);
                    echo implode(', ', $nomes_labs);
                    ?>
                <?php endif; ?>
            </p>

            <?php $al = $alunos_por_turma[$turma['id_turma']] ?? []; ?>

            <?php if (count($al) == 0): ?>
                <p class="empty-state">Nenhum aluno associado a esta turma.</p>
            <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>Matrícula</th>
                            <th>Nome</th>
                            <th>Curso</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($al as $aluno): ?>
                            <tr>
                                <td><?= htmlspecialchars($aluno['matricula']) ?></td>
                                <td><?= htmlspecialchars($aluno['nome']) ?></td>
                                <td><?= htmlspecialchars($aluno['curso']) ?></td>
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
