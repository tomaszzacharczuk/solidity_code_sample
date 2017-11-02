pragma solidity 0.4.17;


library DoublyLinkedListOfParticipants {

    struct Elements {
        address head;
        address tail;
        uint256 size;
        mapping(address => Element) elements;
    }

    struct Element {
        address previous;
        address next;
        Participant data;
    }

    struct Participant {
        address accAddr;
        // in Wei
        uint256 etherPaid;
        uint32 quantityOrdered;
        bytes32 deliveryAddress;
    }

    function getElement(Elements storage self, address key) public view returns (
            uint256 etherPaid,
            uint32 quantityOrdered,
            bytes32 deliveryAddress
        ) {
        Participant storage p = self.elements[key].data;
        etherPaid = p.etherPaid;
        quantityOrdered = p.quantityOrdered;
        deliveryAddress = p.deliveryAddress;
    }

    function addElement(
            Elements storage self, 
            address key, 
            uint256 etherPaid,
            uint32 quantityOrdered,
            bytes32 deliveryAddress
        ) public returns (bool success) {
        Element storage elem = self.elements[key];
        if (elem.data.etherPaid != 0 
            || elem.data.quantityOrdered != 0 
            || elem.data.deliveryAddress.length != 0
            ) {
            return false;
        }

        if (self.size == 0) {
            self.head = key;
            self.tail = key;
        } else {
            self.elements[self.head].next = key;
            elem.previous = self.head;
            self.head = key;
        }
        Participant memory value = Participant({
            accAddr: key,
            etherPaid: etherPaid, 
            quantityOrdered: quantityOrdered, 
            deliveryAddress: deliveryAddress});
        elem.data = value;
        self.size++;
        return true;
    }

    function updateElement(
            Elements storage self, 
            address key, 
            uint256 etherPaid,
            uint32 quantityOrdered,
            bytes32 deliveryAddress
        ) public returns (bool success) {
        Element storage elem = self.elements[key];
        if (elem.data.etherPaid == 0 
            && elem.data.quantityOrdered == 0 
            && elem.data.deliveryAddress.length == 0
            ) {
            return false;
        }

        elem.data.etherPaid += etherPaid;
        elem.data.quantityOrdered += quantityOrdered;
        if(deliveryAddress.length > 0) {
            elem.data.deliveryAddress = deliveryAddress;
        }
        return true;
    }

    function removeElement(Elements storage self, address key) public returns (bool success) {
        Element storage elem = self.elements[key];
        if (self.size == 0 
            || (elem.data.etherPaid == 0 
                && elem.data.quantityOrdered == 0 
                && elem.data.deliveryAddress.length == 0
                )
            ) {
            return false;
        } else if (self.size == 1) {
            self.head = 0x0;
            self.tail = 0x0;
        } else if (key == self.head) {
            self.head = elem.previous;
        } else if (key == self.tail) {
            self.tail = elem.next;
        } else {
            self.elements[elem.previous].next = elem.next;
            self.elements[elem.next].previous = elem.previous;
        }
        delete self.elements[key];
        self.size--;
    }
}