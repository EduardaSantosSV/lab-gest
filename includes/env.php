<?php

function carregar_env(string $caminho): void
{
    if (!file_exists($caminho)) {
        return;
    }

    foreach (file($caminho, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $linha) {
        $linha = trim($linha);

        if ($linha === '' || str_starts_with($linha, '#') || !str_contains($linha, '=')) {
            continue;
        }

        [$chave, $valor] = explode('=', $linha, 2);
        $chave = trim($chave);
        $valor = trim($valor);

        if (getenv($chave) === false) {
            putenv("$chave=$valor");
        }
    }
}

carregar_env(__DIR__ . '/../.env');
