// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Authorization.sol";
import "../src/Token.sol";


contract AuthorizationTest is Test {
    Authorization public authorizationContract;

    address public user1;

    function setUp() public {
        authorizationContract = new Authorization();
        user1 = address(1);
    }

    function testRegisterUser() public {
        // Simulate user1 registering with a username and profile image
        vm.startPrank(user1);
        authorizationContract.registerUser("TestUser", "http://example.com/image.png");
        vm.stopPrank();

        // Verify the user is registered
        assertTrue(authorizationContract.registeredUsers(user1), "User should be registered");

        // Verify user details
        (string memory username, address walletAddress, string memory profileImage) = authorizationContract.getUserDetails(user1);
        
        assertEq(username, "TestUser", "Username should match");
        assertEq(walletAddress, user1, "Wallet address should match");
        assertEq(profileImage, "http://example.com/image.png", "Profile image should match");
    }

    function testGetUserAddress() public {
        // Simulate user1 registering with a username
        vm.startPrank(user1);
        authorizationContract.registerUser("TestUser", "http://example.com/image.png");
        vm.stopPrank();

        // Retrieve the user address by username
        address retrievedAddress = authorizationContract.getUserAddress("TestUser");

        // Verify the retrieved address matches user1's address
        assertEq(retrievedAddress, user1, "Retrieved address should match user1's address");
    }
        
    function testRegisterUserAlreadyRegistered() public {
        authorizationContract.registerUser("TestUser", "(link unavailable)");
        
        // Try to register the same user again and expect it to revert
        vm.expectRevert("User is already registered");
        authorizationContract.registerUser("TestUser", "(link unavailable)");
    }

    function testRegisterUserWithTakenUsername() public {
        // Register user1 with a username
        vm.startPrank(user1);
        authorizationContract.registerUser("TestUser", "http://example.com/image1.png");
        vm.stopPrank();

        // Attempt to register user2 with the same username
        // address user2 = address(2);
        (bool success, ) = address(authorizationContract).call(
            abi.encodeWithSignature("registerUser(string,string)", "TestUser", "http://example.com/image2.png")
        );

        // Verify that the registration fails
        assertFalse(success, "User should not be able to register with a taken username");
    }
}

contract TokenTest is Test {
    Token public token;
    address public user1;
    address public user2;

    function setUp() public {
        // Deploy the token contract
        token = new Token("TestToken", "TTK");
        user1 = address(1);
        user2 = address(2);
    }

    // function testInitialSupply() public {
    //     // Verify the total supply of the token
    //     uint256 expectedSupply = 1000000000 * 10 ** 18;
    //     assertEq(token.totalSupply(), expectedSupply, "Total supply should match the expected supply");
        
    //     // Verify the balance of the contract deployer (msg.sender)
    //     assertEq(token.balanceOf(address(this)), expectedSupply, "Initial balance of deployer should match total supply");
    // }

    function testMinting() public {
        // Mint tokens to user1
        uint256 mintAmount = 100 * 10 ** 18; // 100 tokens
        token.mint(user1, mintAmount);

        // Verify that user1's balance increased by the mint amount
        assertEq(token.balanceOf(user1), mintAmount, "User1's balance should match the minted amount");

        // Verify the total supply after minting
        assertEq(token.totalSupply(), 1000000000 * 10 ** 18, "Total supply should not change after minting");
    }
}
