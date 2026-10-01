import re
import os

files = [
    r'f:\projek\anise_app\frontend\lib\features\home\screens\siswa_home_screen.dart',
    r'f:\projek\anise_app\frontend\lib\features\home\screens\main_navigation_screen.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # PhosphorIconsBold.check -> PhosphorIcons.check(PhosphorIconsStyle.bold)
    content = re.sub(r'PhosphorIconsBold\.([a-zA-Z]+)', r'PhosphorIcons.\1(PhosphorIconsStyle.bold)', content)
    
    # PhosphorIconsFill.house -> PhosphorIcons.house(PhosphorIconsStyle.fill)
    content = re.sub(r'PhosphorIconsFill\.([a-zA-Z]+)', r'PhosphorIcons.\1(PhosphorIconsStyle.fill)', content)

    # PhosphorIcons.bell (without parens) -> PhosphorIcons.bell()
    # Need to be careful not to match PhosphorIcons.bell( already
    content = re.sub(r'PhosphorIcons\.([a-zA-Z]+)(?!\()', r'PhosphorIcons.\1()', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
