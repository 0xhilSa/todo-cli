#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
STRIKETHROUGH="\033[9m"
UNDERLINE="\033[4;34m"
RST="\033[0m"
BOLD="\033[1m"
FILE="$HOME/.todo.txt"
VERSION="0.2"

if [[ ! -f "$FILE" ]]; then
  touch "$FILE"
fi
sed -i '/^\[ \]/!{/^\[x\]/!d;}' "$FILE"
sed -i '/^$/d' "$HOME/.todo.txt"

main(){
  local cmd=$1
  local args=${2:-}

  if [[ "$cmd" == "ls" || "$cmd" == "show" ]]; then
    i=1
    while IFS= read -r line; do
      if [[ "$line" =~ ^\[X\] ]]; then
        echo -e "${GREEN}$i. $line${RST}"
      else
        echo -e "${RED}$i. $line${RST}"
      fi
      ((i++))
    done < "$FILE"
  elif [[ "$cmd" == "help" || "$cmd" == "h" ]]; then
    echo -e "${CYAN}${BOLD}todo.sh - A Simple CLI To-Do List Manager${RST}"
    echo -e "${CYAN}${BOLD}the indexing starts from '1' not from '0'${RST}\n"
    echo -e "${CYAN}${BOLD}Version: ${YELLOW}$VERSION${RST}\n"

    echo -e "${UNDERLINE}${BOLD}Usage:${RST}"
    echo -e "  ${BOLD}todo.sh${RST} [command] [argument](optional for some commands e.g. ls, help)\n"

    echo -e " ${UNDERLINE}${BOLD}Commands:${RST}"
    echo -e "  ${BOLD}ls/show                  - List all tasks${RST}"
    echo -e "  ${BOLD}add [argument]           - Add a new task${RST}"
    echo -e "  ${BOLD}done [argument]          - Mark a task as completed${RST}"
    echo -e "  ${BOLD}undone [argument]        - Mark a task as incomplete${RST}"
    echo -e "  ${BOLD}rm [argument]            - Mark a task as incomplete${RST}"
    echo -e "  ${BOLD}h/help                   - Show this help message${RST}"
    echo -e "  ${BOLD}v/version                - Show version${RST}\n"

    echo -e "${UNDERLINE}${BOLD}Legend:${RST}"
    echo -e "  ${GREEN}[X] Completed tasks appear in GREEN${RST}"
    echo -e "  ${RED}[ ] Incomplete tasks appear in RED${RST}\n"
  elif [[ "$cmd" == "version" || "$cmd" == "v" ]]; then
    echo -e "${BOLD}Version: ${YELLOW}$VERSION${RST}"
  elif [[ "$cmd" == "add" && -n "$args" ]]; then
    lower_task=$(echo "$args" | tr '[:upper:]' '[:lower:]')
    if grep -iqF "[ ] $lower_task" "$FILE"; then
      echo -e "${YELLOW}Task already exists: \"$args\"${RST}"
    else
      echo "[ ] $args" >> "$FILE"
    fi
  elif [[ "$cmd" == "done" && -n "$args" ]]; then
    if sed -n "${args}p" "$FILE" | grep -q "^\[X\]"; then
      echo -e "${BOLD}Task is already completed${RST}"
    else
      sed -i "${args}s/^\[ \]/[X]/" "$FILE"
    fi
  elif [[ "$cmd" == "undone" && -n "$args" ]]; then
    if ! [[ "$args" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}Error: Index must be a valid number${RST}"
    elif (( args < 1 || args > $(wc -l < "$FILE") )); then
      echo -e "${RED}Error: Invalid index${RST}"
    else
      if sed -n "${args}p" "$FILE" | grep -q "^\[X\]"; then
        sed -i "${args}s/^\[X\]/[ ]/" "$FILE"
      else
        echo -e "${BOLD}Task is already listed in the queue${RST}"
      fi
    fi
  elif [[ "$cmd" == "rm" || "$cmd" == "remove" ]]; then
    if [[ -z "$args" ]]; then
      echo -e "${RED}Error: Please provide an index to remove${RST}"
    elif [[ "$args" == "." || "$args" == "all" ]]; then
      echo -e "${YELLOW}Warning: This action is undoable!${RST}"
      read -p "Are you sure you want to remove all tasks? (y/n): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        > "$FILE"
      else
        echo -e "${RED}Operation canceled${RST}"
      fi
    elif ! [[ "$args" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}Error: Index must be a valid number${RST}"
    elif (( args < 1 || args > $(wc -l < "$FILE") )); then
      echo -e "${RED}Error: Invalid index${RST}"
    else
      sed -i "${args}d" "$FILE"
    fi
  else
    echo -e "${RED}${BOLD}Command: '$cmd' is an invalid command${RST}"
  fi
}

main "$@"
