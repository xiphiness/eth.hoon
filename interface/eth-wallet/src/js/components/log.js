import React, { Component } from 'react';
import { observer } from 'mobx-react'
import { computed } from 'mobx';
import web3Utils from 'web3-utils';
import _ from 'lodash';
import { store } from '../store.js';
/*
 TODO: switch to mobx reaction to debounce events to rerender more slowly
*/


@observer
export class EventLogs extends Component {
  constructor(props) {
    super(props);
    // this.state = {
    //   contract: props.contract
    // }
  }

  @computed get contract () {
    if(this.props.symbol == 'ETH') {
      return {
        symbol: 'ETH',
        name: 'Ether',
        txnLog: store.state.ethTxnLog,
        pending: store.state.ethPending
      }
    }
    return store.state.contracts.find(val => val.symbol == this.props.symbol)
  }

  render() {
    const { filterOptions } = this.props;
    // const { contract } = this.state;
    if (!this.contract) {
      return this.renderNoDataAvailable();
    }

    // let { showAllEvents, filters } = filterOptions || { filters: [], showAllEvents: true };
    // const hashPairs = getEventHashPairs(this.contract.abiEvents);

    const logs = this.contract.txnLog || [];
    const pending = this.contract.pending || [];
    console.log("rendering logs", logs)

    // if (!showAllEvents && filters.length > 0) {
    //   logs = this.filterLogs(logs, hashPairs, filters);
    // }

    // show max 200 entries
    // logs = _.take(logs, 200);

    return (<div className="h-100-minus-2 relative">
        {
          logs.length > 0 ? this.renderLog(pending, logs, this.contract) : this.renderNoDataAvailable()
        }
      </div>
    )
  }

  renderLog(pending, logs, contract) {
    return <div className="h-100-minus-60 overflow-auto">
      <ul className="list pl0 ma0 dt w-100">
        {this.renderPending(pending, contract.symbol)}
        {this.renderConfirmed(logs, contract.symbol)}
      </ul>
    </div>;
  }

  renderConfirmed(logs, symbol) {
    return (
      <div>
        {
          logs
            .map((log) => {
              const sent = symbol == 'eth' ? true : log.from == store.state.owner;
              let amt = web3Utils.fromWei(log.value.toString())
              const dot = amt.indexOf('.')
              if(dot > 0)
              amt = amt.slice(0, dot+2)
              return (
                <li className={'lh-copy pl3 pv3 ba bl-0 bt-0 br-0 b--solid b--gray4 b--gray1-d bg-animate'}>
                  <div className="flex-wrap items-center ml6 pv2">
                    <div className="flex flex-row nowrap items-center w-50 mb2">
                      <p className="f7 w-50 green2 mr6">{sent ? 'Sent' : 'Received'}</p>
                      <p className='f7 w-50 fl green2'>{`${amt} ${symbol}`}</p>
                    </div>
                    <div className="flex flex-row nowrap items-center w-75 pl2">
                      <p className="f8 mr5 i">{sent ? 'to: ' : 'from:'}</p>
                      <p className="f8 fl pr10">{sent ? log.to : log.from}</p>
                      <div className="flex flex-column items-center w-50 pl10">
                        <p className="f9 w-50 mr1">Tx <span className="gray2">{log.txHash}</span></p>
                        <p className="f9 w-50">Block <span className="gray2">{log.block}</span></p>
                      </div>
                    </div>
                  </div>
                </li>
              );
            })
        }
      </div>
    );
  }

  renderPending(pending, symbol) {
    return (
      <div>
        {
          pending
            .map((log) => {
              const sent = symbol == 'eth' ? true : log.from == store.state.owner;
              let amt = web3Utils.fromWei(log.value.toString())
              const dot = amt.indexOf('.')
              if(dot > 0)
              amt = amt.slice(0, dot+2)
              return (
                <li className={'lh-copy pl3 pv3 ba bl-0 bt-0 br-0 b--solid b--gray4 b--gray1-d bg-animate'}
                style={{"background-color": "#EEEEEE"}}>
                  <div className="flex-wrap items-center ml6 pv2">
                    <div className="flex flex-row nowrap items-center w-50 mb2">
                      <p className="f7 w-50 green2 mr6">{sent ? 'Sent' : 'Received'} (pending)</p>
                      <p className='f7 w-50 fl green2'>{`${amt} ${symbol}`}</p>
                    </div>
                    <div className="flex flex-row nowrap items-center w-75 pl2">
                      <p className="f8 mr5 i">{sent ? 'to: ' : 'from:'}</p>
                      <p className="f8 fl pr10">{sent ? log.to : log.from}</p>
                      <div className="flex flex-column items-center w-50 pl10">
                        {log.txHash && <p className="f9 w-50 mr1">Tx <span className="green4">{log.txHash}</span></p>}
                      </div>
                    </div>
                  </div>
                </li>
              );
            })
        }
      </div>
    )
  }

  renderNoDataAvailable() {
    return <div className="pl3 pr3 pt2 dt pb3 w-100 h-100-minus-56">
      <div className="f9 pt3 gray2 w-100 h-100 dtc v-mid tc">
        <p className="w-100 tc mb2">No contract data available.</p>
        <p className="w-100 tc">It might need a minute - lean back.</p>
      </div>
    </div>;
  }
}