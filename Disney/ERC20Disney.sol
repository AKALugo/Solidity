//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

// Interface del token ERC20
interface IERC20 {
    //Devuelve la cantidad de tokes en existencia
    function totalSupply() external view returns(uint256);

    //Devuelve la cantidad de tokes para una dirección indicada por parámetro
    function balanceOf(address account) external view returns (uint256);

    //Devuelve el número de token que el spender podrá gastar en nombre del propietario
    function allowance(address owner, address spender) external view returns (uint256);

    //Devuelve un bool resultado de la operacion indicada
    function transfer(address recipient, uint256 numTokens) external returns(bool);

    //Devuelve un bool resultado de la operacion indicada
    function transfer_Disney(address cliente, address recipient, uint256 numTokens) external returns(bool);

    //Devuelve un bool resultado de la operación de gasto
    function approve(address spender, uint amount) external returns(bool);

    //Devuelve un valor bool resultado de la operación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);


    //Evento que se emite en la transferencia del token.
    event Transfer(address indexed from, address indexed to, uint256 amount);

    //Evento que se debe transmitir cuando se establece una asignación con el método allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20 {

    using SafeMath for uint256;

    string public constant name = "ERC20AKALugo";
    string public constant symbol = "AKA";
    uint8 public constant decimals = 18;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public override view returns(uint256) {
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return allowed[owner][spender];
    }

    function transfer(address recipient, uint256 numTokens) public override returns(bool) {
        require (numTokens <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(numTokens); 
        balances[recipient] = balances[recipient].add(numTokens);

        emit Transfer(msg.sender, recipient, numTokens);

        return true;
    }

    function transfer_Disney(address cliente, address recipient, uint256 numTokens) public override returns(bool) {
        require (numTokens <= balances[cliente]);

        balances[cliente] = balances[cliente].sub(numTokens); 
        balances[recipient] = balances[recipient].add(numTokens);

        emit Transfer(cliente, recipient, numTokens);

        return true;
    }

    function approve(address spender, uint numTokens) public override returns(bool) {
        
        allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);

        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool) {
        require (balances[owner] >= numTokens);
        require (allowed[owner][msg.sender] >= numTokens);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);

        emit Transfer(owner, buyer, numTokens); 
        return true;
    }
}