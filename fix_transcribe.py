import re

with open("bakwaas.py", "r") as f:
    content = f.read()

old = '''    result = pipe(
        audio_path,
        generate_kwargs={
            "language": "hindi",
            "initial_prompt": "Ronin, Jharkhand, Delhi, Mumbai, India, AI, GitHub, LinkedIn, Python, Mac"
        }
    )'''

new = '''    result = pipe(
        audio_path,
        generate_kwargs={
            "language": "hindi",
        }
    )'''

content = content.replace(old, new)

with open("bakwaas.py", "w") as f:
    f.write(content)

print("✅ Fixed!")
