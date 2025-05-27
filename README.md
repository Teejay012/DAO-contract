# On-Chain Governance System with Foundry

This project implements a full on-chain governance workflow using Solidity and the Foundry framework. It includes smart contracts for a Governor, Timelock, governance token, and a simple `Box` contract as the target of governance proposals.

## 🧱 Stack

- **Solidity `^0.8.20`**
- **Foundry (Forge)** — blazing fast testing, deploying, and fuzzing
- **OpenZeppelin Contracts** — Governor, Timelock, and ERC20 logic

---

## 📦 Contracts

### `GovToken.sol`
An ERC20 token with voting capabilities (delegation, snapshotting). Used as the governance token.

### `MyGovernor.sol`
Custom governor contract extending OpenZeppelin’s `Governor`, `GovernorCountingSimple`, and `GovernorTimelockControl`.

### `TimeLock.sol`
Timelock controller that queues proposals and enforces a delay before execution.

### `Box.sol`
A simple contract with an integer storage that only the timelock can modify.

---

## 🧪 Test Suite

### File: `test/MyGovernorTest.t.sol`

Thoroughly tests the full governance lifecycle:

1. ✅ **Cannot update Box directly**  
2. 🗳 **Create Proposal**  
3. 🗳 **Vote on Proposal**  
4. 🕐 **Queue Proposal (after voting)**  
5. ✅ **Execute Proposal (after delay)**  

Sample test:

```solidity
function testGovernanceUpdatesBox() public {
    // Setup and propose
    ...
    // Voting
    ...
    // Queueing
    ...
    // Execution
    ...
    assertEq(box.getNumber(), valueToStore);
}
```
## ⚙️ Governance Parameters

| Parameter       | Value                   |
| --------------- | ----------------------- |
| `Voting Delay`  | 1 block                 |
| `Voting Period` | \~1 week (50400 blocks) |
| `Quorum`        | 4% of total supply      |
| `Min Delay`     | 1 hour (3600s)          |

## 📂 Project Structure

├── src/
│   ├── GovToken.sol
│   ├── MyGovernor.sol
│   ├── TimeLock.sol
│   └── Box.sol
├── test/
│   └── MyGovernorTest.t.sol
├── foundry.toml
└── README.md

## 📌 How Governance Works
1. A user proposes a change (e.g., call Box.store()).

2. Delegated token holders vote during the voting period.

3. If passed, the proposal is queued in the TimeLock.

4. After the delay, it can be executed to change state.

## 🚀 Getting Started

1. Install Foundry
https://book.getfoundry.sh/getting-started/installation
2. Clone and install deps
```bash
git clone https://github.com/Teejay012/DAO-contract.git
cd DAO-contract
forge install
```

## 🧠 Author

Follow me on twitter [EtherEngineer](https://x.com/Tee_Jay4life)

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
