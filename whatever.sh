#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

#script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-i <node1_ip> <node2_ip> ...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
    exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

clone=false
init_cluster=false
parse_params() {
    while getopts "ci" opt; do
        case $opt in
        c)
            clone=true
            ;;
        i)
            init_cluster=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
        esac
    done

    # Shift out the parsed options
    shift $((OPTIND - 1))

    # If -i is used, collect additional arguments
    if [ "$init_cluster" = true ]; then
        while [ $# -gt 0 ]; do
            case $1 in
            -*)
                echo "Unexpected option $1 after -i"
                usage
                exit 1
                ;;
            *)
                cluster_ips+=("$1")
                shift
                ;;
            esac
        done
    fi

    return 0
}

parse_params "$@"
setup_colors

if $clone; then
    git clone git@github.com:tollsimy/k8s-mesh-eval.git
fi

# Get join command from master node
get_join_command() {
    echo ""
    echo "Fetching the join command from the master node..."
    JOIN_COMMAND="dur"
}

join_slaves() {
    local nodes=("$@")
    echo ""
    echo "Making slave nodes join the Kubernetes cluster:"
    for SLAVE in "${nodes[@]}"; do
        echo -e "\tConfiguring $SLAVE..."
        #ssh $SSH_USER@$SLAVE "sudo $JOIN_COMMAND"
    done
}

if $init_cluster; then
    echo "Initializing cluster - Nodes IP: ${cluster_ips[*]}"
    #sudo kubeadm init --config config   # create master
    get_join_command
    join_slaves "${cluster_ips[@]}"
fi

# script logic here
