// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {MockHubV1} from "test/MockHubV1.sol";
import {NameRegistryV1} from "src/NameRegistryV1.sol";

contract NameRegistryV1Test is Test {
    MockHubV1 internal hub;
    NameRegistryV1 internal nameRegistry;

    address internal seeder = address(0x34256647657234affafa);

    // Sample addresses for testing
    address internal recognizedUser = address(0x1111);
    address internal recognizedOrg = address(0x2222);
    address internal unrecognizedUser = address(0x3333);

    // A sample bytes32 metadata digest for demonstration
    bytes32 internal constant METADATA_DIGEST = keccak256("example-metadata");

    // Runs once before each test function
    function setUp() public {
        hub = new MockHubV1();
        nameRegistry = new NameRegistryV1(address(hub), seeder);

        // Label addresses in logs (for debugging)
        vm.label(seeder, "Seeder");
        vm.label(recognizedUser, "RecognizedUser");
        vm.label(recognizedOrg, "RecognizedOrg");
        vm.label(unrecognizedUser, "UnrecognizedUser");

        // Configure the mock Hub:
        //   - recognizedUser is set to have a non-zero token address
        //   - recognizedOrg is flagged as an organization
        hub.setUserToken(recognizedUser, address(0xAAAA));
        hub.setOrganization(recognizedOrg, true);
    }

    // --------------------------------------------------------
    //          Tests: Single Avatar Update (updateMetadataDigest)
    // --------------------------------------------------------

    /// @notice Test that a recognized user (by userToToken) can update their metadata.
    function testCanUpdateMetadataDigestAsRecognizedUser() public {
        vm.prank(recognizedUser); // Make calls as recognizedUser

        nameRegistry.updateMetadataDigest(METADATA_DIGEST);

        // Check that the metadata has been set
        bytes32 storedDigest = nameRegistry.getMetadataDigest(recognizedUser);
        assertEq(storedDigest, METADATA_DIGEST, "Metadata digest not updated correctly");
    }

    /// @notice Test that a recognized organization can update its metadata.
    function testCanUpdateMetadataDigestAsRecognizedOrg() public {
        vm.prank(recognizedOrg); // Make calls as recognizedOrg

        nameRegistry.updateMetadataDigest(METADATA_DIGEST);

        // Check that the metadata has been set
        bytes32 storedDigest = nameRegistry.getMetadataDigest(recognizedOrg);
        assertEq(storedDigest, METADATA_DIGEST, "Metadata digest not updated for organization");
    }

    /// @notice Test that an unrecognized user reverts when trying to update metadata.
    function testRevertWhenUnrecognizedUserUpdatesMetadata() public {
        vm.prank(unrecognizedUser);

        vm.expectRevert(NameRegistryV1.InvalidHubV1User.selector);
        nameRegistry.updateMetadataDigest(METADATA_DIGEST);
    }

    // --------------------------------------------------------
    //        Tests: Batch Updates (updateMetadataDigestBatch)
    // --------------------------------------------------------

    /// @notice Test a successful batch update by the seeder.
    function testBatchUpdateBySeeder() public {
        address[] memory avatars = new address[](2);
        avatars[0] = recognizedUser;
        avatars[1] = recognizedOrg;

        bytes32[] memory metadata = new bytes32[](2);
        metadata[0] = bytes32("USER_DIGEST");
        metadata[1] = bytes32("ORG_DIGEST");

        vm.prank(seeder);
        nameRegistry.updateMetadataDigestBatch(avatars, metadata);

        // Verify updates
        assertEq(nameRegistry.getMetadataDigest(recognizedUser), metadata[0], "User digest mismatch");
        assertEq(nameRegistry.getMetadataDigest(recognizedOrg), metadata[1], "Org digest mismatch");
    }

    /// @notice Test reverting when non-seeder attempts a batch update.
    function testRevertWhenNonSeederBatchUpdate() public {
        address[] memory avatars = new address[](1);
        avatars[0] = recognizedUser;

        bytes32[] memory metadata = new bytes32[](1);
        metadata[0] = METADATA_DIGEST;

        vm.prank(recognizedUser);
        vm.expectRevert(NameRegistryV1.UnauthorizedSeeder.selector);
        nameRegistry.updateMetadataDigestBatch(avatars, metadata);
    }

    /// @notice Test reverting if batch array lengths are mismatched.
    function testRevertWhenBatchArrayLengthsMismatch() public {
        address[] memory avatars = new address[](2);
        avatars[0] = recognizedUser;
        avatars[1] = recognizedOrg;

        bytes32[] memory metadata = new bytes32[](1);
        metadata[0] = METADATA_DIGEST;

        vm.prank(seeder);
        vm.expectRevert(NameRegistryV1.MismatchedArrayLengths.selector);
        nameRegistry.updateMetadataDigestBatch(avatars, metadata);
    }

    /// @notice Test reverting if one of the avatars in the batch is unrecognized.
    function testRevertWhenBatchContainsUnrecognizedUser() public {
        address[] memory avatars = new address[](2);
        avatars[0] = recognizedUser;
        avatars[1] = unrecognizedUser;

        bytes32[] memory metadata = new bytes32[](2);
        metadata[0] = bytes32("USER_DIGEST");
        metadata[1] = bytes32("BAD_DIGEST");

        vm.prank(seeder);
        vm.expectRevert(NameRegistryV1.InvalidHubV1User.selector);
        nameRegistry.updateMetadataDigestBatch(avatars, metadata);
    }

    // --------------------------------------------------------
    //               Tests: Seeder Role
    // --------------------------------------------------------

    /// @notice Test that the seeder can renounce the role, after which batch updates are impossible.
    function testSeederCanRenounceSeederRole() public {
        // Renounce the role
        vm.prank(seeder);
        nameRegistry.renounceSeederRole();

        // Attempt a batch update again
        address[] memory avatars = new address[](1);
        avatars[0] = recognizedUser;

        bytes32[] memory metadata = new bytes32[](1);
        metadata[0] = METADATA_DIGEST;

        vm.prank(seeder);
        vm.expectRevert(NameRegistryV1.UnauthorizedSeeder.selector);
        nameRegistry.updateMetadataDigestBatch(avatars, metadata);
    }
}
