<?php
require_once __DIR__ . "/env.php";

$host = getenv("DB_HOST");
$port = getenv("DB_PORT");
$dbname = getenv("DB_NAME");
$user = getenv("DB_USER");
$password = getenv("DB_PASSWORD");

try {
    $pdo = new PDO(
        "pgsql:host=$host;port=$port;dbname=$dbname",
        $user,
        $password
    );

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch (PDOException $e) {
    error_log("Erro na conexão: " . $e->getMessage());
    die("Erro ao conectar ao banco de dados.");
}

function db_execute(PDO $pdo, string $sql, array $params = []): PDOStatement
{
    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    } catch (PDOException $e) {
        error_log("Erro na consulta: " . $e->getMessage());
        die("Ocorreu um erro ao processar sua solicitação. Tente novamente.");
    }
}
?>