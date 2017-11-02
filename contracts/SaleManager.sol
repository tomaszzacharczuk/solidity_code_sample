pragma solidity 0.4.17;


import './Validee.sol';
import './Sale.sol';


contract SaleManager is Validee {
    address[] public sales;

    function newSale(
        bytes32 title,
        string description,
        bytes32[] imageUrls,
        bytes32 productUrl,
        bytes32 accountConfirmaitonUrl,
        uint256 regularPrice,
        uint256 discountPrice,
        uint256 deliveryPrice,
        uint32 targetQuantity,
        uint256 startDate,
        uint256 endDate
        ) public validate("newSale") returns(bool) {
        Sale s = new Sale(title, description, imageUrls, productUrl, accountConfirmaitonUrl, regularPrice, discountPrice, deliveryPrice, targetQuantity, startDate, endDate);
        sales.push(s);
    }

    function getSale(address addr) public view returns(bytes32, bytes32, uint256, uint256, uint256, uint32, uint256, uint256)
    {
        Sale s = Sale(addr);
        return(
            // s.imageUrls(),
            s.productUrl(),
            s.accountConfirmaitonUrl(),
            s.regularPrice(),
            s.discountPrice(),
            s.deliveryPrice(),
            s.targetQuantity(),
            s.startDate(),
            s.endDate()
        );
    }
}