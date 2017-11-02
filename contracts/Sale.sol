pragma solidity 0.4.17;


import './DoublyLinkedListOfParticipants.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validee.sol';


contract Sale is Validee, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint32;
    using DoublyLinkedListOfParticipants for DoublyLinkedListOfParticipants.Elements;

    enum SaleState {
        future, // waiting for sale to start
        active, // sale active and collecting customers
        successfull, // sale has been finilized and target quantity has been met
        unsuccessful, // not enought customers by end date for finalizing
        canceled // sale canceled by retailer
    }

    SaleState private state;

    // under that URL retailer should publish its ethereum address on his website to confirm his identity
    bytes32 public accountConfirmaitonUrl;

    bytes32 public title;
    string public description;
    bytes32 public productUrl;
    bytes32[] public imageUrls;

    // all prices in Wei
    uint256 public regularPrice;
    uint256 public discountPrice;
    uint256 public deliveryPrice;
    // quantity of product that fits in single package
    uint32 public maxQuantityInPackage;

    uint32 public targetQuantity;
    uint32 public soldQuantity;

    uint256 public startDate;
    uint256 public endDate;


    DoublyLinkedListOfParticipants.Elements public participants;

    function Sale(
        bytes32 _title,
        string _description,
        bytes32[] _imageUrls,
        bytes32 _productUrl,
        bytes32 _accountConfirmaitonUrl,
        uint256 _regularPrice,
        uint256 _discountPrice,
        uint256 _deliveryPrice,
        uint32 _targetQuantity,
        uint256 _startDate,
        uint256 _endDate
    ) public {
        require(_title.length > 0);
        require(_imageUrls.length > 0);
        require(_productUrl.length > 0);
        require(_accountConfirmaitonUrl.length > 0);

        require(_regularPrice > 0 && _regularPrice > _discountPrice);

        // start date must be no earlier than yesterday
        require(_startDate > now.sub(60*60*24) && _endDate > _startDate);


        title = _title;
        description = _description;
        imageUrls = _imageUrls;
        productUrl = _productUrl;

        accountConfirmaitonUrl = _accountConfirmaitonUrl;

        // all prices in Wei
        regularPrice = _regularPrice;
        discountPrice = _discountPrice;
        deliveryPrice = _deliveryPrice;

        targetQuantity = _targetQuantity;

        startDate = _startDate;
        endDate = _endDate;


        if (block.timestamp >= startDate) {
            state = SaleState.active;
        } else {
            state = SaleState.future;
        }
    }

    modifier inState(SaleState _state) {
        require(getState() == _state);
        _;
    }

    function getState() public returns(SaleState) {
        if (state == SaleState.future && startDate < now && now < endDate) {
            state = SaleState.active;
        } else if (state == SaleState.active && endDate < now) {
            if (soldQuantity >= targetQuantity) {
                state = SaleState.successfull;
            } else {
                state = SaleState.unsuccessful;
            }
        }
        return state;
    }

    function getFullPrice(uint32 qty) internal view returns(uint256) {
        // I'm assuming that div() always returns floor, make sure of that!
        uint256 packagesQty = qty.div(maxQuantityInPackage).add(1);
        return discountPrice.mul(qty).add(packagesQty.mul(deliveryPrice));
    }

    /**
     * Participate in Sale by sending minimum required unrefundable price in advance
     * @param  qty quantity
     * @param  deliveryDetails delivery address
     * @return bool
     */
    function participate(uint32 qty, bytes32 deliveryDetails)
        public
        validate('participate')
        inState(SaleState.active)
        payable
        returns(bool result)
    {
        // make sure that enough token were sent to participate
        require(getFullPrice(qty) <= msg.value);

        // try update first
        result = participants.updateElement(msg.sender, msg.value, qty, deliveryDetails);
        if (!result) {
            result = participants.addElement(msg.sender, msg.value, qty, deliveryDetails);
        }
        if (result) {
            soldQuantity += qty;
        }
    }

    function acceptUnsuccessfulSale() public onlyOwner inState(SaleState.unsuccessful) 
        returns(bool) 
    {
        // give 18h to retailer to accept unsuccessful sale and make it happen anyway
        require(endDate.add(60*60*18) > now);
        state = SaleState.successfull;
        return true;
    }

    function withdrawFundsRetailer() public onlyOwner inState(SaleState.successfull)
        returns(bool)
    {
        uint256 retailerRevenue = getFullPrice(soldQuantity);
        // if unsuccessful, it will thorw
        owner.transfer(retailerRevenue);
        return true;
    }

    function withdrawFundsUser() public returns(bool) {
        // give owner 24h to withdraw funds for security reasons
        require(endDate.add(60*60*24) <= now);
        var (etherPaid, quantityOrdered, deliveryAddress) = participants.getElement(msg.sender);
        SaleState _state = getState();
        if (_state == SaleState.successfull) {
            uint256 price = getFullPrice(quantityOrdered);
            msg.sender.transfer(etherPaid.sub(price));
        } else if (_state == SaleState.unsuccessful) {
            msg.sender.transfer(etherPaid);
        }
        return true;
    }

}
