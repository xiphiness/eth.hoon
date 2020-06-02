import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

class UrbitApi {
  setAuthTokens(authTokens) {
    this.authTokens = authTokens;
    this.bindPaths = [];
  }

  bind(path, method, ship = this.authTokens.ship, appl = "eth-wallet-view", success, fail) {
    this.bindPaths = _.uniq([...this.bindPaths, path]);

    window.subscriptionId = window.urb.subscribe(ship, appl, path,
      (err) => {
        fail(err);
      },
      (event) => {
        success({
          data: event,
          from: {
            ship,
            path
          }
        });
      },
      (err) => {
        fail(err);
      });
  }

  sendEth(to, value) {
    const payload = { to, value }
    this.ethWallet({ type: 'send-eth', payload })
  }

  addErc20(symbol, name, address) {
    const payload = { symbol, name, address}
    this.ethWallet({ type: 'add-erc20', payload })
  }

  sendErc20(symbol, to, value) {
    const payload = { symbol, to, value }
    this.ethWallet({ type: 'send-erc20', payload })
  }

  ethWallet(data) {
    this.action("eth-wallet-store", "json", data);
  }

  action(appl, mark, data) {
    return new Promise((resolve, reject) => {
      window.urb.poke(ship, appl, mark, data,
        (json) => {
          resolve(json);
        },
        (err) => {
          reject(err);
        });
    });
  }
}
export let api = new UrbitApi();
window.api = api;
