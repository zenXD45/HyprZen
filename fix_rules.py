import re

with open('.config/hypr/modules/windowrules.conf', 'r') as f:
    content = f.read()

# Replace "windowrule = <action> 1, " with "windowrulev2 = <action>, "
content = re.sub(r'windowrule = (.*?) 1,\s+', r'windowrulev2 = \1, ', content)

# Replace "windowrule = <action>," with "windowrulev2 = <action>,"
content = re.sub(r'windowrule = (.*?),\s+', r'windowrulev2 = \1, ', content)

# Replace "match:class ^(.*?)$" with "class:^(.*?)$"
content = re.sub(r'match:class \^\((.*?)\)\$', r'class:^(\1)$', content)

# Replace "match:title ^(.*?)$" with "title:^(.*?)$"
content = re.sub(r'match:title \^\((.*?)\)\$', r'title:^(\1)$', content)

# Replace remaining "match:class " just in case
content = re.sub(r'match:class ', r'class:', content)
content = re.sub(r'match:title ', r'title:', content)

with open('.config/hypr/modules/windowrules.conf', 'w') as f:
    f.write(content)
