ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
KEY      = "QWERTYUIOPASDFGHJKLZXCVBNM"

# Lookup tables, built once.
# zip() pairs up the two strings letter by letter: ('A','Q'), ('B','W'), ...
ENCRYPT_MAP = dict(zip(ALPHABET, KEY))   # {'A': 'Q', 'B': 'W', ...}
DECRYPT_MAP = dict(zip(KEY, ALPHABET))   # {'Q': 'A', 'W': 'B', ...}


def substitute(text, mapping):
    """Replace each letter using the given lookup table."""

    result = ""

    for char in text:
        upper = char.upper()

        if upper in mapping:
            new_char = mapping[upper]
            # Keep the original letter case
            result += new_char if char.isupper() else new_char.lower()
        else:
            # Keep spaces, numbers, punctuation unchanged
            result += char

    return result


# ==========================================
# USER INTERACTION
# ==========================================

print("=== SUBSTITUTION CIPHER ===")

while True:
    choice = input("\nEncrypt or Decrypt? (e/d, or q to quit): ").lower()

    if choice == 'q':
        print("Goodbye!")
        break

    if choice not in ('e', 'd'):
        print("Please enter 'e', 'd', or 'q'.")
        continue

    message = input("Enter your message: ")

    if choice == 'e':
        print("Encrypted:", substitute(message, ENCRYPT_MAP))
    else:
        print("Decrypted:", substitute(message, DECRYPT_MAP))






'''=== SAMPLE RUNS ===

Encrypt or Decrypt? (e/d, or q to quit): e
Enter your message: Tehillah
Encrypted: Ztiossqi

Encrypt or Decrypt? (e/d, or q to quit): d
Enter your message: Ztiossqi
Decrypted: Tehillah

Encrypt or Decrypt? (e/d, or q to quit): e
Enter your message: Hello, World!
Encrypted: Itssg, Vgksr!                        '''