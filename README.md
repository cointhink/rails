# HeisenCoin


## Features

* Monitor btc/usd market offers from multiple exchanges
* Formulate a trade strategy.
* Display market analytics and strategy detail

## Rake Tasks

Grab offers from the active exchanges.
```bash
$ rake btc:snapshot
```

Compute the maximum arbitrage opportunity
```bash
$ rake btc:opportunity
```
