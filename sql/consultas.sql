-- Resumo por ano: volume de contestações, aceitação e devolução.
SELECT
    ano,
    COUNT(*) AS meses,
    ROUND(SUM(contestados) / 1e6, 1) AS contestados_mi,
    ROUND(100.0 * SUM(aceitas) / SUM(contestados), 1) AS aceitacao_pct,
    ROUND(SUM(valor_aceito) / 1e9, 2) AS valor_aceito_bi,
    ROUND(100.0 * SUM(devolvido) / SUM(valor_aceito), 1) AS devolucao_pct
FROM fraudes
GROUP BY ano
ORDER BY ano;

-- Para onde foi o valor das contestações aceitas em todo o período.
WITH totais AS (
    SELECT 'Devolvido pelo MED' AS destino, SUM(devolvido) AS valor FROM fraudes
    UNION ALL SELECT 'Saldo insuficiente', SUM(saldo_insuficiente) FROM fraudes
    UNION ALL SELECT 'Residual não devolvido', SUM(residual) FROM fraudes
    UNION ALL SELECT 'Motivos diversos', SUM(motivos_diversos) FROM fraudes
    UNION ALL SELECT 'Conta encerrada', SUM(conta_encerrada) FROM fraudes
)
SELECT
    destino,
    ROUND(valor / 1e9, 2) AS valor_bi,
    ROUND(100.0 * valor / SUM(valor) OVER (), 1) AS participacao_pct
FROM totais
ORDER BY valor DESC;

-- Devolução em janela móvel de 12 meses, que reduz o ruído mensal.
SELECT
    ano_mes,
    ROUND(
        100.0 * SUM(devolvido) OVER janela / SUM(valor_aceito) OVER janela,
        1
    ) AS devolucao_12m_pct
FROM fraudes
WINDOW janela AS (ORDER BY ano_mes ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
ORDER BY ano_mes;
