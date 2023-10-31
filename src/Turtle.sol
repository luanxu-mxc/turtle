// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin libraries, which provide secure contract templates
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Turtle is Ownable, ERC20Permit {

    uint public fee = 1000; // 50 = 0.5%, 100 = 1%, 10000 = 100%

    uint public supplyTarget = 21_000_000 * (10 ** decimals());

    mapping (address => bool) private _inWhitelist;

    address[] private _whitelist;

    constructor() ERC20Permit("turtle") ERC20("crypto turtle", "TURTLE") Ownable(msg.sender) {
        _inWhitelist[msg.sender] = true;
        _whitelist.push(msg.sender);
        _mint(msg.sender, 10_000_000_000 * (10 ** decimals()));
    }

    function burn(uint amount) external onlyOwner {
        _burn(msg.sender, amount);
    }

    function addWhiteList(address account) external onlyOwner {
        _inWhitelist[account] = true;
        _whitelist.push(account);
    }

    function removeWhiteList(address account) external onlyOwner {
        _inWhitelist[account] = false;
        for (uint i = 0; i < _whitelist.length; i++) {
            if (_whitelist[i] == account) {
                _whitelist[i] = _whitelist[_whitelist.length - 1];
                _whitelist.pop();
                break;
            }
        }
    }

    function _applyFee(uint amount) internal view returns (uint) {
        if(fee == 0) {
            return 0;
        }
        if(_inWhitelist[_msgSender()]) {
            return 0;
        }
        uint _fee = amount * fee / 10000;
        if(totalSupply() - _fee < supplyTarget) {
            _fee = totalSupply() - supplyTarget;
        }
        return _fee;
    }

    function setFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function transfer(address to, uint amount) public override returns (bool) {
        if (_inWhitelist[msg.sender] || _inWhitelist[to] || totalSupply() <= supplyTarget) {
            _transfer(msg.sender, to, amount);
        } else {
            uint _fee = _applyFee(amount);
            _burn(msg.sender, _fee);
            _transfer(msg.sender, to, amount - _fee);
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        if (_inWhitelist[from] || _inWhitelist[to] || totalSupply() <= supplyTarget) {
            _transfer(from, to, amount);
        } else {
            uint _fee = _applyFee(amount);
            _burn(from, _fee);
            _transfer(from, to, amount - _fee);
        }
        return true;
    }
}