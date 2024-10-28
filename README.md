# <h1 align="center"> Seree TLS Notary Blueprint 🔐 </h1>

**A TLS Notary Blueprint for Seree on Tangle**

## 🔍 Overview

The Seree TLS Notary Blueprint provides a secure and scalable infrastructure for verifying TLS-based proofs of payment processing and currency exchange transactions. It leverages TLSNotary to create cryptographic proofs that can be used to validate on-chain and off-chain payment flows.

### Key Features

- **TLS Notary Integration**: Creates verifiable proofs of TLS sessions for payment validation
- **Secure Payment Processing**: Validates payment flows between on-chain and off-chain systems
- **Scalable Architecture**: Built on Tangle Network for high throughput and reliability
- **Smart Contract Integration**: Seamless interaction with Ethereum-based payment contracts

### Architecture

The blueprint consists of three main components:

1. **TLS Notary Server**: Handles TLS session proofs and verification
2. **Payment Processor**: Manages currency conversions and payment flows
3. **Smart Contract Interface**: Interacts with on-chain payment contracts

## 📚 Prerequisites

Before you can run this project, you will need to have the following software installed on your machine:

- [Rust](https://www.rust-lang.org/tools/install)
- [Forge](https://getfoundry.sh)
- [Tangle](https://github.com/tangle-network/tangle?tab=readme-ov-file#-getting-started-)

You will also need to install [cargo-tangle](https://crates.io/crates/cargo-tangle), our CLI tool for creating and
deploying Tangle Blueprints:

To install the Tangle CLI, run the following command:

> Supported on Linux, MacOS, and Windows (WSL2)
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tangle-network/gadget/releases/download/cargo-tangle-v0.1.2/
cargo-tangle-installer.sh | sh
```

Or, if you prefer to install the CLI from crates.io:

```bash
cargo install cargo-tangle --force # to get the latest version.
```

## 🛠️ Development
```sh
cargo build
```

to build the project, and

```sh
cargo tangle blueprint deploy
```

to deploy the blueprint to the Tangle network.

## 📜 License

Licensed under either of

* Apache License, Version 2.0
  ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license
  ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.