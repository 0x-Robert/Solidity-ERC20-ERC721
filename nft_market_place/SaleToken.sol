// SPDX-License-Identifier: MIT 

//버전 명시 
pragma solidity ^0.8.0; 

//mint 함수 컨트랙트 추가 
import "./MintToken.sol";

//판매 컨트랙트 설정 
//민트 컨트랙트가 있어야 하므로 실행과정은 다음과 같다.
// MintToken을 deploy
// 이후 SaleToken 배포
// mintToken 함수로 NFT를 민트한다.  
// MintToken의 setApprovedForAll 함수에서 operator로 판매 컨트랙트주소를 넣고 bool값에 true로 권한을 허용해줘야함 
// 이후 isApprovedForAll을 실행해준다. owner 계정과 판매컨트랙트 계정을 입력해준다. 
// 이후 SaleToken의 setForSaleToken함수를 호출한다.  가격과 토큰 아이디를 설정한다. 



contract SaleToken {
    //MintToken 어드레스를 담을 주소를 선언 
    MintToken public mintTokenAddress;

    //생성자, 컨트랙트 빌드시 한번 실행됨 
    constructor (address _mintTokenAddress){
        mintTokenAddress = MintToken(_mintTokenAddress);
    }   

    //nftTokenId가 입력이면 출력은 nftTokenPrices로 설정함 
    //왜? 속성 체크때문에 설정했다.
    mapping(uint256 => uint256 ) public nftTokenPrices; 

    //프론트에서 이 배열을 가지고 어떤 토큰이 판매중인지 확인하기 위한 배열 
    uint256[] public onSaleTokenArray; 


    //함수 인자에 대한 설명 
    //무엇을 판매할지 >> nftTokenId(왜? 유일한 값이니까) , 얼마에 팔지 >> _price
    //함수범위는 public  
    function setForSaletoken(uint256 _nftTokenId, uint256 _price ) public {
        // address 변수 nftTokenOwner = constructor에서 생성한 mintTokenAddress의 속성 ownerOf(주인이 누군지 출력해줌)
        address nftTokenOwner = mintTokenAddress.ownerOf(_nftTokenId);

        //주인이 맞는지 확인 require로 조건 체크 1 / 아닐 경우 다음 에러 출력 
        require(nftTokenOwner == msg.sender, "Caller is not  token owner! ");

        //가격이 0초과여야 한다. 아닐 경우 다음 에러 출력  
        require(_price > 0, "Price is zero or lower.");

        //nftTokenPrices의 가격이 0인지 체크, 0이 아니라는 것은 이미 판매중이라는 뜻 따라서 0이 아닐 경우 다음과 같은 에러가 출력된다. 
        require(nftTokenPrices[_nftTokenId] == 0, "This  token is already on sale");

        //isApprovedForAll에는 2개의 인자가 있다. 첫 번째는 컨트랙트의 Owner, 2번째 address[this]에서 this는 이 컨트랙트(sales contract)를 말한다. 
        //이 주인이 이 판매계약서, 즉 스마트 컨트랙트의 판매권한을 넘겼는지 체크하는 구문이라고 보면된다. 왜냐하면 이 스마트컨트랙트가 1개의 파일인데 
        // 이상한 스마트컨트랙트로 코인을 보내면 코인이 묶여서 영원히 찾을 수 없다. 그래서 이 함수가 ERC721에서 만들어졌다. 
        //true일 때만 판매 등록 가능 false는 판매등록 안됨 
        require(mintTokenAddress.isApprovedForAll(nftTokenOwner, address(this)), " token owner did not approve token." );

        //nftTokenId에 해당하는 값을 넣어준다.
        nftTokenPrices[_nftTokenId] = _price;

        //판매 중인 _nftTokenId, 즉 NFT를 배열에 추가해준다. 
        onSaleTokenArray.push(_nftTokenId);

    }

    //구매 컨트랙트 
    function purchaseToken(uint256 _nftTokenId) public payable{
        //판매 가격 변수 설정 
        uint256 price = nftTokenPrices[_nftTokenId];
        
        //mintTokenAddress의 주소의 owner 변수 설정 
        address nftTokenOwner = mintTokenAddress.ownerOf(_nftTokenId);

        //판매금액이 0보다 큰지 체크 
        require(price > 0, " token not sale");

        //msg.value는 이 함수를 실행할 때 보내는 토큰 양
        require(price <= msg.value, "Caller sent lower than prie" );

        //판매할 때 판매자가 owner인것과는 달리 구매자는 owner가 아니여야 구매가 되므로 설정함
        //즉 token owner와 구매자는 같지 않다는 것을 체크하기 위한 구문 
        require(nftTokenOwner != msg.sender, "Caller is  token owner");

        //구매로직 
        //다음 구문 때문에 함수에서 payable이 필요했다. 
        //이 함수를 실행한 msg.sender에게 msg.value(nft의 가격)만큼의 토큰 양이 nftTokenOwner에게 간다. 
        //즉 구매처리되서 판매가격은 주인한테 전송한다는 뜻이다. 
        payable(nftTokenOwner).transfer(msg.value);

        //인자 3개, 첫 번재 보내는 사람, 받는 사람, 애니멀 토큰아이디(NFT 고유아이디)
        //다음은 토큰을 전송하는 함수로 NFT표준에 등록되어있는 함수 
        mintTokenAddress.safeTransferFrom(nftTokenOwner, msg.sender, _nftTokenId);        


        //매핑에서 제거된 것은 구매 완료처리된 속성
        nftTokenPrices[_nftTokenId] = 0;

        //판매중인 목록에서 제거, 배열에서 제거 
        //onSaleTokenArray 판매중인 NFT 배열 크기만큼 순회 
        for(uint256 i=0; i < onSaleTokenArray.length; i++){
            //위 코드에서 매핑에서 제거한 값이 0이되었으므로 구매로직이 끝난 NFT토큰을 조건문으로 찾는다. 
            if(nftTokenPrices[onSaleTokenArray[i]] == 0 ){
                //onSaleTokenArray[i] 즉 구매로직이 끝난 배열값에 마지막 배열값을 대입하면 
                //구매로직이 끝난 배열값은 사라진다. 
                
                //예를 들면 onSaleTokenArray의 길이가 총 5이고 마지막 값이 3일 때 (onSaleTokenArray[4]==3) 
                //onSaleTokenArray[2] == 0 일 때 3번째 인덱스의 값이 매핑에서 제거되고 구매도 끝났다면 
                // onSaleTokenArray[2] == 3(마지막 배열 값을 대입)한 후 배열에서 마지막 값을 pop으로 빼주면
                //구매로직이 끝난 배열은 사라졌고 기존 마지막 배열값도 사라졌으므로 판매중인 NFT 목록에서 완벽하게 제거됐다. 
                onSaleTokenArray[i] = onSaleTokenArray[onSaleTokenArray.length-1];
                onSaleTokenArray.pop(); 
            }

        }
    }
    //view로 함수를 만든 이유는 프론트에서 for문으로 배열값을 찾아서 리턴하면 느리므로
    //스마트 컨트랙트에서 데이터를 리턴해주는 조회용 함수다. 
    //판매중인 토큰의 길이를 리턴해주므로 메인페이지나 전체 판매중인 토큰 개수를 체크할 때 유용하다. 
    function getOnSaleTokenArrayLength() view public returns (uint256){
        return onSaleTokenArray.length;
    }

    //nft 토큰의 가격을 반환해주는 함수 
    function getTokenPrice(uint256 _nftTokenId) view public returns (uint256){
        return nftTokenPrices[_nftTokenId];
    }
}
