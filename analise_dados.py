from sqlalchemy import create_engine
import pandas as pd

# Conexão com o banco
user = "postgres"
password = ""
host = "localhost"
port = "5432"
dbname = "projeto_integrador3"

# Engine de conexão
engine = create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{dbname}")
# Carregando as tabelas
fato_vendas_jogos = pd.read_sql("SELECT * FROM fato_vendas_jogos", engine)
dim_jogo = pd.read_sql("SELECT * FROM dim_jogo", engine)
dim_cliente = pd.read_sql("SELECT * FROM dim_cliente", engine)
dim_plataforma = pd.read_sql("SELECT * FROM dim_plataforma", engine)
dim_genero = pd.read_sql("SELECT * FROM dim_genero", engine)
dim_publicadora = pd.read_sql("SELECT * FROM dim_publicadora", engine)
dim_tempo = pd.read_sql("SELECT * FROM dim_tempo", engine) 

# ---------------------------- Análise de Dados -------------------------------------------

# Q1: Gêneros de jogos mais vendidos globalmente
def generos_mais_vendidos(fato_vendas_jogos, dim_jogo, dim_genero):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_genero, on="id_genero")
    resultado = df.groupby("nome_genero")["vendas_globais"].sum().sort_values(ascending=False)
    return resultado

# Q2: Plataformas com maior volume de vendas
def plataformas_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_plataforma):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_plataforma, on="id_plataforma")
    resultado = df.groupby("nome_plataforma")["vendas_globais"].sum().sort_values(ascending=False)
    return resultado

# Q3: Editora com maior volume de vendas globais
def editoras_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_publicadora):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_publicadora, on="id_publicadora")
    resultado = df.groupby("nome_publicadora")["vendas_globais"].sum().sort_values(ascending=False)
    return resultado

# Q4: Comportamento de vendas ao longo dos anos
def vendas_por_ano(fato_vendas_jogos, dim_tempo):
    df = fato_vendas_jogos.merge(dim_tempo, on="id_tempo")
    resultado = df.groupby("ano")["vendas_globais"].sum().sort_index()
    return resultado

# Q5: Jogos mais vendidos de todos os tempos
def jogos_mais_vendidos(fato_vendas_jogos, dim_jogo):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    resultado = df.groupby("nome_jogo")["vendas_globais"].sum().sort_values(ascending=False).head(5)
    return resultado

# Q6: Distribuição de vendas por região
def distribuicao_geografica(fato_vendas_jogos):
    resultado = {
        "América do Norte": fato_vendas_jogos["vendas_na"].sum(),
        "Europa": fato_vendas_jogos["vendas_eu"].sum(),
        "Japão": fato_vendas_jogos["vendas_jp"].sum(),
        "Outras": fato_vendas_jogos["vendas_outros"].sum()
    }
    return resultado

# Q7: Diferença de preferência por gênero entre regiões
def preferencias_genero_por_regiao(fato_vendas_jogos, dim_jogo, dim_genero):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_genero, on="id_genero")   
    resultado = df.groupby("nome_genero")[["vendas_na", "vendas_eu", "vendas_jp", "vendas_outros"]].sum()
    return resultado

# ----------------------------------Chamando as Funções Criadas---------------------------------------------
# Ajuste de exibição para não mostrar notação científica
pd.options.display.float_format = '{:,.0f}'.format

# Q1
resultado_q1 = generos_mais_vendidos(fato_vendas_jogos, dim_jogo, dim_genero)
print("\nGêneros mais vendidos:\n", resultado_q1)
# Q2
resultado_q2 = plataformas_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_plataforma)
print("\nPlataformas com mais jogos vendidos:\n", resultado_q2)
# Q3
resultado_q3 = editoras_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_publicadora)
print("\nEditoras com maior volume de vendas:\n", resultado_q3)
# Q4
resultado_q4 = vendas_por_ano(fato_vendas_jogos, dim_tempo)
print("\nVendas por ano:\n", resultado_q4)
# Q5
resultado_q5 = jogos_mais_vendidos(fato_vendas_jogos, dim_jogo)
print("\nTop 5 jogos mais vendidos:\n", resultado_q5)
# Q6
resultado_q6 = distribuicao_geografica(fato_vendas_jogos)
print("\nDistribuição Geográfica de Vendas:\n", resultado_q6)
# Q7
resultado_q7 = preferencias_genero_por_regiao(fato_vendas_jogos, dim_jogo, dim_genero)
print("\nPreferência de Gênero por Região:\n", resultado_q7)

