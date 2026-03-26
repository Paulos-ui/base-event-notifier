# 🔔 BaseEventNotifier

> **On-chain event subscription and notification system built natively on Base.**

A lightweight, gas-efficient smart contract that lets any wallet subscribe to watch on-chain addresses and receive permanent, indexable notifications when activity occurs — no oracles, no off-chain infrastructure required to get started.

Built for the **Builder Fund on Base**.

---

## 🌐 Live Demo

🔗 **Frontend:** [Deploy on Vercel — link coming soon]

📄 **Contract on BaseScan:** [https://basescan.org/address/0x9E1086290dc05649A13B0af1Ae4e9A55F41CFC63](https://basescan.org/address/0x9E1086290dc05649A13B0af1Ae4e9A55F41CFC63)

---

## 📋 Contract Details

| Field | Value |
|---|---|
| **Network** | Base Mainnet |
| **Chain ID** | 8453 |
| **Contract Address** | `0x9E1086290dc05649A13B0af1Ae4e9A55F41CFC63` |
| **Solidity Version** | 0.8.20 |
| **License** | MIT |

---

## ✨ Features

- **Subscribe** to watch any on-chain address for transfers, contract calls, or custom events
- **Permanent on-chain notifications** — logged forever, indexable by any RPC or subgraph
- **Self-reporting** — other contracts can integrate and emit `ActivityTracked` events
- **Zero external dependencies** — pure Solidity, no oracles or middleware required
- **Gas efficient** — deploy costs ~$0.01 on Base, subscriptions cost < $0.001

---

## 🔧 Contract Functions

### Write Functions

| Function | Description |
|---|---|
| `subscribe(address, uint8, string)` | Watch an address for TRANSFER (0), CONTRACT_CALL (1), or CUSTOM (2) events |
| `unsubscribe(uint256)` | Cancel a subscription by its ID |
| `emitNotification(uint256, address, string)` | Fire an on-chain notification (owner/relayer) |
| `trackActivity(address, string)` | Any contract can self-report on-chain activity |

### Read Functions

| Function | Description |
|---|---|
| `getUserSubscriptions(address)` | Get all subscription IDs for a wallet |
| `getSubscription(uint256)` | Get full details of a subscription |
| `getSubscriptionNotifications(uint256)` | Get all notification IDs for a subscription |
| `getNotification(uint256)` | Get full details of a notification |
| `getStats()` | Total subscriptions, notifications, and owner address |

### Events (Indexable)

```solidity
event Subscribed(uint256 indexed subscriptionId, address indexed subscriber, address indexed watchedAddress, EventType eventType, string label);
event Unsubscribed(uint256 indexed subscriptionId, address indexed subscriber);
event NotificationEmitted(uint256 indexed notificationId, uint256 indexed subscriptionId, address indexed triggeredBy, string message, uint256 timestamp);
event ActivityTracked(address indexed actor, address indexed target, uint256 value, string action, uint256 timestamp);
```

---

## 🚀 Deploy Your Own

### Prerequisites
- [MetaMask](https://metamask.io/) with Base Mainnet added
- ~0.002 ETH on Base for gas (~$0.01)

### Base Mainnet RPC Config

| Field | Value |
|---|---|
| Network Name | Base |
| RPC URL | https://mainnet.base.org |
| Chain ID | 8453 |
| Currency | ETH |
| Explorer | https://basescan.org |

### Deploy via Remix (Recommended)

1. Open [remix.ethereum.org](https://remix.ethereum.org)
2. Create a new file → paste contents of `contracts/BaseEventNotifier.sol`
3. Compile with Solidity `0.8.20`
4. Under **Deploy & Run** → set Environment to **Injected Provider - MetaMask**
5. Confirm you're on Base Mainnet (Chain 8453)
6. Click **Deploy** → confirm in MetaMask
7. Copy your contract address from the Deployed Contracts panel

---

## 🗂 Repository Structure

```
base-event-notifier/
├── contracts/
│   └── BaseEventNotifier.sol    # Main smart contract
├── frontend/
│   └── index.html               # Live dashboard (deploy to Vercel)
├── README.md                    # You are here
└── .gitignore
```

---

## 🌍 Frontend — Deploy to Vercel

The frontend is a single `index.html` file — no build step needed.

1. Push this repo to GitHub
2. Go to [vercel.com](https://vercel.com) → **New Project** → Import your repo
3. Set **Root Directory** to `frontend`
4. Click **Deploy**
5. Share the live URL 🎉

---

## 🔮 Roadmap

- [ ] Gelato / Chainlink relayer integration for automated notification firing
- [ ] The Graph subgraph for real-time event indexing
- [ ] Email / Telegram webhook bridge
- [ ] ERC-20 token transfer tracking
- [ ] Multi-chain support (Optimism, Arbitrum)

---

## 📄 License

MIT — free to use, fork, and build on.

---

*Built on Base · Powered by the Builder Fund*
