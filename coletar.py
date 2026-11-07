"""Baixa as estatísticas de fraude do Pix publicadas pelo Banco Central."""

import json
from pathlib import Path
from urllib.request import Request, urlopen

import pandas as pd

URL = (
    'https://olinda.bcb.gov.br/olinda/servico/Pix_DadosAbertos/versao/v1/odata/'
    "EstatisticasFraudesPix(Database=@Database)?@Database=%27202001%27&$format=json&$top=1000"
)


def main():
    pedido = Request(URL, headers={'User-Agent': 'portfolio-dados'})
    with urlopen(pedido, timeout=120) as resposta:
        linhas = json.load(resposta)['value']
    tabela = pd.DataFrame(linhas).sort_values('AnoMes')
    Path('dados').mkdir(exist_ok=True)
    tabela.to_csv('dados/fraudes_pix.csv', index=False)
    print(f"{len(tabela)} meses, de {tabela['AnoMes'].min()} a {tabela['AnoMes'].max()}")


if __name__ == '__main__':
    main()
