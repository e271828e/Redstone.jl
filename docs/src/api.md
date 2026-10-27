```@meta
CurrentModule = Redstone
```

# API

The entry points, grouped as the specification's Appendix B groups them.

## Authoring

```@docs
AbstractComponent
x_init
m_init
ws_init
u_types
y_types
state_events
y_state
y_direct
x_deriv
StateEvent
x_projection
s_init
s_update
local_wires
input_wires
output_wires
sample_times
transparent_container
Relative
Absolute
Period
Hz
stop_reason
Pinned
```

## Build

```@docs
build
Build
Structure
Outputs
Events
descriptor
ProbeDual
resolve
input_faces
output_faces
input_passthrough
output_passthrough
```

## Deployment and the model

```@docs
Deployment
Schedule
RK4
Heun
Model
FrameHooks
NoHooks
frame_top!
settled!
frame!
port
state
modes
ModelState
```

## The simulation and its devices

```@docs
Simulation
attach!
detach!
AbstractDevice
AbstractBinding
is_input
is_output
is_greedy
claims
map_input
map_output
TableBinding
loop
shutdown!
unblock!
DeviceHandle
wait_next_snapshot
running
binding
gather
report!
port_views
pending
peek
incumbent_status
orphaned
stale
PortView
WriterStatus
MalformedDatum
```

## Condition algebra

```@docs
set
at
combine
override
condition
Fragment
Scoped
Combined
Override
ConditionNode
```

## Stopped-sim services

```@docs
init!
trim!
TrimProblem
TrimReport
LevenbergMarquardt
solve
checkpoint
Checkpoint
restore!
overlay!
linearize
Linearization
get_state
get_deriv
get_output
get_input
get_face
taps
GetState
GetDeriv
GetOutput
GetInput
GetFace
Taps
Reads
```

## Running

```@docs
run!
step!
stage!
latest
phase_bodies
pause!
resume!
stop!
paused
pace!
margin!
pace
margin
termination
TerminationSource
EndTimeReached
ModelRequestedStop
ControlRequestedStop
LoopError
StopFlag
logged
reads
series
trace
replay!
warnings
closed
lifecycle
mode
live!
Snapshot
Run
TerminationRecord
Trace
Series
Diagnostic
```

## The component library

```@meta
CurrentModule = Redstone.Blocks
```

The standard library, `Redstone.Blocks`, grouped as the inventory in
`companions/library_inventory.md` groups it. Every block is reached by import
from the submodule.

### Structure

```@docs
Junction
SumJunction
Or
And
Pack
Unpack
Group
Switch
StopRequest
```

### Sources

```@docs
Constant
Step
Source
GaussianWhiteNoise
```

### Continuous dynamics

```@docs
Integrator
LimitedIntegrator
FirstOrderLag
LinearBlock
StateSpace
TransferFunction
```

### Discontinuities

```@docs
Relay
```

### Discrete tier

```@docs
UnitDelay
Delay
DiscreteIntegrator
DiscreteLimitedIntegrator
RateLimiter
DiscreteLinearBlock
DiscreteStateSpace
DiscreteTransferFunction
DiscretizedStateSpace
DiscretizedTransferFunction
```

### Stop-gradient

```@docs
Freeze
```

### Controllers

```@docs
AsPort
ControllerBlock
PIDBlock
PID
DiscretePID
LQRTrackerBlock
LQRTracker
DiscreteLQRTracker
```
