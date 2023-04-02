// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ScoreToken is ERC20 {
    mapping (address => uint256) public scores;
    
    constructor () ERC20("CustomScore", "SC"){
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        if (msg.sender != address(0) && msg.sender != recipient) {
            scores[msg.sender] += 10;
        }
        return true;
    }

    function getScore() public view returns (uint256) {
        return scores[msg.sender];
    }
}
