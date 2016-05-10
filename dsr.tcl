set opt(chan)           Channel/WirelessChannel    ;# channel type 
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model 
set opt(netif)          Phy/WirelessPhy            ;# network interface type 
set opt(mac)            Mac/802_11                 ;# MAC type 
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type 
set opt(ll)             LL                         ;# link layer type 
set opt(ant)            Antenna/OmniAntenna        ;# antenna model 
set opt(ifqlen)         50                         ;# max packet in ifq 
set opt(nn)             3                         ;# number of mobilenodes 
set opt(rp)             DSR                       ;# routing protocol
set opt(x)              500   			   ;# X dimension of topography 
set opt(y)              400 			   ;# Y dimension of topography   
set opt(stop)		150                         ;
set ns              [new Simulator]
#Creating trace file and nam file 
set tracefd       [open Dsr.tr w]

set namtrace      [open dsr.nam w]    

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $opt(x) $opt(y)

create-god $opt(nn)

# configure the nodes
        $ns node-config -adhocRouting $opt(rp) \
                   -llType $opt(ll) \
                   -macType $opt(mac) \
                   -ifqType $opt(ifq) \
                   -ifqLen $opt(ifqlen) \
                   -antType $opt(ant) \
                   -propType $opt(prop) \
                   -phyType $opt(netif) \
                   -channelType $opt(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON
                   
      for {set i 0} {$i < $opt(nn) } { incr i } {
            set node_($i) [$ns node]      
      }

# Provide initial location of mobilenodes
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

# Generation of movements
$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0" 

# Set a TCP connection between node_(0) and node_(1)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start" 



# Define node initial position in nam
for {set i 0} {$i < $opt(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $opt(nn) } { incr i } {
    $ns at $opt(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $opt(stop) "$ns nam-end-wireless $opt(stop)"
$ns at $opt(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam dsr.nam
}

$ns run

exec nam dsr.nam
