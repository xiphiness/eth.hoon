import React, { Component } from 'react';
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import { observer } from 'mobx-react'
import { api } from '/api';
import { store } from '/store';
import { NewContract } from './new';
import { Skeleton } from './skeleton';
import { EventLogs } from './log';
import { Send } from './send';

@observer
export class Root extends Component {
  constructor(props) {
    super(props);
    this.state = {}
  }

  render() {
    return (
      <BrowserRouter>
        <Switch>
          <Route
            exact
            path="/~eth-wallet"
            render={() => {
              return (
                <Skeleton key="main" contracts={store.state.contracts} ethBalance={store.state.ethBalance}>
                  {this.renderBaseViewContent()}
                </Skeleton>
              );
            }}
          />
          <Route
            exact
            path="/~eth-wallet/new"
            render={() => {
              return (
                <Skeleton key="new" contracts={store.state.contracts} ethBalance={store.state.ethBalance}>
                  <NewContract
                    abi={this.state.abi}
                    contracts={store.state.contracts}
                    onAcceptClicked={contract => api.newContract(contract)}
                  />
                </Skeleton>
              );
            }}
          />
          <Route
            exact
            path="/~eth-wallet/send-ether"
            render={() => {
              return (
                <Skeleton
                  key={"sendether"}
                  contracts={store.state.contracts}
                  ethBalance={store.state.ethBalance}
                >
                  <Send
                    key={'send-ether'}
                    symbol={'ETH'}
                  />
                </Skeleton>
              )
            }}
          />
          <Route
            exact
            path="/~eth-wallet/send-erc20/:contract"
            render={props => {
              return (
                <Skeleton
                  key={"send-erc20"}
                  selectedContract={props.match.params.contract}
                  contracts={store.state.contracts}
                  ethBalance={store.state.ethBalance}
                >
                  <Send 
                    key={props.match.params.contract}
                    symbol={props.match.params.contract}
                  />
                </Skeleton>
              )
            }}
          />
          <Route
            exact
            path="/~eth-wallet/logs/:contract"
            render={props => {
              return (
                <Skeleton
                  key={"logs"}
                  selectedContract={props.match.params.contract}
                  contracts={store.state.contracts}
                  ethBalance={store.state.ethBalance}
                >
                  <EventLogs
                    symbol={props.match.params.contract}
                  />
                </Skeleton>
              );
            }}
          />
        </Switch>
      </BrowserRouter>
    );
  }

  renderBaseViewContent() {
    // const { contracts } = this.state;
    let message = 'There are no contracts, feel free to add one.';
    if (store.state.contracts.length > 0) {
      message = 'Please select a contract.';
    }
    return <div className="pl3 pr3 pt2 dt pb3 w-100 h-100">
      <p className="f9 pt3 gray2 w-100 h-100 dtc v-mid tc">{message}</p>
    </div>
  }
}
