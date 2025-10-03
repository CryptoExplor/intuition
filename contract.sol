// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title EvolvingIntuitionCounter v3
/// @notice Counter + leaderboard with evolving on-chain badge NFTs (no cooldown, top 50, single-call leaderboard)
contract EvolvingIntuitionCounter is ERC721, Ownable {
    // --- Configurable ---
    uint256 public fee; // fee (in wei) required to call counter actions
    uint256 public constant MAX_TOP = 50; // expanded leaderboard size

    // --- Counter & leaderboard state ---
    uint256 public count;
    mapping(address => uint256) public incrementCount; // lifetime actions count

    // compact bounded top-N leaderboard (descending)
    address[] public topAddresses;
    uint256[] public topCounts;

    // --- Badge state ---
    uint256 private nextTokenId = 1;

    struct UserStats {
        uint256 increments;
        uint256 decrements;
        uint256 badgeTier;
    }

    mapping(address => UserStats) public userStats;
    mapping(address => uint256) public userTokenId;

    // thresholds (owner configurable)
    uint256 public bronzeThreshold = 10;
    uint256 public silverThreshold = 25;
    uint256 public goldThreshold = 50;
    uint256 public platinumThreshold = 100;
    uint256 public diamondThreshold = 250;
    uint256 public masterThreshold = 500;
    uint256 public legendaryThreshold = 1000;

    mapping(uint256 => string) public badgeNames;

    // Events
    event CounterChanged(address indexed user, int256 delta, uint256 newCount);
    event BadgeAssigned(address indexed user, uint256 tokenId, uint256 tier);
    event FeeUpdated(uint256 newFee);
    event BadgeThresholdsUpdated();
    event CounterReset(uint256 newValue);

    // --- Constructor ---
    constructor(uint256 _initialFee) ERC721("EvolvingIntuitionBadge", "INTUBADGE") Ownable(msg.sender) {
        fee = _initialFee;

        badgeNames[1] = "Bronze Counter Badge";
        badgeNames[2] = "Silver Counter Badge";
        badgeNames[3] = "Gold Counter Badge";
        badgeNames[4] = "Platinum Counter Badge";
        badgeNames[5] = "Diamond Counter Badge";
        badgeNames[6] = "Master Counter Badge";
        badgeNames[7] = "Legendary Counter Badge";
    }

    // --- Modifiers ---
    modifier onlyPaid() {
        require(msg.value == fee, "Must pay exact fee");
        _;
    }

    // --- Public counter functions ---
    function increment() external payable onlyPaid {
        count += 1;
        incrementCount[msg.sender] += 1;

        _updateTopLeaderboard(msg.sender);

        userStats[msg.sender].increments += 1;
        _assignOrUpdateBadge(msg.sender);

        payable(owner()).transfer(msg.value);

        emit CounterChanged(msg.sender, 1, count);
    }

    function decrement() external payable onlyPaid {
        require(count > 0, "Counter already zero");
        count -= 1;
        incrementCount[msg.sender] += 1;

        _updateTopLeaderboard(msg.sender);

        userStats[msg.sender].decrements += 1;
        _assignOrUpdateBadge(msg.sender);

        payable(owner()).transfer(msg.value);

        emit CounterChanged(msg.sender, -1, count);
    }

    // --- Owner/admin functions ---
    function setFee(uint256 _newFee) external onlyOwner {
        fee = _newFee;
        emit FeeUpdated(_newFee);
    }

    function resetCounter(uint256 _newValue) external onlyOwner {
        count = _newValue;
        emit CounterReset(_newValue);
    }

    function setBadgeThresholds(
        uint256 bronze,
        uint256 silver,
        uint256 gold,
        uint256 platinum,
        uint256 diamond,
        uint256 master,
        uint256 legendary
    ) external onlyOwner {
        bronzeThreshold = bronze;
        silverThreshold = silver;
        goldThreshold = gold;
        platinumThreshold = platinum;
        diamondThreshold = diamond;
        masterThreshold = master;
        legendaryThreshold = legendary;
        emit BadgeThresholdsUpdated();
    }

    // --- Top-N leaderboard maintenance ---
    function _updateTopLeaderboard(address user) internal {
        uint256 userCount = incrementCount[user];

        // 1. Already in leaderboard?
        for (uint256 i = 0; i < topAddresses.length; i++) {
            if (topAddresses[i] == user) {
                topCounts[i] = userCount;
                while (i > 0 && topCounts[i] > topCounts[i - 1]) {
                    (topCounts[i - 1], topCounts[i]) = (topCounts[i], topCounts[i - 1]);
                    (topAddresses[i - 1], topAddresses[i]) = (topAddresses[i], topAddresses[i - 1]);
                    i--;
                }
                return;
            }
        }

        // 2. Not present, insert
        if (topAddresses.length < MAX_TOP) {
            topAddresses.push(user);
            topCounts.push(userCount);
            uint256 j = topAddresses.length - 1;
            while (j > 0 && topCounts[j] > topCounts[j - 1]) {
                (topCounts[j - 1], topCounts[j]) = (topCounts[j], topCounts[j - 1]);
                (topAddresses[j - 1], topAddresses[j]) = (topAddresses[j], topAddresses[j - 1]);
                j--;
            }
        } else {
            if (userCount <= topCounts[topCounts.length - 1]) return;

            topAddresses[topAddresses.length - 1] = user;
            topCounts[topCounts.length - 1] = userCount;

            uint256 k = topAddresses.length - 1;
            while (k > 0 && topCounts[k] > topCounts[k - 1]) {
                (topCounts[k - 1], topCounts[k]) = (topCounts[k], topCounts[k - 1]);
                (topAddresses[k - 1], topAddresses[k]) = (topAddresses[k], topAddresses[k - 1]);
                k--;
            }
        }
    }

    // --- Leaderboard view (new) ---
    struct LeaderboardEntry {
        address user;
        uint256 count;
    }

    function getLeaderboard() external view returns (LeaderboardEntry[] memory) {
        uint256 len = topAddresses.length;
        LeaderboardEntry[] memory leaderboard = new LeaderboardEntry[](len);
        for (uint256 i = 0; i < len; i++) {
            leaderboard[i] = LeaderboardEntry({
                user: topAddresses[i],
                count: topCounts[i]
            });
        }
        return leaderboard;
    }

    // --- Badge logic ---
    function _determineTier(uint256 increments) internal view returns (uint256) {
        if (increments >= legendaryThreshold) return 7;
        if (increments >= masterThreshold) return 6;
        if (increments >= diamondThreshold) return 5;
        if (increments >= platinumThreshold) return 4;
        if (increments >= goldThreshold) return 3;
        if (increments >= silverThreshold) return 2;
        if (increments >= bronzeThreshold) return 1;
        return 0;
    }

    function _assignOrUpdateBadge(address user) internal {
        uint256 tier = _determineTier(userStats[user].increments);
        if (tier > userStats[user].badgeTier) {
            userStats[user].badgeTier = tier;
            if (userTokenId[user] == 0) {
                uint256 tokenId = nextTokenId;
                nextTokenId++;
                _safeMint(user, tokenId);
                userTokenId[user] = tokenId;
            }
            emit BadgeAssigned(user, userTokenId[user], tier);
        }
    }

    // --- ERC721 metadata ---
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: nonexistent token"); 
        
        address ownerAddr = ownerOf(tokenId);
        UserStats memory stats = userStats[ownerAddr];
        uint256 tier = stats.badgeTier;
        string memory name = badgeNames[tier];
        string memory svg = _generateSVG(stats.increments, tier);
        string memory image = Base64.encode(bytes(svg));
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        name,
                        '","description":"Evolving On-chain Intuition Badge NFT","attributes":[',
                        '{"trait_type":"Tier","value":"', name, '"},',
                        '{"trait_type":"Increments","value":"', Strings.toString(stats.increments), '"}',
                        '],"image":"data:image/svg+xml;base64,',
                        image,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _generateSVG(uint256 increments, uint256 tier) internal pure returns (string memory) {
        string memory tierColor = _tierColor(tier);
        string memory tierText = _tierText(tier);
        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' width='300' height='300'>",
                "<rect width='300' height='300' fill='", tierColor, "'/>",
                "<text x='50%' y='40%' dominant-baseline='middle' text-anchor='middle' font-size='24' fill='white'>", tierText, "</text>",
                "<text x='50%' y='60%' dominant-baseline='middle' text-anchor='middle' font-size='18' fill='white'>Increments: ", Strings.toString(increments), "</text>",
                "</svg>"
            )
        );
    }

    function _tierColor(uint256 tier) internal pure returns (string memory) {
        if (tier == 7) return "purple";
        if (tier == 6) return "blue";
        if (tier == 5) return "cyan";
        if (tier == 4) return "pink";
        if (tier == 3) return "gold";
        if (tier == 2) return "silver";
        if (tier == 1) return "bronze";
        return "gray";
    }

    function _tierText(uint256 tier) internal pure returns (string memory) {
        if (tier == 7) return "Legendary Badge";
        if (tier == 6) return "Master Badge";
        if (tier == 5) return "Diamond Badge";
        if (tier == 4) return "Platinum Badge";
        if (tier == 3) return "Gold Badge";
        if (tier == 2) return "Silver Badge";
        if (tier == 1) return "Bronze Badge";
        return "No Badge";
    }

    // --- Utility views ---
    function getUserStats(address user) external view returns (uint256 increments, uint256 decrements, uint256 tier) {
        UserStats memory s = userStats[user];
        return (s.increments, s.decrements, s.badgeTier);
    }
}
