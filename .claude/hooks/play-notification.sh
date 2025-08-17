#!/bin/bash

# Play notification sound when Claude finishes
# Cross-platform support for Mac, Windows (WSL), and Linux

# Detect platform and play appropriate sound
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use afplay with system sounds
    if command -v afplay &> /dev/null; then
        # Play unique Claude Code completion sound - Submarine (distinctive, deep)
        afplay /System/Library/Sounds/Submarine.aiff 2>/dev/null
        
        # Alternative unique Mac sounds (uncomment to try different ones):
        
        # Option 1: Funk sound (retro, pleasant)
        # afplay /System/Library/Sounds/Funk.aiff 2>/dev/null
        
        # Option 2: Glass sound (sharp, attention-grabbing)
        # afplay /System/Library/Sounds/Glass.aiff 2>/dev/null
        
        # Option 3: Hero sound (triumphant)
        # afplay /System/Library/Sounds/Hero.aiff 2>/dev/null
        
        # Option 4: Sosumi sound (classic Mac sound)
        # afplay /System/Library/Sounds/Sosumi.aiff 2>/dev/null
    else
        # Fallback: Terminal bell
        echo -e "\a"
    fi
    
elif command -v powershell.exe &> /dev/null; then
    # Windows (WSL) - use PowerShell
    # Play a more distinctive Windows sound (choose one by uncommenting)
    
    # Custom unique sound sequence - Claude Code completion signature
    powershell.exe -Command "[console]::beep(523,150); [console]::beep(659,150); [console]::beep(784,200)" 2>/dev/null
    
    # Alternative unique sounds (uncomment to try different ones):
    
    # Option 1: Chord progression (musical)
    # powershell.exe -Command "[console]::beep(440,200); [console]::beep(554,200); [console]::beep(659,300)" 2>/dev/null
    
    # Option 2: Robot-like descending beeps
    # powershell.exe -Command "[console]::beep(1000,100); [console]::beep(800,100); [console]::beep(600,200)" 2>/dev/null
    
    # Option 3: Victory fanfare
    # powershell.exe -Command "[console]::beep(523,100); [console]::beep(659,100); [console]::beep(784,100); [console]::beep(1047,300)" 2>/dev/null
    
    # Option 4: Retro game completion sound
    # powershell.exe -Command "[console]::beep(392,150); [console]::beep(523,150); [console]::beep(659,150); [console]::beep(784,300)" 2>/dev/null
    
elif command -v paplay &> /dev/null; then
    # Native Linux with PulseAudio
    # Try to play a system sound
    if [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
    else
        # Fallback: Terminal bell
        echo -e "\a"
    fi
    
elif command -v aplay &> /dev/null; then
    # Native Linux with ALSA
    # Try to play a system sound
    if [ -f /usr/share/sounds/alsa/Front_Center.wav ]; then
        aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null
    else
        # Fallback: Terminal bell
        echo -e "\a"
    fi
    
else
    # Universal fallback: Terminal bell
    echo -e "\a"
fi

exit 0