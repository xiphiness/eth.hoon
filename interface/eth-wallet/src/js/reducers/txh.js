import _ from 'lodash'
export class TxHashReducer {
    reduce(json, state) {
      let data = json;
      if (data) {
        const ev = _.get(data, 'txh')
        if(ev) {
          this.txh(ev, state);
        }
      }
    }
    txh(data, state) {
        const sym = data['contract-id']
        const { from, to, value, txHash } = data
        if(sym === 'ETH') {
          state.ethPending.unshift({from, to, value, txHash})
        } else {
          const contract = state.contracts.find(val => val.symbol == sym)
          contract.pending.unshift({ from, to, value, txHash})
        }
    }
}