// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

contract Base58Converter {
    // Constants

    string internal constant ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    uint256 internal constant FIXED_SHORT_NAME_LENGTH = 12;

    uint256 internal constant ALPHABET_LENGTH = 58;

    // Internal functions

    function _toBase58(uint256 _data) internal pure returns (string memory) {
        // Initialize enough length, only called in view functions
        // so no need to optimize gas costs
        bytes memory b58 = new bytes(64);
        uint256 i = 0;
        // Ensure the loop runs at least once,
        // even if the input is 0 return "1"
        while (_data > 0 || i == 0) {
            uint256 mod = _data % ALPHABET_LENGTH;
            b58[i++] = bytes(ALPHABET)[mod];
            _data = _data / ALPHABET_LENGTH;
        }
        // Reverse the string since the encoding works backwards
        return string(_reverse(b58, i));
    }

    function _toBase58WithPadding(uint256 _data) internal pure returns (string memory) {
        bytes memory b58 = new bytes(FIXED_SHORT_NAME_LENGTH); // Fixed length for short name
        uint256 i = 0;
        while (_data > 0 || i == 0) {
            uint256 mod = _data % ALPHABET_LENGTH;
            b58[i++] = bytes(ALPHABET)[mod];
            _data /= ALPHABET_LENGTH;
        }
        while (i < FIXED_SHORT_NAME_LENGTH) {
            // Ensure the output is exactly 12 characters
            b58[i++] = bytes(ALPHABET)[0]; // '1' in base58 represents the value 0
        }
        return string(_reverse(b58, i));
    }

    function _reverse(bytes memory _b, uint256 _len) internal pure returns (bytes memory) {
        bytes memory reversed = new bytes(_len);
        for (uint256 i = 0; i < _len; i++) {
            reversed[i] = _b[_len - 1 - i];
        }
        return reversed;
    }
}
