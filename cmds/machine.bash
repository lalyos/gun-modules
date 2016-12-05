
init() {
  cmd-export-ns machine "Docker-machine"
  cmd-export machine-create
  cmd-export machine-cmd
  cmd-export machine-env
  cmd-export machine-rm
  cmd-export machine-check
  cmd-export machine-start

  env-import MACHINE_NAME cbd
  env-import MACHINE_STORAGE_PATH $HOME/.docker/machine
  env-import MACHINE_MEM 4096
  env-import MACHINE_CPU 2
  env-import MACHINE_OPTS "--xhyve-virtio-9p"

  deps-require docker-machine 0.8.2
  deps-require docker-machine-driver-xhyve 0.3.1
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
    debug "$desc"
    
    docker-machine create \
        -d xhyve \
        --xhyve-memory-size $MACHINE_MEM \
        --xhyve-cpu-count $MACHINE_CPU \
        --xhyve-boot-cmd="loglevel=3 user=docker console=ttyS0 console=tty0 noembed nomodeset norestore waitusb=10 base host=$MACHINE_NAME" \
        $MACHINE_OPTS \
        $MACHINE_NAME

    machine-env
}

machine-start() {
    declare desc="starts the vm"

    docker-machine start $MACHINE_NAME
}

machine-check() {
   declare desc="Check the vm"

   debug "Check if vm is running"
   local status=$(docker-machine status $MACHINE_NAME)
   if [[ "$status" != "Running" ]]; then
       echo "docker vm is not running! status: $status"  | red
       echo "=====> start the VM:"
       echo "gun machine start" | yellow
       exit 1
   fi

   debug "Check if volume sharing works"
   local localDate=$(date)
   echo $localDate > delme.txt
   local dockerDate=$(docker run -v $PWD:/data alpine cat /data/delme.txt)
   if [[ "$localDate" != "$dockerDate" ]]; then
       echo "docker volume sharing doesnt work !!!" | red
   else
       echo "docker volume sharing: OK" | green 1>&2
   fi
   rm delme.txt
}

machine-rm() {
    declare desc="removes cbd specific docker-machine"
    
    Docker-machine rm $MACHINE_NAME -f
}

machine-env() {
    declare desc="creates local profile script"
    debug "$desc"
    
    docker-machine env $MACHINE_NAME > .profile.docker

    debug docker ENV are saved to .profile.docker
    echo "=====> You can set docker ENV vars by:" 1>&2
    echo "source .profile.docker" | yellow

    sed -i '/PUBLIC_IP/ d' Profile
    echo "export PUBLIC_IP=$(docker-machine ip $MACHINE_NAME )" >> Profile
}

machine-cmd() {
    declare desc="Runs docker-machine subcommand"
    eval $(docker-machine env $MACHINE_NAME)
    docker-machine "$@"
}
