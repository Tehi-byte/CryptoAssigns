def caesar_cipher(text, shift, decrypt=False):
    """Encrypt or decrypt text using the Caesar Cipher."""

    # Decrypting means shifting in the opposite direction
    if decrypt:
        shift = -shift

    result = ""

    for char in text:
        if char.isalpha():
            # Pick the starting point depending on upper or lower case
            base = ord('A') if char.isupper() else ord('a')

            # Position in alphabet (0-25), shift it, wrap with % 26, convert back
            new_position = (ord(char) - base + shift) % 26
            result += chr(new_position + base)
        else:
            # Keep spaces, numbers, punctuation unchanged
            result += char

    return result


# ==========================================
# USER INTERACTION
# ==========================================

print("=== CAESAR CIPHER ===")

while True:
    choice = input("\nEncrypt or Decrypt? (e/d, or q to quit): ").lower()

    if choice == 'q':
        print("Goodbye!")
        break

    if choice not in ('e', 'd'):
        print("Please enter 'e', 'd', or 'q'.")
        continue

    message = input("Enter your message: ")

    # Make sure the shift is a valid whole number
    try:
        shift = int(input("Enter the shift value (e.g. 3): "))
    except ValueError:
        print("Shift must be a whole number.")
        continue

    if choice == 'e':
        print("Encrypted:", caesar_cipher(message, shift))
    else:
        print("Decrypted:", caesar_cipher(message, shift, decrypt=True))