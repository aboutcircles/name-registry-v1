// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {INameRegistryV1} from "src/interfaces/INameRegistryV1.sol";
import {IHubV1} from "src/interfaces/IHubV1.sol";

/**
 * @title NameRegistryV1
 * @notice Tracks and manages metadata digests for avatars that are registered in the Hub V1.
 */
contract NameRegistryV1 is INameRegistryV1 {
    // --------------------------------------------------------
    //                         Errors
    // --------------------------------------------------------

    /**
     * @notice Thrown when a provided address is neither a Hub V1 human user nor a recognized organization.
     */
    error InvalidHubV1User();

    /**
     * @notice Thrown when the caller is not the current seeder address.
     */
    error UnauthorizedSeeder();

    /**
     * @notice Thrown when two related arrays have mismatched lengths.
     */
    error MismatchedArrayLengths();

    // --------------------------------------------------------
    //                       Constants
    // --------------------------------------------------------

    /**
     * @notice The address of the Hub contract.
     *         Every valid avatar must already be registered there.
     */
    IHubV1 public immutable hub;

    // --------------------------------------------------------
    //                   State Variables
    // --------------------------------------------------------

    /**
     * @notice The address allowed to seed initial metadata for avatars.
     */
    address public seeder;

    /**
     * @notice Maps an avatar address (registered in Hub V1) to its metadata digest (e.g., IPFS CIDv0).
     */
    mapping(address => bytes32) public avatarToMetaDataDigest;

    // --------------------------------------------------------
    //                        Events
    // --------------------------------------------------------

    /**
     * @notice Emitted when the metadata digest for a given avatar is updated.
     * @param avatar The avatar address whose metadata was updated.
     * @param metadataDigest The new metadata digest (typically an IPFS CIDv0).
     */
    event UpdateMetadataDigest(address indexed avatar, bytes32 metadataDigest);

    // --------------------------------------------------------
    //                       Modifiers
    // --------------------------------------------------------

    /**
     * @dev Ensures that only the current seeder address can invoke the function.
     */
    modifier onlySeeder() {
        if (msg.sender != seeder) revert UnauthorizedSeeder();
        _;
    }

    // --------------------------------------------------------
    //                      Constructor
    // --------------------------------------------------------

    /**
     * @notice Deploy the NameRegistryV1 contract.
     * @param _hub The address of the Hub V1 contract.
     * @param _seeder The address that is initially allowed to seed avatar metadata.
     */
    constructor(address _hub, address _seeder) {
        hub = IHubV1(_hub);
        seeder = _seeder;
    }

    // --------------------------------------------------------
    //                 External Functions
    // --------------------------------------------------------

    /**
     * @notice Renounces the seeder role by setting the seeder address to the zero address.
     *         After this call, no further "seed" operations (like batch updates) will be possible.
     *
     * Requirements:
     * - Caller must be the current seeder.
     */
    function renounceSeederRole() external onlySeeder {
        seeder = address(0);
    }

    /**
     * @notice Updates the metadata digest for a batch of avatars in a single transaction.
     * @param avatars An array of avatar addresses (registered in Hub V1).
     * @param metadataDigests An array of metadata digests corresponding to each avatar.
     *
     * Requirements:
     * - Caller must be the current seeder.
     * - The lengths of both arrays must be the same.
     * - Each avatar in the list must be recognized by Hub V1.
     *
     * Emits a {UpdateMetadataDigest} event for each update.
     */
    function updateMetadataDigestBatch(address[] memory avatars, bytes32[] memory metadataDigests)
        external
        onlySeeder
    {
        if (avatars.length != metadataDigests.length) revert MismatchedArrayLengths();

        for (uint256 i; i < avatars.length;) {
            address avatar = avatars[i];
            _requireHubV1User(avatar);
            _setMetadataDigest(avatar, metadataDigests[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Updates the metadata digest for the caller's own avatar (registered in Hub V1).
     * @param _metadataDigest The new metadata digest (e.g., IPFS CIDv0).
     *
     * Requirements:
     * - The caller must be recognized by Hub V1 (either a human user or an organization).
     *
     * Emits a {UpdateMetadataDigest} event.
     */
    function updateMetadataDigest(bytes32 _metadataDigest) external {
        _requireHubV1User(msg.sender);
        _setMetadataDigest(msg.sender, _metadataDigest);
    }

    // --------------------------------------------------------
    //                      View Functions
    // --------------------------------------------------------

    /**
     * @notice Retrieves the current metadata digest for a specified avatar.
     * @param _avatar The avatar address (registered in Hub V1).
     * @return The 32-byte metadata digest (e.g., IPFS CIDv0).
     */
    function getMetadataDigest(address _avatar) external view returns (bytes32) {
        return avatarToMetaDataDigest[_avatar];
    }

    // --------------------------------------------------------
    //                    Internal Functions
    // --------------------------------------------------------

    /**
     * @dev Checks that the given address is recognized by Hub V1 (i.e., a human user or an organization).
     *      Reverts if not recognized.
     * @param user The address to verify against Hub V1.
     */
    function _requireHubV1User(address user) private view {
        // If it's not registered as a user...
        if (hub.userToToken(user) == address(0)) {
            // ... check if it's recognized as an organization
            if (!hub.organizations(user)) revert InvalidHubV1User();
        }
    }

    /**
     * @dev Internal function to set the metadata digest for an avatar and emit the event.
     * @param _avatar The avatar address.
     * @param _metadataDigest The new metadata digest.
     */
    function _setMetadataDigest(address _avatar, bytes32 _metadataDigest) internal {
        avatarToMetaDataDigest[_avatar] = _metadataDigest;
        emit UpdateMetadataDigest(_avatar, _metadataDigest);
    }
}
