#Hide welcome message
set -g fish_greeting

# Starship prompt
if status --is-interactive
   source ("/usr/bin/starship" init fish --print-full-init | psub)
end

# Run neofetch if session is interactive
if status --is-interactive
   neofetch
end
