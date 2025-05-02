// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    struct Candidate {
        uint id;
        string name;
        string image;
        uint voteCount;
        bool approved;
    }

    string public electionName;
    address public admin;

    mapping(address => bool) public hasVoted;
    mapping(address => bool) public candidateRequestWallets;
    Candidate[] public candidates;
    Candidate[] public candidateRequests;

    bool public electionStarted;
    bool public electionEnded;
    uint public startTime;
    uint public endTime;

    constructor(string memory _name, address _admin) {
    electionName = _name;
    admin = _admin;
}


    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier electionOngoing() {
        require(electionStarted, "Election not started");
        require(!electionEnded, "Election ended");
        require(block.timestamp >= startTime, "Election not started yet");
        require(block.timestamp <= endTime, "Election time is over");
        _;
    }

    // Candidate requests to join
    function requestToBecomeCandidate(string memory _name, string memory _image) public {
        require(!candidateRequestWallets[msg.sender], "Already requested");
        require(msg.sender != admin, "Admin cannot be a candidate");

        candidateRequests.push(Candidate({
            id: candidateRequests.length,
            name: _name,
            image: _image,
            voteCount: 0,
            approved: false
        }));

        candidateRequestWallets[msg.sender] = true;
    }

  


    // View all pending requests
    function getPendingCandidates() public view returns (Candidate[] memory) {
        uint count = 0;
        for (uint i = 0; i < candidateRequests.length; i++) {
            if (!candidateRequests[i].approved) {
                count++;
            }
        }

        Candidate[] memory pending = new Candidate[](count);
        uint index = 0;
        for (uint i = 0; i < candidateRequests.length; i++) {
            if (!candidateRequests[i].approved) {
                pending[index] = candidateRequests[i];
                index++;
            }
        }

        return pending;
    }

    // Admin approves candidate
    function approveCandidate(uint _id) public onlyAdmin {
        require(_id < candidateRequests.length, "Invalid ID");
        require(!candidateRequests[_id].approved, "Already approved");

        candidateRequests[_id].approved = true;

        candidates.push(Candidate({
            id: candidates.length,
            name: candidateRequests[_id].name,
            image: candidateRequests[_id].image,
            voteCount: 0,
            approved: true
        }));
    }

    // Admin rejects candidate
    function rejectCandidate(uint _id) public onlyAdmin {
        require(_id < candidateRequests.length, "Invalid ID");
        delete candidateRequests[_id];
    }

    // View all approved candidates
    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    // Vote for a candidate
    function vote(uint _candidateId) public electionOngoing {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateId < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount += 1;
    }

    // Start election
    function startElection(uint _durationInMinutes) public onlyAdmin {
        require(!electionStarted, "Already started");
        electionStarted = true;
        electionEnded = false;
        startTime = block.timestamp;
        endTime = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    // End election
    function endElection() public onlyAdmin {
        require(electionStarted, "Not started");
        require(!electionEnded, "Already ended");
        electionEnded = true;
    }

    // Get winner with tie check
    function getWinner() public view returns (Candidate memory, bool) {
        require(electionEnded, "Election not ended");

        require(candidates.length > 0, "No candidates");
        Candidate memory winner = candidates[0];
        bool tie = false;

        for (uint i = 1; i < candidates.length; i++) {
            if (candidates[i].voteCount > winner.voteCount) {
                winner = candidates[i];
                tie = false;
            } else if (candidates[i].voteCount == winner.voteCount && candidates[i].voteCount != 0) {
                tie = true;
            }
        }

        return (winner, tie);
    }
}
