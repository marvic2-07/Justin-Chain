# Justin-Chain Smart Contract

A Clarity smart contract for decentralized dispute resolution on the Stacks blockchain. This contract allows users to file disputes, assign mediators, and resolve cases transparently with robust validation and error handling.

## Features

- **File Dispute:** Users can initiate disputes with a description and a counterparty.
- **Assign Mediator:** Only the contract owner can assign a mediator to a dispute.
- **Resolve Dispute:** Assigned mediators can resolve disputes and declare a winner.
- **View Dispute:** Anyone can view dispute details.
- **Strict Validation:** Prevents self-disputes, enforces description length, and ensures only valid parties can win.

## File Structure

```
contracts/
  Justin-chain.clar   # Main smart contract
.gitignore            # Git ignore rules
README.md             # Project documentation
```

## Usage

### 1. File a Dispute

```clarity
(file-dispute party-b description)
```
- `party-b`: Principal address of the counterparty.
- `description`: Description of the dispute (max 100 UTF-8 characters).

### 2. Assign a Mediator

```clarity
(assign-mediator dispute-id mediator)
```
- Only contract owner can call.
- `dispute-id`: ID of the dispute.
- `mediator`: Principal address of the mediator.

### 3. Resolve a Dispute

```clarity
(resolve-dispute dispute-id winner)
```
- Only assigned mediator can call.
- `winner`: Must be either party-a or party-b.

### 4. View Dispute Details

```clarity
(get-dispute id)
```
- Returns dispute details for the given ID.

## Error Codes

| Code | Meaning                                 |
|------|-----------------------------------------|
| u100 | Unauthorized (not contract owner)       |
| u101 | Not mediator                            |
| u102 | Already resolved                        |
| u103 | Dispute not found                       |
| u104 | Mediator not found                      |
| u105 | Cannot file dispute against self        |
| u106 | Mediator already assigned               |
| u107 | Contract owner cannot be mediator       |
| u108 | Winner must be one of the parties       |
| u109 | Description too long                    |

## Development

- Written in [Clarity](https://docs.stacks.co/docs/clarity-language/overview/).
- Compatible with Stacks blockchain.
- To deploy, use the Stacks CLI or supported IDEs like [VS Code](https://marketplace.visualstudio.com/items?itemName=hirosystems.clarity).
