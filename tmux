#! /bin/bash

dir=$(pwd)
session=$(basename "$dir")

tmux rename-session "$session"
tmux rename-window shell

tmux new-window   -n vim -d
tmux send-keys    -t vim "cd ." C-m  
tmux send-keys    -t vim "vim ." C-m  

tmux new-window   -n rspec -d
tmux send-keys    -t rspec "cd ." C-m
tmux send-keys    -t rspec "rs" C-m

tmux new-window   -n irb -d
tmux send-keys    -t irb "cd ." C-m
tmux send-keys    -t irb "irb" C-m

tmux swap-window  -s vim -t shell

