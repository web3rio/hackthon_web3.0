// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/Chainlink.sol";

contract ScoreToken is ERC20 {
    mapping (address => uint256) public scores;
    Chainlink private chainlink;

    constructor (address _chainlinkNode, address _chainlinkOracle, string memory _chainlinkJobId) ERC20("CustomScore", "SC"){
        _mint(msg.sender, 1000 * 10 ** decimals());
        chainlink = Chainlink(_chainlinkOracle);
        chainlink.setChainlinkToken(address(0x01BE23585060835E02B77ef475b0Cc51aA1e0709)); // Define o endereço do token LINK como padrão
        chainlink.add(
            _chainlinkJobId,
            "https://api.etherscan.io/api?module=account&action=txlist&address=%s&startblock=0&endblock=99999999&sort=asc&apikey=%s&fromBlock=%d&toBlock=%d",
            "application/json"
        );
        chainlink.setChainlinkNode(_chainlinkNode);
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

    function checkTransactionCount(address _address) public view returns (bool) {
        // Define o intervalo de 2 minutos
        uint256 startDate = block.timestamp - 120;
        uint256 endDate = block.timestamp;

        // Faz a solicitação HTTP para a API do Etherscan usando o Chainlink
        Chainlink.Request memory request = chainlink.requestJob(
            address(this),
            bytes4(keccak256("fulfillTransactionCount(bytes32,uint256)")),
            _address,
            startDate,
            endDate
        );

        // Envia a solicitação para o Chainlink
        bytes32 requestId = chainlink.send(request, 1 ether);

        // Retorna o ID da solicitação
        return requestId > 0;
    }

    function fulfillTransactionCount(bytes32 _requestId, uint256 _transactionCount) public {
        // Verifica se o ID da solicitação é válido e se o número de transações é diferente de zero
        require(_requestId > 0 && _transactionCount > 0, "Número de transações é igual a zero");

        // Atribui a pontuação ao endereço
        scores[address(bytes20(_requestId))] += 50;
    }
}

