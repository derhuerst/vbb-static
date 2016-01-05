# vbb-static

*vbb-static* is a **collection of JSON datasets covering the [Berlin Brandenburg public transport service (VBB)](http://www.vbb.de/)**, processed from [open](http://daten.berlin.de/datensaetze/vbb-fahrplandaten-juni-2015-bis-dezember-2015) [GTFS](https://developers.google.com/transit/gtfs/) [data](https://github.com/derhuerst/vbb-gtfs).

[![npm version](https://img.shields.io/npm/v/vbb-static.svg)](https://www.npmjs.com/package/vbb-static)
[![dependency status](https://img.shields.io/david/derhuerst/vbb-static.svg)](https://david-dm.org/derhuerst/vbb-static)
[![dev dependency status](https://img.shields.io/david/dev/derhuerst/vbb-static.svg)](https://david-dm.org/derhuerst/vbb-static#info=devDependencies)



## Installing

```shell
npm install vbb-static
```

*Warning:* This module contains `.ndjson` files with **a total size of roughly 130 megabytes of data**.



## Usage

```javascript
var static = require('vbb-static');
```

This will give you a static object with one method for each dataset. Each method has an optional `promised` switch and a required `filter`.

- `agencies( [promised,] filter )`
- `lines( [promised,] filter )`
- `stations( [promised,] filter )`
- `transfers( [promised,] filter )`
- `trips( [promised,] filter )`
- `schedules( [promised,] filter )`

**To filter by `id`, just pass the value.**

```javascript
static.lines(true, 1173).then(…);
```

**To filter by multiple fields, pass them in an object.**

```javascript
static.transfers(true, {
	stationFromId: 9003104,
	stationToId: 9003176
}).then(…);
```

**To get all elements, pass `'all'` as the `filter`.**



## Examples


### `agencies` dataset

```javascript
static.agencies(true, 'VIB')
```

returns a [promise that will resolve](http://documentup.com/kriskowal/q/#tutorial) with

```javascript
[{
	id: 'VIB',
	name: 'Verkehrsbetrieb Potsdam GmbH',
	url: 'http://www.vip-potsdam.de'
}]
```


### `stations` dataset

```javascript
static.stations(9042101);
```

returns an [object stream](https://nodejs.org/api/stream.html#stream_object_mode) that will emit `data` once with

```javascript
{
	id: 9042101,
	name: 'U Spichernstr. (Berlin)',
	latitude: 52.496582,
	longitude: 13.330613,
	weight: 13585
}
```



## Contributing

If you **have a question**, **found a bug** or want to **propose a feature**, have a look at [the issues page](https://github.com/derhuerst/vbb-static/issues).
