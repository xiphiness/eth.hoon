import _ from 'lodash';


export class InitialReducer {
    reduce(json, state) {
        let data = _.get(json, 'initial', false);
        if (data) {
            state.owner = data.owner;
            state.ethBalance = data.ethBalance;
            state.contracts = data.contracts;
            state.ethPending = data.ethPending
            state.ethTxnLog = data.ethTxnLog
        }
    }
}