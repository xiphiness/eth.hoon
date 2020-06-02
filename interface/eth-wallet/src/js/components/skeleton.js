import React, { Component } from "react";
import { HeaderBar } from "./lib/header-bar";
import { ContractsSidebar } from "./lib/contracts-sidebar";
import { observer } from 'mobx-react'

@observer
export class Skeleton extends Component {
  render() {
    return (
      <div className="absolute h-100 w-100 bg-gray0-d ph4-m ph4-l ph4-xl pb4-m pb4-l pb4-xl">
        <HeaderBar />
        <div className="cf w-100 flex flex-column ba-m ba-l ba-xl b--gray2 br1 h-100-minus-40">
          {this.renderContent()}
        </div>
      </div>
    );
  }

  renderContent() {
    const { children, selectedContract } = this.props;
    console.log('skeleton children', children)
    return (
      <div className="flex flex-column flex-row h-100 flex-wrap">
        <ContractsSidebar
          selectedContract={selectedContract}
        />
        <div className="mb0 w-100-minus-320 w-100-s h-100 h-100-minus-200-s">{children}</div>
      </div>
    );
  }
}
