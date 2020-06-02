import _ from 'lodash'
export class EthReducer {
    reduce(json, state) {
      let data = json;
      if (data) {
        const ev = _.get(data, 'eth-send-rez')
        // this.newContract(data, state);
        // this.removeContract(data, state);
        // this.contracts(ev, state);
        // this.abi(data, state);
        if(ev) {
          this.ethSendRez(ev, state);
        }
      }
    }
    ethSendRez(data, state) {
        const pIndex = state.ethPending.findIndex(val => val.txHash === data.txHash)
        let value
        if(pIndex > -1) {
          value = state.ethPending[pIndex].value
          state.ethPending.splice(pIndex,1)
        }
        const { to, block, txHash, status, balance } = data
        state.ethBalance = balance
        if(status)
            state.ethTxnLog.unshift({ block, to, value, txHash})
    }
}