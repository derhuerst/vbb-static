# vbb-static

*vbb-static* is a **collection of JSON datasets the [Berlin Brandenburg public transport service (VBB)](http://www.vbb.de/)**, taken from [open](https://github.com/derhuerst/vbb-gtfs) [GTFS](https://developers.google.com/transit/gtfs/) data.

[![npm version](https://img.shields.io/npm/v/vbb-static.svg)](https://www.npmjs.com/package/vbb-static)
[![dependency status](https://img.shields.io/david/derhuerst/vbb-static.svg)](https://david-dm.org/derhuerst/vbb-static)
[![dev dependency status](https://img.shields.io/david/dev/derhuerst/vbb-static.svg)](https://david-dm.org/derhuerst/vbb-static#info=devDependencies)



## Installing

```shell
npm install vbb-static
```

*vbb-static* will download selected [GTFS](https://developers.google.com/transit/gtfs/) files from [derhuerst/vbb-gtfs](https://github.com/derhuerst/vbb-gtfs), process them and store it them locally in JSON files.



## Usage

To get all three datasets, just `require('vbb-static')`.

More datasets are comings soon!


### `stations` dataset

`require('vbb-static/stations')` gives you:

```javascript
{
	'5100071': {
		name: 'Zbaszynek',
		latitude: 52.2425040,
		longitude: 15.8180870,
		weight: 2
	},
	// …
	'9835850': {
		name: 'Senftenberg, Puschkinstr.',
		latitude: 51.5249170,
		longitude: 14.0051770,
		weight: 15
	}
}
```


### `agencies` dataset

`require('vbb-static/agencies')` gives you:

```javascript
{
	VBB: {
		name: 'Verkehrsverbund Brandenburg-Berlin',
		url: 'http://www.vbb.de',
		phone: ''
	},
	// …
	WS: {
		name: 'Woltersdorfer Straßenbahn GmbH',
		url: 'http://www.woltersdorfer-strassenbahn.com',
		phone: '03362 881230'
	}
}
```


### `routes` dataset

`require('vbb-static/routes')` gives you:

```javascript
{
	'1': {
		agency: 'FFT',
		type: 'bus'
	},
	// …
	RB51: {
		agency: 'ODEN',
		type: 'regional'
	}
}
```



## Contributing

If you **have a question**, **found a bug** or want to **propose a feature**, have a look at [the issues page](https://github.com/derhuerst/vbb-static/issues).
