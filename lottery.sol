//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    //Only a payable address can be sent ETH. 
    address payable[] public players;
    address public manager;

    //Constructor is run only once at deployment
    constructor(){
        //set state for manager to contract deployer
        manager = msg.sender;
    }

    //Allow contract to receive ETH
    receive() external payable{
        //Require that each player sends the same amount of ETH per entry. Values are always in wei unles given a suffix.
        require(msg.value == 0.1 ether);
        //Add address that sent ETH to players array. Since players array is payable addresses vs. plain must declare msg.sender payable.
        players.push(payable(msg.sender));
    }

    //Function to display contract ETH balance.
    function getBalance() public view returns(uint){
        //Require that only the manager can see the balance
        require(msg.sender == manager);
        return address(this).balance;
    }

    //Function to create psuedo random number. Do not use in production. Must use oracle like Chainlink CRF for verifiable randomness.
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    //Function to pick winner and send contract's ether balance
    function pickWinner() public{
        //Require that only the manager can call this function.
        require(msg.sender == manager);
        //Require atleast 3 players
        require(players.length >= 3);
        
        //Call random function.
        uint r = random();
        //Make a payable address winner
        address payable winner;

        //Divide random number by length of players array. Get remainder.
        uint index = r % players.length;

        //Declare winner.
        winner = players[index];
        //Transfer contract ether balance to winner.
        winner.transfer(getBalance());

        //Reset the lottery.
        players = new address payable[](0);
    }

}
