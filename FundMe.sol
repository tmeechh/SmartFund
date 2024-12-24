//// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

 // Constant, immutable keywords

// 887,174 - Non Constant
// 863,759 - Constant 

error NotOwner();

contract FundMe {
  using PriceConverter for uint256;


    uint256 public  constant MINIMUM_USD = 5e18;
// 347 gas - Constant  == 347 * 4852000000 = 1,683,644,000,000 = 0.01$
// 2,446 gas  - Non constant  == 2,446 * 4852000000 = 11,867,992,000,000 = 0.04$ 

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    // 439 gas - immutable
    // 2,574 gas  - Non immutable
    
    constructor() {
      i_owner = msg.sender; 
    }

    function fund() public payable {  
        //Allow users to send $
        // Have a minimum $ sent  $5
        require(msg.value.getConversionRate() >= MINIMUM_USD,"didn't send enough ETH" ); // 1e18 = 1 ETH
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    
    // function getVersion() public view returns (uint256) {
    //     return
    //         AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF)
    //             .version();
    // }

    function withdraw() public onlyOwner {
     // for loop
     // for (/* starting index, ending index, step amoun;t */)
     for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
        address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
       }
       //reset the array 
       funders = new address[](0);

    //    //withdraw the funds 

    //   // transfer: if there is an error the transaction fail
    //   payable(msg.sender).transfer(address(this).balance);
    //    // send : if there is an error , it sned back a bool - message
    //   bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //   require(sendSuccess, "Send failed");
       //call
     (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
     require(callSuccess, "Call failed");
    }


  modifier onlyOwner() {
    //  require(msg.sender == i_owner, "Must be owner!");
    if(msg.sender != i_owner) {revert NotOwner(); }
     _;
  }

  // What happens if somone sends this contract ETH without calling the fund funcion??

  receive() external payable {
    fund();
  }
  fallback() external payable {
    fund();
  }
}
