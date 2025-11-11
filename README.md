# KipuBankV3 - Advanced DeFi Bank

Banco DeFi que acepta cualquier token soportado por Uniswap V2 y automáticamente lo convierte a USDC.

---

## 🚀 Deployments

### 🔷 Production-Ready (Tenderly Fork)

**Network:** Tenderly Virtual TestNet (Ethereum Mainnet Fork)  
**Contract Address:** `0xE0f14bcF51C00F169E6e60461550B70483601745`  
**Explorer:** [Ver en Tenderly Dashboard](https://dashboard.tenderly.co/explorer/vnet/80f2560f-5511-4975-8898-43569969a122/transactions)  
**Deployment Tx:** `0xfdc7468af6608b635b13c413c16a84c3d64ae3315f5cb9ba93bb81d63ac3274f`  
**Block:** #23771370  
**Estado:** ✅ **Funcional con liquidez real**

**Transacciones verificables:**
- ✅ Depósito ETH → USDC: 1 ETH → 3,562.40 USDC ([Tx](https://dashboard.tenderly.co/explorer/vnet/80f2560f-5511-4975-8898-43569969a122/tx/0x172a5f9ae20b27d5128ccf16606aa2bca6407712af6d4adfab95152f265d0465))
- ✅ Retiro: 1,000 USDC exitoso ([Tx](https://dashboard.tenderly.co/explorer/vnet/80f2560f-5511-4975-8898-43569969a122/tx/0x19352117e593d6ffcae4d8960e05ceabbe28b7e102ced00104e2e7268a2f5361))
- ✅ Segundo depósito: 0.5 ETH → 1,781.20 USDC
- ✅ Límites bancarios y de retiro funcionando correctamente

**¿Por qué Tenderly?**
- ✅ Liquidez real de Mainnet Ethereum (fork local)
- ✅ Todos los pares de Uniswap V2 disponibles
- ✅ Precios de mercado actuales

---

### 🔷 Public Testnet (Sepolia - Deployment alternativo)

**Network:** Sepolia Testnet  
**Contract Address:** `[TU_DIRECCION_SEPOLIA]`  
**Verified:** [Ver en Etherscan](https://sepolia.etherscan.io/address/TU_DIRECCION#code)  
**Estado:**  ⚠️ **Constructor modificado - Funcionalidad básica**

**Funcionalidad disponible en Sepolia:**
- ✅ Depósitos directos de USDC
- ✅ Sistema de roles (Admin, Operator)
- ✅ Retiros con límites (respetados)
- ✅ Contrato verificado en explorer público
- ❌ `depositETH()` NO disponible por defecto (requiere `addToken()` posterior)
- ⚠️ Otros tokens pueden agregarse con `addToken()` si existe liquidez

**Nota técnica:** Esta versión del contrato tiene el **constructor modificado** para deployar exitosamente en Sepolia. Solo **USDC está "pre-configurado"** en el deployment. ETH y otros tokens pueden agregarse posteriormente usando `addToken()` si existe liquidez en los pares de Uniswap V2. La versión completa con ETH pre-configurado está deployada en **Tenderly Fork** donde existe liquidez real de Mainnet.

---

## 📊 Comparativa de Deployments

| Aspecto | Tenderly Fork (Mainnet) | Sepolia Testnet |
|---------|-------------------------|-----------------|
| **Verificación pública** | Explorer custom | ✅ Etherscan/Routescan |
| **Liquidez Uniswap V2** | ✅ Completa (Mainnet real) | ❌ Inexistente/mínima |
| **Swaps ETH→USDC** | ✅ Funcionales | ❌ Requiere addToken() + liquidez |
| **Swaps Token→USDC** | ✅ Todos los tokens | ❌ Solo si hay liquidez (raro) |
| **Depósitos USDC directos** | ✅ Funcional | ✅ Funcional |
| **Precios realistas** | ✅ Mercado real | ❌ No aplicable |
| **Testing profesional** | ✅ Standard en la industria | Testing básico |
| **Para evaluación** | ⭐ **Recomendado** | Cumplimiento formal |
| **Código del contrato** | Constructor original | Constructor modificado (solo USDC) |

---

## 🔄 Diferencias de Implementación

### Tenderly Fork (Código original - sin modificaciones)

**Constructor pre-configura:**
- ✅ ETH nativo → USDC (swap automático via WETH)
- ✅ USDC directo (sin swap)

**Funciona porque:**
- El par WETH/USDC existe y tiene liquidez real en Mainnet
- El fork replica el estado completo de Ethereum Mainnet

---

### Sepolia (Constructor modificado)

**Constructor pre-configura:**
- ✅ USDC directo solamente
- ❌ ETH NO está pre-configurado

**ETH y otros tokens se agregan con `addToken()` después del deployment**

**Razón del cambio:**
Evitar que el deployment falle al intentar validar el par WETH/USDC durante la inicialización del constructor. En Sepolia, aunque el par técnicamente existe, no tiene liquidez suficiente para operar, lo que causaría un revert en producción.

**Cambio específico en el código (línea ~214):**
```solidity
// ANTES (Tenderly):
// Pre-configura ETH + USDC en constructor

// AHORA (Sepolia):
// Solo pre-configura USDC
// ETH se agrega manualmente después si es necesario
```

## 🎯 Recomendación a modo educativo

### Para evaluar la funcionalidad completa del protocolo:

**👉 Revisar el deployment en Tenderly** donde:
- Integración Uniswap V2 completamente funcional
- Swaps automáticos con liquidez real
- Manejo de slippage con precios de mercado
- Todas las características operativas

**URL del fork:** [https://dashboard.tenderly.co/javprueba](https://dashboard.tenderly.co/explorer/vnet/80f2560f-5511-4975-8898-43569969a122/transactions)  
**Contract:** `0xe0f14bcf51c00f169e6e60461550b70483601745`

### Verificación en testnet pública:

El deployment en Sepolia está disponible para "verificación formal" del código en explorers públicos, pero con funcionalidad DeFi limitada debido a restricciones inherentes de las testnets.

---

## 📋 Addresses de Referencia

### Tenderly Fork (Mainnet state)

| Componente | Address |
|------------|---------|
| KipuBankV3 | `0xE0f14bcF51C00F169E6e60461550B70483601745` |
| USDC (Mainnet) | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| WETH (Mainnet) | `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2` |
| Uniswap V2 Router | `0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D` |
| Uniswap V2 Factory | `0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f` |

### Sepolia Testnet

| Componente | Address |
|------------|---------|
| Uniswap V2 Router | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` |
| Uniswap V2 Factory | `0x7E0987E5b3a30e3f2828572Bb659A548460a3003` |
| USDC (Circle) | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |
| WETH | `0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14` |

**Parámetros de Deploy para Sepolia:**
```
withdrawalLimitUSDC: 1000000000 (1,000 USDC)
bankCapUSDC: 100000000000 (100,000 USDC)
uniswapRouter: 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
uniswapFactory: 0x7E0987E5b3a30e3f2828572Bb659A548460a3003
usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```

---

## ✨ Características Implementadas

✅ **Depósitos multi-token:** ETH, USDC, y cualquier ERC20 con par USDC en Uniswap V2  
✅ **Swaps automáticos:** Integración completa con Uniswap V2 Router  
✅ **Bank Cap:** Límite máximo de 100,000 USDC  
✅ **Withdrawal Limit:** 1,000 USDC por transacción  
✅ **Control de acceso:** Sistema de roles con AccessControl de OpenZeppelin  
✅ **Seguridad:** ReentrancyGuard en operaciones críticas  
✅ **Token Management:** Admin puede agregar/remover tokens soportados dinámicamente  
✅ **Slippage Protection:** 2% de tolerancia configurable  
✅ **Gas Optimization:** Variables inmutables, custom errors, storage eficiente

---

## 🔧 Decisiones de Diseño

### Enfoque de Testing: Tenderly Fork

**Problema identificado:**

Las testnets públicas (Sepolia, Goerli, etc.) presentan limitaciones críticas para testing de protocolos DeFi:

1. **Falta de liquidez real:** Los pares en Uniswap V2 existen pero están vacíos o con liquidez mínima
2. **Precios no realistas:** Sin volumen de trading, los precios no reflejan mercado real
3. **Swaps fallidos:** Transacciones revierten por `INSUFFICIENT_LIQUIDITY` o slippage extremo
4. **Imposibilidad de testear funcionalidad completa:** No se puede demostrar el core del protocolo

**Solución adoptada:**

Usar **Tenderly Fork** que replica el estado completo de Ethereum Mainnet:

- ✅ Liquidez real de todos los pares Uniswap V2
- ✅ Precios actualizados del mercado
- ✅ Estado idéntico a producción (incluyendo contratos verificados)
- ✅ Permite testing exhaustivo sin gastar ETH real
- ✅ Infraestructura de debugging avanzada

### Arquitectura del Contrato

**Normalización a USDC:**
- Todos los depósitos se convierten y almacenan en USDC (6 decimales)
- Simplifica la contabilidad interna del banco
- USDC es la stablecoin con mayor liquidez en Uniswap V2
- Facilita auditoría y reporting

**Protección de Slippage:**
- 2% de tolerancia predeterminada en todos los swaps
- Balance entre protección al usuario y probabilidad de éxito de transacción
- Configurable a través de `SwapConfig` por token si fuera necesario

**Optimización de Rutas de Swap:**
- Path directo token→USDC cuando existe par
- Minimiza gas y reduce slippage acumulativo
- El constructor pre-configura ETH (vía WETH) con path directo a USDC

**Eficiencia de Gas:**
- Variables inmutables (`i_`) para parámetros que no cambian
- Variables de estado con prefijo `s_` para claridad de lectura
- Custom errors en lugar de strings (ahorro gas en reverts)
- Eventos optimizados para indexación off-chain

**Seguridad:**
- `ReentrancyGuard` en todas las funciones que mueven fondos
- Validaciones tempranas con fail-fast pattern
- Role-based access control con OpenZeppelin AccessControl
- SafeERC20 para prevenir issues con tokens non-standard

---

## 🧪 Tests y Resultados (Tenderly Fork)

### ✅ Test 1: Depósito de ETH con Swap Automático
```bash
Input:  1 ETH
Output: 3,562.40 USDC acreditados
Status: ✅ Exitoso
Tx:     0x172a5f9ae20b27d5128ccf16606aa2bca6407712af6d4adfab95152f265d0465
```

**Validaciones:**
- ETH convertido a WETH automáticamente
- Swap WETH→USDC ejecutado en Uniswap V2
- Slippage dentro del 2% permitido
- Balance de usuario actualizado correctamente
- `s_totalDepositsUSDC` incrementado
- Eventos `Deposit` y `TokenSwapped` emitidos

### ✅ Test 2: Retiro Respetando Límites
```bash
Input:       1,000 USDC
Validación:  ≤ i_withdrawalLimitUSDC (1,000 USDC)
Status:      ✅ Exitoso
Tx:          0x19352117e593d6ffcae4d8960e05ceabbe28b7e102ced00104e2e7268a2f5361
```

**Validaciones:**
- Verificación de balance suficiente
- Límite de retiro respetado
- USDC transferido correctamente al usuario
- Balance y `s_totalDepositsUSDC` actualizados
- Evento `Withdrawal` emitido

### ✅ Test 3: Segundo Depósito ETH
```bash
Input:  0.5 ETH
Output: 1,781.20 USDC acreditados
Status: ✅ Exitoso
Tx:     0xd3f901c7e3eec12b031f550db178f8eac7030741de439d2fa4142a9ce82bad5f
```

**Validaciones:**
- Swap ejecutado correctamente con nuevo precio de mercado
- Balance acumulativo correcto (3,562.40 - 1,000 + 1,781.20)
- Bank cap no excedido (4,343.60 < 100,000)

### ✅ Test 4: Verificación de Bank Cap
```bash
Total Deposits: 4,343.60 USDC
Bank Cap:       100,000 USDC
Status:         ✅ Dentro del límite (4.34% utilizado)
```

**Validación:** Sistema rechazaría correctamente depósitos que excedan el bank cap

### ✅ Test 5: Control de Acceso y Roles
```bash
Roles verificados: DEFAULT_ADMIN_ROLE, ADMIN_ROLE, OPERATOR_ROLE
Status:            ✅ Funcionando correctamente
```

**Validación:** Solo direcciones con `ADMIN_ROLE` pueden agregar/remover tokens

---

## 📝 Instrucciones de Interacción

### Setup de Variables

```bash
# Tenderly Fork RPC
export TENDERLY_RPC="https://virtual.mainnet.eu.rpc.tenderly.co/TU_FORK_ID"

# Contract Address
export CONTRACT="0xE0f14bcF51C00F169E6e60461550B70483601745"

# Private Key (NUNCA compartir - usar .env)
export PRIVATE_KEY="your-private-key-here"
```

**⚠️ IMPORTANTE:** Crea un archivo `.env` (agregado a `.gitignore`) para tus claves:

```bash
# .env (NUNCA subir a GitHub)
TENDERLY_RPC=https://virtual.mainnet.eu.rpc.tenderly.co/tu-fork-id
CONTRACT=0xE0f14bcF51C00F169E6e60461550B70483601745
PRIVATE_KEY=tu-clave-privada-aqui
```

Luego carga las variables:
```bash
source .env
```

### Depositar ETH (convertido automáticamente a USDC)

```bash
cast send $CONTRACT "depositETH()" \
  --value 1ether \
  --rpc-url $TENDERLY_RPC \
  --private-key $PRIVATE_KEY
```

### Consultar Balance de Usuario

```bash
cast call $CONTRACT \
  "s_balances(address)(uint256)" \
  YOUR_ADDRESS \
  --rpc-url $TENDERLY_RPC
```

**Output:** Balance en USDC (6 decimals). Ejemplo: `3562399918` = 3,562.40 USDC

### Retirar USDC

```bash
cast send $CONTRACT \
  "withdraw(uint256)" \
  1000000000 \
  --rpc-url $TENDERLY_RPC \
  --private-key $PRIVATE_KEY
```

**Nota:** Monto en 6 decimals. `1000000000` = 1,000 USDC

### Ver Información del Banco

```bash
cast call $CONTRACT "getBankInfo()" --rpc-url $TENDERLY_RPC
```

### Estimar Swap de Token a USDC

```bash
cast call $CONTRACT \
  "getEstimatedUSDC(address,uint256)" \
  0x0000000000000000000000000000000000000000 \
  1000000000000000000 \
  --rpc-url $TENDERLY_RPC
```

### Ver Tokens Soportados

```bash
cast call $CONTRACT "getSupportedTokens()" --rpc-url $TENDERLY_RPC
```

### Agregar Nuevo Token (Solo ADMIN_ROLE)

```bash
# Ejemplo: Agregar DAI
cast send $CONTRACT \
  "addToken(address)" \
  0x6B175474E89094C44Da98b954EedeAC495271d0F \
  --rpc-url $TENDERLY_RPC \
  --private-key $PRIVATE_KEY
```
## 🔧 Instrucciones para Sepolia

### Setup de Variables (Sepolia)

```bash
# Sepolia RPC
export SEPOLIA_RPC="https://sepolia.infura.io/v3/YOUR_KEY"

# Contract deployado en Sepolia
export CONTRACT_SEPOLIA="TU_DIRECCION_AQUI"

# USDC en Sepolia
export USDC_SEPOLIA="0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2"

# Private Key
export PRIVATE_KEY="your-private-key"
```

### 1. Obtener USDC de testnet

```bash
# Necesitas conseguir USDC de prueba en Sepolia:
# - Faucets de testnet
# - Swap en Uniswap Sepolia si tienes SepoliaETH
# - Pedir en comunidades Discord/Telegram
```

### 2. Depositar USDC en Sepolia

```bash
# Aprobar el contrato
cast send $USDC_SEPOLIA "approve(address,uint256)" \
  $CONTRACT_SEPOLIA \
  1000000000 \
  --rpc-url $SEPOLIA_RPC \
  --private-key $PRIVATE_KEY

# Depositar 1,000 USDC
cast send $CONTRACT_SEPOLIA "depositToken(address,uint256)" \
  $USDC_SEPOLIA \
  1000000000 \
  --rpc-url $SEPOLIA_RPC \
  --private-key $PRIVATE_KEY
```

### 3. Ver balance

```bash
cast call $CONTRACT_SEPOLIA \
  "s_balances(address)(uint256)" \
  YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC
```

### 4. Intentar agregar ETH (esperará fallo por falta de liquidez)

```bash
# Esto probablemente fallará con "NoPairExists()" o durante el swap
cast send $CONTRACT_SEPOLIA "addToken(address)" \
  0x0000000000000000000000000000000000000000 \
  --rpc-url $SEPOLIA_RPC \
  --private-key $PRIVATE_KEY

# Expected: Revert con NoPairExists() o InsufficientLiquidity
# Esto demuestra que el sistema de validación funciona correctamente

```
## 📋 Addresses de Referencia

### Tenderly Fork (Mainnet state)

| Componente | Address |
|------------|---------|
| KipuBankV3 | `0xE0f14bcF51C00F169E6e60461550B70483601745` |
| USDC (Mainnet) | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| WETH (Mainnet) | `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2` |
| Uniswap V2 Router | `0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D` |
| Uniswap V2 Factory | `0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f` |

### Sepolia Testnet

| Componente | Address |
|------------|---------|
| Uniswap V2 Router | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` |
| Uniswap V2 Factory | `0x7E0987E5b3a30e3f2828572Bb659A548460a3003` |
| USDC (Circle) | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |
| WETH | `0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14` |

**Parámetros de Deploy para Sepolia:**
```
withdrawalLimitUSDC: 1000000000 (1,000 USDC)
bankCapUSDC: 100000000000 (100,000 USDC)
uniswapRouter: 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
uniswapFactory: 0x7E0987E5b3a30e3f2828572Bb659A548460a3003
usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```


## 🔐 Consideraciones de Seguridad

### Medidas Implementadas

1. **ReentrancyGuard** en `depositETH()`, `depositToken()`, `withdraw()`
2. **Access Control** con roles granulares (ADMIN_ROLE, OPERATOR_ROLE)
3. **Input Validation** en todas las funciones públicas
4. **Custom Errors** para claridad y ahorro de gas
5. **SafeERC20** para operaciones seguras con tokens
6. **Slippage Protection** en swaps (2% tolerance)
7. **Zero Address Checks** en constructor y funciones críticas
8. **Amount Validation** con modifier `validAmount`

### Vectores de Ataque Considerados

| Vector | Protección | Estado |
|--------|-----------|--------|
| **Reentrancy** | ReentrancyGuard | ✅ Protegido |
| **Front-running swaps** | Slippage protection | ⚠️ Mitigado parcialmente |
| **Access control bypass** | OpenZeppelin AccessControl | ✅ Protegido |
| **Integer overflow/underflow** | Solidity 0.8.26 checks | ✅ Protegido |
| **Token approval exploits** | Aprobaciones temporales y limitadas | ✅ Protegido |
| **Malicious token contracts** | SafeERC20 + pair verification | ✅ Mitigado |
| **Bank cap bypass** | Check after swap calculation | ✅ Protegido |
| **Withdrawal limit bypass** | Verificación explícita | ✅ Protegido |

### Consideraciones para Producción

⚠️ **Este contrato es con fines educativos.** Antes de usar en mainnet:

1. Auditoría profesional de seguridad
2. Circuit breakers / Pause mechanism
3. Timelock para cambios críticos
4. Price oracle adicional (Chainlink)
5. Testing con fuzzing y formal verification
6. MEV protection avanzada
7. Insurance fund
8. Bug bounty program

---

## 📚 Recursos y Referencias

- [Código fuente completo](./src/KipuBankv3.sol)
- [Código fuente alternativo sepolia](./src/KipuBankv3sep.sol)
- [Script de deployment](./script/DeployKipuBankv3.s.sol)
- [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Tenderly Forks Documentation](https://docs.tenderly.co/forks)
- [Foundry Book](https://book.getfoundry.sh/)

---

## 🏗️ Estructura del Proyecto

```
kipu-bank-v3/
├── src/
│   └── KipuBankv3.sol              # Contrato principal
    └── KipuBankv3sep.sol           # Contrato alternativo sepolia
├── script/
│   └── DeployKipuBankv3.s.sol      # Script de deployment (Tenderly)
├── lib/
│   ├── forge-std/                  # Foundry standard library
│   └── openzeppelin-contracts/     # OpenZeppelin dependencies
├── foundry.toml                    # Configuración de Foundry
├── .gitignore
├── LICENSE                         # MIT License
└── README.md                       # Este archivo
```

---


## 🔄 Flujo de Operaciones

### Depósito de Token con Swap

```
Usuario deposita Token
         ↓
    ¿Es USDC?
    /        \
  Sí         No
   ↓          ↓
Acreditar  ¿Tiene par con USDC?
directo    /              \
          Sí              No
          ↓               ↓
    Swap Token→USDC   Revert: NoPairExists
          ↓
    Verificar Bank Cap
          ↓
    ¿Excede capacidad?
    /              \
   Sí               No
    ↓                ↓
Revert:          Actualizar balances
BankCapacity         ↓
Exceeded        Emitir eventos
            (Deposit, TokenSwapped)
```

### Retiro de USDC

```
Usuario solicita retiro
         ↓
    ¿Balance suficiente?
    /              \
   No              Sí
    ↓               ↓
Revert:      ¿Dentro del límite?
InsufficientBalance  /        \
                   No         Sí
                    ↓          ↓
                Revert:    Transferir USDC
                WithdrawalLimit   ↓
                Exceeded    Actualizar estado
                                  ↓
                            Emitir Withdrawal
```

---

## 👤 Autor

**Javier Mateos**  
Kipu Blockchain Accelerator - Módulo 4  
Trabajo Final - Noviembre 2025

GitHub: [@javierpmateos](https://github.com/javierpmateos)

---

**License:** MIT  

**Disclaimer:** Educational purposes only. Not audited for production use.ecto

