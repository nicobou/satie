# SATIE Changelog



## [1.2.0] - 2019-01-23

### New features
- New `Satie.quit` method
- New `Satie.clearScene` method
- New `SatieQueryTree` class
- New convenience method `Satie.switchMake`
- Allow function to be called immediately after boot
- Make use of SuperCollider's CmdPeriod and ServerTree classes
- Project now uses Gitlab CI
- Many new unit tests

### Improvements
- Improved booting
- Allow freeing OSCdefs
- OSC API message 'update' now more flexible
- Renamed SATIE plugin folders
- Renamed some SATIE plugins
- All plugins make use of the `~channelLayout` field
- Throw error when `listeningFormat` and `outBusIndex` don't match
- Removed duplicate plugin dictionary variables from class `Satie`
- SATIE no longer forces `blockSize = 128` when doing ambisonics
- SATIE no longer depends on NodeWatcher quark
- Removed unused methods
- Revised documentation
- Cleaned up OSC API



## [1.1.1] - 2018-08-15

### Improvements
- A better Readme



## [1.1.0] - 2018-08-13

### New features
- Analysis/monitoring side-chain with example monitoring plugins
- _delay_ post-processor
- Execute a file upon SATIE server boot
- Enable/disable compilation of SATIE plugins at boot

### Improvements
- Updated OSC API documentation which is now rendered in html
- Added new audio generator
- Ability to load custom plugins from user-defined directory
- Revised documentation

### Bugfixes
- Proper handling of sceneClear
- Proper handling of freeing synths from IDE
- Fix to quark file

### Removals
- SAT specific plugins



## [1.0.1] - 2018-04-19

### New features
- Support for ambisonics via SC-HOA quark
- Several mappers for each spatialiser
- Far and near field mappers

### Improvements
- Updated documentation
- Various bugfixes
