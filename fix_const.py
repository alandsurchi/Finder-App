import re

def main():
    filepath = r"c:\Users\barza\OneDrive\Desktop\Finder-App-master\lib\screens\manage_post_screen.dart"
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    # _1 replacing
    text = text.replace("color: _$1", "color: _textDark")

    # const Icon
    text = re.sub(r'const Icon\((.*?color:\s*_[a-zA-Z]+)', r'Icon(\1', text, flags=re.DOTALL)
    
    # const Expanded Text
    text = re.sub(r'const Expanded\(\s*child:\s*Text\(', r'Expanded(child: Text(', text)
    
    # const Text ... style: TextStyle(color: _)
    # We will loop through the known strings
    words = ["Manage Post", "Discard", "STATUS", "General Details", "Incentive", "AMOUNT \(\$\)", "Reward Offered", "Encourages safe returns", "Negotiable", "Danger Zone", "Delete Post\?", "This will permanently", "Cancel", "Delete"]
    for w in words:
        # Match `const Text(` for these words with flexible whitespace
        text = re.sub(rf'const Text\(\s*\'{w}\'', f'Text(\'{w}\'', text)
        text = re.sub(rf'const Text\(\s*\"{w}\"', f'Text(\"{w}\"', text)
    
    # Fix the children: const [ ... ] containing variables
    # Line 503: children: const [ Text('Reward Offered' ...
    text = re.sub(r'children:\s*const\s*\[\s*Text\(\s*\'Reward Offered\'', r'children: [\n                                Text(\'Reward Offered\'', text)
    
    # const Padding containing text
    text = re.sub(r'const Padding\(\s*padding:(.*?),\s*child:\s*Text\(', r'Padding(padding:\1, child: Text(', text, flags=re.DOTALL)

    # const BorderSide
    text = re.sub(r'const BorderSide\((.*?color:\s*_[a-zA-Z]+)', r'BorderSide(\1', text, flags=re.DOTALL)

    # The line "This will permanently remove the post" might not exactly match regex, replace explicit substring:
    text = text.replace("const Text(\n          'This will permanently", "Text(\n          'This will permanently")
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(text)

if __name__ == "__main__":
    main()
