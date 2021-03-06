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
tmux send-keys    -t rspec "rs --tag ~js" C-m

tmux new-window   -n pry -d
tmux send-keys    -t pry "cd ." C-m
tmux send-keys    -t pry "bundle exec pry -r 'woyo/server'" C-m 
tmux swap-window  -s vim -t shell

