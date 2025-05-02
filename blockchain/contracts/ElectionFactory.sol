// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Election.sol";

contract ElectionFactory {
    struct ElectionInfo {
        address electionAddress;
        string name;
    }

    ElectionInfo[] public elections;
    address public admin;

    event ElectionCreated(address indexed electionAddress, string name);

    constructor() {
        admin = msg.sender; // whoever deploys is admin
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function createElection(string memory _name) public onlyAdmin {
        Election newElection = new Election(_name, msg.sender);

        elections.push(ElectionInfo({
            electionAddress: address(newElection),
            name: _name
        }));
        emit ElectionCreated(address(newElection), _name);
    }

    function getAllElections() public view returns (ElectionInfo[] memory) {
        return elections;
    }
}
