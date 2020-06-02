import _ from 'lodash';
import { getOrderedContracts, mapContract, splitContracts } from './utils';

export class ContractsReducer {
  reduce(json, state) {
    let data = json;
    if (data) {
      const ev = _.get(data, 'erc20')
      // this.newContract(data, state);
      // this.removeContract(data, state);
      // this.contracts(ev, state);
      // this.abi(data, state);
      if(ev) {
        this.ERC20Log(ev, state);
        this.ERC20History(ev, state);
      }
    }
  }

  // removeContract(obj, state) {
  //   let data = _.get(obj, 'remove-contract', false);
  //   if (data) {
  //     state.contracts = getOrderedContracts(state.contracts.filter(contract => contract.address !== data));
  //   }
  // }

  // newContract(obj, state) {
  //   let data = _.get(obj, 'new-contract', false);
  //   if (data) {
  //     const newContract = mapContract(data);
  //     state.contracts = getOrderedContracts([
  //       ...state.contracts,
  //       newContract
  //     ]);
  //   }
  // }

  // contracts(obj, state) {
  //   let data = _.get(obj, 'contracts', false);
  //   if (data) {
  //     state.contracts = getOrderedContracts(data.map(contract => mapContract(contract)));
  //   }
  // }

  // abi(obj, state) {
  //   let data = _.get(obj, 'abi-result', false);

  //   if (data) {
  //     state.abi = data && JSON.parse(data);
  //   }
  // }

  ERC20Log(obj, state) {
    let data = _.get(obj, 'log', false);
    if (data && data.type == 'transfer') {
      const { from, to, value } = data.payload;
      const { block, txHash } = data
      const contract = state.contracts.find(val => val.address == data.address)
      const pIndex = contract.pending.findIndex(val => val.txHash === data.txHash)
      if(pIndex > -1) contract.pending.splice(pIndex, 1)
      console.log('found contract', contract)
      const log = { from, to, value, block, txHash }
      if(contract) {
        contract.txnLog.unshift(log)
        console.log('wtffff', log.value, contract.balance)
        if(log.from == state.owner) {
          console.log('from owner')
          console.log('wtf2', contract.balance-=log.value)
        } else if (log.to == state.owner) {
          console.log('to owner')
          console.log('wtf2', contract.balance+=log.value)
        } else {
          console.warn("unexpected event", log)
        }
      }
      // const { existingContracts, currentContract } = splitContracts(state.contracts, data.address);
      // if (currentContract) {
      //   this.setContractsState(state, existingContracts, currentContract, log)
      // }
    }
  }

  // setContractsState(state, existingContracts, currentContract, log) {
  //   const currentLogs = currentContract.txnLog || []
  //   const logs = [...currentLogs, log];

  //   const updatedContract = {
  //     ...currentContract,
  //     txnLog: logs
  //   };
  //   state.contracts = getOrderedContracts([...existingContracts, updatedContract]);
  // }

  ERC20History(obj, state) {
    let history = _.get(obj, 'history', false);
    if (history && history[0]) {
      const address = history[0].address;
      const contract = state.contracts.find(val => val.address == address)
      console.log('found contract', contract)
      if(contract) {
        const [transfers, balance] = _.transform(history, (acc, val) => {
          const log = val.payload
          if(val.type == 'transfer') {
            acc[0].push(log)
            if(log.from == state.owner) {
              console.log('from owner')
              acc[1]-=log.value
            } else if (log.to == state.owner) {
              console.log('to owner')
              acc[1]+=log.value
            } else {
              console.warn("unexpected event", log)
            }
          }
        }, [[],0])
        console.log('have transfers')
        contract.txnLog.length = 0
        contract.txnLog.push(transfers)
        contract.balance = balance
      }
      // const { existingContracts, currentContract } = splitContracts(state.contracts, address);
      // const logs = history.map(log => log.payload);
      // const updatedContract = {
      //   ...currentContract,
      //   txnLog: logs
      // };
      // if (currentContract) {
      //   state.contracts = getOrderedContracts([...existingContracts, updatedContract]);
      // }
    }
  }
}
