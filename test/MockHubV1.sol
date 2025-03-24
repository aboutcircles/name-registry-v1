// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {IHubV1} from "src/interfaces/IHubV1.sol";

/**
 * @title MockHubV1
 * @dev A simple mock for testing contracts that depend on HubV1's interface.
 *      Allows setting and retrieving user-to-token mappings and organization flags.
 */
contract MockHubV1 is IHubV1 {
    // Internal storage to simulate Hub V1 data
    mapping(address => address) private _userToToken;
    mapping(address => bool) private _organizations;

    /**
     * @notice Returns the token address associated with a user.
     * @param user The address of the user in question.
     * @return The token address associated with that user.
     */
    function userToToken(address user) external view returns (address) {
        return _userToToken[user];
    }

    /**
     * @notice Checks if the specified address is recognized as an organization.
     * @param org The address in question.
     * @return True if org is recognized as an organization, false otherwise.
     */
    function organizations(address org) external view returns (bool) {
        return _organizations[org];
    }

    // --------------------------------------------------------
    //                    Mock Setters
    // --------------------------------------------------------

    /**
     * @dev Sets the token address for a given user (to simulate HubV1 behavior).
     * @param user The user address.
     * @param token The associated token address.
     */
    function setUserToken(address user, address token) external {
        _userToToken[user] = token;
    }

    /**
     * @dev Sets whether an address is recognized as an organization (to simulate HubV1 behavior).
     * @param org The address to be set.
     * @param isOrg True if this address should be recognized as an organization.
     */
    function setOrganization(address org, bool isOrg) external {
        _organizations[org] = isOrg;
    }
}
