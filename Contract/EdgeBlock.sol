// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EdgeBlock: Decentralized Edge Computing Resource Marketplace
 * @dev A blockchain-based marketplace for renting and providing edge computing resources.
 */
contract Project {
    struct Resource {
        uint256 id;
        address provider;
        string description;
        uint256 pricePerHour; // in wei
        bool isAvailable;
    }

    mapping(uint256 => Resource) public resources;
    uint256 public resourceCount;

    event ResourceListed(uint256 indexed id, address indexed provider, uint256 pricePerHour);
    event ResourceRented(uint256 indexed id, address indexed renter, uint256 hoursRented, uint256 amountPaid);
    event ResourceAvailabilityChanged(uint256 indexed id, bool isAvailable);

    /**
     * @dev Provider lists an available computing resource.
     * @param _description A brief description of the resource.
     * @param _pricePerHour Cost in wei per hour.
     */
    function listResource(string memory _description, uint256 _pricePerHour) external {
        resourceCount++;
        resources[resourceCount] = Resource(resourceCount, msg.sender, _description, _pricePerHour, true);
        emit ResourceListed(resourceCount, msg.sender, _pricePerHour);
    }

    /**
     * @dev Rent a resource for a specific number of hours.
     * @param _id ID of the resource.
     * @param _hours Number of hours to rent.
     */
    function rentResource(uint256 _id, uint256 _hours) external payable {
        Resource storage res = resources[_id];
        require(res.isAvailable, "Resource not available");
        uint256 totalCost = res.pricePerHour * _hours;
        require(msg.value >= totalCost, "Insufficient payment");

        payable(res.provider).transfer(totalCost);
        emit ResourceRented(_id, msg.sender, _hours, totalCost);
    }

    /**
     * @dev Provider can change availability of their resource.
     * @param _id ID of the resource.
     * @param _status True = available, False = unavailable.
     */
    function setAvailability(uint256 _id, bool _status) external {
        Resource storage res = resources[_id];
        require(msg.sender == res.provider, "Only provider can change availability");
        res.isAvailable = _status;
        emit ResourceAvailabilityChanged(_id, _status);
    }
}
