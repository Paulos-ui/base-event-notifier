// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BaseEventNotifier
 * @notice On-chain event subscription and notification system built for Base
 * @dev Deploy on Base Mainnet (Chain ID: 8453)
 *      Built for the Builder Fund on Base
 */
contract BaseEventNotifier {

    // ─────────────────────────────────────────────
    //  TYPES
    // ─────────────────────────────────────────────

    enum EventType {
        TRANSFER,       // 0 – ETH or token transfer
        CONTRACT_CALL,  // 1 – arbitrary contract interaction
        CUSTOM          // 2 – user-defined label
    }

    struct Subscription {
        address subscriber;
        address watchedAddress;   // address to monitor
        EventType eventType;
        string  label;            // human-readable tag
        bool    active;
        uint256 createdAt;
    }

    struct Notification {
        uint256 subscriptionId;
        address triggeredBy;      // tx sender that fired the event
        string  message;
        uint256 timestamp;
    }

    // ─────────────────────────────────────────────
    //  STATE
    // ─────────────────────────────────────────────

    address public owner;
    uint256 public subscriptionCount;
    uint256 public notificationCount;

    /// subscriptionId => Subscription
    mapping(uint256 => Subscription) public subscriptions;

    /// subscriber => list of their subscription IDs
    mapping(address => uint256[]) public userSubscriptions;

    /// notificationId => Notification
    mapping(uint256 => Notification) public notifications;

    /// subscriptionId => list of notification IDs fired for it
    mapping(uint256 => uint256[]) public subscriptionNotifications;

    // ─────────────────────────────────────────────
    //  EVENTS  (these are what external indexers watch)
    // ─────────────────────────────────────────────

    event Subscribed(
        uint256 indexed subscriptionId,
        address indexed subscriber,
        address indexed watchedAddress,
        EventType       eventType,
        string          label
    );

    event Unsubscribed(
        uint256 indexed subscriptionId,
        address indexed subscriber
    );

    event NotificationEmitted(
        uint256 indexed notificationId,
        uint256 indexed subscriptionId,
        address indexed triggeredBy,
        string          message,
        uint256         timestamp
    );

    event ActivityTracked(
        address indexed actor,
        address indexed target,
        uint256         value,
        string          action,
        uint256         timestamp
    );

    // ─────────────────────────────────────────────
    //  MODIFIERS
    // ─────────────────────────────────────────────

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validSubscription(uint256 subId) {
        require(subId < subscriptionCount, "Invalid subscription");
        require(subscriptions[subId].active, "Subscription inactive");
        _;
    }

    // ─────────────────────────────────────────────
    //  CONSTRUCTOR
    // ─────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
    }

    // ─────────────────────────────────────────────
    //  SUBSCRIPTION MANAGEMENT
    // ─────────────────────────────────────────────

    /**
     * @notice Subscribe to watch an address for a specific event type
     * @param watchedAddress The address you want to monitor
     * @param eventType      Type of event (TRANSFER=0, CONTRACT_CALL=1, CUSTOM=2)
     * @param label          A short human-readable label for this subscription
     * @return subscriptionId
     */
    function subscribe(
        address  watchedAddress,
        EventType eventType,
        string calldata label
    ) external returns (uint256 subscriptionId) {
        require(watchedAddress != address(0), "Invalid watched address");
        require(bytes(label).length > 0,      "Label required");

        subscriptionId = subscriptionCount++;

        subscriptions[subscriptionId] = Subscription({
            subscriber:     msg.sender,
            watchedAddress: watchedAddress,
            eventType:      eventType,
            label:          label,
            active:         true,
            createdAt:      block.timestamp
        });

        userSubscriptions[msg.sender].push(subscriptionId);

        emit Subscribed(subscriptionId, msg.sender, watchedAddress, eventType, label);
    }

    /**
     * @notice Cancel an active subscription
     */
    function unsubscribe(uint256 subscriptionId) external {
        Subscription storage sub = subscriptions[subscriptionId];
        require(sub.subscriber == msg.sender || msg.sender == owner, "Not authorized");
        require(sub.active, "Already inactive");

        sub.active = false;
        emit Unsubscribed(subscriptionId, msg.sender);
    }

    // ─────────────────────────────────────────────
    //  NOTIFICATION EMISSION
    // ─────────────────────────────────────────────

    /**
     * @notice Emit a notification for a subscription (callable by owner/relayer)
     * @dev In production, a Gelato/Chainlink relayer calls this after detecting
     *      off-chain that the watched address had relevant activity.
     */
    function emitNotification(
        uint256 subscriptionId,
        address triggeredBy,
        string calldata message
    ) external onlyOwner validSubscription(subscriptionId) {
        uint256 notifId = notificationCount++;

        notifications[notifId] = Notification({
            subscriptionId: subscriptionId,
            triggeredBy:    triggeredBy,
            message:        message,
            timestamp:      block.timestamp
        });

        subscriptionNotifications[subscriptionId].push(notifId);

        emit NotificationEmitted(
            notifId,
            subscriptionId,
            triggeredBy,
            message,
            block.timestamp
        );
    }

    /**
     * @notice Self-report activity — any address can log its own on-chain action
     * @dev Useful for contracts that integrate and want to surface notifications
     */
    function trackActivity(
        address target,
        string calldata action
    ) external payable {
        emit ActivityTracked(
            msg.sender,
            target,
            msg.value,
            action,
            block.timestamp
        );
    }

    // ─────────────────────────────────────────────
    //  READ HELPERS
    // ─────────────────────────────────────────────

    /// @notice Get all subscription IDs for a user
    function getUserSubscriptions(address user)
        external view returns (uint256[] memory)
    {
        return userSubscriptions[user];
    }

    /// @notice Get all notification IDs for a subscription
    function getSubscriptionNotifications(uint256 subscriptionId)
        external view returns (uint256[] memory)
    {
        return subscriptionNotifications[subscriptionId];
    }

    /// @notice Get full subscription details
    function getSubscription(uint256 subscriptionId)
        external view returns (Subscription memory)
    {
        return subscriptions[subscriptionId];
    }

    /// @notice Get full notification details
    function getNotification(uint256 notificationId)
        external view returns (Notification memory)
    {
        return notifications[notificationId];
    }

    /// @notice Summary stats
    function getStats() external view returns (
        uint256 totalSubscriptions,
        uint256 totalNotifications,
        address contractOwner
    ) {
        return (subscriptionCount, notificationCount, owner);
    }

    // ─────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    /// @notice Accept ETH (for future fee model)
    receive() external payable {}

    /// @notice Withdraw ETH (owner only)
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
