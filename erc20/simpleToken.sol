// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC20Interface {
    // 솔리디티에서 interface 는 사용할 함수를 선언합니다.
    // 실제 함수의 기능은 Contract 에서 정의합니다.
    // ERC20Interface 에는 ERC-20 에서 사용하는 함수들의 형태가 선언되어 있습니다.
    // fuction 은 이더리움에서 제공하는 함수이며, event 는 이더리움에서 제공하는 로그입니다.
    // function 과 event 를 선언할 때는 입력값과 반환값을 선택할 수 있으나, function 의 자료형, 이름, 순서 는 고정되어 있으니 주의해야 합니다.
    // ERC20Interface 의 Transfer 이벤트는 토큰이 이동할 때마다 로그를 남기고, Approval 이벤트는 approve 함수가 실행될 때 로그를 남깁니다.

    // 함수 정의
    // 1
    function totalSupply() external view returns (uint256);

    // 해석: 함수 totalSupply()는 계약서 외부에서 사용하며 상태를 변경하지 않습니다(조회). uint256 타입을 반환합니다.

    // 2
    function balanceOf(address account) external view returns (uint256);

    // 해석: 함수 balanceOf()주소형 타입을 account 파라미터로 받습니다. 계약서 외부에서 사용하며 상태를 변경하지 않습니다(조회). uint256 타입을 반환합니다.

    // 3
    function transfer(address recipent, uint256 amount) external returns (bool);

    // 해석: 함수 transfer()는 주소형 타입을 recipient, uint256 타입을 amount 파라미터로 받습니다.
    //      계약서 외부에서 사용하며 bool 타입을 반환합니다.

    // 4
    function approve(address spender, uint256 amount) external returns (bool);

    // 해석: 함수 approve()는 주소형 타입을 spender, uint256 타입을 amount 파라미터로 받습니다.
    //      계약서 외부에서 사용하며 bool 타입을 반환합니다.

    // 5
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // 해석: 함수 allowance는 주소형 타입을 owner와 spener 파라미터로 받습니다.
    //      계약서 외부에서 사용하며, 상태를 변경하지 않습니다(조회). uint256 타입을 반환합니다.

    // 6
    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 해석: 함수 transferFrom()은 주소형 타입으로 spender와 recipient를, uint256 타입으로 amount를 파라미터로 받습니다.
    //      계약서 외부에서 사용하며, bool 타입을 반환합니다.

    // 이벤트 정의
    // 7
    event Transfer(address indexed from, address indexed to, uint256 amount);
    // 8
    event Transger(
        address indexed spender,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    // 9
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 oldAmount,
        uint256 amount
    );

    // ======
    // 솔리디티의 함수는 다음과 같이 구성됩니다.
    // function (<parameter types>) {internal | external | public | private} [pure constant view payable] [(modifiers)] [returns (<return types>)]

    // ======
    // parameter types
    // 함수에서 받을 매개변수를 타입과 함께 선언합니다. 매개변수의 이름을 정할 때는 앞에 언더바를 쓰는 관례가 있습니다.
    // e.g., uint256 _paramName

    // ======
    // Visibility Keyword   internal external public private
    // Java나 C++에서 Public Private Protected등과 같은 접근제어자 (access control) 역할을 합니다.

    // ======
    // 솔리디티 언어에서 스마트 컨트랙트 내의 상태 변수(State variable)와 함수에 적용할 수 있는 Visibility는 4가지가 있습니다.

    // internal
    // 스마트 컨트랙트의 계약서(Contract)에서 해당 내용을 비공개한다는 뜻이며, 계약서의 내부에서만 사용한다는 것을 의미합니다.
    // 상태변수(state variable)는 internal이 기본값입니다.
    // 함수나 상태 변수에 Visibility를 쓰지 않고 비워둔다면 internal로 설정됩니다.
    // 계약서 자신과 상속받은 계약서에 한하여 사용할 수 있게 합니다.

    // external
    // 스마트 컨트랙트의 계약서에서 해당 내용을 공개한다는 뜻이며, 계약서의 외부에서 사용한다는 것을 의미합니다.
    // 상태변수는 external일 수 없습니다.
    // 계약서 내부에서 사용하게 될 경우, this 를 사용해서 접근합니다.

    // public
    // 공개의 뜻입니다.
    // 공개 기능은 계약 인터페이스의 일부이며, 내부적으로 또는 메시지를 통해 호출할 수 있습니다.
    // 공개 상태 변수의 경우 자동 getter 함수가 생성됩니다.

    // private
    // 비공개의 뜻입니다.
    // 비공개 함수는 계약서 내부에서도 계약서 자신만 사용하는 함수입니다.
    // 상태변수와 함수 모두 파생된 계약이 아닌, 정의된 계약에서만 볼 수 있습니다.

    // ======
    // 함수의 동작과 관련된 키워드
    // pure             | storage에서 변수를 읽어오거나 쓰지 않는 함수(데이터를 읽는 것이 아닌, 인자로 전달받은 값을 활용하여 반환 - 가스가 소모되지 않음)
    // view             | 상태를 변경하지 않는 함수(데이터를 읽고 반환 - 가스가 소모되지 않음)
    // payable          | 입금을 받을 수 있는 함수
    // constant         | 0.4.17 버전 이전에는 view와 pure대신 사용되었으나,상위 버전에서부터는 view와 pure로 사용.
}
