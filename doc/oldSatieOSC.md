# Address space

-   **/satie:** the root address space. At this level we can create and delete synth instances and groups.
    -   **/default:** group level, only methods affecting a group of synths should be used. The group and synths must already be created. A group `default` is already created on the server and synth instances are placed in the `default` group automatically, unless a different group is specified.

# OSC messages

## Handling sound sources

### create

Create synth group:

`/satie create name`

Create effect group:

`/satie createFX name`

Create a group member:

`/satie/group create name synthType`

creates an instance of a SATIE synthDef. it also creates a group if the group does not exist.

-   Arguments:
    -   **name:** unique identifier for the created object
    -   **synthType:** the reference name of the synth or effect being used. The synth must have been compiled on the server with `~satie.makeSynthDef` method before instantiating

### delete

`/satie/group delete`
`/satie/group/instance delete`
delete a named instance from the SATIE server. *name* is the uniquely identified synth instance.

-   **Receiver:** `/satie`

-   Arguments:
    -   **name:** the named instance of the synth to remove

### set

`/satie/group set param value [param, value, ...]`

`/satie/group/instance set param value [param, value, ...]`

sets parameter values to a SATIE instance. Any number of `param / value` pairs may be provided

-   Arguments
 -   **param:** parameter to affect, dependent on the instrument. The common parameters are:
        
| Parameter  | Unit     | Description                                     |
|------------|----------|-------------------------------------------------|
| `gainDB`   | decibels | gain                                            |
| `aziDeg`   | degrees  | azimuth +/- 180                                 |
| `elevDeg`  | degrees  | elevation +/- 90                                |
| `delaySec` | seconds  | delay time for doppler effect                   |
| `lpHz`     | hertz    | low pass filter for for doppler                 |
| `spread`   | int      | panning spread, 0 - 100. 0 = narrow, 100 = omni |
    
 -   **value:** parameter's value

### clear

`/satie clear`

remove all SATIE groups, their synths/effects and associated OSC addresses and reset to default.

# Workflow

Basic workflow:

-   create groups for desired synths/effects
-   instantiate synths and effects in their groups
