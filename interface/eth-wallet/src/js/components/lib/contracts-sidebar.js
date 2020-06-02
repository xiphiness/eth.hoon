import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { observer } from 'mobx-react'
import web3Utils from 'web3-utils';
import { store } from '../../store.js';
// import CopyToClipboard from 'react-copy-to-clipboard';

@observer
export class ContractsSidebar extends Component {
  render() {

    return (
      <div className="ba bl-0 bt-0 bb-0 b--solid b--gray4 b--gray1-d w-320-px w-100-s ba-0-s"
      >
        {this.renderEthWallet(store.state.ethBalance)}
        <div className="w-100 bg-transparent pa4 bb b--gray4 b--gray1-d"
          style={{ paddingBottom: '13px' }}
        >
          <Link to="/~eth-wallet/new">
            <p className="dib f9 pointer green2 gray4-d mr4">Add Token</p>
          </Link>
        </div>
        {this.renderContractsList(store.state.contracts)}
      </div>
    );
  }

  renderEthWallet(ethBalance) {
    // console.log('addr', web3Utils.isAddress, 'sha3', web3Utils.sha3, 'fromWei', web3Utils.fromWei("400000"))
    // console.log('wutils', wutils)
    let amt = web3Utils.fromWei(ethBalance.toString())
    const dot = amt.indexOf('.')
    if(dot > 0)
    amt = amt.slice(0, dot+2)
    return (
      <div className="w-100 h-25 bg-transparent flex auto items-center justify-center">
        <div className="flex flex-column">
          <Link
                to={`/~eth-wallet/logs/ETH`}
              >
            <div className="flex justify-center items-center mb4">
              <p className="f4 mr2">{amt}</p>
              <p className="f6 ml2">ETH</p>
            </div>
          </Link>
          <Link to={"/~eth-wallet/send-ether"} className="flex justify-center">
            <button className="db f9 green2 ba pa2 b--green2 bg-gray0-d pointer ph5">
              Send
            </button>
          </Link>
        </div>
        
      </div>
    )
  }

  renderContractsList(contracts) {
    if (!contracts) {
      return null;
    }
    return (
      <ul className="list pl0 ma0 mh-134-s">
        {contracts.map(contract => {
            return (
              <Link
                to={`/~eth-wallet/logs/${contract.symbol}`}
                key={contract.address + contract.name}
              >
                {this.renderListItem(contract)}
              </Link>
            );
        })}
      </ul>
    );
  }

  renderListItem(contract) {
    const { selectedContract } = this.props;
    let amt = web3Utils.fromWei(contract.balance.toString())
    const dot = amt.indexOf('.')
    if(dot > 0)
    amt = amt.slice(0, dot+2)
    return (
      <li
        className={`lh-copy pl3 pv3 ba bl-0 bt-0 br-0 b--solid b--gray4 b--gray1-d bg-animate pointer ${
          selectedContract === contract.symbol ? 'bg-gray5' : 'bg-white'
        }`}
      >
        <div className="flex flex-column">
          <div className="flex justify-between">
            <p className="f8">{contract.symbol}</p>
            <p className="f8 pr9 fw5">{amt}</p>
          </div>
          <p className="f8">{contract.name}</p>
          {
            selectedContract === contract.symbol && this.renderExpandedView(contract)
          }
        </div>
      </li>
    );
  }

  renderExpandedView(contract) {
    return (
      <div>
        <div>
          <p className="f8 gray3 mw4 truncate ba b--solid b--green1">{contract.address}</p>
          {/* <CopyToClipboard text={contract.address}>
            {<img src='./icons/clip'}
          </CopyToClipboard> */}
        </div>
        <Link to={`/~eth-wallet/send-erc20/${contract.symbol}`}>
            <button className="db f9 green2 ba pa2 b--green2 bg-gray0-d pointer fr mr9 pa2">
              Send
            </button>
        </Link>
      </div>
    )
  }
}
