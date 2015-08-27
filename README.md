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

First, `require` the API to access the data.

```javascript
var static = require('vbb-static');
```

Now, you can query single datasets. Because some of them are pretty big, **all operations work [promise](http://documentup.com/kriskowal/q/)-based**.

Each dataset has a method. All methods accept a filter `pattern` that will be applied strictly (`===`).

To filter by `id`, just pass the value.

```javascript
static.route(1173).then(…);
```

To filter by multiple field, pass them in an object.

```javascript
static.route({
	stationFromId: 9003104,
	stationToId: 9003176
}).then(…);
```

### Methods

- `agency(pattern)`
- `route(pattern)`
- `schedule(pattern)`
- `station(pattern)`
- `transfer(pattern)`
- `trip(pattern)`
- `schedule(pattern)`



## Examples


### `agencies` dataset

```javascript
static.agency('VIB');
```

will [resolve](http://documentup.com/kriskowal/q/#tutorial) with

```javascript
{
	id: 'VIB',
	name: 'Verkehrsbetrieb Potsdam GmbH',
	url: 'http://www.vip-potsdam.de'
}
```


### `stations` dataset

```javascript
static.station(9042101);
```

will [resolve](http://documentup.com/kriskowal/q/#tutorial) with

```javascript
{
	id: 9042101,
	name: 'U Spichernstr. (Berlin)',
	latitude: 52.496582,
	longitude: 13.330613,
	weight: 13585
}
```


### `trips` dataset

```javascript
static.trip(107);
```

will [resolve](http://documentup.com/kriskowal/q/#tutorial) with

```javascript
{
	id: 107,
	routeId: 11,
	scheduleId: '001506',
	name: 'S Strausberg Bhf',
	stations: [
		{
			s: 9321168,   // station id
			t: 58500000   // time in milliseconds
		},
		// …
		{
			s: 9320004,
			t: 61800000
		}
	]
}
```



## Contributing

If you **have a question**, **found a bug** or want to **propose a feature**, have a look at [the issues page](https://github.com/derhuerst/vbb-static/issues).
