import React, { Component } from 'react';
import { observer } from 'mobx-react'
import { computed } from 'mobx'
import { Link } from 'react-router-dom';
import _ from 'lodash';
import web3Utils from 'web3-utils';
import { store } from '../store'
import { api } from '../api';

const initialState = {
    address: '',
    amount: null,
    gasPrice: null,
    gasLimit: null,
    validAddress: false,
    validAmount: false
}

@observer
export class Send extends Component {
    constructor (props) {
        super(props);
        this.state = initialState;
        this.handleGasInputBound = this.handleGasInput.bind(this);
        this.handleAddressChangeBound = this.handleAddressChange.bind(this);
        this.handleAmountChangeBound = this.handleAmountChange.bind(this);
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

    render () {
        const { symbol } = this.props;
        const { amount, gasLimit, gasPrice } = this.state;
        return (
            <div className="flex flex-column pa3">
                <div className="flex flex-row flex-wrap">
                    <div className="w-100-s">
                        <p className="f7 mt3 lh-copy db mb5">{symbol} Transfer</p>
                        <p className="f8 mt3 lh-copy db mb2">Recipient</p>
                        <textarea
                            id="address"
                            className="ba b--black-20 pa3 db w-70 b--gray4 f9 flex-basis-full-s focus-b--black focus-b--white-d
                                    w-382-px w-auto-s"
                            rows={1}
                            placeholder="Address"
                            style={{ resize: 'none' }}
                            onChange={this.handleAddressChangeBound}
                            aria-describedby="name-desc"
                        />
                        {this.renderAddressStatus()}
                        <p className="f8 mt3 lh-copy db mb2">Amount</p>
                        <textarea
                            id="amount"
                            className="ba b--black-20 pa3 db w-70 b--gray4 f9 flex-basis-full-s focus-b--black focus-b--white-d
                                    w-382-px w-auto-s"
                            rows={1}
                            placeholder='0'
                            style={{ resize: 'none' }}
                            onChange={this.handleAmountChangeBound}
                            aria-describedby="name-desc"
                        />
                        {this.renderAmountStatus()}
                        <div className="flex items-center mt5 mb5">
                            <div className="flex flex-column">
                                <p className="f8 mt3 lh-copy db mb2 mr2">Gas Price</p>
                                <textarea
                                    id="gasPrice"
                                    className="ba b--black-20 pa3 db w-70 b--gray4 f9 flex-basis-full-s focus-b--black focus-b--white-d
                                            w-382-px w-auto-s mr5"
                                    rows={1}
                                    placeholder='0'
                                    value={30000000000}
                                    style={{ resize: 'none' }}
                                    onChange={this.handleGasInputBound}
                                    aria-describedby="name-desc"
                                />
                            </div>
                            <div className="flex flex-column">
                                <p className="f8 mt3 lh-copy db mb2 mr2">Gas Limit</p>
                                <textarea
                                    id="gasLimit"
                                    className="ba b--black-20 pa3 db w-70 b--gray4 f9 flex-basis-full-s focus-b--black focus-b--white-d
                                            w-382-px w-auto-s mr2"
                                    rows={1}
                                    value={100000}
                                    style={{ resize: 'none' }}
                                    onChange={this.handleGasInputBound}
                                    aria-describedby="name-desc"
                                />
                            </div>
                        </div>
                        {this.renderGasStatus()}
                    </div>
                </div>
                <div className="flex mt3">
                <Link to={`/~eth-wallet/logs/${symbol}`}>
                <button className={`db f9 green2 ba pa2 b--green2 bg-gray0-d pointer`}
                    onClick={() => {
                        const amt = parseInt(web3Utils.toWei(amount.toString()),10)
                        if(symbol == 'ETH') {
                            console.log('send eth')
                            api.sendEth(this.state.address, amt)
                        } else {
                            console.log('send erc20')
                            api.sendErc20(symbol, this.state.address, amt)
                        }
                    }}
                        >
                    Send
                </button>
                </Link>
                <Link to={`/~eth-wallet/logs/${symbol}`}>
                    <button className="f9 ml3 ba pa2 b--black pointer bg-transparent b--white-d white-d"
                       >
                    Cancel
                    </button>
                </Link>
            </div>
        </div>)
    }
    
    renderAddressStatus() {
        if(!this.state.validAddress && this.state.address) {
            return (<span className="f9 inter red2 db pt2">Must be a valid address.</span>);
        }
        return null;
    }

    renderAmountStatus() {
        if(!this.state.validAmount && this.state.amount) {
            return (<span className="f9 inter red2 db pt2">Amount exceeds your available balance.</span>);
        }
        return null;
    }

    renderGasStatus() {
        if((this.state.gasPrice && this.state.gasPrice <= 0) || (this.state.gasLimit && this.state.gasLimit <= 0)) {
            return (<span className="f9 inter red2 db pt2">Gas price and gas limit must be greater than zero.</span>);
        }
        return null;
    }
    
    isValidAddress(address) {
        return web3Utils.isAddress(address);
    }

    validateAddress(address) {
        if(!address){
            return
        }
        if(!this.isValidAddress(address)) {
            this.setState({validAddress:false});
        } else {
        //   api.getAbi(address);
            this.setState({validAddress: true});
        }
    }

    handleAddressChange(event) {
        const address = event.target.value;
        _.debounce(() => this.validateAddress(address), 100)();
        this.setState({ address });
    }

    handleAmountChange(event) {
        const amount = parseInt(event.target.value,10);
        // const validAmount = amount <= this.contract.balance;
        // console.log('amount', amount, 'balance', this.contract.balance, 'valid', validAmount);
        this.setState({ amount, validAmount: true });
    }

    handleGasInput(event) {
        const {id, value} = event.target;
        const newState = {};
        newState[id] = value;
        this.setState(newState);
    }
}