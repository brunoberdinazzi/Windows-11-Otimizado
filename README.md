# Win11 Pro Clean Install Pack (Debloat + Policies + Native NVMe opcional)

Um pacote **seguro** para instalar o **Windows 11 Pro** com menos “lixo” (apps inbox e sugestões), aplicando políticas de sistema e (opcionalmente) habilitando o **Native NVMe stack** via feature flags.

✅ Objetivo: **menos processos desnecessários**, **menos apps pré-instalados**, **menos sugestões/consumer experiences**, e um Windows mais “enxuto” sem depender de ISO modificada por terceiros.

> **Importante:** este projeto NÃO distribui ISO do Windows. Use sempre **ISO oficial** da Microsoft.

---

## O que este pack faz

### 1) Automatiza parte da instalação (OOBE)
- Define idioma/locale para **pt-BR**
- Cria um **usuário local admin** (editável)
- Tenta reduzir telas de conta Microsoft no OOBE (depende do build/políticas)

Arquivo: `Autounattend.xml`

### 2) Debloat “seguro” de apps inbox (UWP)
Remove apps comuns e também remove o **provisionamento** (para não voltar em novos usuários), mantendo componentes essenciais como Store/winget e runtimes.

Arquivo: `debloat.ps1`

### 3) Aplica políticas de sistema (HKLM)
- **Desativa Microsoft consumer experiences** (reduz apps sugeridos/reinstalações promocionais)
- **Bloqueia apps UWP rodando em background** (Force Deny)
- **Desliga Windows Copilot** (política do dispositivo)

Arquivo: `debloat.ps1` (executado via SetupComplete)

### 4) (Opcional/Experimental) Native NVMe
Habilita o “novo caminho” do NVMe via feature flags no registro (pode melhorar desempenho em workloads randômicos e reduzir overhead em alguns cenários — mas NÃO é garantido e pode mudar com updates).

Arquivo: `debloat.ps1` (toggle)

### 5) Execução automática no fim da instalação
Roda automaticamente após o setup terminar (sem precisar abrir PowerShell manualmente).

Arquivo: `SetupComplete.cmd`

---

## Requisitos

- **Windows 11 Pro** (recomendado 24H2/mais novo para maior chance do Native NVMe funcionar)
- Pendrive criado a partir de **ISO oficial**
- Acesso administrativo (o SetupComplete roda como sistema/admin)

---

## Estrutura do projeto

Arquivos principais:
- `Autounattend.xml`
- `debloat.ps1`
- `SetupComplete.cmd`
- `README.md` (este arquivo)

Estrutura no pendrive (importante):
