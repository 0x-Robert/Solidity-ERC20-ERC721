// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC20Interface {
    // ERC20 토큰 총 발행량 확인 
    function totalSupply() external view returns (uint256); 
    //owner가 가진 토큰 보유량 확인 
    function balanceOf(address account) external view returns (uint256);    
     //토큰을 전송 
    function transfer(address recipient, uint256 amount) external returns (bool); 
    //spender에 밸류만큼 토큰을 인출할 권리를 부여
    // 이 함수를 이용할 떄 Approveal 이벤트 함수를 호출해야 함 
    function approve(address spender, uint256 amount) external returns (bool);      
    //owner가 spender에 양도설정한 토큰의 양을 확인 
    function allowance(address owner, address spender) external view returns (uint256);
    //spender가 거래할 수 있도록 양도받은 토큰을 전송 
    function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);

    //직접 토큰을 다른 사람에게 전송할 때는 transfer 함수 사용 
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed spender, address indexed from, address indexed to, uint256 amount);


    event Approval(address indexed owner, address indexed spender, uint256 oldAmount, uint256 amount);
}


library SafeMath {
  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
	    uint256 c = a / b;
		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract SimpleToken is ERC20Interface {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    //이중 매핑 _allowances 
    // _allowances 변수는 이중 객체임 
    // { "Owner의 address" :  "{ "spender의 address"  :  "맡겨둔 token의 개수" }" }
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 public _totalSupply; // erc20 토큰 총 발행량 확인 
    string public _name;        
    string public _symbol;
    uint8 public _decimals;
    uint private E18 = 1000000000000000000;

    constructor(string memory getName, string memory getSymbol) {
        _name = getName;
        _symbol = getSymbol;
        _decimals = 18;
        _totalSupply = 100000000 * E18;
        _balances[msg.sender] = _totalSupply; // 추가
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    //토큰의 총 발행량을 반환
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    //balanceOf는 매핑된 값인 _balances에서 입력한 address인 account가 가지고 있는 토큰의 수를 반환합니다.
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }


    //allowance는 입력한 두 개의 owner, spender 주소값에 대한 _allowances값 
    //owner가 spender에게 등록한 토큰의 수량을 반환함 
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        emit Transfer(msg.sender, sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance, currentAllowance.sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
         _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }
}


    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount); //내부함수인 _transfer 호출 
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

  

    function approve(address spender, uint amount) external virtual override returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(_balances[msg.sender] >= amount,"ERC20: The amount to be transferred exceeds the amount of tokens held by the owner.");
        _approve(msg.sender, spender, currentAllowance, amount); //내부함수 _approve 호출
        return true;
    }

    // function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual {
    //     require(owner != address(0), "ERC20: approve from the zero address");
    //     require(spender != address(0), "ERC20: approve to the zero address");
    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, currentAmount, amount);
    // }
    function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, currentAmount, amount);
    }
}
