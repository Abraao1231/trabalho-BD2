# Mnemônicos das Entidades

### Dimensões

| Mnemônico | Entidade | Descrição |
|-----------|----------|-----------|
| `dist` | DIM_DISTRIBUIDORA | Dimensão das distribuidoras de filmes |
| `filme` | DIM_FILME | Dimensão dos filmes e obras cinematográficas |
| `dlan` | DIM_DATA_LANCAMENTO | Dimensão temporal dos lançamentos |

### Fatos

| Mnemônico | Entidade | Descrição |
|-----------|----------|-----------|
| `lan` | FAT_LANCAMENTO | Fato dos lançamentos de filmes |

## Padrão de Chaves

### Chaves Primárias
- **Formato**: `srk_{mnemônico}_pk`
- **Exemplo**: `srk_dist_pk`, `srk_filme_pk`

### Chaves Estrangeiras
- **Formato**: `srk_{mnemônico}_fk` 
- **Exemplo**: `srk_dist_fk`, `srk_filme_fk`

## Observações

- Todos os mnemônicos seguem o padrão snake_case
- As chaves utilizam o prefixo "srk" (surrogate key)
- Mnemônicos são mantidos em português para facilitar a compreensão da equipe