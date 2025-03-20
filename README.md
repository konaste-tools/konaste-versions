# Konaste Versions

This repository tracks memory offsets tracked by the SoundVoltex Konaste versioning API. Note that this API is currently private.

## Supported Versions

- **QCV:J:B:A:2025031400**

## Contributing

### Adding to an existing version
If you are introducing a new offset to an existing version, please update the corresponding `addresses.yaml` file, located in the directory denoted by the version timestamp.

Note that you may need to make adjustments to konaste-api if your offset is not used by any other version.

### Adding a new version
Create a new directory using the timestamp portion of the version (ie. QCV:J:B:A:2025031400 will become 2025031400) and add a file `addresses.yaml`

Configure this file using an existing `addresses.yaml` file as reference. Please **do not** copy across existing offsets from another version - these are unlikely to work.

As a bare minimum, all new versions must at least define `version` and `gamedirectory` properties.