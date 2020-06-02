Implementation of the urbit bounty Display ETH Data
Link: https://grants.urbit.org/bounties/831044524-display-eth-data

It is an ethereum event viewer gall + landscape app which can be used to listen for ethereum contract events.

## Installation

This repository is available as a template; to immediately generate your application's repository you can click [here](https://github.com/urbit/create-landscape-app/generate). Clone the generated repository, `npm install` and then run `npm start` to get started (you can also directly clone this repository, if you wish!).

In order to run your application on your ship, you will need Urbit v.0.10.0 or higher. On your Urbit ship, if you haven't already, mount your pier to Unix with `|mount %`.

## Using

Once you're up and running, your tile lives in `tile/tile.js`, which uses [React](https://reactjs.org) to render itself -- you'll want a basic foothold with it first. When you make changes, the `urbit` directory will update with the compiled application and, if you're running `npm run serve`, it will automatically copy itself to your Urbit ship when you save your changes (more information on that below).

### `npm run build`

This builds your application and copies it into your Urbit ship's desk. In your Urbit (v.0.8.0 or higher) `|commit %home` (or `%your-desk-name`) to synchronise your changes.

If this is the first time you're running your application on your Urbit ship, don't forget to `|start %yourapp`.

### `npm run serve`

Builds the application and copies it into your Urbit ship's desk, watching for changes. In your Urbit (v.0.8.0 or higher) `|commit %home` (or `%your-desk-name`) to synchronise your changes.

