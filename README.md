# NameRegistryV1

A simple registry contract for mapping [Hub V1](https://github.com/CirclesUBI/circles-contracts) avatars to metadata digests (e.g., IPFS CIDs). This contract enforces that only recognized Hub V1 users (humans or organizations) can update their own metadata, and it allows a single privileged "seeder" role to batch-update multiple avatars if required.

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Contract Architecture](#contract-architecture)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Testing](#testing)
7. [Security Considerations](#security-considerations)
8. [License](#license)

---

## Overview

**NameRegistryV1** manages a mapping of addresses (avatars) to metadata digests. A typical use case is to store off-chain information such as IPFS CIDs.

The contract references a **HubV1** instance to verify that each address is indeed a valid user or organization in the Hub V1 ecosystem. If they are not recognized, updates to their metadata digests will revert.

Additionally, the contract designates a "seeder" address that:
- Initially has privileged rights to seed metadata in bulk (via `updateMetadataDigestBatch`).
- Can renounce that privilege at any time, ensuring no further batch updates are possible.

---

## Features

1. **Metadata Registry**  
   - Each recognized user/organization has an associated metadata digest (e.g., CIDv0 for IPFS).

2. **Batch Updates**  
   - The seeder can set metadata for multiple avatars in one transaction, streamlining the process of seeding data on contract deployment.

3. **Permissioned Logic**  
   - Only a recognized Hub V1 user can update their own metadata via `updateMetadataDigest`.
   - Only the seeder can call the batch update function.

4. **Renounce Seeder**  
   - The seeder may renounce their privileged role, ensuring that no further external seeding or bulk updates can occur after an initial setup period.

---

## Contract Architecture

### NameRegistryV1

- **State Variables**:
  - `hub`: The HubV1 contract used for verifying user addresses.  
  - `seeder`: The account allowed to make bulk metadata updates.  
  - `avatarToMetaDataDigest`: Mapping from avatar addresses to the 32-byte metadata digest.

- **Core Functions**:
  - `updateMetadataDigestBatch(address[] memory avatars, bytes32[] memory metadataDigests)`:  
    Allows the seeder to update multiple avatars in a single call.
  - `updateMetadataDigest(bytes32 _metadataDigest)`:  
    Allows a recognized Hub V1 user (or organization) to update their own metadata.
  - `renounceSeederRole()`:  
    Allows the seeder to revoke its own role.

- **Errors**:
  - `InvalidHubV1User()`: Thrown when an address is neither a recognized user nor an organization in Hub V1.
  - `UnauthorizedSeeder()`: Thrown when the caller attempting a restricted action is not the seeder.
  - `MismatchedArrayLengths()`: Thrown when batch update arrays have different lengths.

---

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/name-registry-v1.git
   cd name-registry-v1
   ```

2. **Install Dependencies**:
   ```bash
   forge install
   ```

## Usage

1. **Deploy** the contract, passing inside DeployNameRegistryV1.s.sol:
   - The address of the HubV1 contract,
   - The address of the initial seeder.   
   
   ```bash
   forge script script/DeployNameRegistryV1.s.sol:DeployNameRegistryV1 --rpc-url gnosis
   ```
2. **Update Single Metadata**
    Once deployed, any recognized Hub V1 user can update their own metadata:
    ```solidity
    nameRegistry.updateMetadataDigest(bytes32("..."));
    ```
3. **Batch Update**
    Only the seeder address can perform a bulk update:
    ```solidity
    address[] memory avatars = ...
    bytes32[] memory metadataDigests = ...
    nameRegistry.updateMetadataDigestBatch(avatars, metadataDigests);
    ```
4. **Renounce Seeder**
    The seeder can remove its own privilege permanently:
    ```solidity
    nameRegistry.renounceSeederRole();
    ```

## Testing

```bash
forge test
```

## Security Considerations

1. **Seeder Privileges**  
   - The seeder can update the metadata of any valid avatar address in bulk. This role should be assigned carefully.
   - Once `renounceSeederRole()` is called, no further batch updates can be made.

2. **Hub V1 Trust**  
   - This contract depends on Hub V1 to accurately identify legitimate users/organizations. If Hub V1 is compromised or misrepresents user addresses, this registry can reflect incorrect data.

3. **Metadata Storage**  
   - Data is stored as a `bytes32` digest, typically referencing an IPFS CID or similar. Any actual content lives off-chain. Ensure integrity checks happen off-chain when retrieving the content via the hash.

## License

This project is licensed under the [AGPL-3.0-only](./LICENSE) license. Please see the [LICENSE](./LICENSE) file for details.
