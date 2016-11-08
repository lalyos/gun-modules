
init() {
  cmd-export-ns machine "Docker-machine"
  cmd-export machine-create
  cmd-export machine-cmd

  env-import MACHINE_NAME cbd
  env-import MACHINE_STORAGE_PATH .gun/machines

  deps-require docker-machine
  deps-require docker-machine-driver-xhyve
  color-init
  }

debug() {
   if [[ "$DEBUG" ]]; then
       if [[ "$DEBUG" -eq 2 ]]; then
           printf "[DEBUG][%-25s] %s\n" $(shorten_function "${FUNCNAME[1]}") "$*" | cyan 1>&2
       else
         echo -e "[DEBUG] $*" | cyan 1>&2
       fi
   fi
 }

machine-create() {
    declare desc="Installs docker-machine xhyve driver"

    docker-machine create \
        -d xhyve \
        --xhyve-experimental-nfs-share --xhyve-memory-size 4096 \
        --xhyve-cpu-count 2 \
        --xhyve-boot-cmd="loglevel=3 user=docker console=ttyS0 console=tty0 noembed nomodeset norestore waitusb=10 base host=$MACHINE_NAME" \
        $MACHINE_NAME
}

machine-cmd() {
    declare desc="Runs docker-machine subcommand"
    eval $(docker-machine env $MACHINE_NAME)
    docker-machine "$@"
}
