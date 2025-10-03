# Intuition Counter dApp (Farcaster Mini App)

A decentralized counter application built as a Farcaster Mini App featuring evolving badge NFTs, a top-50 leaderboard, and seamless wallet interaction.

## Description

Intuition Counter dApp is an interactive blockchain-based application that allows users to increment and decrement a counter while earning badges and competing on a global leaderboard. The app integrates with Web3 wallets and provides a gamified experience through evolving NFT badges based on user activity.

## Features

- **Counter Functionality**: Increment and decrement a global counter with blockchain integration
- **Evolving Badge System**: Earn NFT badges that evolve based on your interaction level
  - Bronze Badge: 0-10 interactions
  - Silver Badge: 11-50 interactions
  - Gold Badge: 51-100 interactions
  - Platinum Badge: 100+ interactions
- **Top-50 Leaderboard**: Compete with other users and track your ranking
- **Wallet Integration**: Connect your Web3 wallet for seamless blockchain interaction
- **Admin Controls**: Administrative functions for managing the dApp
- **Real-time Updates**: Live counter updates and leaderboard rankings

## Quickstart

### Prerequisites
- A Web3-compatible wallet (e.g., MetaMask, WalletConnect)
- Access to the appropriate blockchain network

### How to Use

1. **Connect Your Wallet**
   - Click the "Connect Wallet" button
   - Approve the connection request in your wallet

2. **Interact with the Counter**
   - Click the "+" button to increment the counter
   - Click the "-" button to decrement the counter
   - Each interaction is recorded on the blockchain

3. **Earn Badges**
   - Your badge evolves automatically based on your interaction count
   - View your current badge status in the app

4. **Check the Leaderboard**
   - View the top 50 users by interaction count
   - See your current ranking and progress

## File Descriptions

### `index.html`
The main frontend file containing the user interface for the dApp. Includes:
- Counter display and interaction buttons
- Badge NFT visualization
- Leaderboard component
- Wallet connection interface
- Web3 integration scripts

### `contract.sol`
The Solidity smart contract that powers the dApp backend. Features:
- Counter state management
- Badge NFT minting and evolution logic
- Leaderboard data storage
- Admin functions and access control
- User interaction tracking

### `manifest.json`
The Farcaster Mini App manifest file. Defines:
- App metadata and configuration
- Farcaster frame integration settings
- App permissions and capabilities
- Frame button actions and navigation

### `vercel.json`
Deployment configuration for Vercel hosting. Includes:
- Build settings and environment variables
- Routing rules and redirects
- API endpoint configurations
- Static file handling

## License

MIT License

Copyright (c) 2025 CryptoExplor

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
