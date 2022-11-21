// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CrowdFundingPlatform {

    uint constant DURATION = 30 days;

    struct Startup {
        address payable founder;
        string title;
        string startupDescription;
        uint goal;
        uint currentgoal;
        uint startAt;
        uint endsAt;
        uint countPledges;
    }

    struct Pledge {
        string title;
        string pledgeDescription;
        uint cost;
    }

    Startup private newStartup = Startup({
        founder: payable(owner),
        title: 'null',
        startupDescription: 'null',
        currentgoal: 0,
        goal: 0,
        startAt: 0,
        endsAt: 100000,
        countPledges: 0
    });

    address public owner;
    uint private currentCountPledges = 0;
    mapping (uint => Pledge) public pledges;
    mapping (address => uint) private payments;

    event StartupCreated(string StartupTitle, uint goal, uint duration);

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function updateStartup(string memory _title, string memory _startupDescription, uint _goal, uint _duration, uint _countPledges) external onlyOwner{
        uint duration = _duration == 0 ? DURATION : _duration;
        newStartup = Startup({
            founder: payable(owner),
            title: _title,
            startupDescription: _startupDescription,
            currentgoal: 0,
            goal: _goal,
            startAt: block.timestamp,
            endsAt: block.timestamp + duration,
            countPledges: _countPledges
        });
        emit StartupCreated(_title, _goal, _duration);
    }

    function addPledge(string memory _title, string memory _pledgeDescription, uint _cost) external onlyOwner{
        currentCountPledges += 1;
        require(currentCountPledges <= newStartup.countPledges, "no more Pledges");
        Pledge memory newPledge = Pledge({
            title: _title,
            pledgeDescription: _pledgeDescription,
            cost: _cost
        });
        pledges[currentCountPledges] = newPledge;
    }

    function getPriceForPledge(uint _index) public view returns(uint){
        require(block.timestamp < newStartup.endsAt, "compaign ended!");
        return pledges[_index].cost;
    }

    function buyPledge(uint _index) external payable{
        require(block.timestamp < newStartup.endsAt, "compaign ended!");
        uint cPrice = getPriceForPledge(_index);
        require(msg.value >= cPrice, "not enough funds!");
        newStartup.currentgoal += msg.value;
        payments[msg.sender] += msg.value;
    }

    function supportProject() external payable{
        require(block.timestamp < newStartup.endsAt, "compaign ended!");
        payments[msg.sender] += msg.value;
    }

    function refund() external payable{
        require(block.timestamp > newStartup.endsAt, "compaign not ended!");
        require(newStartup.currentgoal < newStartup.goal);
        payable(msg.sender).transfer(payments[msg.sender]);
    }
}
