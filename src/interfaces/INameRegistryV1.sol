// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

interface INameRegistryV1 {
    function updateMetadataDigestBatch(address[] memory avatars, bytes32[] memory metadataDigests) external;
    function updateMetadataDigest(bytes32 _metadataDigest) external;
    function getMetadataDigest(address avatar) external view returns (bytes32);
}
