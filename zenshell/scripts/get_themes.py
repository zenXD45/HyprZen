#!/usr/bin/env python3
"""List available HyprZen themes with full color palettes for the Dynamic Island theme switcher."""
import json

themes = [
    {"id": "catppuccin",  "name": "Catppuccin",  "icon": "☕", "accent": "#cba6f7", "bg": "#1e1e2e", "surface": "#181825", "fg": "#cdd6f4", "extra": "#f38ba8"},
    {"id": "tokyo-night", "name": "Tokyo Night",  "icon": "🌃", "accent": "#7aa2f7", "bg": "#1a1b26", "surface": "#1f2335", "fg": "#c0caf5", "extra": "#f7768e"},
    {"id": "gruvbox",     "name": "Gruvbox",      "icon": "📦", "accent": "#fe8019", "bg": "#282828", "surface": "#3c3836", "fg": "#ebdbb2", "extra": "#fb4934"},
    {"id": "nord",        "name": "Nord",          "icon": "❄️", "accent": "#88c0d0", "bg": "#2e3440", "surface": "#3b4252", "fg": "#eceff4", "extra": "#bf616a"},
    {"id": "osaka-jade",  "name": "Osaka Jade",   "icon": "🪨", "accent": "#a7c080", "bg": "#2b3339", "surface": "#323d43", "fg": "#d3c6aa", "extra": "#e67e80"},
    {"id": "aetheria",    "name": "Aetheria",     "icon": "☁️", "accent": "#7287fd", "bg": "#eff1f5", "surface": "#e6e9ef", "fg": "#4c4f69", "extra": "#ea76cb"},
    {"id": "akane",       "name": "Akane",        "icon": "🏮", "accent": "#ff5d62", "bg": "#1f1f28", "surface": "#2a2a37", "fg": "#dcd7ba", "extra": "#7e9cd8"},
    {"id": "alabaster",   "name": "Alabaster",    "icon": "🤍", "accent": "#808080", "bg": "#f7f7f7", "surface": "#ebebeb", "fg": "#434343", "extra": "#aa3731"},
    {"id": "lavender",    "name": "Lavender",     "icon": "🪻", "accent": "#b4befe", "bg": "#222236", "surface": "#2f334d", "fg": "#c8d3f5", "extra": "#ff757f"},
    {"id": "eva-theme",   "name": "Eva Theme",    "icon": "🤖", "accent": "#9ece6a", "bg": "#24283b", "surface": "#292e42", "fg": "#a9b1d6", "extra": "#f7768e"},
    {"id": "noir",        "name": "Noir",         "icon": "🌑", "accent": "#838996", "bg": "#0f0f0f", "surface": "#141414", "fg": "#c0c0c0", "extra": "#555555"},
    {"id": "one-dark",    "name": "One Dark",     "icon": "💻", "accent": "#61afef", "bg": "#282c34", "surface": "#21252b", "fg": "#abb2bf", "extra": "#e06c75"},
    {"id": "rose-pine",   "name": "Rosé Pine",    "icon": "🌹", "accent": "#c4a7e7", "bg": "#191724", "surface": "#1f1d2e", "fg": "#e0def4", "extra": "#eb6f92"},
    {"id": "matugen",     "name": "Matugen",      "icon": "🎨", "accent": "#e0a0ff", "bg": "#1c1b1f", "surface": "#211f26", "fg": "#e6e1e5", "extra": "#d0bcff"},
]

print(json.dumps(themes))
