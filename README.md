# Desenvolvendo um DW

Sempre ouvi falar no ‘BI’ da empresa onde trabalhava e sabia que ele era baseado em um Data Warehouse, mas ver a coisa mesmo, nunca, até quis, mas não havia disponibilidade, a infraestrutura cobrava atenção, então nunca pude estudar direito esse tema, e sempre que tinha contato com banco de dados, era para OLTP e suas normalizações.

Durante minha pós graduação em engenharia de dados, na DSA, eu tive contato com DW pela primeira vez, e fiquei bastante intrigado com a modelagem dimensional, é um conceito diferente de modelagem, sinceramente gostei, mas só pude seguir o laboratório, não deu para aprofundar muito porque tinha um prazo para fazer a pós e eu tinha medo de não conseguir cumprir.
Após o término e a obtenção do diploma, voltei ao tema, olhei novamente os laboratórios e resolvi desenvolver um DW. 
O maior desafio neste ponto é o domínio do tema, e qual assunto eu poderia usar, que fosse fácil de entender para a maioria? Me veio a ideia de fazer um DW sobre futebol, usei o mesmo roteiro dos exercícios de laboratório, com uma necessidade do cliente e as respostas que o mesmo desejava que fossem respondidas.

Logo no começo do trabalho, com as entidades definidas, me dei conta que minha modelagem estava indo para o padrão de normalização 1fn, 2fn, 3fn e não é nada disso , não que o professor não tivesse avisado, ele tinha dito que não é assim, mas é a força do hábito, a gente nem pensa muito e aplica… Uma coisa é seguir o lab, outra é desenvolver, no desenvolvimento a gente se dá conta, na marra, que certas coisas não fazem sentido e acorda pra vida, então entrei mesmo no ritmo, criando as tabelas de dimensões para descrever a tabela de fato, e isso não foi trivial, abraçar o conceito é bem, digamos, estranho,  mas depois de muita remodelagem , muito ‘alter table’ da vida, acabou saindo.

Eu utilizei dados sintéticos para preencher as tabelas. Quis assim porque também queria treinar um pouco de script SQL, aliás, é puro SQL, não usei nada além disso, sei que o Python poderia ter facilitado bem a coisa, mas vou fazer de outro jeito daqui a pouco.

A utilização de dados sintéticos me privou de exercitar um dos fundamentos essenciais de um engenheiro de dados, o ETL, mas vamos com calma, nos meus próximos modelos eu farei isso, com Airbyte, DBT, AirFlow, Python,  Spark (tentado a usar java e não Python, para variar), Kafka… Seguiremos.

Para gerar os dashboards, usei o Metabase, que é uma ferramenta fantástica. Você praticamente não precisa pensar muito para fazer um trabalho mais simples. A grande sacada é como você disponibiliza as fontes, ahá! Tive que mudar minha forma de pensar para isso também. Eu ia criar as views igual eu estava acostumado, e entendi que o correto é você fazer views completas (por exemplo, com todos os resultados de um grupo e não de um jeito que algum parâmetro defina o agrupamento),  e ferramentas desse tipo permitem a manipulação facilmente, basta só ter uma noção de SQL.

Esse servidor metabase (assim como o Postgresql) eu subi em um contêiner Docker.

Posso ter feito de forma errada, grotesca, sei lá, sou (infelizmente) o ‘bloco do eu sozinho’, por isso sugestões, críticas, elogios, são de graaaaande valia! 😀


