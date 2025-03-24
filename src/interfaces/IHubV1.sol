// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

interface IHubV1 {
    function userToToken(address avatar) external view returns (address token);
    function organizations(address avatar) external view returns (bool);
}
