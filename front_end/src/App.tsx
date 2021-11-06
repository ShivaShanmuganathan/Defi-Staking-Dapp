import React from 'react';
import logo from './logo.svg';
import './App.css';
import { ChainId, DAppProvider, useEtherBalance, useEthers } from '@usedapp/core'
import {Header} from "./components/Header"
import {Main} from "./components/Main"

function App() {
  return (
    <DAppProvider config={{
      supportedChains: [ChainId.Kovan]
    }}>
      
      <Header />
      <Main />
    </DAppProvider>
  );
}

export default App;
